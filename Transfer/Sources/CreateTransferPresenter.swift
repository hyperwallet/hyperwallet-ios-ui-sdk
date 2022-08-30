//
// Copyright 2018 - Present Hyperwallet
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software
// and associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute,
// sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
// BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#if !COCOAPODS
import BalanceRepository
import Common
import TransferMethodRepository
import TransferRepository
import UserRepository
#endif
import HyperwalletSDK

protocol CreateTransferView: AnyObject {
    func hideLoading()
    func notifyTransferCreated(_ transfer: HyperwalletTransfer)
    func reloadData()
    func showAlert(message: String?)
    func showError(_ error: HyperwalletErrorType,
                   pageName: String,
                   pageGroup: String,
                   _ retry: (() -> Void)?)
    func showLoading()
    func showScheduleTransfer(_ transfer: HyperwalletTransfer)
    func updateTransferAmountSection()
    func updateFooter(for section: CreateTransferController.FooterSection)
    func areAllFieldsValid() -> Bool
}

final class CreateTransferPresenter {
    private weak var view: CreateTransferView?
    private let pageName = "transfer-funds:create-transfer"
    private let pageGroup = "transfer-funds"

    private lazy var userRepository: UserRepository = {
        UserRepositoryFactory.shared.userRepository()
    }()

    private lazy var transferRepository: TransferRepository = {
        TransferRepositoryFactory.shared.transferRepository()
    }()

    private lazy var transferMethodRepository: TransferMethodRepository = {
        TransferMethodRepositoryFactory.shared.transferMethodRepository()
    }()

    private lazy var prepaidCardRepository: PrepaidCardRepository = {
        TransferMethodRepositoryFactory.shared.prepaidCardRepository()
    }()

    private lazy var balanceRepository: UserBalanceRepository = {
        BalanceRepositoryFactory.shared.userBalanceRepository()
    }()

    private(set) var clientTransferId: String
    private(set) var sectionData = [CreateTransferSectionData]()
    private(set) var transferSourceCellConfigurations = [TransferSourceCellConfiguration]()
    private(set) var availableBalance: String?
    private(set) var didFxQuoteChange = false
    private(set) var showAllAvailableSources = false

    var selectedTransferDestination: HyperwalletTransferMethod?
    var amount: String = "0"
    var notes: String?
    var destinationCurrency: String? {
        return selectedTransferDestination?.transferMethodCurrency
    }

    var didTapTransferAllFunds = false {
        didSet {
            if didTapTransferAllFunds {
                amount = availableBalance ?? "0"
                view?.updateTransferAmountSection()
            }
        }
    }

    init(_ clientTransferId: String,
         _ sourceToken: String?,
         _ showAllAvailableSources: Bool?,
         view: CreateTransferView) {
        transferSourceCellConfigurations.removeAll()
        self.clientTransferId = clientTransferId
        if let prepaidCardToken = sourceToken, prepaidCardToken.starts(with: "trm") {
            createTransferSourceCellConfiguration(true, .prepaidCard, prepaidCardToken)
        }
        if let showAllAvailableSources = showAllAvailableSources {
            self.showAllAvailableSources = showAllAvailableSources
        }
        self.view = view
    }

    private func initializeSections() {
        sectionData.removeAll()

        let createTransferSectionAmountData = CreateTransferSectionAmountData()
        sectionData.append(createTransferSectionAmountData)

        let createTransferSectionTransferAllData = CreateTransferSectionTransferAllData()
        sectionData.append(createTransferSectionTransferAllData)

        let createTransferSectionSourceData = CreateTransferSectionSourceData()
        sectionData.append(createTransferSectionSourceData)

        let createTransferDestinationSection = CreateTransferSectionDestinationData()
        sectionData.append(createTransferDestinationSection)

        let createTransferNotesSection = CreateTransferSectionNotesData()
        sectionData.append(createTransferNotesSection)

        let createTransferButtonData = CreateTransferSectionButtonData()
        sectionData.append(createTransferButtonData)
    }

    func loadCreateTransfer() {
        if showAllAvailableSources {
            transferSourceCellConfigurations.removeAll()
            loadAllAvailableSources()
        } else if let token =
            transferSourceCellConfigurations
                .first(where: { $0.isSelected && $0.type == .prepaidCard })?.token {
                loadPrepaidCardAndCreateTransfer(token: token)
        } else {
            loadUserAndCreateTransfer()
        }
    }

