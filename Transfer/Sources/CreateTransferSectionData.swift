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

enum CreateTransferSectionHeader: String {
    case button, destination, notes, transfer
}

protocol CreateTransferSectionData {
    var cellIdentifiers: [String] { get }
    var createTransferSectionHeader: CreateTransferSectionHeader { get }
    var rowCount: Int { get }
    var title: String? { get }
}

extension CreateTransferSectionData {
    var rowCount: Int { return 1 }
    var title: String? { return createTransferSectionHeader !=
        CreateTransferSectionHeader.button ?
            "transfer_section_header_\(createTransferSectionHeader.rawValue)".localized() : nil }
}

struct CreateTransferSectionDestinationData: CreateTransferSectionData {
    var createTransferSectionHeader: CreateTransferSectionHeader { return .destination }
    var cellIdentifiers: [String] { return [TransferDestinationCell.reuseIdentifier] }
}

struct CreateTransferSectionTransferData: CreateTransferSectionData {
    var createTransferSectionHeader: CreateTransferSectionHeader { return .transfer }
    var rowCount: Int { return 2 }
    var cellIdentifiers: [String] { return [
        TransferAmountCell.reuseIdentifier,
        TransferAllFundsCell.reuseIdentifier
    ]}
    var footer: String?

    init(availableBalance: String?) {
        guard let availableBalance = availableBalance,
            let doubleAvailableBalance = Double(availableBalance),
            doubleAvailableBalance != 0 else {
                footer = nil
                return
        }
        footer = String(format: "available_balance_footer".localized(), availableBalance)
    }
}

struct CreateTransferSectionButtonData: CreateTransferSectionData {
    var createTransferSectionHeader: CreateTransferSectionHeader { return .button }
    var cellIdentifiers: [String] { return [TransferButtonCell.reuseIdentifier] }
}

struct CreateTransferSectionNotesData: CreateTransferSectionData {
    var createTransferSectionHeader: CreateTransferSectionHeader { return .notes }
    var cellIdentifiers: [String] { return [TransferNotesCell.reuseIdentifier] }
}
