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

#if !COCOAPODS
import Common
#endif

import HyperwalletSDK

enum ScheduleTransferSectionHeader: String {
    case button, destination, foreignExchange, notes, summary
}

protocol ScheduleTransferSectionData {
    var scheduleTransferSectionHeader: ScheduleTransferSectionHeader { get }
    var rowCount: Int { get }
    var title: String? { get }
    var cellIdentifier: String { get }
}

extension ScheduleTransferSectionData {
    var rowCount: Int { return 1 }
    var title: String? { return scheduleTransferSectionHeader
        != ScheduleTransferSectionHeader.button ?
            "transfer_section_header_\(scheduleTransferSectionHeader.rawValue)".localized() : nil }
}

struct ScheduleTransferDestinationData: ScheduleTransferSectionData {
    var scheduleTransferSectionHeader: ScheduleTransferSectionHeader { return .destination }
    var cellIdentifier: String { return TransferDestinationCell.reuseIdentifier }
    var transferMethod: HyperwalletTransferMethod

    init(transferMethod: HyperwalletTransferMethod) {
        self.transferMethod = transferMethod
    }
}

struct ScheduleTransferForeignExchangeData: ScheduleTransferSectionData {
    var rows = [(title: String?, value: String?)]()
    var scheduleTransferSectionHeader: ScheduleTransferSectionHeader { return .foreignExchange }
    var rowCount: Int { return rows.count }
    var cellIdentifier: String { return TransferForeignExchangeCell.reuseIdentifier }
    var foreignExchanges: [HyperwalletForeignExchange]

    init(foreignExchanges: [HyperwalletForeignExchange]) {
        self.foreignExchanges = foreignExchanges

        for (index, foreignExchange) in foreignExchanges.enumerated() {
            if let sourceAmount = foreignExchange.sourceAmount,
                let sourceCurrency = foreignExchange.sourceCurrency,
                let destinationAmount = foreignExchange.destinationAmount,
                let destinationCurrency = foreignExchange.destinationCurrency,
                let rate = foreignExchange.rate {
                let sourceAmountFormatted = String(format: "%@ %@",
                                                   sourceAmount.format(with: sourceCurrency),
                                                   sourceCurrency)
                let destinationAmountFormatted = String(format: "%@ %@",
                                                        destinationAmount.format(with: destinationCurrency),
                                                        destinationCurrency)
                let rateFormatted = String(format: "%@ = %@",
                                           "1".format(with: sourceCurrency),
                                           rate.format(with: destinationCurrency))

                rows.append((title: "transfer_fx_sell_confirmation".localized(), value:sourceAmountFormatted))
                rows.append((title: "transfer_fx_buy_confirmation".localized(), value: destinationAmountFormatted))
                rows.append((title: "transfer_fx_rate_confirmation".localized(), value: rateFormatted))
                if !foreignExchanges.isLast(index: index) {
                    rows.append((title: nil, value: nil))
                }
            }
        }
    }
}

struct ScheduleTransferSummaryData: ScheduleTransferSectionData {
    var rows = [(title: String, value: String)]()
    var scheduleTransferSectionHeader: ScheduleTransferSectionHeader { return .summary }
    var rowCount: Int { return rows.count }
    var cellIdentifier: String { return TransferSummaryCell.reuseIdentifier }

    init(transfer: HyperwalletTransfer) {
        if let destinationAmount = transfer.destinationAmount,
            let destinationCurrency = transfer.destinationCurrency {
            let destinationAmountFormattedString = destinationAmount.format(with: destinationCurrency)
            guard let feeAmount = transfer.destinationFeeAmount else {
                rows.append((title: "transfer_amount_confirmation".localized(),
                             value: destinationAmountFormattedString))
                rows.append((title: "transfer_net_amount_confirmation".localized(),
                             value: destinationAmountFormattedString))
                return
            }
            let transferAmountFormattedDouble = destinationAmount.formatToDouble(with: destinationCurrency)
            let feeAmountFormattedDouble = feeAmount.formatToDouble(with: destinationCurrency)
            let grossTransferAmount = transferAmountFormattedDouble + feeAmountFormattedDouble

            rows.append((title: "transfer_amount_confirmation".localized(),
                         value: String(grossTransferAmount).format(with: destinationCurrency)))
            rows.append((title: "transfer_fee_confirmation".localized(),
                         value: feeAmount.format(with: destinationCurrency)))
            rows.append((title: "transfer_net_amount_confirmation".localized(),
                         value: destinationAmountFormattedString))
        }
    }
}

struct ScheduleTransferNotesData: ScheduleTransferSectionData {
    let notes: String
    var scheduleTransferSectionHeader: ScheduleTransferSectionHeader { return .notes }
    var cellIdentifier: String { return TransferNotesCell.reuseIdentifier }

    init?(transfer: HyperwalletTransfer) {
        guard let notes = transfer.notes else {
            return nil
        }
        self.notes = notes
    }
}

struct ScheduleTransferButtonData: ScheduleTransferSectionData {
    var scheduleTransferSectionHeader: ScheduleTransferSectionHeader { return .button }
    var cellIdentifier: String { return TransferButtonCell.reuseIdentifier }
}
