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
import ReceiptRepository
#endif

protocol ListReceiptView: class {
    func hideLoading()
    func loadReceipts()
    func showError(_ error: HyperwalletErrorType,
                   hyperwalletInsights: HyperwalletInsightsProtocol,
                   pageName: String,
                   pageGroup: String,
                   _ retry: (() -> Void)?)
    func showLoading()
}

final class ListReceiptPresenter {
    private unowned let view: ListReceiptView
    private let userReceiptLimit = 20

    let pageGroup = "receipts"
    lazy var pageName = {
        prepaidCardToken == nil
            ? "receipts:user:list-receipts"
            : "receipts:prepaidCard:list-receipts"
    }()
    private var hyperwalletInsights: HyperwalletInsightsProtocol
    private var offset = 0
    private var prepaidCardToken: String?
    private lazy var userReceiptRepository = {
        ReceiptRepositoryFactory.shared.userReceiptRepository()
    }()
    private lazy var prepaidCardReceiptRepository = {
        ReceiptRepositoryFactory.shared.prepaidCardReceiptRepository()
    }()

    private var isLoadInProgress = false
    private(set) var areAllReceiptsLoaded = true
    private(set) var sectionData = [(key: Date, value: [HyperwalletReceipt])]()

    /// Initialize ListReceiptPresenter
    init(view: ListReceiptView,
         prepaidCardToken: String? = nil,
         _ hyperwalletInsights: HyperwalletInsightsProtocol = HyperwalletInsights.shared) {
        self.view = view
        self.prepaidCardToken = prepaidCardToken
        self.hyperwalletInsights = hyperwalletInsights
    }

    func listReceipts() {
        if let prepaidCardToken = prepaidCardToken {
            listPrepaidCardReceipts(prepaidCardToken)
        } else {
            listUserReceipts()
        }
    }

    private func listUserReceipts() {
        guard !isLoadInProgress else {
            return
        }

        isLoadInProgress = true
        view.showLoading()
        userReceiptRepository.listUserReceipts(offset: offset,
                                               limit: userReceiptLimit,
                                               completion: listUserReceiptHandler())
    }

    private func listPrepaidCardReceipts(_ prepaidCardToken: String) {
        guard !isLoadInProgress else {
            return
        }

        isLoadInProgress = true
        view.showLoading()
        prepaidCardReceiptRepository.listPrepaidCardReceipts(
            prepaidCardToken: prepaidCardToken,
            completion: listPrepaidCardReceiptHandler())
    }

    private func listUserReceiptHandler()
        -> (Result<HyperwalletPageList<HyperwalletReceipt>?, HyperwalletErrorType>) -> Void {
            return { [weak self] (result) in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.isLoadInProgress = false
                strongSelf.view.hideLoading()
                switch result {
                case .success(let receiptList):
                    guard let receiptList = receiptList, let receipts = receiptList.data else { break }
                    strongSelf.groupReceiptsByMonth(receipts)
                    strongSelf.areAllReceiptsLoaded =
                        receipts.count < strongSelf.userReceiptLimit ? true : false
                    strongSelf.offset += receipts.count

                case .failure(let error):
                    strongSelf.view.showError(error,
                                              hyperwalletInsights: strongSelf.hyperwalletInsights,
                                              pageName: strongSelf.pageName,
                                              pageGroup: strongSelf.pageGroup) {
                        strongSelf.listUserReceipts()
                    }
                    return
                }
                strongSelf.view.loadReceipts()
            }
    }

    private func listPrepaidCardReceiptHandler()
        -> (Result<HyperwalletPageList<HyperwalletReceipt>?, HyperwalletErrorType>) -> Void {
            return { [weak self] (result) in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.isLoadInProgress = false
                strongSelf.view.hideLoading()
                switch result {
                case .success(let receiptList):
                    guard let receiptList = receiptList, let receipts = receiptList.data else { break }
                    strongSelf.areAllReceiptsLoaded = true
                    strongSelf.groupReceiptsByMonth(receipts)

                case .failure(let error):
                    guard let prepaidCardToken = strongSelf.prepaidCardToken else { break }
                    strongSelf.view.showError(error,
                                              hyperwalletInsights: strongSelf.hyperwalletInsights,
                                              pageName: strongSelf.pageName,
                                              pageGroup: strongSelf.pageGroup) {
                        strongSelf.listPrepaidCardReceipts(prepaidCardToken)
                    }
                    return
                }
                strongSelf.view.loadReceipts()
            }
    }

    private func groupReceiptsByMonth(_ receipts: [HyperwalletReceipt]) {
        let groupedSections = Dictionary(grouping: receipts,
                                         by: {
                                            ISO8601DateFormatter
                                                .ignoreTimeZone
                                                .date(from: $0.createdOn ?? "")!
                                                .firstDayOfMonth()
        })

        let sortedGroupedSections = groupedSections
            .sorted(by: prepaidCardToken == nil ? { $0.key > $1.key } : { $0.key < $1.key })

        for section in sortedGroupedSections {
            if let sectionIndex = sectionData.firstIndex(where: { $0.key == section.key }) {
                sectionData[sectionIndex].value.append(contentsOf: section.value)
            } else {
                sectionData.append(section)
            }
        }
    }
}
