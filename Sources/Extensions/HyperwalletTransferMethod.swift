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

extension HyperwalletTransferMethod {
    var additionalInfo: String? {
        switch getField(fieldName: .type) as? String {
        case "BANK_CARD", "PREPAID_CARD":
            return String(format: "%@%@",
                          "transfer_method_list_item_description".localized(),
                          suffix(for: .cardNumber, startAt: 4) )
        case "PAYPAL_ACCOUNT":
            return toString(from: .email)

        default:
            return String(format: "%@%@",
                          "transfer_method_list_item_description".localized(),
                          suffix(for: .bankAccountId, startAt: 4))
        }
    }

    private func toString(from fieldName: HyperwalletTransferMethod.TransferMethodField) -> String? {
        return getField(fieldName: fieldName) as? String
    }

    private func suffix(for fieldName: HyperwalletTransferMethod.TransferMethodField, startAt: Int) -> String {
        return toString(from: fieldName)?.suffix(startAt: startAt) ?? ""
    }
}
