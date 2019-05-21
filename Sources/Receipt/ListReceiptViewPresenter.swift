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
    func showLoading()
    func hideLoading()
    func showError(_ error: HyperwalletErrorType, _ retry: (() -> Void)?)
    func loadReceipts()
}

final class ListReceiptViewPresenter {
    private unowned let view: ListReceiptView
    private var transferMethods = [HyperwalletTransferMethod]()
    var sectionData: [Date: [HyperwalletTransferMethod]] = [:]
    var sections = [ListReceiptSectionData]()
    var nextLink: URL?
    private var currentPage = 0
    private var limit = 10
    private var isFetchInProgress = false

    /// Initialize ListTransferMethodPresenter
    init(view: ListReceiptView) {
        self.view = view
    }

    func listTransferMethod() {
        // 1
        guard !isFetchInProgress else {
            return
        }

        // 2
        isFetchInProgress = true
        view.showLoading()
        let pagination = HyperwalletTransferMethodPagination()
        pagination.offset = currentPage
        pagination.limit = limit
        pagination.sortBy = .descendantCreatedOn
        Hyperwallet.shared.listTransferMethods(pagination: pagination, completion: listTransferMethodHandler())
    }

    private func getTransferMethod(at index: Int) -> HyperwalletTransferMethod? {
        return transferMethods[index]
    }

    private func listTransferMethodHandler()
        -> (HyperwalletPageList<HyperwalletTransferMethod>?, HyperwalletErrorType?) -> Void {
            return { [weak self] (result, error) in
                guard let strongSelf = self else {
                    return
                }
                DispatchQueue.main.async {
                    strongSelf.isFetchInProgress = false
                    strongSelf.view.hideLoading()
                    if let error = error {
                        strongSelf.view.showError(error, { strongSelf.listTransferMethod() })
                        return
                    }
                    strongSelf.nextLink = result?.links.first(where: { $0.params.rel == "next" })?.href
                    strongSelf.currentPage = Int(strongSelf.nextLink?.valueOf("offset") ?? "\(strongSelf.currentPage)")
                        ?? strongSelf.currentPage
                    strongSelf.groupedTransactionsByMonth(result?.data ?? [])
                    strongSelf.view.loadReceipts()
                }
            }
    }

    //swiftlint:disable force_cast
    private func groupedTransactionsByMonth(_ transferMethods: [HyperwalletTransferMethod]) {
        if sections.isEmpty {
            self.transferMethods = transferMethods
        } else {
            self.transferMethods.append(contentsOf: transferMethods)
        }

        sections = ListReceiptSectionData.group(rowItems: self.transferMethods, by: { (transferMethod) in
            firstDayOfMonth(date: parseDate(transferMethod.getField(fieldName: .createdOn) as! String))
        })
    }

    private func parseDate(_ str: String) -> Date {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd'T'H:mm:ss"
        return dateFormat.date(from: str)!
    }

    private func firstDayOfMonth(date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)!
    }

    func getCellConfiguration(for transferMethodIndex: Int) -> ListReceiptCellConfiguration? {
        if let transferMethod = getTransferMethod(at: transferMethodIndex),
            let country = transferMethod.getField(fieldName: .transferMethodCountry) as? String,
            let transferMethodType = transferMethod.getField(fieldName: .type) as? String {
            var lastFourDigitAccountNumber: String?
            if let lastFourDigit = getLastDigits(transferMethod, number: 4) {
                lastFourDigitAccountNumber = String(format: "%@%@",
                                                    "transfer_method_list_item_description".localized(),
                                                    lastFourDigit)
            }
            return ListReceiptCellConfiguration(
                transferMethodType: transferMethodType.lowercased().localized(),
                transferMethodCountry: country.localized(),
                lastFourDigitAccountNumber: lastFourDigitAccountNumber,
                transferMethodIconFont: HyperwalletIcon.of(transferMethodType).rawValue)
        }
        return nil
    }

    private func getLastDigits(_ transferMethod: HyperwalletTransferMethod, number: Int) -> String? {
        var accountId: String?
        switch transferMethod.getField(fieldName: .type) as? String {
        case "BANK_ACCOUNT", "WIRE_ACCOUNT":
            accountId = transferMethod.getField(fieldName: .bankAccountId) as? String
        case "BANK_CARD":
            accountId = transferMethod.getField(fieldName: .cardNumber) as? String

        default:
            break
        }
        return accountId?.suffix(startAt: number)
    }
}
