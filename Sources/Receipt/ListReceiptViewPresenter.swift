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
    var sectionArray: [(key: Date, value: [HyperwalletReceipt])] = []

//    var sections = [ListReceiptSectionData]()
    var nextLink: URL?
    private(set) var currentPage = 0
    private(set) var loadMore = false
    private var limit = 10
    private var isFetchInProgress = false

    //TODO need to remove this mock response
    private var mockedReceipts: [HyperwalletReceipt]!

    /// Initialize ListTransferMethodPresenter
    init(view: ListReceiptView) {
        self.view = view
    }

    func listTransactionReceipt() {
        // 1
        guard !isFetchInProgress else {
            return
        }

        // 2
        isFetchInProgress = true
        view.showLoading()
        let pagination = HyperwalletReceiptQueryParam()
        pagination.offset = currentPage
        pagination.limit = limit
        pagination.sortBy = .descendantCreatedOn
        Hyperwallet.shared.listTransactionReceipts(pagination: pagination, completion: listTransactionReceiptHandler())
    }

    private func getReceipt(at index: Int, in section: Int) -> HyperwalletReceipt? {
        let rowItems = sectionArray[section].value
        return rowItems[index]
    }

    private func listTransactionReceiptHandler()
        -> (HyperwalletPageList<HyperwalletReceipt>?, HyperwalletErrorType?) -> Void {
            return { [weak self] (result, error) in
                guard let strongSelf = self else {
                    return
                }
                DispatchQueue.main.async {
                    strongSelf.isFetchInProgress = false
                    strongSelf.view.hideLoading()
                    if let error = error {
                        strongSelf.view.showError(error, { strongSelf.listTransactionReceipt() })
                        return
                    } else if let result = result {
                        strongSelf.setUpMockedReceipts()
                        strongSelf.groupTransactionsByMonth(strongSelf.mockedReceipts)
                        strongSelf.loadMore = result.data.count < strongSelf.limit ? false : true
                        strongSelf.view.loadReceipts()
                    }
                }
            }
    }

    //swiftlint:disable force_cast
    private func groupTransactionsByMonth(_ receipts: [HyperwalletReceipt]) {
        //self.transferMethods.append(contentsOf: transferMethods)
        let currentSectionData = Dictionary(grouping: receipts, by: { (receipt) in
            firstDayOfMonth(date: parseDate(receipt.createdOn as! String))
        })

        for (date, receipts) in currentSectionData {
            if let sectionIndex = sectionArray.firstIndex(where: { $0.key == date }) {
                sectionArray[sectionIndex].value.append(contentsOf: receipts)
            } else {
                let dict: (key: Date, value: [HyperwalletReceipt]) = (key: date, value: receipts)
                sectionArray.append(dict)
            }
            sectionArray = sectionArray.sorted(by: { $0.key > $1.key })
        }
    }

    private func parseDate(_ stringDate: String) -> Date {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'H:mm:ss"
        return formatter.date(from: stringDate)!
    }

    private func firstDayOfMonth(date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)!
    }

    func getCellConfiguration(for receiptIndex: Int, in section: Int) -> ListReceiptCellConfiguration? {
        if let receipt = getReceipt(at: receiptIndex, in: section),
            let currency = receipt.currency,
            let type = receipt.type?.rawValue,
            let entry = receipt.entry?.rawValue,
            let createdOn = receipt.createdOn {
            return ListReceiptCellConfiguration(
                type: type.lowercased().localized(),
                entry: entry,
                amount: receipt.amount ?? "",
                currency: currency,
                createdOn: parseDate(createdOn),
                iconFont: HyperwalletIcon.of(receipt.entry?.rawValue ?? "").rawValue)
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

    func setUpMockedReceipts() {
        let jsonData = Data(receitpJsonString.utf8)
        let decoder = JSONDecoder()
        mockedReceipts = try? decoder.decode([HyperwalletReceipt].self, from: jsonData)
    }

    static func getDataFromJson(_ fileName: String) -> Data {
        let path = Bundle(for: self).path(forResource: fileName, ofType: "json")!
        return NSData(contentsOfFile: path)! as Data
    }

    let receitpJsonString = """
[
{
"journalId": "55047035",
"type": "PAYMENT",
"createdOn": "2019-05-24T17:35:20",
"entry": "CREDIT",
"sourceToken": "act-68adaba2-42f4-4f0f-8670-81c09f319a12",
"destinationToken": "usr-c5b9ea29-2f6a-4699-b731-76f5af0820e9",
"amount": "5.30",
"fee": "0.00",
"currency": "USD",
"details": {
"clientPaymentId": "DyClk0VG",
"payeeName": "Shaoyun Yang"
}
},
{
"journalId": "55047040",
"type": "PAYMENT",
"createdOn": "2019-05-24T17:39:19",
"entry": "CREDIT",
"sourceToken": "act-68adaba2-42f4-4f0f-8670-81c09f319a12",
"destinationToken": "usr-c5b9ea29-2f6a-4699-b731-76f5af0820e9",
"amount": "5.20",
"fee": "0.00",
"currency": "USD",
"details": {
"clientPaymentId": "DyClk0VGa",
"payeeName": "Shaoyun Yang"
}
},
{
"journalId": "55047041",
"type": "TRANSFER_TO_BANK_ACCOUNT",
"createdOn": "2019-05-24T17:46:28",
"entry": "DEBIT",
"sourceToken": "usr-c5b9ea29-2f6a-4699-b731-76f5af0820e9",
"destinationToken": "trm-0afed1c8-1f7c-4fe4-b620-7d1aab4e57bf",
"amount": "5.10",
"fee": "2.00",
"currency": "USD",
"details": {
"payeeName": "Shaoyun Yang",
"branchId": "026009593",
"bankAccountId": "*****5209",
"bankAccountPurpose": "CHECKING"
}
},
{
"journalId": "55176986",
"type": "PAYMENT",
"createdOn": "2019-04-28T18:16:04",
"entry": "CREDIT",
"sourceToken": "act-68adaba2-42f4-4f0f-8670-81c09f319a12",
"destinationToken": "usr-c5b9ea29-2f6a-4699-b731-76f5af0820e9",
"amount": "4.40",
"fee": "0.00",
"currency": "USD",
"details": {
"clientPaymentId": "DyClk0VG2a",
"payeeName": "Shaoyun Yang"
}
},
{
"journalId": "55176987",
"type": "PAYMENT",
"createdOn": "2019-04-28T18:16:08",
"entry": "CREDIT",
"sourceToken": "act-68adaba2-42f4-4f0f-8670-81c09f319a12",
"destinationToken": "usr-c5b9ea29-2f6a-4699-b731-76f5af0820e9",
"amount": "4.30",
"fee": "0.00",
"currency": "USD",
"details": {
"clientPaymentId": "DyClk0VG3a",
"payeeName": "Shaoyun Yang"
}
},
{
"journalId": "55176988",
"type": "PAYMENT",
"createdOn": "2019-04-28T18:16:10",
"entry": "CREDIT",
"sourceToken": "act-68adaba2-42f4-4f0f-8670-81c09f319a12",
"destinationToken": "usr-c5b9ea29-2f6a-4699-b731-76f5af0820e9",
"amount": "4.20",
"fee": "0.00",
"currency": "USD",
"details": {
"clientPaymentId": "DyClk0VG4a",
"payeeName": "Shaoyun Yang"
}
},
{
"journalId": "55176989",
"type": "PAYMENT",
"createdOn": "2019-04-28T18:16:12",
"entry": "CREDIT",
"sourceToken": "act-68adaba2-42f4-4f0f-8670-81c09f319a12",
"destinationToken": "usr-c5b9ea29-2f6a-4699-b731-76f5af0820e9",
"amount": "4.10",
"fee": "0.00",
"currency": "USD",
"details": {
"clientPaymentId": "DyClk0VG5a",
"payeeName": "Shaoyun Yang"
}
},
{
"journalId": "55176990",
"type": "PAYMENT",
"createdOn": "2019-03-28T18:16:14",
"entry": "CREDIT",
"sourceToken": "act-68adaba2-42f4-4f0f-8670-81c09f319a12",
"destinationToken": "usr-c5b9ea29-2f6a-4699-b731-76f5af0820e9",
"amount": "3.30",
"fee": "0.00",
"currency": "USD",
"details": {
"clientPaymentId": "DyClk0VG6a",
"payeeName": "Shaoyun Yang"
}
},
{
"journalId": "55176991",
"type": "PAYMENT",
"createdOn": "2019-03-28T18:16:17",
"entry": "CREDIT",
"sourceToken": "act-68adaba2-42f4-4f0f-8670-81c09f319a12",
"destinationToken": "usr-c5b9ea29-2f6a-4699-b731-76f5af0820e9",
"amount": "3.20",
"fee": "0.00",
"currency": "USD",
"details": {
"clientPaymentId": "DyClk0VG7a",
"payeeName": "Shaoyun Yang"
}
},
{
"journalId": "55176992",
"type": "PAYMENT",
"createdOn": "2019-03-28T18:16:19",
"entry": "CREDIT",
"sourceToken": "act-68adaba2-42f4-4f0f-8670-81c09f319a12",
"destinationToken": "usr-c5b9ea29-2f6a-4699-b731-76f5af0820e9",
"amount": "3.10",
"fee": "0.00",
"currency": "USD",
"details": {
"clientPaymentId": "DyClk0VG9a",
"payeeName": "Shaoyun Yang"
}
}
]
"""
}
