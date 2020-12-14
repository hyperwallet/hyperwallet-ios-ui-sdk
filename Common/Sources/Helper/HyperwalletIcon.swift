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

import Foundation
import HyperwalletSDK

/// The HyperwalletIcon class
public final class HyperwalletIcon {
    // swiftlint:disable cyclomatic_complexity
    /// Make transfer method type icon by transfer method type
    ///
    /// - Parameter fontType: String
    /// - Returns: a `HyperwalletIconContent` object
    public static func of(_ fontType: String) -> HyperwalletIconContent {
        switch fontType {
        case HyperwalletTransferMethod.TransferMethodType.bankAccount.rawValue:
            return .bankAccount

        case HyperwalletTransferMethod.TransferMethodType.bankCard.rawValue:
            return .debitCredit

        case HyperwalletTransferMethod.TransferMethodType.prepaidCard.rawValue:
            return .prepaidCard

        case HyperwalletTransferMethod.TransferMethodType.payPalAccount.rawValue:
            return .paypal

        case HyperwalletTransferMethod.TransferMethodType.wireAccount.rawValue:
            return .wire

        case HyperwalletTransferMethod.TransferMethodType.venmoAccount.rawValue:
            return .venmo

        case "CASH_PICKUP_MG":
            return .moneygram

        case HyperwalletTransferMethod.TransferMethodType.paperCheck.rawValue:
            return .check

        case HyperwalletReceipt.HyperwalletEntryType.credit.rawValue:
            return .credit

        case HyperwalletReceipt.HyperwalletEntryType.debit.rawValue:
            return .debit

        case "TRASH":
            return .trash

        default:
            return .bankAccount
        }
    }
}
