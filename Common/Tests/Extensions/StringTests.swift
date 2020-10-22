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

import XCTest

@testable import Common
class StringTests: XCTestCase {
    //swiftlint:disable function_body_length
//    func testFormatToCurrency() {
//        let cases = [
//                     ("Albania Currency", "1000000", "ALL", "ALL 1,000,000"),
//                     ("Argentina Currency", "1000000", "ARS", "$1,000,000.00"),
//                     ("Armenia Currency", "1000000", "AMD", "֏1,000,000.00"),
//                     ("Australia Currency", "1000000", "AUD", "$1,000,000.00"),
//                     ("Bangladesh Currency", "1000000", "BDT", "৳1,000,000.00"),
//                     ("Brazil Currency", "1000000", "BRL", "R$1,000,000.00"),
//                     ("Bulgaria Currency", "1000000", "BGN", "лв. 1,000,000.00"),
//                     ("Cambodia Currency", "1000000", "KHR", "៛1,000,000.00"),
//                     ("Canada Currency", "1000000", "CAD", "$1,000,000.00"),
//                     ("Chile Currency", "1000000", "CLP", "$1,000,000"),
//                     ("China Currency", "1000000", "CNY", "¥1,000,000.00"),
//                     ("Colombia Currency", "1000000", "COP", "$1,000,000"),
//                     ("Croatia Currency", "1000000", "HRK", "HRK 1,000,000.00"),
//                     ("Czech Republic Currency", "1000000", "CZK", "Kč 1,000,000.00"),
//                     ("Denmark Currency", "1000000", "DKK", "kr. 1,000,000.00"),
//                     ("Egypt Currency", "1000000", "EGP", "ج.م.‏ 1,000,000.00"),
//                     ("Austria Currency", "1000000", "EUR", "€1,000,000.00"),
//                     ("Hong Kong Currency", "1000000", "HKD", "HK$1,000,000.00"),
//                     ("Hungary Currency", "1000000", "HUF", "Ft 1,000,000.00"),
//                     ("India Currency", "1000000", "INR", "₹1,000,000.00"),
//                     ("Indonesia Currency", "1000000", "IDR", "Rp 1,000,000"),
//                     ("Jamaica Currency", "1000000", "JMD", "$1,000,000.00"),
//                     ("Japan Currency", "1000000", "JPY", "¥1,000,000"),
//                     ("Jordan Currency", "1000000", "JOD", "د.أ.‏ 1,000,000.000"),
//                     ("Kazakhstan Currency", "1000000", "KZT", "₸1,000,000.00"),
//                     ("Kenya Currency", "1000000", "KES", "Ksh 1,000,000.00"),
//                     ("Laos Currency", "1000000", "LAK", "₭1,000,000"),
//                     ("Malaysia Currency", "1000000", "MYR", "RM 1,000,000.00"),
//                     ("Mexico Currency", "1000000", "MXN", "$1,000,000.00"),
//                     ("Morocco Currency", "1000000", "MAD", "MAD 1,000,000.00"),
//                     ("Israel Currency", "1000000", "ILS", "₪1,000,000.00"),
//                     ("Taiwan Currency", "1000000", "TWD", "$1,000,000.00"),
//                     ("Turkey Currency", "1000000", "TRY", "₺1,000,000.00"),
//                     ("New Zealand Currency", "1000000", "NZD", "$1,000,000.00"),
//                     ("Nigeria Currency", "1000000", "NGN", "₦1,000,000.00"),
//                     ("Norway Currency", "1000000", "NOK", "kr 1,000,000.00"),
//                     ("Pakistan Currency", "1000000", "PKR", "Rs 1,000,000"),
//                     ("Peru Currency", "1000000", "PEN", "S/ 1,000,000.00"),
//                     ("Philippines Currency", "1000000", "PHP", "₱1,000,000.00"),
//                     ("Poland Currency", "1000000", "PLN", "zł 1,000,000.00"),
//                     ("Isle of Man Currency", "1000000", "GBP", "£1,000,000.00"),
//                     ("Romania Currency", "1000000", "RON", "RON 1,000,000.00"),
//                     ("Russia Currency", "1000000", "RUB", "₽1,000,000.00"),
//                     ("Serbia Currency", "1000000", "RSD", "RSD 1,000,000"),
//                     ("Singapore Currency", "1000000", "SGD", "$1,000,000.00"),
//                     ("South Africa Currency", "1000000", "ZAR", "R 1,000,000.00"),
//                     ("South Korea Currency", "1000000", "KRW", "₩1,000,000"),
//                     ("Sri Lanka Currency", "1000000", "LKR", "Rs. 1,000,000.00"),
//                     ("Sweden Currency", "1000000", "SEK", "kr 1,000,000.00"),
//                     ("Switzerland Currency", "1000000", "CHF", "CHF 1,000,000.00"),
//                     ("Thailand Currency", "1000000", "THB", "฿1,000,000.00"),
//                     ("Tunisia Currency", "1000000", "TND", "د.ت.‏ 1,000,000.000"),
//                     ("United Arab Emirates Currency", "1000000", "AED", "د.إ.‏ 1,000,000.00"),
//                     ("Uganda Currency", "1000000", "UGX", "USh 1,000,000"),
//                     ("United States Currency", "1000000", "USD", "$1,000,000.00"),
//                     ("Vietnam Currency", "1000000", "VND", "₫1,000,000")
//        ]
//        cases.forEach {
//            XCTAssertEqual($1.formatCurrencyAmount(with: $2), $3, "\($0) test case - currency should be equal to \($3)")
//        }
//    }

