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
import Common
import TransferMethodRepository
import TransferRepository
import UserRepository
#endif
import HyperwalletSDK

protocol CreateTransferView: class {
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

    private(set) var clientTransferId: String
    private(set) var sectionData = [CreateTransferSectionData]()
    private(set) var transferSourceCellConfiguration: TransferSourceCellConfiguration?
    private(set) var availableBalance: String?
    private(set) var didFxQuoteChange: Bool = false
    private(set) var showAllAvailableSources: Bool = false
    private(set) var prepaidCards: [HyperwalletPrepaidCard]?
    private(set) var isTransferFromSelectionAvailable = false

    var selectedTransferMethod: HyperwalletTransferMethod?
    var amount: String = "0"
    var notes: String?
    var destinationCurrency: String? {
        return selectedTransferMethod?.transferMethodCurrency
    }

    var didTapTransferAllFunds: Bool = false {
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
        self.clientTransferId = clientTransferId
        if let prepaidCardToken = sourceToken, prepaidCardToken.starts(with: "trm") {
            self.transferSourceCellConfiguration =
                TransferSourceCellConfiguration(token: prepaidCardToken,
                                                title: "prepaid_card".localized(),
                                                fontIcon: HyperwalletIconContent.prepaidCard.rawValue,
                                                availableBalance: "0",
                                                destinationCurrency: "",
                                                additionalText: nil)
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
        isTransferFromSelectionAvailable = false
        if showAllAvailableSources {
            loadAllAvailableSources()
        } else if let transferSourceCellConfiguration = transferSourceCellConfiguration,
            transferSourceCellConfiguration.token.starts(with: "trm") {
                loadPrepaidCardAndCreateTransfer(token: transferSourceCellConfiguration.token)
            } else {
                loadUserAndCreateTransfer()
            }
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
                if let prepaidCard = prepaidCard, strongSelf.transferSourceCellConfiguration != nil {
                    strongSelf.transferSourceCellConfiguration?
                        .additionalText = prepaidCard.formattedCardBrandCardNumber
                    strongSelf.prepaidCards = [prepaidCard]
                    strongSelf.loadTransferMethods()
                }
            }
        }
    }

    private func loadUserAndCreateTransfer() {
        view?.showLoading()
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
                strongSelf.transferSourceCellConfiguration =
                    TransferSourceCellConfiguration(token: user?.token ?? "",
                                                    title: "availableFunds".localized(),
                                                    fontIcon: HyperwalletIconContent.bankAccount.rawValue,
                                                    availableBalance: strongSelf.availableBalance ?? "0",
                                                    destinationCurrency: strongSelf.destinationCurrency ?? "",
                                                    additionalText: nil)
                //strongSelf.selectedSourceToken = user?.token
                strongSelf.loadTransferMethods()
            }
        }
    }

    private func createTransferSourceCellConfiguration(token: String,
                                                       title: String,
                                                       fontIcon: String,
                                                       additionalText: String?) {
        transferSourceCellConfiguration =
            TransferSourceCellConfiguration(token: token,
                                            title: title,
                                            fontIcon: fontIcon,
                                            availableBalance: self.availableBalance ?? "0",
                                            destinationCurrency: self.destinationCurrency ?? "",
                                            additionalText: additionalText)
    }

    private func loadAllAvailableSources() {
        view?.showLoading()
        Hyperwallet.shared.getConfiguration { configuration, _ in
            if let configuration = configuration {
                // if program model != (PAY2CARD_MODEL && CARD_ONLY_MODEL)
                self.createTransferSourceCellConfiguration(token: configuration.userToken,
                                                           title: "availableFunds".localized(),
                                                           fontIcon: HyperwalletIconContent.bankAccount.rawValue,
                                                           additionalText: nil)
                //self.selectedSourceToken = configuration.userToken
                self.prepaidCardRepository
                    .listPrepaidCards(queryParam: self.setUpPrepaidCardQueryParam()) { [weak self] (result) in
                    guard let strongSelf = self, let view = strongSelf.view else {
                        return
                    }
                    strongSelf.view?.hideLoading()
                    switch result {
                    case .success(let pageList):
                        if let prepaidCard = pageList?.data?.first, let type = prepaidCard.type {
                            if strongSelf.transferSourceCellConfiguration == nil {
                                strongSelf
                                    .createTransferSourceCellConfiguration(token: prepaidCard.token ?? "",
                                                                           title: type.lowercased().localized(),
                                                                           fontIcon:
                                        HyperwalletIconContent.prepaidCard.rawValue,
                                                                           additionalText:
                                        prepaidCard.formattedCardBrandCardNumber)
                                strongSelf.prepaidCards = pageList?.data
                                if pageList?.data?.count ?? 0 > 1 {
                                    strongSelf.isTransferFromSelectionAvailable = true
                                }
                            } else {
                                strongSelf.isTransferFromSelectionAvailable = true
                            }
                            strongSelf.loadTransferMethods()
                        } else {
                            view.showAlert(message: "noTransferFromSourceAvailable".localized())
                            return
                        }

                    case .failure(let error):
                        view.showError(error, pageName: strongSelf.pageName, pageGroup: strongSelf.pageGroup) {
                            strongSelf.loadAllAvailableSources()
                        }
                        return
                    }
                    }
            }
        }
    }

    private func setUpPrepaidCardQueryParam() -> HyperwalletPrepaidCardQueryParm {
        let queryParam = HyperwalletPrepaidCardQueryParm()
        // Only fetch active prepaid cards
        queryParam.status = .activated
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
                if strongSelf.selectedTransferMethod == nil {
                    var transferMethods = result?.data
                    strongSelf.prepaidCards?.forEach { prepaidCard in
                        if prepaidCard.token == transferMethods?.first?.token {
                            transferMethods?.removeFirst()
                        }
                    }

                    strongSelf.selectedTransferMethod = transferMethods?.first
                }
                strongSelf.createInitialTransfer()
            }
        }
    }

    private func createInitialTransfer() {
        guard let sourceToken = transferSourceCellConfiguration?.token,
            let destinationToken = selectedTransferMethod?.token,
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
                view.showError(error, pageName: strongSelf.pageName, pageGroup: strongSelf.pageGroup) {
                    strongSelf.createInitialTransfer()
                }

            case .success(let transfer):
                strongSelf.availableBalance = transfer?.destinationAmount
                strongSelf.transferSourceCellConfiguration?.availableBalance = transfer?.destinationAmount
                strongSelf.transferSourceCellConfiguration?.destinationCurrency =
                    strongSelf.selectedTransferMethod?.transferMethodCurrency
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

        if let sourceToken = transferSourceCellConfiguration?.token,
            let destinationToken = selectedTransferMethod?.token,
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
        sectionData.forEach { $0.errorMessage = nil }
        CreateTransferController.FooterSection.allCases.forEach({ view?.updateFooter(for: $0) })
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
            if let sectionData = sectionData.first(where: { $0.createTransferSectionHeader == .transferAll }) {
                sectionData.errorMessage = error.message
                view?.updateFooter(for: .transferAll)
            }
        }
    }
}
