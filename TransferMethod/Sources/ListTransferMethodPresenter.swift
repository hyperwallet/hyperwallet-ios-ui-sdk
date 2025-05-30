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
import Common
import TransferMethodRepository
#endif

protocol ListTransferMethodView: AnyObject {
    func showLoading()
    func hideLoading()
    func showProcessing()
    func dismissProcessing(handler: @escaping () -> Void)
    func showConfirmation(handler: @escaping (() -> Void))
    func reloadData()
    func notifyTransferMethodDeactivated(_ hyperwalletStatusTransition: HyperwalletStatusTransition)
    func showError(_ error: HyperwalletErrorType,
                   pageName: String,
                   pageGroup: String,
                   _ retry: (() -> Void)?)
}

final class ListTransferMethodPresenter {
    private weak var view: ListTransferMethodView?
    private let pageGroup = "transfer-method"
    private let pageName = "transfer-method:add:list-transfer-method"
    private(set) var sectionData = [HyperwalletTransferMethod]()
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

    func showUpdateTransferMethod(at index: Int, parentController: UIViewController) {
        if transferMethodExists(at: index),
        let token = sectionData[index].token {
            let coordinator = HyperwalletUI.shared
                    .updateTransferMethodCoordinator(token, parentController: parentController)
            coordinator.navigate()
        }
    }

    /// Deactivate the selected Transfer Method
    private func deactivateTransferMethod(_ transferMethod: HyperwalletTransferMethod) {
        view?.showProcessing()

        transferMethodRepository.deactivateTransferMethod(transferMethod) { [weak self] (result) in
            guard let strongSelf = self, let view = strongSelf.view else {
                return
            }

            switch result {
            case .failure(let error):
                view.dismissProcessing(handler: {
                    view.showError(error, pageName: strongSelf.pageName, pageGroup: strongSelf.pageGroup) {
                        strongSelf.deactivateTransferMethod(transferMethod)
                    }
                })

            case .success(let resultStatusTransition):
                guard let statusTransition = resultStatusTransition else {
                    return
                }
                view.showConfirmation(handler: { () in
                    strongSelf.listTransferMethods(true)
                    view.notifyTransferMethodDeactivated(statusTransition)
                })
            }
        }
    }

    /// Get the list of all Activated transfer methods from core SDK
    /// - Parameter forceUpdate: Forces to refresh the data
    func listTransferMethods(_ forceUpdate: Bool = true) {
        view?.showLoading()
        if forceUpdate {
            transferMethodRepository.refreshTransferMethods()
        }

        transferMethodRepository.listTransferMethods { [weak self] (result) in
            guard let strongSelf = self, let view = strongSelf.view else {
                return
            }
            view.hideLoading()

            switch result {
            case .failure(let error):
                view.showError(error, pageName: strongSelf.pageName, pageGroup: strongSelf.pageGroup) {
                    strongSelf.listTransferMethods()
                }

            case .success(let resultPageList):
                if let data = resultPageList?.data {
                    strongSelf.sectionData = data
                } else {
                    strongSelf.sectionData = []
                }

                view.reloadData()
            }
        }
    }

    func transferMethodExists(at index: Int) -> Bool {
        return sectionData.indices.contains(index)
    }
}
