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

/// Represents the Hyperwallet Icon type
public enum HyperwalletIconContent: String {
    /// The icon for Bank Account
    case bankAccount = "\u{e900}"
    /// The icon for add transfer method
    case addTransferMethod = "\u{e90b}"
    /// The icon for check type
    case check = "\u{e902}"
    /// The icon for debit and credit card type
    case debitCredit = "\u{e903}"
    /// The icon for prepaid card type
    case prepaidCard = "\u{e901}"
    /// The icon for wire transfer type
    case wire = "\u{e90a}"
    /// The icon for venmo transfer type
    case venmo = "\u{e905}"
    /// The icon for moenygram transfer type
    case moneygram = "\u{e904}"
    /// The icon for paypal transfer type
    case paypal = "\u{e906}"
    /// The credit icon
    case credit = "\u{e907}"
    /// The debit icon
    case debit = "\u{e908}"
    /// The trash can
    case trash = "\u{e909}"
}
