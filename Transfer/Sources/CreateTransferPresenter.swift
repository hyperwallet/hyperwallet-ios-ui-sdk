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
    typealias SelectItemHandler = (_ value: HyperwalletTransferMethod) -> Void
    typealias MarkCellHandler = (_ value: HyperwalletTransferMethod) -> Bool

    func hideLoading()
    func notifyTransferCreated(_ transfer: HyperwalletTransfer.Transfer)
    func showCreateTransfer()
    func showError(_ error: HyperwalletErrorType, _ retry: (() -> Void)?)
    func showGenericTableView(items: [HyperwalletTransferMethod],
                              title: String,
                              selectItemHandler: @escaping SelectItemHandler,
                              markCellHandler: @escaping MarkCellHandler)
    func showLoading()
    func showScheduleTransfer(_ transfer: HyperwalletTransfer.Transfer)
    func updateTransferSection()
    func updateFooter(for section: CreateTransferController.FooterSection)
    func areAllFieldsValid() -> Bool
}

final class CreateTransferPresenter {
    private unowned let view: CreateTransferView

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

    private var sourceToken: String?

    var selectedTransferMethod: HyperwalletTransferMethod?
    var amount: String?
    var notes: String?
    var transferAllFundsIsOn: Bool = false {
        didSet {
            amount = transferAllFundsIsOn ? availableBalance : nil
            view.updateTransferSection()
        }
    }
    var destinationCurrency: String? {
        return selectedTransferMethod?.transferMethodCurrency
    }

    init(_ clientTransferId: String, _ sourceToken: String?, view: CreateTransferView) {
        self.clientTransferId = clientTransferId
        self.sourceToken = sourceToken
        self.view = view
    }

    func initializeSections() {
        sectionData.removeAll()

        let createTransferDestinationSection = CreateTransferSectionDestinationData()
        sectionData.append(createTransferDestinationSection)

        let createTransferSectionTransferData = CreateTransferSectionTransferData(availableBalance: availableBalance)
        sectionData.append(createTransferSectionTransferData)

        let createTransferNotesSection = CreateTransferSectionNotesData()
        sectionData.append(createTransferNotesSection)

        let createTransferButtonData = CreateTransferSectionButtonData()
        sectionData.append(createTransferButtonData)
    }

    func loadCreateTransfer() {
        view.showLoading()
        if sourceToken != nil {
            loadTransferMethods()
        } else {
            userRepository.getUser { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                switch result {
                case .failure(let error):
                    strongSelf.view.hideLoading()
                    strongSelf.view.showError(error, { () -> Void in
                        strongSelf.loadCreateTransfer()
                    })

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
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .failure(let error):
                strongSelf.view.hideLoading()
                strongSelf.view.showError(error, { () -> Void in
                    strongSelf.loadTransferMethods()
                })

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
            let destinationCurrency = selectedTransferMethod?.transferMethodCurrency else {
                view.hideLoading()
                view.showCreateTransfer()
                return
        }
        let transfer = HyperwalletTransfer.Builder(clientTransferId: clientTransferId,
                                                   sourceToken: sourceToken,
                                                   destinationToken: destinationToken)
            .destinationCurrency(destinationCurrency)
            .build()

        transferRepository.createTransfer(transfer) { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            strongSelf.view.hideLoading()
            switch result {
            case .failure(let error):
                strongSelf.view.showError(error, { () -> Void in
                    strongSelf.createInitialTransfer()
                })

            case .success(let transfer):
                strongSelf.availableBalance = transfer?.destinationAmount
                strongSelf.view.showCreateTransfer()
            }
        }
    }

    // MARK: - Create Transfer Button Tapped
    func createTransfer() {
        guard view.areAllFieldsValid() else {
            return
        }

        if let sourceToken = sourceToken,
            let destinationToken = selectedTransferMethod?.token,
            let destinationCurrency = selectedTransferMethod?.transferMethodCurrency {
            view.showLoading()
            let transfer = HyperwalletTransfer.Builder(clientTransferId: clientTransferId,
                                                       sourceToken: sourceToken,
                                                       destinationToken: destinationToken)
                .destinationAmount(amount)
                .notes(notes)
                .destinationCurrency(destinationCurrency)
                .build()

            transferRepository.createTransfer(transfer) { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.view.hideLoading()
                switch result {
                case .failure(let error):
                    strongSelf.errorHandler(for: error) {
                        strongSelf.view.showError(error, { () -> Void in
                            strongSelf.createTransfer()
                        })
                    }

                case .success(let transfer):
                    if let transfer = transfer {
                        strongSelf.view.notifyTransferCreated(transfer)
                        strongSelf.view.showScheduleTransfer(transfer)
                    }
                }
            }
        }
    }

    // MARK: - Destination view
    func showSelectDestinationAccountView() {
        transferMethodRepository.listTransferMethods { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let pageList):
                if let transferMethods = pageList?.data {
                    strongSelf.view.showGenericTableView(items: transferMethods,
                                                         title: "transfer_select_destination".localized(),
                                                         selectItemHandler: strongSelf
                                                            .selectDestinationAccountHandler(),
                                                         markCellHandler: strongSelf
                                                            .destinationAccountMarkCellHandler())
                }

            case .failure(let error):
                strongSelf.view.showError(error, { () -> Void in
                    strongSelf.loadTransferMethods()
                })
            }
        }
    }

    private func destinationAccountMarkCellHandler() -> CreateTransferView.MarkCellHandler {
        return { [weak selectedTransferMethod] item in
            selectedTransferMethod?.token == item.token
        }
    }

    private func selectDestinationAccountHandler() -> CreateTransferView.SelectItemHandler {
        return { [weak self] item in
            self?.selectedTransferMethod = item
            self?.amount = nil
            self?.transferAllFundsIsOn = false
            self?.createInitialTransfer()
        }
    }

    func resetErrorMessagesForAllSections() {
        sectionData.forEach { $0.errorMessage = nil }
        CreateTransferController.FooterSection.allCases.forEach({ view.updateFooter(for: $0) })
    }

    private func errorHandler(for error: HyperwalletErrorType, _ nonBusinessErrorHandler: @escaping () -> Void) {
        switch error.group {
        case .business:
            resetErrorMessagesForAllSections()
            if let errors = error.getHyperwalletErrors()?.errorList, errors.isNotEmpty {
                if errors.contains(where: { $0.fieldName == nil }) {
                    view.showError(error) { [weak self] in self?.updateFooterContent(errors) }
                } else {
                    updateFooterContent(errors)
                }
            }

        default:
            nonBusinessErrorHandler()
        }
    }

    private func updateFooterContent(_ errors: [HyperwalletError]) {
        for error in errors {
            if let sectionData = sectionData.first(where: { $0.createTransferSectionHeader == .transfer }) {
                sectionData.errorMessage = error.message
                view.updateFooter(for: .transfer)
            }
        }
    }
}
