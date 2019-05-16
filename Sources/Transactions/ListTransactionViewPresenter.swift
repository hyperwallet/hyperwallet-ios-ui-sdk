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

protocol ListTransactionView: class {
    func showLoading()
    func hideLoading()
    func showError(_ error: HyperwalletErrorType, _ retry: (() -> Void)?)
    func loadTransactions(with newIndexPathsToReload: [IndexPath]?)
}

final class ListTransactionViewPresenter {
    private unowned let view: ListTransactionView
    var transferMethods: [HyperwalletTransferMethod] = []
    var transferMethodPagination: HyperwalletPageList<HyperwalletTransferMethod>?
    private var currentPage = 0
    private var limit = 10
    private var isFetchInProgress = false

    /// Initialize ListTransferMethodPresenter
    init(view: ListTransactionView) {
        self.view = view
    }

    var currentNumberOfCells: Int {
        return transferMethods.count
    }

    func getTransferMethod(at index: Int) -> HyperwalletTransferMethod? {
        return transferMethods[index]
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
        Hyperwallet.shared.listTransferMethods(pagination: pagination, completion: listTransferMethodHandler())
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
                    strongSelf.currentPage += strongSelf.limit
                    strongSelf.transferMethodPagination = result
                    strongSelf.transferMethods.append(contentsOf: result?.data ?? [])

                    if result?.offset ?? 0 > 0 {
                        let indexPathsToReload = strongSelf.calculateIndexPathsToReload(from: result?.data ?? [])
                        strongSelf.view.loadTransactions(with: indexPathsToReload)
                    } else {
                        strongSelf.view.loadTransactions(with: .none)
                    }
                }
            }
    }

    private func calculateIndexPathsToReload(from newTransferMethods: [HyperwalletTransferMethod]) -> [IndexPath] {
        let startIndex = transferMethods.count - newTransferMethods.count
        let endIndex = startIndex + newTransferMethods.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }

    func getCellConfiguration(for transferMethodIndex: Int) -> ListTransactionCellConfiguration? {
        if let transferMethod = getTransferMethod(at: transferMethodIndex),
            let country = transferMethod.getField(fieldName: .transferMethodCountry) as? String,
            let transferMethodType = transferMethod.getField(fieldName: .type) as? String {
            var lastFourDigitAccountNumber: String?
            if let lastFourDigit = getLastDigits(transferMethod, number: 4) {
                lastFourDigitAccountNumber = String(format: "%@%@",
                                                    "transfer_method_list_item_description".localized(),
                                                    lastFourDigit)
            }
            return ListTransactionCellConfiguration(
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
