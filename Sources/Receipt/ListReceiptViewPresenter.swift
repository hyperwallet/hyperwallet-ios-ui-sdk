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
    private let limit = 20

    private var isLoadInProgress = false
    private(set) var areAllReceiptsLoaded = true
    private(set) var sectionData = [(key: Date, value: [HyperwalletReceipt])]()

    /// Initialize ListReceiptPresenter
    init(view: ListReceiptView) {
        self.view = view
    }

    func listReceipt() {
        guard !isLoadInProgress else {
            return
        }

        isLoadInProgress = true
        view.showLoading()
        Hyperwallet.shared.listUserReceipts(queryParam: setUpQueryParam(), completion: listReceiptHandler())
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

    private func setUpQueryParam() -> HyperwalletReceiptQueryParam {
        let queryParam = HyperwalletReceiptQueryParam()
        queryParam.offset = offset
        queryParam.limit = limit
        queryParam.sortBy = .descendantCreatedOn
        queryParam.createdAfter = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        return queryParam
    }

    private func listReceiptHandler()
        -> (HyperwalletPageList<HyperwalletReceipt>?, HyperwalletErrorType?) -> Void {
            return { [weak self] (result, error) in
                guard let strongSelf = self else {
                    return
                }
                DispatchQueue.main.async {
                    strongSelf.isLoadInProgress = false
                    strongSelf.view.hideLoading()
                    if let error = error {
                        strongSelf.view.showError(error, { strongSelf.listReceipt() })
                        return
                    } else if let result = result {
                        strongSelf.groupReceiptsByMonth(result.data)
                        strongSelf.areAllReceiptsLoaded = result.data.count < strongSelf.limit ? true : false
                        strongSelf.offset += result.data.count
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

        for section in groupedSections {
            if let sectionIndex = sectionData.firstIndex(where: { $0.key == section.key }) {
                sectionData[sectionIndex].value.append(contentsOf: section.value)
            } else {
                sectionData.append(section)
            }
        }
        sectionData = sectionData.sorted(by: { $0.key > $1.key })
    }
}
