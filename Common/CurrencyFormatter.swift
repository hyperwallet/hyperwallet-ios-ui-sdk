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

@testable import Common
import XCTest

// swiftlint:disable function_body_length
class CurrencyFormatterTests: XCTestCase {
    func testFormatStringAmount() {
        let cases = [
            ("Albania Currency", "1000000", "ALL", "1 000 000,00"),
            ("Argentina Currency", "1000000", "ARS", "1.000.000,00"),
            ("Armenia Currency", "1000000", "AMD", "1 000 000,00"),
            ("Australia Currency", "1000000", "AUD", "1,000,000.00"),
            ("Bangladesh Currency", "1000000", "BDT", "10,00,000.00"),
            ("Brazil Currency", "1000000", "BRL", "1.000.000,00"),
            ("Bulgaria Currency", "1000000", "BGN", "1000000,00"),
            ("Cambodia Currency", "1000000", "KHR", "1.000.000,00"),
            ("Canada Currency", "1000000", "CAD", "1,000,000.00"),
            ("Chile Currency", "1000000", "CLP", "1.000.000"),
            ("China Currency", "1000000", "CNY", "1,000,000.00"),
            ("Colombia Currency", "1000000", "COP", "1.000.000,00"),
            ("Croatia Currency", "1000000", "HRK", "1.000.000,00"),
            ("Czech Republic Currency", "1000000", "CZK", "1 000 000,00"),
            ("Denmark Currency", "1000000", "DKK", "1.000.000,00"),
            ("Egypt Currency", "1000000", "EGP", "1,000,000.00"),
            ("Austria Currency", "1000000", "EUR", "1.000.000,00"),
            ("Hong Kong Currency", "1000000", "HKD", "1,000,000.00"),
            ("Hungary Currency", "1000000", "HUF", "1 000 000,00"),
            ("India Currency", "1000000", "INR", "10,00,000.00"),
            ("Indonesia Currency", "1000000", "IDR", "1.000.000"),
            ("Jamaica Currency", "1000000", "JMD", "1,000,000.00"),
            ("Japan Currency", "1000000", "JPY", "1,000,000"),
            ("Jordan Currency", "1000000", "JOD", "1,000,000.00"),
            ("Kazakhstan Currency", "1000000", "KZT", "1 000 000,00"),
            ("Kenya Currency", "1000000", "KES", "1,000,000.00"),
            ("Laos Currency", "1000000", "LAK", "1.000.000,00"),
            ("Malaysia Currency", "1000000", "MYR", "1,000,000.00"),
            ("Mexico Currency", "1000000", "MXN", "1,000,000.00"),
            ("Morocco Currency", "1000000", "MAD", "1 000 000,00"),
            ("Israel Currency", "1000000", "ILS", "‏1,000,000.00"),
            ("Taiwan Currency", "1000000", "TWD", "1,000,000"),
            ("Turkey Currency", "1000000", "TRY", "1.000.000,00"),
            ("New Zealand Currency", "1000000", "NZD", "1,000,000.00"),
            ("Nigeria Currency", "1000000", "NGN", "1,000,000.00"),
            ("Norway Currency", "1000000", "NOK", "1 000 000,00"),
            ("Pakistan Currency", "1000000", "PKR", "1,000,000.00"),
            ("Peru Currency", "1000000", "PEN", "1,000,000.00"),
            ("Philippines Currency", "1000000", "PHP", "1,000,000.00"),
            ("Poland Currency", "1000000", "PLN", "1 000 000,00"),
            ("Isle of Man Currency", "1000000", "GBP", "1,000,000.00"),
            ("Romania Currency", "1000000", "RON", "1.000.000,00"),
            ("Russia Currency", "1000000", "RUB", "1 000 000,00"),
            ("Serbia Currency", "1000000", "RSD", "1.000.000,00"),
            ("Singapore Currency", "1000000", "SGD", "1,000,000.00"),
            ("South Africa Currency", "1000000", "ZAR", "1 000 000,00"),
            ("South Korea Currency", "1000000", "KRW", "1,000,000"),
            ("Sri Lanka Currency", "1000000", "LKR", "10,00,000.00"),
            ("Sweden Currency", "1000000", "SEK", "1 000 000,00"),
            ("Switzerland Currency", "1000000", "CHF", "1'000'000.00"),
            ("Thailand Currency", "1000000", "THB", "1,000,000.00"),
            ("Tunisia Currency", "1000000", "TND", "1.000.000,000"),
            ("United Arab Emirates Currency", "1000000", "AED", "1,000,000.00"),
            ("Uganda Currency", "1000000", "UGX", "1,000,000"),
            ("United States Currency", "1000000", "USD", "1,000,000.00"),
            ("Vietnam Currency", "1000000", "VND", "1.000.000,00")
        ]
        cases.forEach {
            let expected = $3.replacingOccurrences(of: "\u{200F}",
                                                   with: "",
                                                   options: NSString.CompareOptions.literal,
                                                   range: nil)
            XCTAssertEqual(CurrencyFormatter.formatStringAmount($1, with: $2),
                           expected,
                           "\($0) \($2) test case - currency should be equal to \($3)")
        }
    }

