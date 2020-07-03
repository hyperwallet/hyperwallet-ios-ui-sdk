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
    func showError(_ error: HyperwalletErrorType,
                   pageName: String,
                   pageGroup: String,
                   _ retry: (() -> Void)?)
    func showLoading()
    func showScheduleTransfer(_ transfer: HyperwalletTransfer)
    func updateTransferSection()
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

    private(set) var clientTransferId: String
    private(set) var sectionData = [CreateTransferSectionData]()
    private(set) var availableBalance: String?
    private(set) var didFxQuoteChange: Bool = false

    private var sourceToken: String?

    var selectedTransferMethod: HyperwalletTransferMethod?
    var amount: String = "0"
    var notes: String?
    var destinationCurrency: String? {
        return selectedTransferMethod?.transferMethodCurrency
    }

    var didTapTransferAllFunds: Bool = false {
        didSet {
            amount = didTapTransferAllFunds ? availableBalance ?? "0" : "0"
            view?.updateTransferSection()
        }
    }

    init(_ clientTransferId: String, _ sourceToken: String?, view: CreateTransferView) {
        self.clientTransferId = clientTransferId
        self.sourceToken = sourceToken
        self.view = view
    }

    private func initializeSections() {
        sectionData.removeAll()

        let createTransferSectionAmountData = CreateTransferSectionAmountData()
        sectionData.append(createTransferSectionAmountData)

        let createTransferSectionTransferData = CreateTransferSectionTransferData()
        sectionData.append(createTransferSectionTransferData)

        let createTransferDestinationSection = CreateTransferSectionDestinationData()
        sectionData.append(createTransferDestinationSection)

        let createTransferNotesSection = CreateTransferSectionNotesData()
        sectionData.append(createTransferNotesSection)

        let createTransferButtonData = CreateTransferSectionButtonData()
        sectionData.append(createTransferButtonData)
    }

    func loadCreateTransfer() {
        view?.showLoading()
        if sourceToken != nil { loadTransferMethods() } else {
            userRepository.getUser { [weak self] result in
                guard let strongSelf = self, let view = strongSelf.view else {
                    return
                }
                switch result {
                case .failure(let error):
                    view.hideLoading()
                    view.showError(error, pageName: strongSelf.pageName, pageGroup: strongSelf.pageGroup) {
                        strongSelf.loadCreateTransfer()
                    }

                case .success(let user):
                    strongSelf.sourceToken = user?.token
                    strongSelf.loadTransferMethods()
                }
            }
        }
    }

    private func loadTransferMethods() {
        transferMethodRepository.refreshTransferMethods()
        transferMethodRepository.listTransferMethods { [weak self] result in
            guard let strongSelf = self, let view = strongSelf.view else {
                return
            }
            switch result {
            case .failure(let error):
                view.hideLoading()
                view.showError(error, pageName: strongSelf.pageName, pageGroup: strongSelf.pageGroup) {
                    strongSelf.loadTransferMethods()
                }

            case .success(let result):
                if strongSelf.selectedTransferMethod == nil {
                    strongSelf.selectedTransferMethod = result?.data?.first
                }
                strongSelf.createInitialTransfer()
            }
        }
    }

    private func createInitialTransfer() {
        guard let sourceToken = sourceToken,
            let destinationToken = selectedTransferMethod?.token,
            let destinationCurrency = destinationCurrency else {
                initializeSections()
                view?.reloadData()
                view?.hideLoading()
                return
        }
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

        if let sourceToken = sourceToken,
            let destinationToken = selectedTransferMethod?.token,
            let destinationCurrency = destinationCurrency {
            view.showLoading()
            let transfer = HyperwalletTransfer.Builder(clientTransferId: clientTransferId,
                                                       sourceToken: sourceToken,
                                                       destinationToken: destinationToken)
                .destinationAmount(availableBalance == amount ? nil : amount)
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
                        if transfer.destinationAmount != self?.availableBalance {
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
            if let sectionData = sectionData.first(where: { $0.createTransferSectionHeader == .amount }) {
                sectionData.errorMessage = error.message
                view?.updateFooter(for: .amount)
            }
        }
    }
}
