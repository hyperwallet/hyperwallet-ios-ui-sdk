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
}

struct ReceiptDetailSectionTransactionData: ReceiptDetailSectionData {
    var receiptDetailSectionHeader: ReceiptDetailSectionHeader { return .transaction }
    var cellIdentifier: String { return ReceiptTransactionCell.reuseIdentifier }
    var title: String { return "mobileTransactionTypeLabel".localized() }
    let receipt: HyperwalletReceipt

    init(from receipt: HyperwalletReceipt) {
        self.receipt = receipt
    }
}

struct ReceiptDetailSectionDetailData: ReceiptDetailSectionData {
    var rows = [ReceiptDetailRow]()
    var receiptDetailSectionHeader: ReceiptDetailSectionHeader { return .details }
    var rowCount: Int { return rows.count }
    var cellIdentifier: String { return ReceiptDetailCell.reuseIdentifier }
    var title: String { return "mobileTransactionDetailsLabel".localized() }

    init(from receipt: HyperwalletReceipt) {
        if let receiptId = receipt.journalId {
            rows.append(ReceiptDetailRow(title: "mobileJournalNumberLabel".localized(),
                                         value: receiptId,
                                         field: "journalId"))
        }

        if let createdOn = receipt.createdOn,
            let dateTime = ISO8601DateFormatter.ignoreTimeZone.date(from: createdOn)?.format(for: .dateTime) {
            rows.append(ReceiptDetailRow(title: "date".localized(),
                                         value: dateTime,
                                         field: "createdOn"))
        }

        if let charityName = receipt.details?.charityName {
            rows.append(ReceiptDetailRow(title: "mobileCharityName".localized(),
                                         value: charityName,
                                         field: "charityName"))
        }
        if let checkNumber = receipt.details?.checkNumber {
            rows.append(ReceiptDetailRow(title: "mobileCheckNumber".localized(),
                                         value: checkNumber,
                                         field: "checkNumber"))
        }
        if let clientPaymentId = receipt.details?.clientPaymentId {
            rows.append(ReceiptDetailRow(title: "mobileTransactionIdLabel".localized(),
                                         value: clientPaymentId,
                                         field: "clientPaymentId"))
        }
        if let website = receipt.details?.website {
            rows.append(ReceiptDetailRow(title: "mobilePromoWebsite".localized(),
                                         value: website,
                                         field: "website"))
        }
    }
}

struct ReceiptDetailSectionFeeData: ReceiptDetailSectionData {
    var rows = [ReceiptDetailRow]()
    var receiptDetailSectionHeader: ReceiptDetailSectionHeader { return .fee }
    var rowCount: Int { return rows.count }
    var cellIdentifier: String { return ReceiptFeeCell.reuseIdentifier }
    var title: String { return "mobileFeeInfoLabel".localized() }
    init?(from receipt: HyperwalletReceipt) {
        guard
            let stringFee = receipt.fee,
            let fee = Double(stringFee),
            fee != 0.0,
            let amountValue = receipt.amount, let amount = Double(amountValue), let currency = receipt.currency else {
                return nil
        }

        let amountFormat = receipt.entry == HyperwalletReceipt.HyperwalletEntryType.credit ? "%@ %@" : "-%@ %@"
        let valueCurrencyFormat = "%@ %@"

        rows.append(ReceiptDetailRow(title: "amount".localized(),
                                     value: String(format: amountFormat,
                                                   amountValue.formatToCurrency(with: currency),
                                                   currency),
                                     field: "amount"))

        rows.append(ReceiptDetailRow(title: "mobileFeeLabel".localized(),
                                     value: String(format: valueCurrencyFormat,
                                                   stringFee.formatToCurrency(with: currency),
                                                   currency),
                                     field: "fee"))

        let transaction: Double = amount - fee
        rows.append(ReceiptDetailRow(title: "mobileTransactionDetailsTotal".localized(),
                                     value: String(format: valueCurrencyFormat,
                                                   "\(transaction)".formatToCurrency(with: currency),
                                                   currency),
                                     field: "transaction"))
    }
}

struct ReceiptDetailSectionNotesData: ReceiptDetailSectionData {
    let notes: String?
    var receiptDetailSectionHeader: ReceiptDetailSectionHeader { return .notes }
    var cellIdentifier: String { return ReceiptNotesCell.reuseIdentifier }
    var title: String { return "mobileConfirmNotesLabel".localized() }

    init?(from receipt: HyperwalletReceipt) {
        guard let notes = receipt.details?.notes else {
            return nil
        }
        if receipt.type == .foreignExchange,
           let foreignExchangeRate = receipt.foreignExchangeRate,
           let fixedFX = receipt.foreignExchangeRate?.getFxRateWithFourDecimal() {
            self.notes = notes.replacingOccurrences(of: foreignExchangeRate,
                                                    with: fixedFX)
        } else {
            self.notes = notes
        }
    }
}