    func loadCreateTransferFromSelectedTransferSource(sourceToken: String) {
        transferSourceCellConfigurations.forEach { $0.isSelected = false }
        transferSourceCellConfigurations
            .first(where: { $0.token == sourceToken })?.isSelected = true
        loadTransferMethods()
    }

    private func loadPrepaidCardAndCreateTransfer(token: String) {
        view?.showLoading()
        prepaidCardRepository.getPrepaidCard(token: token) { [weak self] result in
            guard let strongSelf = self, let view = strongSelf.view else {
                return
            }
            strongSelf.view?.hideLoading()
            switch result {
            case .failure(let error):
                view.showError(error, pageName: strongSelf.pageName, pageGroup: strongSelf.pageGroup) {
                    strongSelf.loadPrepaidCardAndCreateTransfer(token: token)
                }

            case .success(let prepaidCard):
                if let prepaidCard = prepaidCard, let token = prepaidCard.token,
                    strongSelf.transferSourceCellConfigurations.isNotEmpty {
                    strongSelf.transferSourceCellConfigurations
                        .first(where: { $0.isSelected })?.additionalText =
                        prepaidCard.formattedCardBrandCardNumber
                    strongSelf.transferSourceCellConfigurations
                        .first(where: { $0.isSelected })?.destinationCurrency =
                        prepaidCard.transferMethodCurrency
                    strongSelf.loadCreateTransferFromSelectedTransferSource(sourceToken: token)
                }
            }
        }
    }

    private func loadUserAndCreateTransfer() {
        view?.showLoading()
        transferSourceCellConfigurations.removeAll()
        userRepository.getUser { [weak self] result in
            guard let strongSelf = self, let view = strongSelf.view else {
                return
            }
            view.hideLoading()
            switch result {
            case .failure(let error):
                view.showError(error, pageName: strongSelf.pageName, pageGroup: strongSelf.pageGroup) {
                    strongSelf.loadUserAndCreateTransfer()
                }

            case .success(let user):
                if let token = user?.token {
                    strongSelf.createTransferSourceCellConfiguration(true, .user, token)
                    strongSelf.loadCreateTransferFromSelectedTransferSource(sourceToken: token)
                }
            }
        }
    }

    private func createTransferSourceCellConfiguration(_ isSelectedTransferSource: Bool,
                                                       _ transferSourceType: TransferSourceType,
                                                       _ token: String,
                                                       _ additionalText: String? = nil,
                                                       _ transferMethodCurrency: String? = nil) {
        let configuration = TransferSourceCellConfiguration(isSelectedTransferSource: isSelectedTransferSource,
                                                            type: transferSourceType,
                                                            token: token,
                                                            title: transferSourceType == .user
                                                                ? "mobileAvailableFunds".localized() :
                                                                "prepaid_card".localized(),
                                                            fontIcon: transferSourceType == .user
                                                                ? .addTransferMethod : .prepaidCard)
        configuration.additionalText = additionalText
        configuration.availableBalance = availableBalance
        configuration.destinationCurrency = destinationCurrency
        if transferSourceType == .user { addCurrencyCodesToAvailableFundsConfiguration() }
        if transferSourceType == .prepaidCard { configuration.destinationCurrency = transferMethodCurrency }
        transferSourceCellConfigurations.append(configuration)
    }

    /// Add currency codes to available funds configuration
    func addCurrencyCodesToAvailableFundsConfiguration() {
        balanceRepository.listUserBalances(offset: 0, limit: 0) { [weak self]  (result) in
            guard let strongSelf = self, let view = strongSelf.view else {
                return
            }
            switch result {
            case .success(let balanceList):
                if let balanceList = balanceList, let balances = balanceList.data {
                    let currencies = balances
                        .filter({ $0.amount?.formatAmountToDouble() ?? 0 > 0 })
                        .map { String($0.currency!) }
                        .sorted()
                    let configuration = strongSelf.transferSourceCellConfigurations.first(where: { $0.isSelected })
                    if let type = configuration?.type, type == .user {
                        configuration?.destinationCurrency = currencies.joined(separator: ", ")
                    }
                }

            case .failure(let error):
                view.showError(error, pageName: strongSelf.pageName, pageGroup: strongSelf.pageGroup) {
                    strongSelf.addCurrencyCodesToAvailableFundsConfiguration()
                }
            }
        }
    }

