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

import HyperwalletSDK

protocol CreateTransferView: class {
    typealias SelectItemHandler = (_ value: ListTransferMethodCellConfiguration) -> Void
    typealias MarkCellHandler = (_ value: ListTransferMethodCellConfiguration) -> Bool
    func hideLoading()
    func showBusinessError(_ error: HyperwalletErrorType, _ handler: @escaping () -> Void)
    func showCreateTransfer()
    func showError(_ error: HyperwalletErrorType, _ retry: (() -> Void)?)

    func showGenericTableView(items: [ListTransferMethodCellConfiguration],
                              title: String,
                              selectItemHandler: @escaping SelectItemHandler,
                              markCellHandler: @escaping MarkCellHandler)
    func showLoading()
    func showScheduleTransfer(_ transfer: HyperwalletTransfer)
}

final class CreateTransferPresenter {
    private unowned let view: CreateTransferView
    private (set) var clientTransferId: String
    private(set) var sectionData = [CreateTransferSectionData]()
    private(set) var transferMethods = [HyperwalletTransferMethod]()
    private var sourceToken: String?
    private(set) var availableBalance: String?
    var selectedTransferMethod: HyperwalletTransferMethod!

    /// Initialize CreateTransferPresenter
    init(_ clientTransferId: String, _ sourceToken: String?, view: CreateTransferView) {
        self.clientTransferId = clientTransferId
        self.sourceToken = sourceToken
        self.view = view
    }

    func createTransfer(amount: String?, notes: String?) {
        let transfer = populateTransferObject(amount, notes)
        Hyperwallet.shared.createTransfer(transfer: transfer, completion: { [weak self] (result, error) in
            guard let strongSelf = self else {
                return
            }
            if let error = error {
                strongSelf.view.showError(error, { self?.createTransfer(amount: amount,
                                                                        notes: notes) })
                return
            }
            DispatchQueue.main.async {
                strongSelf.view.hideLoading()
                if let result = result {
                    strongSelf.view.showScheduleTransfer(result)
                }
            }
        })
    }

    func initializeSections() {
        sectionData.removeAll()
        let createTransferDestinationSection = CreateTransferSectionDestinationData(transferMethod: selectedTransferMethod)
        sectionData.append(createTransferDestinationSection)

        if let currency = selectedTransferMethod.transferMethodCurrency {
            let createTransferUserInputSection = CreateTransferSectionTransferData(destinationCurrency: currency,
                                                                                   availableBalance: availableBalance ?? "0.00")
            sectionData.append(createTransferUserInputSection)
        }

        let createTransferNotesSection = CreateTransferSectionNotesData()
        sectionData.append(createTransferNotesSection)

        let createTransferButtonData = CreateTransferSectionButtonData()
        sectionData.append(createTransferButtonData)
    }

    func loadCreateTransfer() {
        // TODO GetUser from UserRepository
        view.showLoading()
        if let _ = sourceToken {
            loadTransferMethods()
        } else {
            Hyperwallet.shared.getUser {[weak self] (result, error) in
                guard let strongSelf = self else {
                    return
                }
                DispatchQueue.main.async {
                    if let error = error {
                            self?.view.hideLoading()
                            self?.view.showError(error, { self?.loadCreateTransfer() })
                         return
                    }
                    strongSelf.sourceToken = result?.token
                    strongSelf.loadTransferMethods()
                }
            }
        }
    }

    /// Display all the destination accounts
    func showSelectDestinationAccountView() {
        view.showGenericTableView(items: getSelectDestinationCellConfiguration(),
                                  title: "select_destination".localized(),
                                  selectItemHandler: selectDestinationAccountHandler(),
                                  markCellHandler: destinationAccountMarkCellHandler())
    }

    /// Get the list of all Activated transfer methods from core SDK
    private func loadTransferMethods() {
//        TODO Use TransferMethodRepository to call listTransferMethods
        let queryParam = HyperwalletTransferMethodQueryParam()
        queryParam.limit = 100
        queryParam.status = .activated
//        view.showLoading()
        Hyperwallet.shared.listTransferMethods(queryParam: queryParam, completion: loadTransferMethodsHandler())
    }

    private func loadTransferMethodsHandler()
        -> (HyperwalletPageList<HyperwalletTransferMethod>?, HyperwalletErrorType?) -> Void {
            return { [weak self] (result, error) in
                guard let strongSelf = self else {
                    return
                }
                DispatchQueue.main.async {
                    //strongSelf.view.hideLoading()
                    if let error = error {
                        strongSelf.view.hideLoading()
                        strongSelf.view.showError(error, { strongSelf.loadTransferMethods() })
                        return
                    }
                    if let data = result?.data, data.isNotEmpty() {
                        strongSelf.transferMethods = data
                        if strongSelf.selectedTransferMethod == nil {
                            strongSelf.selectedTransferMethod = strongSelf.transferMethods.first!
                        }
                        strongSelf.createInitialTransfer()
                    }
                }
            }
    }

