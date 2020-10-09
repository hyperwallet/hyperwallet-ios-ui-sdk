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

protocol ListTransferDestinationView: class {
    func hideLoading()
    func showError(_ error: HyperwalletErrorType,
                   pageName: String,
                   pageGroup: String,
                   _ retry: (() -> Void)?)
    func showLoading()
    func reloadData()
}

final class ListTransferDestinationPresenter {
    private weak var view: ListTransferDestinationView?
    private let pageGroup = "transfer-funds"
    private let pageName = "trasfer-funds:create:list-transfer-destination"
    private(set) var sectionData = [HyperwalletTransferMethod]()
    private var selectedTransferSourceType: TransferSourceType?
    private lazy var transferMethodRepository = {
        TransferMethodRepositoryFactory.shared.transferMethodRepository()
    }()

    /// Initialize ListTransferDestinationPresenter
    init(view: ListTransferDestinationView, selectedTransferSourceType: String? = nil) {
        self.view = view
        if let selectedTransferSourceType = selectedTransferSourceType {
            self.selectedTransferSourceType = TransferSourceType(rawValue: selectedTransferSourceType)
        }
    }

    /// Get the list of all Activated transfer methods from core SDK
    func listTransferMethods() {
        view?.showLoading()

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
                if var data = resultPageList?.data {
                    if strongSelf.selectedTransferSourceType == .prepaidCard {
                        data.removeAll(where: { $0.type ==
                            HyperwalletTransferMethod.TransferMethodType.prepaidCard.rawValue })
                    }

                    strongSelf.sectionData = data
                } else {
                    strongSelf.sectionData.removeAll()
                }

                view.reloadData()
            }
        }
    }
}
