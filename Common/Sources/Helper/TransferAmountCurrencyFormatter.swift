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

/// Transfer Amount Currency Formatter 
public struct TransferAmountCurrencyFormatter {
    private static let transferAmountCurrencyData: TransferAmountCurrencyData? = {
        if let path = Bundle(for: HyperwalletBundle.self).path(forResource: "Currency", ofType: "json"),
            let data = NSData(contentsOfFile: path) as Data? {
            return try? JSONDecoder().decode(TransferAmountCurrencyData.self, from: data)
        }
        return nil
    }()
    
    /// Get Transfer Amount Currency
    /// - Parameter currencyCode: currency code
    /// - Returns: instance of TransferAmountCurrency
    public static func getTransferAmountCurrency(for currencyCode: String) -> TransferAmountCurrency? {
        return transferAmountCurrencyData?.data.first(where: { $0.currencyCode == currencyCode })
    }
    
    /// Format double amount to currency string
    /// - Parameters:
    ///   - amount: amount
    ///   - currencyCode: currency code
    /// - Returns: a formatted currency string
    public static func formatDoubleAmount(_ amount: Double, with currencyCode: String) -> String {
        if let transferAmountCurrency = getTransferAmountCurrency(for: currencyCode) {
            let formatter = NumberFormatter()
            formatter.usesGroupingSeparator = true
            formatter.maximumFractionDigits = transferAmountCurrency.decimals
            formatter.minimumFractionDigits = transferAmountCurrency.decimals
            formatter.numberStyle = .currency
            formatter.currencyCode = currencyCode
            formatter.locale = getLocaleIdentifer(for: currencyCode)
            formatter.currencySymbol = ""

            if let amount = formatter.string(from: NSNumber(value: amount)) {
                return amount.trimmingCharacters(in: .whitespaces)
            }
        }
        return "\(amount)"
    }
    