    func testFormatCurrencyAmount() {
        let cases = [
                     ("Albania Currency", "1000000", "ALL", "ALL 1,000,000"),
                     ("Argentina Currency", "1000000", "ARS", "ARS 1,000,000.00"),
                     ("Armenia Currency", "1000000", "AMD", "AMD 1,000,000.00"),
                     ("Australia Currency", "1000000", "AUD", "A$1,000,000.00"),
                     ("Bangladesh Currency", "1000000", "BDT", "BDT 1,000,000.00"),
                     ("Brazil Currency", "1000000", "BRL", "R$1,000,000.00"),
                     ("Bulgaria Currency", "1000000", "BGN", "BGN 1,000,000.00"),
                     ("Cambodia Currency", "1000000", "KHR", "KHR 1,000,000.00"),
                     ("Canada Currency", "1000000", "CAD", "CA$1,000,000.00"),
                     ("Chile Currency", "1000000", "CLP", "CLP 1,000,000"),
                     ("China Currency", "1000000", "CNY", "CN¥1,000,000.00"),
                     ("Colombia Currency", "1000000", "COP", "COP 1,000,000"),
                     ("Croatia Currency", "1000000", "HRK", "HRK 1,000,000.00"),
                     ("Czech Republic Currency", "1000000", "CZK", "CZK 1,000,000.00"),
                     ("Denmark Currency", "1000000", "DKK", "DKK 1,000,000.00"),
                     ("Egypt Currency", "1000000", "EGP", "EGP 1,000,000.00"),
                     ("Austria Currency", "1000000", "EUR", "€1,000,000.00"),
                     ("Hong Kong Currency", "1000000", "HKD", "HK$1,000,000.00"),
                     ("Hungary Currency", "1000000", "HUF", "HUF 1,000,000.00"),
                     ("India Currency", "1000000", "INR", "₹1,000,000.00"),
                     ("Indonesia Currency", "1000000", "IDR", "IDR 1,000,000"),
                     ("Jamaica Currency", "1000000", "JMD", "JMD 1,000,000.00"),
                     ("Japan Currency", "1000000", "JPY", "¥1,000,000"),
                     ("Jordan Currency", "1000000", "JOD", "JOD 1,000,000.000"),
                     ("Kazakhstan Currency", "1000000", "KZT", "KZT 1,000,000.00"),
                     ("Kenya Currency", "1000000", "KES", "KES 1,000,000.00"),
                     ("Laos Currency", "1000000", "LAK", "LAK 1,000,000"),
                     ("Malaysia Currency", "1000000", "MYR", "MYR 1,000,000.00"),
                     ("Mexico Currency", "1000000", "MXN", "MX$1,000,000.00"),
                     ("Morocco Currency", "1000000", "MAD", "MAD 1,000,000.00"),
                     ("Israel Currency", "1000000", "ILS", "₪1,000,000.00"),
                     ("Taiwan Currency", "1000000", "TWD", "NT$1,000,000.00"),
                     ("Turkey Currency", "1000000", "TRY", "TRY 1,000,000.00"),
                     ("New Zealand Currency", "1000000", "NZD", "NZ$1,000,000.00"),
                     ("Nigeria Currency", "1000000", "NGN", "NGN 1,000,000.00"),
                     ("Norway Currency", "1000000", "NOK", "NOK 1,000,000.00"),
                     ("Pakistan Currency", "1000000", "PKR", "PKR 1,000,000"),
                     ("Peru Currency", "1000000", "PEN", "PEN 1,000,000.00"),
                     ("Philippines Currency", "1000000", "PHP", "PHP 1,000,000.00"),
                     ("Poland Currency", "1000000", "PLN", "PLN 1,000,000.00"),
                     ("Isle of Man Currency", "1000000", "GBP", "£1,000,000.00"),
                     ("Romania Currency", "1000000", "RON", "RON 1,000,000.00"),
                     ("Russia Currency", "1000000", "RUB", "RUB 1,000,000.00"),
                     ("Serbia Currency", "1000000", "RSD", "RSD 1,000,000"),
                     ("Singapore Currency", "1000000", "SGD", "SGD 1,000,000.00"),
                     ("South Africa Currency", "1000000", "ZAR", "ZAR 1,000,000.00"),
                     ("South Korea Currency", "1000000", "KRW", "₩1,000,000"),
                     ("Sri Lanka Currency", "1000000", "LKR", "LKR 1,000,000.00"),
                     ("Sweden Currency", "1000000", "SEK", "SEK 1,000,000.00"),
                     ("Switzerland Currency", "1000000", "CHF", "CHF 1,000,000.00"),
                     ("Thailand Currency", "1000000", "THB", "THB 1,000,000.00"),
                     ("Tunisia Currency", "1000000", "TND", "TND 1,000,000.000"),
                     ("United Arab Emirates Currency", "1000000", "AED", "AED 1,000,000.00"),
                     ("Uganda Currency", "1000000", "UGX", "UGX 1,000,000"),
                     ("United States Currency", "1000000", "USD", "$1,000,000.00"),
                     ("Vietnam Currency", "1000000", "VND", "₫1,000,000")
        ]
        cases.forEach {
            XCTAssertEqual($1.formatCurrencyAmount(with: $2), $3, "\($0) test case - currency should be equal to \($3)")
        }
    }
}
