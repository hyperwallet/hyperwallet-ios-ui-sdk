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

    private lazy var transferMethodRepository = {
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
        view.showProcessing()

        transferMethodRepository.deactivateTransferMethod(transferMethod) { [weak self] (result) in
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

        transferMethodRepository.listTransferMethod { [weak self] (result) in
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
        switch transferMethod.type {
        case "BANK_CARD", "PREPAID_CARD":
            additionalInfo = transferMethod.getField(HyperwalletTransferMethod
                .TransferMethodField.cardNumber.rawValue)
            additionalInfo = String(format: "%@%@",
                                    "transfer_method_list_item_description".localized(),
                                    additionalInfo?.suffix(startAt: 4) ?? "")
        case "PAYPAL_ACCOUNT":
            additionalInfo = transferMethod.getField(HyperwalletTransferMethod
                .TransferMethodField.email.rawValue)

        default:
            additionalInfo = transferMethod.getField(HyperwalletTransferMethod
                .TransferMethodField.bankAccountId.rawValue)
            additionalInfo = String(format: "%@%@",
                                    "transfer_method_list_item_description".localized(),
                                    additionalInfo?.suffix(startAt: 4) ?? "")
        }
        return additionalInfo
    }
}
