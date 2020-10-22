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

class Currency {
    static let shared = Currency()

    private var currencyCodeSymbolCache: [String: String] = [:]

    func findCurrencySymbol(for currencyCode: String) -> String {
        if let currencySymbol = currencyCodeSymbolCache[currencyCode] {
            return currencySymbol
        }
        if let localeIdentifier = currencyMappings[currencyCode] {
            if let symbol = findCurrencySymbol(using: localeIdentifier, for: currencyCode) {
                currencyCodeSymbolCache[currencyCode] = symbol
                return symbol
            }
        }
        return ""
    }

    private func findCurrencySymbol(using localeIdentifier: String, for currencyCode: String) -> String? {
        let locale = Locale(identifier: localeIdentifier)
        return currencyCode.caseInsensitiveCompare(locale.currencyCode ?? "") == .orderedSame
            ? locale.currencySymbol : nil
    }

    func findLocale(for currencyCode: String) -> Locale? {
        if let identifier = currencyMappings[currencyCode] {
            return Locale(identifier: identifier)
        }
        return nil
    }

    deinit {
        currencyCodeSymbolCache.removeAll()
    }

    /// CurrencyCode and Locale Identifier
    private let currencyMappings: [String: String] = {
        return [
            "AED": "ar_AE",
            "AFN": "ps_AF",
            "ALL": "en_AL",
            "AMD": "hy_AM",
            "ANG": "en_SX",
            "AOA": "ln_AO",
            "ARS": "en_AR",
            "AUD": "en_NF",
            "AWG": "es_AW",
            "AZN": "az_AZ",
            "BAM": "hr_BA",
            "BBD": "en_BB",
            "BDT": "en_BD",
            "BGN": "bg_BG",
            "BHD": "ar_BH",
            "BIF": "en_BI",
            "BMD": "en_BM",
            "BND": "ms_BN",
            "BOB": "qu_BO",
            "BRL": "en_BR",
            "BSD": "en_BS",
            "BTN": "dz_BT",
            "BWP": "en_BW",
            "BYN": "ru_BY",
            "BZD": "en_BZ",
            "CAD": "es_CA",
            "CDF": "sw_CD",
            "CHF": "en_CH",
            "CLP": "es_CL",
            "CNY": "en_CN",
            "COP": "en_CO",
            "CRC": "es_CR",
            "CUP": "es_CU",
            "CVE": "kea_CV",
            "CZK": "cs_CZ",
            "DJF": "fr_DJ",
            "DKK": "en_DK",
            "DOP": "es_DO",
            "DZD": "fr_DZ",
            "EGP": "ar_EG",
            "ERN": "byn_ER",
            "ETB": "so_ET",
            "EUR": "es_EA",
            "FJD": "en_FJ",
            "FKP": "en_FK",
            "GBP": "kw_GB",
            "GEL": "os_GE",
            "GHS": "ee_GH",
            "GIP": "en_GI",
            "GMD": "en_GM",
            "GNF": "fr_GN",
            "GTQ": "es_GT",
            "GYD": "en_GY",
            "HKD": "en_HK",
            "HNL": "es_HN",
            "HRK": "en_HR",
            "HTG": "fr_HT",
            "HUF": "hu_HU",
            "IDR": "jv_ID",
            "ILS": "he_IL",
            "INR": "en_IN",
            "IQD": "syr_IQ",
            "IRR": "fa_IR",
            "ISK": "is_IS",
            "JMD": "en_JM",
            "JOD": "ar_JO",
            "JPY": "en_JP",
            "KES": "guz_KE",
            "KGS": "ky_KG",
            "KHR": "km_KH",
            "KMF": "fr_KM",
            "KPW": "ko_KP",
            "KRW": "en_KR",
            "KWD": "ar_KW",
            "KYD": "en_KY",
            "KZT": "ru_KZ",
            "LAK": "lo_LA",
            "LBP": "ar_LB",
            "LKR": "ta_LK",
            "LRD": "vai-Latn_LR",
            "LYD": "ar_LY",
            "MAD": "shi_MA",
            "MDL": "ru_MD",
            "MGA": "en_MG",
            "MKD": "mk_MK",
            "MMK": "my_MM",
            "MNT": "mn_MN",
            "MOP": "zh_MO",
            "MRU": "ff_MR",
            "MUR": "en_MU",
            "MVR": "dv_MV",
            "MWK": "en_MW",
            "MXN": "en_MX",
            "MYR": "en_MY",
            "MZN": "mgh_MZ",
            "NAD": "af_NA",
            "NGN": "en_NG",
            "NIO": "es_NI",
            "NOK": "nn_NO",
            "NPR": "ne_NP",
            "NZD": "en_PN",
            "OMR": "ar_OM",
            "PAB": "es_PA",
            "PEN": "es_PE",
            "PGK": "en_PG",
            "PHP": "ceb_PH",
            "PKR": "en_PK",
            "PLN": "pl_PL",
            "PYG": "gn_PY",
            "QAR": "ar_QA",
            "RON": "ro_RO",
            "RSD": "sr-Latn_RS",
            "RUB": "ru_RU",
            "RWF": "rw_RW",
            "SAR": "ar_SA",
            "SBD": "en_SB",
            "SCR": "fr_SC",
            "SDG": "en_SD",
            "SEK": "en_SE",
            "SGD": "ta_SG",
            "SHP": "en_SH",
            "SLL": "en_SL",
            "SOS": "so_SO",
            "SRD": "nl_SR",
            "SSP": "nus_SS",
            "STN": "pt_ST",
            "SYP": "ar_SY",
            "SZL": "en_SZ",
            "THB": "th_TH",
            "TJS": "tg_TJ",
            "TMT": "tk_TM",
            "TND": "ar_TN",
            "TOP": "to_TO",
            "TRY": "tr_TR",
            "TTD": "en_TT",
            "TWD": "zh_TW",
            "TZS": "rwk_TZ",
            "UAH": "ru_UA",
            "UGX": "cgg_UG",
            "USD": "es_US",
            "UYU": "es_UY",
            "UZS": "uz-Cyrl_UZ",
            "VND": "vi_VN",
            "VUV": "en_VU",
            "WST": "en_WS",
            "XAF": "en_CM",
            "XCD": "en_AG",
            "XOF": "ee_TG",
            "XPF": "fr_PF",
            "YER": "ar_YE",
            "ZAR": "en_ZA",
            "ZMW": "en_ZM"
        ]
    }()
}
