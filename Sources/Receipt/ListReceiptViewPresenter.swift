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
import ReceiptRepository
#endif

protocol ListReceiptView: class {
    func hideLoading()
    func loadReceipts()
    func showError(_ error: HyperwalletErrorType, _ retry: (() -> Void)?)
    func showLoading()
}

final class ListReceiptViewPresenter {
    private unowned let view: ListReceiptView

    private var offset = 0
    private let userReceiptLimit = 20
    private var prepaidCardToken: String?
    private let prepaidCardReceiptCreatedAfter = Calendar.current.date(byAdding: .year, value: -1, to: Date())
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
    init(view: ListReceiptView, prepaidCardToken: String? = nil) {
        self.view = view
        self.prepaidCardToken = prepaidCardToken
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
        userReceiptRepository.listUserReceipts(queryParam: setUpUserQueryParam(),
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
            queryParam: setUpPrepaidCardQueryParam(),
            completion: listPrepaidCardReceiptHandler())
    }

    func getCellConfiguration(indexPath: IndexPath) -> ReceiptTransactionCellConfiguration? {
        guard let receipt = sectionData[safe: indexPath.section]?.value[safe:indexPath.row] else {
            return nil
        }
        let currency = receipt.currency
        let type = receipt.type.rawValue
        let entry = receipt.entry.rawValue
        let createdOn = ISO8601DateFormatter
            .ignoreTimeZone
            .date(from: receipt.createdOn)!
            .format(for: .date)
        return ReceiptTransactionCellConfiguration(
            type: type.lowercased().localized(),
            entry: entry,
            amount: receipt.amount,
            currency: currency,
            createdOn: createdOn,
            iconFont: HyperwalletIcon.of(receipt.entry.rawValue).rawValue)
    }

    private func setUpUserQueryParam() -> HyperwalletReceiptQueryParam {
        let queryParam = HyperwalletReceiptQueryParam()
        queryParam.offset = offset
        queryParam.limit = userReceiptLimit
        queryParam.sortBy = HyperwalletReceiptQueryParam.QuerySortable.descendantCreatedOn.rawValue
        queryParam.createdAfter = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        return queryParam
    }

    private func setUpPrepaidCardQueryParam() -> HyperwalletReceiptQueryParam {
        let queryParam = HyperwalletReceiptQueryParam()
        queryParam.createdAfter = prepaidCardReceiptCreatedAfter
        return queryParam
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
                    guard let receiptList = receiptList else { break }
                    strongSelf.groupReceiptsByMonth(receiptList.data)
                    strongSelf.areAllReceiptsLoaded =
                        receiptList.data.count < strongSelf.userReceiptLimit ? true : false
                    strongSelf.offset += receiptList.data.count

                case .failure(let error):
                    strongSelf.view.showError(error, { strongSelf.listUserReceipts() })
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
                    guard let receiptList = receiptList else { break }
                    strongSelf.areAllReceiptsLoaded = true
                    strongSelf.groupReceiptsByMonth(receiptList.data)

                case .failure(let error):
                    guard let prepaidCardToken = strongSelf.prepaidCardToken else { break }
                    strongSelf.view.showError(error, { strongSelf.listPrepaidCardReceipts(prepaidCardToken) })
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
                                                .date(from: $0.createdOn)!
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