    private func loadAllAvailableSources() {
        view?.showLoading()
        transferSourceCellConfigurations.removeAll()
        Hyperwallet.shared.getConfiguration { [weak self] configuration, error in
            guard let strongSelf = self, let view = strongSelf.view else {
                return
            }
            if let error = error {
                strongSelf.view?.hideLoading()
                view.showError(error, pageName: strongSelf.pageName, pageGroup: strongSelf.pageGroup) {
                    strongSelf.loadAllAvailableSources()
                }
                return
            }

            if let configuration = configuration, let programModel = configuration.programModel,
            let programModelEnum = HyperwalletProgramModel(rawValue: programModel),
            !programModelEnum.isPay2CardOrCardOnlyModel() {
                strongSelf.createTransferSourceCellConfiguration(true, .user, configuration.userToken)
            }
            strongSelf.prepaidCardRepository
                .listPrepaidCards(queryParam: strongSelf.setUpPrepaidCardQueryParam()) { [weak self] (result) in
                guard let strongSelf = self, let view = strongSelf.view else {
                    return
                }
                strongSelf.view?.hideLoading()
                switch result {
                case .success(let pageList):
                    var isSelectedTransferSource = false
                    if strongSelf.transferSourceCellConfigurations.isEmpty { isSelectedTransferSource = true }
                    if let prepaidCards = pageList?.data {
                        prepaidCards.forEach { prepaidCard in
                            strongSelf
                                .createTransferSourceCellConfiguration(isSelectedTransferSource,
                                                                       .prepaidCard,
                                                                       prepaidCard.token ?? "",
                                                                       prepaidCard.formattedCardBrandCardNumber,
                                                                       prepaidCard.transferMethodCurrency)
                            isSelectedTransferSource = false
                        }
                    } else if isSelectedTransferSource {
                        view.showAlert(message: "noTransferFromSourceAvailable".localized())
                        return
                    }
                    strongSelf.loadTransferMethods()

                case .failure(let error):
                    view.showError(error, pageName: strongSelf.pageName, pageGroup: strongSelf.pageGroup) {
                        strongSelf.loadAllAvailableSources()
                    }
                    return
                }
                }
        }
    }

    private func setUpPrepaidCardQueryParam() -> HyperwalletPrepaidCardQueryParam {
        let queryParam = HyperwalletPrepaidCardQueryParam()
        // Only fetch active prepaid cards
        queryParam.status = HyperwalletPrepaidCardQueryParam.QueryStatus.activated.rawValue
        return queryParam
    }

    private func loadTransferMethods() {
        view?.showLoading()
        transferMethodRepository.refreshTransferMethods()
        transferMethodRepository.listTransferMethods { [weak self] result in
            guard let strongSelf = self, let view = strongSelf.view else {
                return
            }
            view.hideLoading()
            switch result {
            case .failure(let error):
                view.showError(error, pageName: strongSelf.pageName, pageGroup: strongSelf.pageGroup) {
                    strongSelf.loadTransferMethods()
                }

            case .success(let result):
                var transferMethods = result?.data
                if strongSelf.transferSourceCellConfigurations.first(where: {
                    $0.isSelected
                })?.type == .prepaidCard {
                    let prepaidCardType = HyperwalletTransferMethod.TransferMethodType.prepaidCard.rawValue
                    transferMethods?.removeAll(where: {
                        $0.type == prepaidCardType
                    })
                }
                if strongSelf.selectedTransferDestination == nil {
                    strongSelf.selectedTransferDestination = transferMethods?.first
                }
                strongSelf.createInitialTransfer()
            }
        }
    }