    func testFormatDoubleAmount() {
        let cases = [
            ("Albania Currency", "1000000", "ALL", "1 000 000,00"),
            ("Argentina Currency", "1000000", "ARS", "1.000.000,00"),
            ("Armenia Currency", "1000000", "AMD", "1 000 000,00"),
            ("Australia Currency", "1000000", "AUD", "1,000,000.00"),
            ("Bangladesh Currency", "1000000", "BDT", "10,00,000.00"),
            ("Brazil Currency", "1000000", "BRL", "1.000.000,00"),
            ("Bulgaria Currency", "1000000", "BGN", "1000000,00"),
            ("Cambodia Currency", "1000000", "KHR", "1.000.000,00"),
            ("Canada Currency", "1000000", "CAD", "1,000,000.00"),
            ("Chile Currency", "1000000", "CLP", "1.000.000"),
            ("China Currency", "1000000", "CNY", "1,000,000.00"),
            ("Colombia Currency", "1000000", "COP", "1.000.000,00"),
            ("Croatia Currency", "1000000", "HRK", "1.000.000,00"),
            ("Czech Republic Currency", "1000000", "CZK", "1 000 000,00"),
            ("Denmark Currency", "1000000", "DKK", "1.000.000,00"),
            ("Egypt Currency", "1000000", "EGP", "1,000,000.00"),
            ("Austria Currency", "1000000", "EUR", "1.000.000,00"),
            ("Hong Kong Currency", "1000000", "HKD", "1,000,000.00"),
            ("Hungary Currency", "1000000", "HUF", "1 000 000,00"),
            ("India Currency", "1000000", "INR", "10,00,000.00"),
            ("Indonesia Currency", "1000000", "IDR", "1.000.000"),
            ("Jamaica Currency", "1000000", "JMD", "1,000,000.00"),
            ("Japan Currency", "1000000", "JPY", "1,000,000"),
            ("Jordan Currency", "1000000", "JOD", "1,000,000.00"),
            ("Kazakhstan Currency", "1000000", "KZT", "1 000 000,00"),
            ("Kenya Currency", "1000000", "KES", "1,000,000.00"),
            ("Laos Currency", "1000000", "LAK", "1.000.000,00"),
            ("Malaysia Currency", "1000000", "MYR", "1,000,000.00"),
            ("Mexico Currency", "1000000", "MXN", "1,000,000.00"),
            ("Morocco Currency", "1000000", "MAD", "1 000 000,00"),
            ("Israel Currency", "1000000", "ILS", "‏1,000,000.00"),
            ("Taiwan Currency", "1000000", "TWD", "1,000,000"),
            ("Turkey Currency", "1000000", "TRY", "1.000.000,00"),
            ("New Zealand Currency", "1000000", "NZD", "1,000,000.00"),
            ("Nigeria Currency", "1000000", "NGN", "1,000,000.00"),
            ("Norway Currency", "1000000", "NOK", "1 000 000,00"),
            ("Pakistan Currency", "1000000", "PKR", "1,000,000.00"),
            ("Peru Currency", "1000000", "PEN", "1,000,000.00"),
            ("Philippines Currency", "1000000", "PHP", "1,000,000.00"),
            ("Poland Currency", "1000000", "PLN", "1 000 000,00"),
            ("Isle of Man Currency", "1000000", "GBP", "1,000,000.00"),
            ("Romania Currency", "1000000", "RON", "1.000.000,00"),
            ("Russia Currency", "1000000", "RUB", "1 000 000,00"),
            ("Serbia Currency", "1000000", "RSD", "1.000.000,00"),
            ("Singapore Currency", "1000000", "SGD", "1,000,000.00"),
            ("South Africa Currency", "1000000", "ZAR", "1 000 000,00"),
            ("South Korea Currency", "1000000", "KRW", "1,000,000"),
            ("Sri Lanka Currency", "1000000", "LKR", "10,00,000.00"),
            ("Sweden Currency", "1000000", "SEK", "1 000 000,00"),
            ("Switzerland Currency", "1000000", "CHF", "1'000'000.00"),
            ("Thailand Currency", "1000000", "THB", "1,000,000.00"),
            ("Tunisia Currency", "1000000", "TND", "1.000.000,000"),
            ("United Arab Emirates Currency", "1000000", "AED", "1,000,000.00"),
            ("Uganda Currency", "1000000", "UGX", "1,000,000"),
            ("United States Currency", "1000000", "USD", "1,000,000.00"),
            ("Vietnam Currency", "1000000", "VND", "1.000.000,00")
        ]
        cases.forEach {
            let expected = $3.replacingOccurrences(of: "\u{200F}",
                                                   with: "",
                                                   options: NSString.CompareOptions.literal,
                                                   range: nil)
            let doubleAmount = NSString(string: $1).doubleValue
            XCTAssertEqual(CurrencyFormatter.formatDoubleAmount(doubleAmount, with: $2),
                           expected,
                           "\($0) test case - currency should be equal to \($3)")
        }
    }

