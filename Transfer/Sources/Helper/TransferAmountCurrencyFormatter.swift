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

    static func formatDoubleAmount(_ amount: Double, with currencyCode: String) -> String {
        if let transferAmountCurrency = getTransferAmountCurrency(for: currencyCode) {
            let formatter = NumberFormatter()
            formatter.usesGroupingSeparator = true
            formatter.maximumFractionDigits = transferAmountCurrency.decimals
            formatter.numberStyle = .currency
            formatter.currencyCode = currencyCode
            formatter.locale = Locale.current
            formatter.currencySymbol = ""

            if let amount = formatter.string(from: NSNumber(value: amount)) {
                return amount.trimmingCharacters(in: .whitespaces)
            }
        }
        return "\(amount)"
    }

    static func getDecimalAmount(amount: String, currencyCode: String?) -> Double {
        let doubleAmount = NSString(string: amount).doubleValue
        if let currencyCode = currencyCode,
            let currency = getTransferAmountCurrency(for: currencyCode) {
            var fractionalDenominator: Double = 10
            if currency.decimals > 0 {
                for _ in 1..<currency.decimals {
                    fractionalDenominator *= 10
                }
                return doubleAmount / fractionalDenominator
            }
        }
        return doubleAmount
    }

    /// Format amount for currency code using users locale
    /// - Parameter currencyCode: currency code
    /// - Returns: a formatted amount string
    static func formatStringAmount(_ amount: String, with currencyCode: String) -> String {
        if let transferAmountCurrency = getTransferAmountCurrency(for: currencyCode) {
            let number = amount.formatAmountToDouble()
            let formatter = NumberFormatter()
            formatter.usesGroupingSeparator = true
            formatter.maximumFractionDigits = transferAmountCurrency.decimals
            formatter.numberStyle = .currency
            formatter.currencyCode = currencyCode
            formatter.locale = Locale.current
            formatter.currencySymbol = ""
            return formatter.string(for: number)?.trimmingCharacters(in: .whitespaces) ?? amount
        } else {
            return amount
        }
    }

    /// Format currency amount by adding symbol and currency code
    /// - Parameter currencyCode: currency code
    /// - Returns: a formatted amount string
    static func addCurrencySymbolAndCode(_ amount: String, with currencyCode: String) -> String {
        if let currencySymbol = TransferAmountCurrencyFormatter.getTransferAmountCurrency(for: currencyCode)?.symbol {
            return String(format: "%@%@ %@", currencySymbol, amount, currencyCode)
        } else {
            return amount
        }
    }

    /// Format amount for currency code using users locale while adding symbol and currency code
    /// - Parameter currencyCode: currency code
    /// - Returns: a formatted amount string
    static func formatCurrencyWithSymbolAndCode(_ amount: String, with currencyCode: String) -> String {
        return addCurrencySymbolAndCode(formatStringAmount(amount, with: currencyCode), with: currencyCode)
    }
}
