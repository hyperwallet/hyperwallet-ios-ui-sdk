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

typealias TitleValueRow = (title: String, value: String)

enum ReceiptSectionType: String {
    case transaction, detail, fee, notes
}

protocol ReceiptSection {
    var sectionType: ReceiptSectionType { get }
    var rowCount: Int { get }
    var title: String { get }
    var cellIdentifier: String { get }
}

extension ReceiptSection {
    var rowCount: Int { return 1 }
    var title: String { return "receipt_section_header_\(sectionType.rawValue)".localized() }
}

struct ReceiptTransactionSection: ReceiptSection {
    var sectionType: ReceiptSectionType { return .transaction }
    var cellIdentifier: String { return ReceiptTransactionTableViewCell.reuseIdentifier }
    let tableViewCellConfiguration: ReceiptTransactionCellConfiguration

    init(from receipt: HyperwalletReceipt) {
        tableViewCellConfiguration = ReceiptTransactionCellConfiguration(
            type: receipt.type.rawValue.lowercased().localized(),
            entry: receipt.entry.rawValue,
            amount: receipt.amount,
            currency: receipt.currency,
            createdOn: ISO8601DateFormatter
                .ignoreTimeZone
                .date(from: receipt.createdOn)!
                .format(for: .date),
            iconFont: HyperwalletIcon.of(receipt.entry.rawValue).rawValue)
    }
}

struct ReceiptDetailSection: ReceiptSection {
    var rows: [TitleValueRow] = []
    var sectionType: ReceiptSectionType { return .detail }
    var rowCount: Int { return rows.count }
    var cellIdentifier: String { return ReceiptDetailTableViewCell.reuseIdentifier }

    init(from receipt: HyperwalletReceipt) {
        let receiptId = receipt.journalId
        rows.append((title: "receipt_details_receipt_id".localized(), value: receiptId))

        let dateTime = ISO8601DateFormatter.ignoreTimeZone.date(from: receipt.createdOn)!.format(for: .dateTime)
        rows.append((title: "receipt_details_date".localized(), value: dateTime))

        if let charityName = receipt.details?.charityName {
            rows.append((title: "receipt_details_charity_name".localized(), value: charityName))
        }
        if let checkNumber = receipt.details?.checkNumber {
            rows.append((title: "receipt_details_check_number".localized(), value: checkNumber))
        }
        if let clientPaymentId = receipt.details?.clientPaymentId {
            rows.append((title: "receipt_details_client_payment_id".localized(), value: clientPaymentId))
        }
        if let website = receipt.details?.website {
            rows.append((title: "receipt_details_website".localized(), value: website))
        }
    }
}

struct ReceiptFeeSection: ReceiptSection {
    var rows: [TitleValueRow] = []
    var sectionType: ReceiptSectionType { return .fee }
    var rowCount: Int { return rows.count }
    var cellIdentifier: String { return ReceiptFeeTableViewCell.reuseIdentifier }

    init(from receipt: HyperwalletReceipt) {
        rows.append((title: "receipt_details_amount".localized(), value: receipt.amount))
        if let fee = receipt.fee {
            rows.append((title: "receipt_details_fee".localized(), value: fee))
        }
        ///TODO
        rows.append((title: "receipt_details_transaction".localized(), value: "???"))
    }
}

struct ReceiptNotesSection: ReceiptSection {
    let notes: String?
    var sectionType: ReceiptSectionType { return .notes }
    var cellIdentifier: String { return ReceiptNotesTableViewCell.reuseIdentifier }

    init?(from receipt: HyperwalletReceipt) {
        if let notes = receipt.details?.notes {
            self.notes = notes
        } else {
            return nil
        }
    }
}
