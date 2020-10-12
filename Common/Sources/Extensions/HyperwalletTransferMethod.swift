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

/// The HyperwalletTransferMethod extension
extension HyperwalletTransferMethod: GenericCellConfiguration {
    public var title: String? {
        return type?.lowercased().localized()
    }

    public var value: String? {
        return additionalInfo
    }

    /// Additional information about the transfer method
    var additionalInfo: String? {
        switch type {
        case TransferMethodType.bankCard.rawValue:
            return String(format: "%@%@",
                          "endingIn".localized(),
                          getField(TransferMethodField.cardNumber.rawValue)?
                            .suffix(startAt: 4) ?? "" )

        case TransferMethodType.payPalAccount.rawValue:
            return String(format: "%@%@",
                          "to".localized(),
                          getField(TransferMethodField.email.rawValue) ?? "")
        case TransferMethodType.prepaidCard.rawValue:
            let cardBrand = getField(TransferMethodField.cardBrand.rawValue)?.lowercased().localized() ?? ""
            let cardNumber = getField(TransferMethodField.cardNumber.rawValue)?.suffix(startAt: 4) ?? ""
            let bullets = Array(repeating: "\u{2022}", count: 4).joined()
            return String(format: "%@ %@ %@", cardBrand, bullets, cardNumber)

        case TransferMethodType.venmoAccount.rawValue:
            return String(format: "%@%@",
                          "endingIn".localized(),
                          getField(TransferMethodField.accountId.rawValue)?
                            .suffix(startAt: 4) ?? "")

        default:
            return String(format: "%@%@",
                          "endingIn".localized(),
                          getField(TransferMethodField.bankAccountId.rawValue)?
                            .suffix(startAt: 4) ?? "")
        }
    }
    /// Checking for transfer method is prepaid card or not
    /// - Returns: True if transfer method is prepaid card
    public func isPrepaidCard() -> Bool { return type == TransferMethodType.prepaidCard.rawValue }
}