    /// Get decimal amount from formatted currency code
    /// - Parameters:
    ///   - amount: amount string
    ///   - currencyCode: currency code
    /// - Returns: a decimal amount 
    public static func getDecimalAmount(amount: String, currencyCode: String?) -> Double {
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
    public static func formatStringAmount(_ amount: String, with currencyCode: String) -> String {
        if let transferAmountCurrency = getTransferAmountCurrency(for: currencyCode) {
            let number = amount.formatAmountToDouble()
            let formatter = NumberFormatter()
            formatter.usesGroupingSeparator = true
            formatter.maximumFractionDigits = transferAmountCurrency.decimals
            formatter.minimumFractionDigits = transferAmountCurrency.decimals
            formatter.numberStyle = .currency
            formatter.currencyCode = currencyCode
            formatter.locale = getLocaleIdentifer(for: currencyCode)
            formatter.currencySymbol = ""
            return formatter.string(for: number)?.trimmingCharacters(in: .whitespaces) ?? amount
        } else {
            return amount
        }
    }

    /// Format currency amount by adding symbol and currency code
    /// - Parameter currencyCode: currency code
    /// - Returns: a formatted amount string
    public static func addCurrencySymbolAndCode(_ amount: String, with currencyCode: String) -> String {
        if let currencySymbol = TransferAmountCurrencyFormatter.getTransferAmountCurrency(for: currencyCode)?.symbol {
            return String(format: "%@%@ %@", currencySymbol, amount, currencyCode)
        } else {
            return amount
        }
    }

    /// Format amount for currency code using users locale while adding symbol and currency code
    /// - Parameter currencyCode: currency code
    /// - Returns: a formatted amount string
    public static func formatCurrencyWithSymbolAndCode(_ amount: String, with currencyCode: String) -> String {
        return addCurrencySymbolAndCode(formatStringAmount(amount, with: currencyCode), with: currencyCode)
    }
    
    /// Format amount for currency code and add currency symbol from Currency.json
    /// - Parameters:
    ///   - amount: amount to format
    ///   - currencyCode: currency code
    /// - Returns: formatted amount with currency symbol
    public static func formatCurrencyWithSymbol(_ amount: String, with currencyCode: String) -> String {
        let amount = formatStringAmount(amount, with: currencyCode)
        if let currencySymbol = TransferAmountCurrencyFormatter.getTransferAmountCurrency(for: currencyCode)?.symbol {
            return String(format: "%@%@", currencySymbol, amount)
        } else {
            return amount
        }
    }
    
    /// Get locale
    /// - Parameter currencyCode: currency code
    /// - Returns: a locale
    private static func getLocaleIdentifer(for currencyCode: String) -> Locale? {
        if let identifier = currencyMappings[currencyCode] {
            return Locale(identifier: identifier)
        }
        return Locale.current
    }
    
    /// Currency code and it is locale identifier
    private static let currencyMappings: [String: String] = {
        return [
            "AED": "ar_AE",
            "ALL": "en_AL",
            "AMD": "hy_AM",
            "ARS": "en_AR",
            "AUD": "en_AU",
            "BAM": "hr_BA",
            "BDT": "en_BD",
            "BGN": "bg_BG",
            "BHD": "en_US",
            "BOB": "qu_BO",
            "BRL": "en_BR",
            "BWP": "en_BW",
            "CAD": "es_CA",
            "CHF": "en_CH",
            "CLP": "es_CL",
            "CNH": "en_CN",
            "CNY": "en_CN",
            "COP": "en_CO",
            "CZK": "cs_CZ",
            "DKK": "en_DK",
            "EEK": "en_US",
            "EGP": "en_US",
            "ETB": "so_ET",
            "EUR": "es_EA",
            "FJD": "en_FJ",
            "GBP": "kw_GB",
            "GHS": "ee_GH",
            "GMD": "en_GM",
            "HKD": "en_HK",
            "HRK": "en_HR",
            "HUF": "hu_HU",
            "IDR": "jv_ID",
            "ILS": "he_IL",
            "INR": "en_IN",
            "ISK": "en_US",
            "JMD": "en_JM",
            "JOD": "en_US",
            "JPY": "en_JP",
            "KES": "guz_KE",
            "KHR": "km_KH",
            "KRW": "en_KR",
            "KWD": "en_US",
            "KZT": "ru_KZ",
            "LAK": "lo_LA",
            "LKR": "ta_LK",
            "LSL": "en_US",
            "MAD": "zgh_MA",
            "MGA": "en_MG",
            "MRU": "ff_MR",
            "MUR": "en_MU",
            "MWK": "en_MW",
            "MXN": "en_MX",
            "MYR": "en_MY",
            "MZN": "mgh_MZ",
            "NAD": "af_NA",
            "NGN": "en_NG",
            "NOK": "nn_NO",
            "NPR": "en_US",
            "NZD": "en_PN",
            "OMR": "ar_OM",
            "PEN": "es_PE",
            "PGK": "en_PG",
            "PHP": "ceb_PH",
            "PKR": "en_PK",
            "PLN": "pl_PL",
            "QAR": "en_US",
            "RON": "ro_RO",
            "RSD": "sr-Latn_RS",
            "RUB": "ru_RU",
            "SBD": "en_SB",
            "SEK": "en_SE",
            "SGD": "ta_SG",
            "SVC": "en_US",
            "SZL": "en_SZ",
            "THB": "th_TH",
            "TND": "ar_TN",
            "TOP": "to_TO",
            "TRY": "tr_TR",
            "TWD": "zh_TW",
            "UGX": "cgg_UG",
            "USD": "es_US",
            "UYU": "es_UY",
            "VND": "vi_VN",
            "VUV": "en_VU",
            "WST": "en_WS",
            "XPF": "fr_PF",
            "ZAR": "en_ZA",
            "ZMW": "en_ZM"
        ]
    }()
}
