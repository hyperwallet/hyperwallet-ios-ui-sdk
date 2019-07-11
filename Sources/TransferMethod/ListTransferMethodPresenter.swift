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
#if !COCOAPODS
import TransferMethodRepository
#endif

protocol ListTransferMethodView: class {
    func showLoading()
    func hideLoading()
    func showProcessing()
    func dismissProcessing(handler: @escaping () -> Void)
    func showConfirmation(handler: @escaping (() -> Void))
    func showTransferMethods()
    func notifyTransferMethodDeactivated(_ hyperwalletStatusTransition: HyperwalletStatusTransition)
    func showError(_ error: HyperwalletErrorType, _ retry: (() -> Void)?)
}

final class ListTransferMethodPresenter {
    private unowned let view: ListTransferMethodView
    private (set) var sectionData = [HyperwalletTransferMethod]()

    let transferMethodRepository: TransferMethodRepository = {
        TransferMethodRepositoryFactory.shared.transferMethodRepository()
    }()

    /// Initialize ListTransferMethodPresenter
    init(view: ListTransferMethodView) {
        self.view = view
    }

    func deactivateTransferMethod(at index: Int) {
        if transferMethodExists(at: index) {
            deactivateTransferMethod(sectionData[index])
        }
    }

    /// Deactivate the selected Transfer Method
    private func deactivateTransferMethod(_ transferMethod: HyperwalletTransferMethod) {
        self.view.showProcessing()
        if let transferMethodType = transferMethod.getField(fieldName: .type)  as? String,
            let token = transferMethod.getField(fieldName: .token) as? String {
            selectedTransferMethod = transferMethod
            switch transferMethodType {
            case "BANK_ACCOUNT", "WIRE_ACCOUNT":
                deactivateBankAccount(token)
            case "BANK_CARD":
                deactivateBankCard(token)
            case "PAYPAL_ACCOUNT":
                deactivatePayPalAccount(token)

            default:
                break
            }
        }
    }

    private func listTransferMethodHandler()
        -> (HyperwalletPageList<HyperwalletTransferMethod>?, HyperwalletErrorType?) -> Void {
            return { [weak self] (result, error) in
                guard let strongSelf = self else {
                    return
                }
                DispatchQueue.main.async {
                    strongSelf.view.hideLoading()
                    if let error = error {
                        strongSelf.view.showError(error, { strongSelf.listTransferMethod() })
                        return
                    }
                    if let data = result?.data {
                        strongSelf.sectionData = data
                    } else {
                        strongSelf.sectionData = []
                    }

                    strongSelf.view.showTransferMethods()
                }
            }
    }

    private func deactivateBankAccount(_ token: String) {
        Hyperwallet.shared.deactivateBankAccount(transferMethodToken: token,
                                                 notes: "Deactivating Account",
                                                 completion: deactivateTransferMethodHandler())
    }

    private func deactivateBankCard(_ token: String) {
        Hyperwallet.shared.deactivateBankCard(transferMethodToken: token,
                                              notes: "Deactivating the Bank Card",
                                              completion: deactivateTransferMethodHandler())
    }

    private func deactivatePayPalAccount(_ token: String) {
        Hyperwallet.shared.deactivatePayPalAccount(transferMethodToken: token,
                                                   notes: "Deactivating the PayPal Account",
                                                   completion: deactivateTransferMethodHandler())
    }

    private func deactivateTransferMethodHandler()
        -> (HyperwalletStatusTransition?, HyperwalletErrorType?) -> Void {
            return { [weak self] (result, error) in
                guard let strongSelf = self else {
                    return
                }
                DispatchQueue.main.async {
                    if let error = error {
                        let errorHandler = {
                            strongSelf.view.showError(error, {
                                strongSelf.deactivateTransferMethod(strongSelf.selectedTransferMethod!) })
                        }

                        strongSelf.view.dismissProcessing(handler: errorHandler)
                    } else if let statusTransition = result {
                        let processingHandler = {
                            () -> Void in strongSelf.listTransferMethod()
                            strongSelf.view.notifyTransferMethodDeactivated(statusTransition)
                        }
                        strongSelf.view.showConfirmation(handler: processingHandler)
                    }
                }
            }
    }

    func getCellConfiguration(indexPath: IndexPath) -> ListTransferMethodCellConfiguration? {
        if let transferMethod = sectionData[safe: indexPath.row],
            let country = transferMethod.getField(fieldName: .transferMethodCountry) as? String,
            let transferMethodType = transferMethod.getField(fieldName: .type) as? String {
            return ListTransferMethodCellConfiguration(
                transferMethodType: transferMethodType.lowercased().localized(),
                transferMethodCountry: country.localized(),
                additionalInfo: getAdditionalInfo(transferMethod),
                transferMethodIconFont: HyperwalletIcon.of(transferMethodType).rawValue)
        }
        return nil
    }

    /// Deactivate the selected Transfer Method
    private func deactivateTransferMethod(_ transferMethod: HyperwalletTransferMethod) {
        view.showProcessing()

        transferMethodRepository.deactivate(transferMethod) { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }

            switch result {
            case .failure(let error):
                strongSelf.view.dismissProcessing(handler: {
                    strongSelf.view.showError(error, {
                        strongSelf.deactivateTransferMethod(transferMethod) })
                })

            case .success(let resultStatusTransition):
                guard let statusTransition = resultStatusTransition else {
                    return
                }
                strongSelf.view.showConfirmation(handler: { () -> Void in
                    strongSelf.listTransferMethod()
                    strongSelf.view.notifyTransferMethodDeactivated(statusTransition)
                })
            }
        }
    }

    /// Get the list of all Activated transfer methods from core SDK
    func listTransferMethod() {
        view.showLoading()
        let queryParam = HyperwalletTransferMethodQueryParam()
        queryParam.limit = 100
        queryParam.status = .activated
        transferMethodRepository.list(queryParam) { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.view.hideLoading()

            switch result {
            case .failure(let error):
                strongSelf.view.showError(error, { strongSelf.listTransferMethod() })

            case .success(let resultPageList):
                if let data = resultPageList?.data {
                    strongSelf.sectionData = data
                } else {
                    strongSelf.sectionData = []
                }

                strongSelf.view.showTransferMethods()
            }
        }
    }

    func transferMethodExists(at index: Int) -> Bool {
        return sectionData[safe: index] != nil
    }

    private func getAdditionalInfo(_ transferMethod: HyperwalletTransferMethod) -> String? {
        var additionalInfo: String?
        switch transferMethod.getField(fieldName: .type) as? String {
        case "BANK_CARD", "PREPAID_CARD":
            additionalInfo = transferMethod.getField(fieldName: .cardNumber) as? String
            additionalInfo = String(format: "%@%@",
                                    "transfer_method_list_item_description".localized(),
                                    additionalInfo?.suffix(startAt: 4) ?? "")
        case "PAYPAL_ACCOUNT":
            additionalInfo = transferMethod.getField(fieldName: .email) as? String

        default:
            additionalInfo = transferMethod.getField(fieldName: .bankAccountId) as? String
            additionalInfo = String(format: "%@%@",
                                    "transfer_method_list_item_description".localized(),
                                    additionalInfo?.suffix(startAt: 4) ?? "")
        }
        return additionalInfo
    }
}
