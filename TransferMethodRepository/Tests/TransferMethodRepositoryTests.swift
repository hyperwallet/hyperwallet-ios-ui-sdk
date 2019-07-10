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

import Hippolyte
import HyperwalletSDK
@testable import TransferMethodRepository
import XCTest

//swiftlint:disable force_cast
class RemoteTransferMethodRepositoryTests: XCTestCase {
    override func setUp() {
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
    }

    override func tearDown() {
        if Hippolyte.shared.isStarted {
            Hippolyte.shared.stop()
        }
    }

    func testCreate_bankAccount() {
        let expectation = self.expectation(description: "Create bank account completed")
        let transferMethodRepository = TransferMethodRepositoryFactory.shared.transferMethodRepository()
        var bankAccountResult: HyperwalletTransferMethod?
        var bankAccountError: HyperwalletErrorType?

        setupOkResponseMockServer(endpoint: "/bank-accounts", responseDataFile: "BankAccountIndividualResponse")

        let bankAccount = HyperwalletBankAccount
            .Builder(transferMethodCountry: "US",
                     transferMethodCurrency: "USD",
                     transferMethodProfileType: "INDIVIDUAL",
                     transferMethodType: "BANK_ACCOUNT")
            .bankName("US BANK NA")
            .bankAccountId("7861012347")
            .build()

        transferMethodRepository.create(bankAccount) { result in
            switch result {
            case .failure(let error):
                bankAccountError = error

            case .success(let createResult):
                bankAccountResult = createResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        XCTAssertNil(bankAccountError)
        XCTAssertNotNil(bankAccountResult)
        XCTAssertEqual(bankAccountResult?.getField(fieldName: .bankName)! as! String, "US BANK NA")
        XCTAssertEqual(bankAccountResult?.getField(fieldName: .bankAccountId)! as! String, "7861012347")
    }

    func testCreate_bankCard() {
        let expectation = self.expectation(description: "Create bank card completed")
        let transferMethodRepository = TransferMethodRepositoryFactory.shared.transferMethodRepository()
        var bankCardResult: HyperwalletTransferMethod?
        var bankCardError: HyperwalletErrorType?

        setupOkResponseMockServer(endpoint: "/bank-cards", responseDataFile: "BankCardResponse")

        let bankCard = HyperwalletBankCard
            .Builder(transferMethodCountry: "US",
                     transferMethodCurrency: "USD",
                     transferMethodProfileType: "INDIVIDUAL")
            .cardNumber("0000000000000114")
            .dateOfExpiry("2022-12")
            .build()

        transferMethodRepository.create(bankCard) { result in
            switch result {
            case .failure(let error):
                bankCardError = error

            case .success(let createResult):
                bankCardResult = createResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1000)

        XCTAssertNil(bankCardError)
        XCTAssertNotNil(bankCardResult)
        XCTAssertEqual(bankCardResult?.getField(fieldName: .cardNumber)! as! String, "************0114")
        XCTAssertEqual(bankCardResult?.getField(fieldName: .dateOfExpiry)! as! String, "2022-12")
    }

    func testCreate_payPalAccount() {
        let expectation = self.expectation(description: "Create PayPal account completed")
        let transferMethodRepository = TransferMethodRepositoryFactory.shared.transferMethodRepository()
        var payPalAccountResult: HyperwalletTransferMethod?
        var payPalAccountError: HyperwalletErrorType?

        setupOkResponseMockServer(endpoint: "/paypal-accounts", responseDataFile: "PayPalAccountResponse")

        let payPalAccount = HyperwalletPayPalAccount
            .Builder(transferMethodCountry: "US",
                     transferMethodCurrency: "USD",
                     transferMethodProfileType: "INDIVIDUAL")
            .email("carroll.lynn@byteme.com")
            .build()

        transferMethodRepository.create(payPalAccount) { result in
            switch result {
            case .failure(let error):
                payPalAccountError = error

            case .success(let createResult):
                payPalAccountResult = createResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1000)

        XCTAssertNil(payPalAccountError)
        XCTAssertNotNil(payPalAccountResult)
        XCTAssertEqual(payPalAccountResult?.getField(fieldName: .email)! as! String, "carroll.lynn@byteme.com")
    }

    func testCreate_wireAccount() {
        let expectation = self.expectation(description: "Create bank account completed")
        let transferMethodRepository = TransferMethodRepositoryFactory.shared.transferMethodRepository()
        var wireAccountResult: HyperwalletTransferMethod?
        var wireAccountError: HyperwalletErrorType?

        setupOkResponseMockServer(endpoint: "/bank-accounts", responseDataFile: "WireAccountIndividualResponse")

        let wireAccount = HyperwalletBankAccount
            .Builder(transferMethodCountry: "US",
                     transferMethodCurrency: "USD",
                     transferMethodProfileType: "INDIVIDUAL",
                     transferMethodType: "WIRE_ACCOUNT")
            .intermediaryBankAccountId("246810")
            .intermediaryBankId("12345678901")
            .build()

        transferMethodRepository.create(wireAccount) { result in
            switch result {
            case .failure(let error):
                wireAccountError = error

            case .success(let createResult):
                wireAccountResult = createResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        XCTAssertNil(wireAccountError)
        XCTAssertNotNil(wireAccountResult)
        XCTAssertEqual(wireAccountResult?.getField(fieldName: .intermediaryBankAccountId)! as! String, "246810")
        XCTAssertEqual(wireAccountResult?.getField(fieldName: .intermediaryBankId)! as! String, "12345678901")
    }

    func testCreate_failure() {
        let expectation = self.expectation(description: "Create bank account completed")
        let transferMethodRepository = TransferMethodRepositoryFactory.shared.transferMethodRepository()
        var bankAccountResult: HyperwalletTransferMethod?
        var bankAccountError: HyperwalletErrorType?

        setupBadResponseMockServer(endpoint: "/bank-accounts",
                                   responseDataFile: "BankAccountErrorResponseWithMissingFieldAndValidationError")

        let bankAccount = HyperwalletBankAccount
            .Builder(transferMethodCountry: "US",
                     transferMethodCurrency: "USD",
                     transferMethodProfileType: "INDIVIDUAL",
                     transferMethodType: "BANK_ACCOUNT")
            .build()

        transferMethodRepository.create(bankAccount) { result in
            switch result {
            case .failure(let error):
                bankAccountError = error

            case .success(let createResult):
                bankAccountResult = createResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        XCTAssertNil(bankAccountResult)
        XCTAssertNotNil(bankAccountError)
        XCTAssertGreaterThan(bankAccountError!.getHyperwalletErrors()!.errorList!.count, 0)
    }

    func testDeactivate_bankAccount() {
    }

    func testDeactivate_bankCard() {
    }

    func testDeactivate_bankCardWithError() {
    }

    func testDeactivate_payPalAccount() {
    }

    func testDeactivate_failure() {
    }

    func testList_returnsBankAccount() {
    }

    func testList_returnsNoAccounts() {
    }

    private func setupOkResponseMockServer(endpoint: String, responseDataFile: String ) {
        let url = String(format: "%@%@", HyperwalletTestHelper.userRestURL, endpoint) //
        let response = HyperwalletTestHelper.okHTTPResponse(for: responseDataFile)
        let request = HyperwalletTestHelper.buildPostRequest(baseUrl: url, response)
        HyperwalletTestHelper.setUpMockServer(request: request)
    }

    private func setupBadResponseMockServer(endpoint: String, responseDataFile: String ) {
        let url = String(format: "%@%@", HyperwalletTestHelper.userRestURL, endpoint) //
        let response = HyperwalletTestHelper.badRequestHTTPResponse(for: responseDataFile)
        let request = HyperwalletTestHelper.buildPostRequest(baseUrl: url, response)
        HyperwalletTestHelper.setUpMockServer(request: request)
    }
}
