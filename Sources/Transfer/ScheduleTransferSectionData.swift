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

enum ScheduleTransferSectionHeader: String {
    case destination, foreignExchange, summary, notes, button
}

protocol ScheduleTransferSectionData {
    var scheduleTransferSectionHeader: ScheduleTransferSectionHeader { get }
    var rowCount: Int { get }
    var title: String? { get }
    var cellIdentifier: String { get }
}

extension ScheduleTransferSectionData {
    var rowCount: Int { return 1 }
    var title: String? { return scheduleTransferSectionHeader != ScheduleTransferSectionHeader.button ? "schedule_transfer_section_header_\(scheduleTransferSectionHeader.rawValue)".localized() : nil }
}

struct ScheduleTransferDestinationData: ScheduleTransferSectionData {
    var scheduleTransferSectionHeader: ScheduleTransferSectionHeader { return .destination }
    var cellIdentifier: String { return SelectDestinationTableViewCell.reuseIdentifier }
    var configuration: SelectDestinationCellConfiguration?
    var transferMethod: HyperwalletTransferMethod

    init(transferMethod: HyperwalletTransferMethod) {
        self.transferMethod = transferMethod
        setUpCellConfiguration(transferMethod: transferMethod)
    }

    mutating func setUpCellConfiguration(transferMethod: HyperwalletTransferMethod) {
        if let country = transferMethod.getField(fieldName: .transferMethodCountry) as? String,
            let transferMethodType = transferMethod.getField(fieldName: .type) as? String {
            configuration = SelectDestinationCellConfiguration(
                transferMethodType: transferMethodType.lowercased().localized(),
                transferMethodCountry: country.localized(),
                additionalInfo: getAdditionalInfo(transferMethod),
                transferMethodIconFont: HyperwalletIcon.of(transferMethodType).rawValue,
                transferMethodToken: transferMethod.getField(fieldName: .token) as? String ?? "")
        }
    }

    private func getAdditionalInfo(_ transferMethod: HyperwalletTransferMethod) -> String? {
        var additionlInfo: String?
        switch transferMethod.getField(fieldName: .type) as? String {
        case "BANK_ACCOUNT", "WIRE_ACCOUNT":
            additionlInfo = transferMethod.getField(fieldName: .bankAccountId) as? String
            additionlInfo = String(format: "%@%@",
                                   "transfer_method_list_item_description".localized(),
                                   additionlInfo?.suffix(startAt: 4) ?? "")
        case "BANK_CARD":
            additionlInfo = transferMethod.getField(fieldName: .cardNumber) as? String
            additionlInfo = String(format: "%@%@",
                                   "transfer_method_list_item_description".localized(),
                                   additionlInfo?.suffix(startAt: 4) ?? "")
        case "PAYPAL_ACCOUNT":
            additionlInfo = transferMethod.getField(fieldName: .email) as? String

        default:
            break
        }
        return additionlInfo
    }
}

struct ScheduleTransferForeignExchangeData: ScheduleTransferSectionData {
    var rows = [(title: String, value: String)]()
    var scheduleTransferSectionHeader: ScheduleTransferSectionHeader { return .foreignExchange }
    var rowCount: Int { return rows.count }
    var cellIdentifier: String { return ScheduleTransferForeignExchangeCell.reuseIdentifier }
    var foreignExchanges: [HyperwalletForeignExchange]

    init(foreignExchanges: [HyperwalletForeignExchange]) {
        self.foreignExchanges = foreignExchanges

        for foreignExchange in foreignExchanges {
            let souceAmount = String(format: "%@ %@",
                                     foreignExchange.sourceAmount!,
                                     foreignExchange.sourceCurrency!)
            let destinationAmount = String(format: "%@ %@",
                                           foreignExchange.destinationAmount!,
                                           foreignExchange.destinationCurrency!)
            let rate = String(format: "1 %@ = %@ %@",
                              foreignExchange.sourceCurrency!,
                              foreignExchange.rate!,
                              foreignExchange.destinationCurrency!)

            rows.append((title: "You sell:", value:souceAmount))
            rows.append((title: "You buy:", value: destinationAmount))
            rows.append((title: "Exchange Rate:", value: rate))
        }
    }
}

struct ScheduleTransferSummaryData: ScheduleTransferSectionData {
    var rows = [(title: String, value: String)]()
    var scheduleTransferSectionHeader: ScheduleTransferSectionHeader { return .summary }
    var rowCount: Int { return rows.count }
    var cellIdentifier: String { return ScheduleTransferSummaryCell.reuseIdentifier }

    init(transfer: HyperwalletTransfer) {
        let transferAmount = String(format: "%@ %@", transfer.sourceAmount!, transfer.destinationCurrency!)
        rows.append((title: "Amount:", value: transferAmount))
        if let destinationFeeAmount = transfer.destinationFeeAmount {
            let fee = String(format: "%@ %@", destinationFeeAmount, transfer.destinationCurrency!)
            let amoutReceived = String(format: "%@ %@", transfer.destinationAmount!, transfer.destinationCurrency!)
            rows.append((title: "Fee:", value: fee))
            rows.append((title: "You will receive:", value: amoutReceived))
        }
    }
}

struct ScheduleTransferNotesData: ScheduleTransferSectionData {
    let notes: String?
    var scheduleTransferSectionHeader: ScheduleTransferSectionHeader { return .notes }
    var cellIdentifier: String { return ScheduleTransferNotesCell.reuseIdentifier }

    init?(transfer: HyperwalletTransfer) {
        guard let notes = transfer.notes else {
            return nil
        }
        self.notes = notes
    }
}

struct ScheduleTransferButtonData: ScheduleTransferSectionData {
    var scheduleTransferSectionHeader: ScheduleTransferSectionHeader { return .button }
    var cellIdentifier: String { return ScheduleTransferButtonCell.reuseIdentifier }
}
