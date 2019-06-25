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
    typealias SelectItemHandler = (_ value: SelectDestinationCellConfiguration) -> Void
    typealias MarkCellHandler = (_ value: SelectDestinationCellConfiguration) -> Bool
    func showLoading()
    func hideLoading()
    func showCreateTransfer(with transferMethod: HyperwalletTransferMethod)
    func showError(_ error: HyperwalletErrorType, _ retry: (() -> Void)?)
    func showBusinessError(_ error: HyperwalletErrorType, _ handler: @escaping () -> Void)
    func showGenericTableView(items: [SelectDestinationCellConfiguration],
                              title: String,
                              selectItemHandler: @escaping SelectItemHandler,
                              markCellHandler: @escaping MarkCellHandler)
    func showScheduleTransfer(_ transfer: HyperwalletTransfer)
    func notifyTransferCreated(_ transfer: HyperwalletTransfer)
}

//swiftlint:disable force_cast
final class CreateTransferViewPresenter {
    private unowned let view: CreateTransferView
    private(set) var sectionData = [CreateTransferSectionData]()
    private(set) var transferMethods = [HyperwalletTransferMethod]()
    private(set) var selectedTransferMethod: HyperwalletTransferMethod!
    private var transfer: HyperwalletTransfer?

    /// Initialize CreateTransferPresenter
    init(view: CreateTransferView) {
        self.view = view
    }

    /// Display all the select Country or Currency based on the index
    func performShowDestinationAccountView() {
        view.showGenericTableView(items: getSelectDestinationCellConfiguration(),
                                  title: "select_transfer_method_country".localized(),
                                  selectItemHandler: selectCountryHandler(),
                                  markCellHandler: countryMarkCellHandler())
    }

    private func selectCountryHandler() -> CreateTransferView.SelectItemHandler {
        return { [weak self] (configuration) in
            guard let strongSelf = self else {
                return
            }
            for transferMethod in strongSelf.transferMethods
                where transferMethod.getField(fieldName: .token) as! String == configuration.transferMethodToken {
                strongSelf.selectedTransferMethod = transferMethod
                strongSelf.view.showCreateTransfer(with: transferMethod)
            }
        }
    }

    private func countryMarkCellHandler() -> CreateTransferView.MarkCellHandler {
        return { [weak self] item in
            self?.selectedTransferMethod.getField(fieldName: .token) as! String == item.transferMethodToken
        }
    }

    private func getSelectDestinationCellConfiguration() -> [SelectDestinationCellConfiguration] {
        var list = [SelectDestinationCellConfiguration]()
        for transferMethod in transferMethods {
            if let configuration = getCellConfiguration(for: transferMethod) {
                list.append(configuration)
            }
        }
        return list
    }

    private func getAdditionalInfo(_ transferMethod: HyperwalletTransferMethod) -> String? {
        var additionlInfo: String?
        switch transferMethod.getField(fieldName: .type) as? String {
        case "BANK_ACCOUNT", "WIRE_ACCOUNT":
            additionlInfo = transferMethod.getField(fieldName: .bankAccountId) as? String
            additionlInfo = String(format: "%@%@",
                                   "transfer_method_list_item_description".localized(),
                                   additionlInfo?.suffix(startAt: 4) ?? "")
        case "BANK_CARD":
            additionlInfo = transferMethod.getField(fieldName: .cardNumber) as? String
            additionlInfo = String(format: "%@%@",
                                   "transfer_method_list_item_description".localized(),
                                   additionlInfo?.suffix(startAt: 4) ?? "")
        case "PAYPAL_ACCOUNT":
            additionlInfo = transferMethod.getField(fieldName: .email) as? String

        default:
            break
        }
        return additionlInfo
    }

    private func getCellConfiguration(for transferMethod: HyperwalletTransferMethod) -> SelectDestinationCellConfiguration? {
        if let country = transferMethod.getField(fieldName: .transferMethodCountry) as? String,
            let transferMethodType = transferMethod.getField(fieldName: .type) as? String {
            return SelectDestinationCellConfiguration(
                transferMethodType: transferMethodType.lowercased().localized(),
                transferMethodCountry: country.localized(),
                additionalInfo: getAdditionalInfo(transferMethod),
                transferMethodIconFont: HyperwalletIcon.of(transferMethodType).rawValue,
                transferMethodToken: transferMethod.getField(fieldName: .token) as? String ?? "")
        }
        return nil
    }

    func initializeSections() {
        sectionData.removeAll()
        let addTransferDestinationSection = CreateTransferDestinationData(transferMethod: selectedTransferMethod)
        sectionData.append(addTransferDestinationSection)

        if let currency = selectedTransferMethod.getField(fieldName: .transferMethodCurrency) as? String {
            let addTransferUserInputSection = CreateTransferUserInputData(destinationCurrency: currency)
            sectionData.append(addTransferUserInputSection)
        }

        let addTransferButtonData = CreateTransferButtonData()
        sectionData.append(addTransferButtonData)
    }

    /// Get the list of all Activated transfer methods from core SDK
    func loadTransferMethods() {
        let queryParam = HyperwalletTransferMethodQueryParam()
        queryParam.limit = 100
        queryParam.status = .activated
        view.showLoading()
        Hyperwallet.shared.listTransferMethods(queryParam: queryParam, completion: loadTransferMethodHandler())
    }

    func createTransfer(_ transfer: HyperwalletTransfer) {
        self.transfer = transfer
//        Hyperwallet.shared.createTransfer(transfer: transfer,
//                                             completion: createTransferHandler())
        // TODO remove this once create transfer is added to core sdk
        view.showScheduleTransfer(transfer)
    }

    private func createTransferHandler() -> (HyperwalletTransfer?, HyperwalletErrorType?) -> Void {
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
                        strongSelf.view.notifyTransferCreated(transfer)
                        strongSelf.view.showScheduleTransfer(transfer)
                    }
                }
            }
        }
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
                if let transfer = self?.transfer {
                    self?.createTransfer(transfer)
                }}
            view.showError(error, handler)
        }
    }

    private func loadTransferMethodHandler()
        -> (HyperwalletPageList<HyperwalletTransferMethod>?, HyperwalletErrorType?) -> Void {
            return { [weak self] (result, error) in
                guard let strongSelf = self else {
                    return
                }
                DispatchQueue.main.async {
                    strongSelf.view.hideLoading()
                    if let error = error {
                        strongSelf.view.showError(error, { strongSelf.loadTransferMethods() })
                        return
                    }
                    if let data = result?.data, data.isNotEmpty() {
                        strongSelf.transferMethods = data
                        strongSelf.selectedTransferMethod = strongSelf.transferMethods.first!
                        strongSelf.view.showCreateTransfer(with: strongSelf.transferMethods.first!)
                    }
                }
            }
    }
}