    private func createInitialTransfer() {
        availableBalance = nil
        guard let sourceToken =
            transferSourceCellConfigurations.first(where: { $0.isSelected })?.token,
            let destinationToken = selectedTransferDestination?.token,
            let destinationCurrency = destinationCurrency else {
                initializeSections()
                view?.reloadData()
                return
        }
        view?.showLoading()
        let transfer = HyperwalletTransfer.Builder(clientTransferId: clientTransferId,
                                                   sourceToken: sourceToken,
                                                   destinationToken: destinationToken)
            .destinationCurrency(destinationCurrency)
            .build()

        transferRepository.createTransfer(transfer) { [weak self] result in
            guard let strongSelf = self, let view = strongSelf.view else {
                return
            }
            view.hideLoading()
            switch result {
            case .failure(let error):
                if error.group != .business {
                    view.showError(error, pageName: strongSelf.pageName, pageGroup: strongSelf.pageGroup) {
                        strongSelf.createInitialTransfer()
                    }
                }

            case .success(let transfer):
                strongSelf.availableBalance = transfer?.destinationAmount
                if strongSelf.didTapTransferAllFunds { strongSelf.amount = strongSelf.availableBalance ?? "0" }
                strongSelf.transferSourceCellConfigurations.forEach {
                    $0.availableBalance = transfer?.destinationAmount
                }
            }
            strongSelf.initializeSections()
            view.reloadData()
        }
    }

    // MARK: - Create Transfer Button Tapped
    func createTransfer() {
        guard let view = view, view.areAllFieldsValid() else {
            return
        }

        if let sourceToken =
            transferSourceCellConfigurations.first(where: { $0.isSelected })?.token,
            let destinationToken = selectedTransferDestination?.token,
            let destinationCurrency = destinationCurrency {
            view.showLoading()
            let transfer = HyperwalletTransfer.Builder(clientTransferId: clientTransferId,
                                                       sourceToken: sourceToken,
                                                       destinationToken: destinationToken)
                .destinationAmount(didTapTransferAllFunds ? nil : amount)
                .notes(notes)
                .destinationCurrency(destinationCurrency)
                .build()

            transferRepository.createTransfer(transfer) { [weak self] result in
                guard let strongSelf = self, let view = strongSelf.view else {
                    return
                }
                view.hideLoading()
                switch result {
                case .failure(let error):
                    strongSelf.errorHandler(for: error) {
                        view.showError(error, pageName: strongSelf.pageName, pageGroup: strongSelf.pageGroup) {
                            strongSelf.createTransfer()
                        }
                    }

                case .success(let transfer):
                    if let transfer = transfer {
                        if strongSelf.didTapTransferAllFunds &&
                            transfer.destinationAmount != strongSelf.availableBalance {
                            strongSelf.didFxQuoteChange = true
                        }
                        view.notifyTransferCreated(transfer)
                        view.showScheduleTransfer(transfer)
                    }
                }
            }
        }
    }

    func resetErrorMessagesForAllSections() {
        if sectionData.contains(where: { $0.errorMessage != nil }) {
            sectionData.filter({ $0.errorMessage != nil }).forEach({
                $0.errorMessage = nil
                switch $0.createTransferSectionHeader {
                case .amount:
                    view?.updateFooter(for: .amount)

                case .button:
                    view?.updateFooter(for: .button)

                case .destination:
                    view?.updateFooter(for: .destination)

                case .notes:
                    view?.updateFooter(for: .notes)

                case .transferAll:
                    view?.updateFooter(for: .transferAll)

                case .source:
                    view?.updateFooter(for: .source)
                }
            })
        }
    }

    private func errorHandler(for error: HyperwalletErrorType, _ nonBusinessErrorHandler: @escaping () -> Void) {
        switch error.group {
        case .business:
            resetErrorMessagesForAllSections()
            if let errors = error.getHyperwalletErrors()?.errorList, errors.isNotEmpty {
                updateFooterContent(errors)
                if errors.contains(where: { $0.fieldName == nil }) {
                    view?.showError(error, pageName: pageName, pageGroup: pageGroup, nil)
                }
            }

        default:
            nonBusinessErrorHandler()
        }
    }

    private func updateFooterContent(_ errors: [HyperwalletError]) {
        for error in errors {
            if let sectionData = sectionData.first(where: { $0.createTransferSectionHeader == .transferAll }),
               error.fieldName != nil {
                sectionData.errorMessage = error.message
                view?.updateFooter(for: .transferAll)
            }
        }
    }
}
