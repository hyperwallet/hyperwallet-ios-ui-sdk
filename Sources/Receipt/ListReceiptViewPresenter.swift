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
    private let prepaidCardReceiptLimit = 10
    private var prepaidCardReceiptCreatedAfter = Calendar.current.date(byAdding: .year, value: -1, to: Date())

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
        Hyperwallet.shared.listUserReceipts(queryParam: setUpUserQueryParam(), completion: listUserReceiptHandler())
    }

    private func listPrepaidCardReceipts(_ prepaidCardToken: String) {
        guard !isLoadInProgress else {
            return
        }

        isLoadInProgress = true
        view.showLoading()
        Hyperwallet.shared.listPrepaidCardReceipts(prepaidCardToken: prepaidCardToken,
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
        -> (HyperwalletPageList<HyperwalletReceipt>?, HyperwalletErrorType?) -> Void {
            return { [weak self] (result, error) in
                guard let strongSelf = self else {
                    return
                }
                DispatchQueue.main.async {
                    strongSelf.isLoadInProgress = false
                    strongSelf.view.hideLoading()
                    if let error = error {
                        strongSelf.view.showError(error, { strongSelf.listUserReceipts() })
                        return
                    } else if let result = result {
                        print("For User receipts: \(result.data.count)")
                        strongSelf.groupReceiptsByMonth(result.data)
                        strongSelf.areAllReceiptsLoaded =
                            result.data.count < strongSelf.userReceiptLimit ? true : false
                        strongSelf.offset += result.data.count
                    }
                    strongSelf.view.loadReceipts()
                }
            }
    }

    private func listPrepaidCardReceiptHandler()
        -> (HyperwalletPageList<HyperwalletReceipt>?, HyperwalletErrorType?) -> Void {
            return { [weak self] (result, error) in
                guard let strongSelf = self else {
                    return
                }
                DispatchQueue.main.async {
                    strongSelf.isLoadInProgress = false
                    strongSelf.view.hideLoading()
                    if let error = error,
                        let prepaidCardToken = strongSelf.prepaidCardToken {
                        strongSelf.view.showError(error, { strongSelf.listPrepaidCardReceipts(prepaidCardToken) })
                        return
                    } else if let result = result {
                        strongSelf.areAllReceiptsLoaded =
                            result.data.count < strongSelf.prepaidCardReceiptLimit ? true : false

                        if let receiptsWithoutDuplicate = strongSelf.loadedReceiptWithoutDuplicate(from: result) {
                            strongSelf.groupReceiptsByMonth(receiptsWithoutDuplicate)
                            strongSelf.setCreatedAfter(from: receiptsWithoutDuplicate)
                        }
                    }
                    strongSelf.view.loadReceipts()
                }
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

    private func loadedReceiptWithoutDuplicate(from result: HyperwalletPageList<HyperwalletReceipt>)
        -> [HyperwalletReceipt]? {
            let receipts = result.data
            var loadedReceipts = [HyperwalletReceipt]()

            sectionData.forEach { loadedReceipts.append(contentsOf: $0.value) }

            if loadedReceipts.isNotEmpty() {
                return  receipts.filter { !loadedReceipts.contains($0) }
            } else {
                return nil
            }
    }

    private func setCreatedAfter(from receipts: [HyperwalletReceipt]) {
        if let createdOn = receipts.last?.createdOn,
            let date = ISO8601DateFormatter.ignoreTimeZone.date(from: createdOn) {
            prepaidCardReceiptCreatedAfter = date
        }
    }
}