    private func createInitialTransfer() {
       let transfer = HyperwalletTransfer.Builder(clientTransferId: clientTransferId,
                                                  sourceToken: sourceToken ?? "",
                                                  destinationToken: selectedTransferMethod.token ?? "")
        .destinationCurrency(selectedTransferMethod.transferMethodCurrency)
        .build()
        Hyperwallet.shared.createTransfer(transfer: transfer,
                                          completion: createInitialTransferHandler())
    }

    private func createInitialTransferHandler() -> (HyperwalletTransfer?, HyperwalletErrorType?) -> Void {
        return { [weak self] (result, error) in
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                strongSelf.view.hideLoading()
                if let error = error {
                    strongSelf.errorHandler(for: error)
                } else {
                    if let transfer = result {
                        strongSelf.availableBalance = transfer.destinationAmount
                        strongSelf.view.showCreateTransfer()
                    }
                }
            }
        }
    }

    private func populateTransferObject(_ amount: String?, _ notes: String?) -> HyperwalletTransfer {
        return HyperwalletTransfer.Builder(clientTransferId: "123543567",
                                           sourceToken: sourceToken ?? "",
                                           destinationToken: selectedTransferMethod.token ?? "")
            .destinationAmount(amount)
            .notes(notes)
            .destinationCurrency(selectedTransferMethod.transferMethodCurrency)
            .build()
    }

    private func errorHandler(for error: HyperwalletErrorType) {
        switch error.group {
        case .business:
            guard let errors = error.getHyperwalletErrors()?.errorList, errors.isNotEmpty() else {
                return
            }
            // TODO add error handling logic, refer to AddTransferMethodPresenter

        default:
            let handler = { [weak self] () -> Void in
                self?.loadCreateTransfer()
            }
            view.showError(error, handler)
        }
    }

    private func selectDestinationAccountHandler() -> CreateTransferView.SelectItemHandler {
        return { [weak self] (configuration) in
            guard let strongSelf = self else {
                return
            }
            for transferMethod in strongSelf.transferMethods
                where transferMethod.token == configuration.transferMethodToken {
                    strongSelf.selectedTransferMethod = transferMethod
                    strongSelf.createInitialTransfer()
            }
        }
    }

    private func destinationAccountMarkCellHandler() -> CreateTransferView.MarkCellHandler {
        return { [weak self] item in
            self?.selectedTransferMethod.token == item.transferMethodToken
        }
    }

    private func getSelectDestinationCellConfiguration() -> [ListTransferMethodCellConfiguration] {
        var list = [ListTransferMethodCellConfiguration]()
        for transferMethod in transferMethods {
            if let configuration = getCellConfiguration(for: transferMethod) {
                list.append(configuration)
            }
        }
        return list
    }

    private func getAdditionalInfo(_ transferMethod: HyperwalletTransferMethod) -> String? {
        var additionalInfo: String?
        switch transferMethod.type {
        case "BANK_CARD", "PREPAID_CARD":
            additionalInfo = transferMethod.getField(HyperwalletTransferMethod.TransferMethodField.cardNumber.rawValue)
            additionalInfo = String(format: "%@%@",
                                    "transfer_method_list_item_description".localized(),
                                    additionalInfo?.suffix(startAt: 4) ?? "")
        case "PAYPAL_ACCOUNT":
            additionalInfo = transferMethod.getField(HyperwalletTransferMethod.TransferMethodField.email.rawValue)

        default:
            additionalInfo = transferMethod.getField(HyperwalletTransferMethod.TransferMethodField.bankAccountId.rawValue)
            additionalInfo = String(format: "%@%@",
                                    "transfer_method_list_item_description".localized(),
                                    additionalInfo?.suffix(startAt: 4) ?? "")
        }
        return additionalInfo
    }
    private func getCellConfiguration(for transferMethod: HyperwalletTransferMethod) -> ListTransferMethodCellConfiguration? {
        if let country = transferMethod.transferMethodCountry,
            let transferMethodType = transferMethod.type {
            return ListTransferMethodCellConfiguration(
                transferMethodType: transferMethodType.lowercased().localized(),
                transferMethodCountry: country.localized(),
                additionalInfo: getAdditionalInfo(transferMethod),
                transferMethodIconFont: HyperwalletIcon.of(transferMethodType).rawValue,
                transferMethodToken: transferMethod.token ?? "")
        }
        return nil
    }
}
