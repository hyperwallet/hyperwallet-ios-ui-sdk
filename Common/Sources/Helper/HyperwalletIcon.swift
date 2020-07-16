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

/// The HyperwalletIcon class
public final class HyperwalletIcon {
    // swiftlint:disable cyclomatic_complexity
    /// Make transfer method type icon by transfer method type
    ///
    /// - Parameter transferMethodType: a type of transfer method in String
    /// - Returns: a `HyperwalletIconContent` object
    public static func of(_ fontType: String) -> HyperwalletIconContent {
        switch fontType {
        case "BANK_ACCOUNT":
            return .bank
        case "BANK_CARD":
            return .debitCredit
        case "PREPAID_CARD":
            return .prepaidCard
        case "PAPER_CHECK":
            return .check
        case "PAYPAL_ACCOUNT":
            return .paypal
        case "WIRE_ACCOUNT":
            return .wire
        case "CREDIT":
            return .credit
        case "DEBIT":
            return .debit
        case "VENMO_ACCOUNT":
            return .venmo
        case "CASH_PICKUP_MG":
            return .moneygram

        default:
            return .bank
        }
    }
}