    func testGetDecimalAmount() {
        let cases = [
            ("Albania Currency", "1000000", "ALL", 10000.0),
            ("Argentina Currency", "1000000", "ARS", 10000.0),
            ("Armenia Currency", "1000000", "AMD", 10000.0),
            ("Australia Currency", "1000000", "AUD", 10000.0),
            ("Bangladesh Currency", "1000000", "BDT", 10000.0),
            ("Brazil Currency", "1000000", "BRL", 10000.0),
            ("Bulgaria Currency", "1000000", "BGN", 10000.0),
            ("Cambodia Currency", "1000000", "KHR", 10000.0),
            ("Canada Currency", "1000000", "CAD", 10000.0),
            ("Chile Currency", "1000000", "CLP", 1000000.0),
            ("China Currency", "1000000", "CNY", 10000.0),
            ("Colombia Currency", "1000000", "COP", 10000.0),
            ("Croatia Currency", "1000000", "HRK", 10000.0),
            ("Czech Republic Currency", "1000000", "CZK", 10000.0),
            ("Denmark Currency", "1000000", "DKK", 10000.0),
            ("Egypt Currency", "1000000", "EGP", 10000.0),
            ("Austria Currency", "1000000", "EUR", 10000.0),
            ("Hong Kong Currency", "1000000", "HKD", 10000.0),
            ("Hungary Currency", "1000000", "HUF", 10000.0),
            ("India Currency", "1000000", "INR", 10000.0),
            ("Indonesia Currency", "1000000", "IDR", 1000000.0),
            ("Jamaica Currency", "1000000", "JMD", 10000.0),
            ("Japan Currency", "1000000", "JPY", 1000000.0),
            ("Jordan Currency", "1000000", "JOD", 10000.0),
            ("Kazakhstan Currency", "1000000", "KZT", 10000.0),
            ("Kenya Currency", "1000000", "KES", 10000.0),
            ("Laos Currency", "1000000", "LAK", 10000.0),
            ("Malaysia Currency", "1000000", "MYR", 10000.0),
            ("Mexico Currency", "1000000", "MXN", 10000.0),
            ("Morocco Currency", "1000000", "MAD", 10000.0),
            ("Israel Currency", "1000000", "ILS", 10000.0),
            ("Taiwan Currency", "1000000", "TWD", 1000000.0),
            ("Turkey Currency", "1000000", "TRY", 10000.0),
            ("New Zealand Currency", "1000000", "NZD", 10000.0),
            ("Nigeria Currency", "1000000", "NGN", 10000.0),
            ("Norway Currency", "1000000", "NOK", 10000.0),
            ("Pakistan Currency", "1000000", "PKR", 10000.0),
            ("Peru Currency", "1000000", "PEN", 10000.0),
            ("Philippines Currency", "1000000", "PHP", 10000.0),
            ("Poland Currency", "1000000", "PLN", 10000.0),
            ("Isle of Man Currency", "1000000", "GBP", 10000.0),
            ("Romania Currency", "1000000", "RON", 10000.0),
            ("Russia Currency", "1000000", "RUB", 10000.0),
            ("Serbia Currency", "1000000", "RSD", 10000.0),
            ("Singapore Currency", "1000000", "SGD", 10000.0),
            ("South Africa Currency", "1000000", "ZAR", 10000.0),
            ("South Korea Currency", "1000000", "KRW", 1000000.0),
            ("Sri Lanka Currency", "1000000", "LKR", 10000.0),
            ("Sweden Currency", "1000000", "SEK", 10000.0),
            ("Switzerland Currency", "1000000", "CHF", 10000.0),
            ("Thailand Currency", "1000000", "THB", 10000.0),
            ("Tunisia Currency", "1000000", "TND", 1000.0),
            ("United Arab Emirates Currency", "1000000", "AED", 10000.0),
            ("Uganda Currency", "1000000", "UGX", 1000000.0),
            ("United States Currency", "1000000", "USD", 10000.0),
            ("Vietnam Currency", "1000000", "VND", 10000.0)
        ]
        cases.forEach {
            XCTAssertEqual(CurrencyFormatter.getDecimalAmount(amount: $1, currencyCode: $2),
                           $3,
                           "\($0) test case - currency should be equal to \($3)")
        }
    }
}
// swiftlint:enable function_body_length
