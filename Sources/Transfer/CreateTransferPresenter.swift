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
    func showLoading()
    func hideLoading()
    func showCreateTransfer(with transferMethod: HyperwalletTransferMethod)
    func showError(_ error: HyperwalletErrorType, _ retry: (() -> Void)?)
    func showBusinessError(_ error: HyperwalletErrorType, _ handler: @escaping () -> Void)
    func showScheduleTransfer(_ transfer: HyperwalletTransfer)
    func notifyTransferCreated(_ transfer: HyperwalletTransfer)
}

final class CreateTransferPresenter {
    private unowned let view: CreateTransferView
    private(set) var sectionData = [CreateTransferSectionData]()
    private(set) var transferMethods = [HyperwalletTransferMethod]()
    private var transfer: HyperwalletTransfer?

    /// Initialize CreateTransferPresenter
    init(view: CreateTransferView) {
        self.view = view
    }

    func initializeSections(with transferMethod: HyperwalletTransferMethod) {
        sectionData.removeAll()
        let addTransferDestinationSection = CreateTransferDestinationData(transferMethod: transferMethod)
        sectionData.append(addTransferDestinationSection)

        if let currency = transferMethod.getField(fieldName: .transferMethodCurrency) as? String {
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
                        strongSelf.view.showCreateTransfer(with: strongSelf.transferMethods.first!)
                    }
                }
            }
    }
}
