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
#if !COCOAPODS
import Common
#endif

struct TransferAmountCurrencyFormatter {
    private static let transferAmountCurrencyData: TransferAmountCurrencyData? = {
        if let path = Bundle(for: HyperwalletBundle.self).path(forResource: "Currency", ofType: "json"),
            let data = NSData(contentsOfFile: path) as Data? {
            return try? JSONDecoder().decode(TransferAmountCurrencyData.self, from: data)
        }
        return nil
    }()

    static func getTransferAmountCurrency(for currencyCode: String) -> TransferAmountCurrency? {
        return transferAmountCurrencyData?.data.first(where: { $0.currencyCode == currencyCode })
    }

    static func format(amount: String, with currencyCode: String) -> String {
        if let transferAmountCurrency = getTransferAmountCurrency(for: currencyCode) {
            let number = amount.formatToDouble(with: currencyCode)
            let formatter = NumberFormatter()
            formatter.usesGroupingSeparator = true
            formatter.maximumFractionDigits = transferAmountCurrency.decimals
            formatter.numberStyle = .currency
            formatter.currencyCode = currencyCode
            formatter.locale = Locale.current
            formatter.currencySymbol = ""
            return formatter.string(for: number) ?? amount
        } else {
            return amount
        }
    }

    static func formatToLocaleFromAPI(for amount: String?, currencyCode: String?) -> String {
        guard let currencyCode = currencyCode, let amount = amount, !amount.isEmpty
        else { return "0" }
        let decimalsSymbol = amount.decimalSymbol(for: currencyCode)
        let decimals = Set("0123456789.")
        let result = String(amount.filter { decimals.contains($0) })
        let formattedAmount = result.replacingOccurrences(of: ".", with: decimalsSymbol)
        return self.format(amount: formattedAmount, with: currencyCode)
    }

    static func formatToAPIFromLocale(for amount: String?, currencyCode: String?) -> String {
        guard let currencyCode = currencyCode, let amount = amount, !amount.isEmpty
        else { return "0" }
        let decimals = Set("0123456789")
        let result = String(amount.filter { decimals.contains($0) })
        let numberOfDecimals = self.getTransferAmountCurrency(for: currencyCode)?.decimals ?? 0
        if numberOfDecimals != 0 {
            let decimalValues = result.suffix(numberOfDecimals)
            return result.dropLast(numberOfDecimals) + "." + decimalValues
        }
        return result
    }
}
