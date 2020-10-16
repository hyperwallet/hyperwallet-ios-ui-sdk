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
import HyperwalletSDK
import XCTest

class HyperwalletTransferMethodTests: XCTestCase {
    let country = "US"
    let currency = "USD"
    let profileType = "INDIVIDUAL"

    func testAdditionalInfo_bankCard() {
        let transferMethod = HyperwalletBankCard.Builder(transferMethodCountry: country,
                                                         transferMethodCurrency: currency,
                                                         transferMethodProfileType: profileType)
            .cardNumber("1111111100001234")
            .build()

        XCTAssertEqual(transferMethod.additionalInfo!, "ending in 1234")
    }

    func testAdditionalInfo_prepaidCard() {
        let transferMethod = HyperwalletPrepaidCard.Builder(transferMethodProfileType: profileType)
            .build()

        transferMethod.setField(key: HyperwalletTransferMethod.TransferMethodField.cardBrand.rawValue, value: "VISA")
        transferMethod.setField(key: HyperwalletTransferMethod.TransferMethodField.cardNumber.rawValue,
                                value: "1111111100006789")
        XCTAssertEqual(transferMethod.isPrepaidCard(), true)
        XCTAssertEqual(transferMethod.additionalInfo!, "Visa \u{2022}\u{2022}\u{2022}\u{2022} 6789")
    }

    func testAdditionalInfo_payPalAccount() {
        let transferMethod = HyperwalletPayPalAccount.Builder(transferMethodCountry: country,
                                                              transferMethodCurrency: currency,
                                                              transferMethodProfileType: profileType)
            .email("email@domain.com")
            .build()

        XCTAssertEqual(transferMethod.additionalInfo!, "to email@domain.com")
    }

    func testAdditionalInfo_bankAccount() {
        let transferMethod = HyperwalletBankAccount.Builder(transferMethodCountry: country,
                                                            transferMethodCurrency: currency,
                                                            transferMethodProfileType: profileType,
                                                            transferMethodType:
            HyperwalletTransferMethod.TransferMethodType.bankAccount.rawValue)
            .bankAccountId("0001233")
            .build()

        XCTAssertEqual(transferMethod.additionalInfo!, "ending in 1233")
    }

    func testAdditionalInfo_venmoAccount() {
        let transferMethod = HyperwalletVenmoAccount.Builder(transferMethodCountry: country,
                                                             transferMethodCurrency: currency,
                                                             transferMethodProfileType: profileType)
            .accountId("9876543210")
            .build()

        XCTAssertEqual(transferMethod.additionalInfo!, "ending in 3210")
    }
}
