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

enum ReceiptDetailSectionHeader: String {
    case transaction, details, fee, notes
}

struct ReceiptDetailRow {
    let title: String
    let value: String
    let field: String
}

protocol ReceiptDetailSectionData {
    var receiptDetailSectionHeader: ReceiptDetailSectionHeader { get }
    var rowCount: Int { get }
    var title: String { get }
    var cellIdentifier: String { get }
}

extension ReceiptDetailSectionData {
    var rowCount: Int { return 1 }
    var title: String { return "receipt_details_section_header_\(receiptDetailSectionHeader.rawValue)".localized() }
}

struct ReceiptDetailSectionTransactionData: ReceiptDetailSectionData {
    var receiptDetailSectionHeader: ReceiptDetailSectionHeader { return .transaction }
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

struct ReceiptDetailSectionDetailData: ReceiptDetailSectionData {
    var rows = [ReceiptDetailRow] ()
    var receiptDetailSectionHeader: ReceiptDetailSectionHeader { return .details }
    var rowCount: Int { return rows.count }
    var cellIdentifier: String { return ReceiptDetailTableViewCell.reuseIdentifier }

    init(from receipt: HyperwalletReceipt) {
        let receiptId = receipt.journalId
        rows.append(ReceiptDetailRow(title: "receipt_details_receipt_id".localized(),
                                     value: receiptId,
                                     field: "journalId"))

        let dateTime = ISO8601DateFormatter.ignoreTimeZone.date(from: receipt.createdOn)!.format(for: .dateTime)
        rows.append(ReceiptDetailRow(title: "receipt_details_date".localized(),
                                     value: dateTime,
                                     field: "createdOn"))

        if let charityName = receipt.details?.charityName {
            rows.append(ReceiptDetailRow(title: "receipt_details_charity_name".localized(),
                                         value: charityName,
                                         field: "charityName"))
        }
        if let checkNumber = receipt.details?.checkNumber {
            rows.append(ReceiptDetailRow(title: "receipt_details_check_number".localized(),
                                         value: checkNumber,
                                         field: "checkNumber"))
        }
        if let clientPaymentId = receipt.details?.clientPaymentId {
            rows.append(ReceiptDetailRow(title: "receipt_details_client_payment_id".localized(),
                                         value: clientPaymentId,
                                         field: "clientPaymentId"))
        }
        if let website = receipt.details?.website {
            rows.append(ReceiptDetailRow(title: "receipt_details_website".localized(),
                                         value: website,
                                         field: "website"))
        }
    }
}

struct ReceiptDetailSectionFeeData: ReceiptDetailSectionData {
    var rows = [ReceiptDetailRow]()
    var receiptDetailSectionHeader: ReceiptDetailSectionHeader { return .fee }
    var rowCount: Int { return rows.count }
    var cellIdentifier: String { return ReceiptFeeTableViewCell.reuseIdentifier }

    init(from receipt: HyperwalletReceipt) {
        let amountFormat = receipt.entry == HyperwalletReceipt.HyperwalletEntryType.credit ? "+%@ %@" : "-%@ %@"
        let valueCurrencyFormat = "%@ %@"
        rows.append(ReceiptDetailRow(title: "receipt_details_amount".localized(),
                                     value: String(format: amountFormat, receipt.amount, receipt.currency),
                                     field: "amount"))
        var fee: Double = 0.0
        if let strFee = receipt.fee {
            rows.append(ReceiptDetailRow(title: "receipt_details_fee".localized(),
                                         value: String(format: valueCurrencyFormat, strFee, receipt.currency),
                                         field: "fee"))
            fee = Double(strFee) ?? 0.0
        }
        if let amount = Double(receipt.amount) {
            let transaction: Double = receipt.entry == .debit
                ? 0 - amount - fee
                : amount - fee
            let transactionFormat = getTransactionFormat(basedOn: receipt.amount)
            rows.append(ReceiptDetailRow(title: "receipt_details_transaction".localized(),
                                         value: String(format: valueCurrencyFormat,
                                                       String(format: transactionFormat, transaction),
                                                       receipt.currency),
                                         field: "transaction"))
        }
    }

    private func getTransactionFormat(basedOn value: String) -> String {
        let locale = Locale(identifier: Locale.preferredLanguages[0])
        let localizedDecimalSeparator: Character = locale.decimalSeparator?.first ?? "."
        let components = value.split(separator: localizedDecimalSeparator)
        return components.count == 1
            ? "%.0f"
            : "%.\(components[1].count)f"
    }
}

struct ReceiptDetailSectionNotesData: ReceiptDetailSectionData {
    let notes: String?
    var receiptDetailSectionHeader: ReceiptDetailSectionHeader { return .notes }
    var cellIdentifier: String { return ReceiptNotesTableViewCell.reuseIdentifier }

    init?(from receipt: HyperwalletReceipt) {
        guard let notes = receipt.details?.notes else {
            return nil
        }
        self.notes = notes
    }
}
