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

class TransferMethodRepositoryTests: XCTestCase {
    private var transferMethodRepository: TransferMethodRepository!

    override func setUp() {
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        transferMethodRepository = TransferMethodRepositoryFactory.shared.transferMethodRepository()
    }

    override func tearDown() {
        transferMethodRepository.refreshTransferMethods()
        if Hippolyte.shared.isStarted {
            Hippolyte.shared.stop()
        }
    }

    func testCreateTransferMethod_bankAccount() {
        let expectation = self.expectation(description: "Create bank account completed")
        var bankAccountResult: HyperwalletTransferMethod?
        var bankAccountError: HyperwalletErrorType?

        setupOkResponseMockServer(endpoint: "/bank-accounts", responseDataFile: "BankAccountIndividualResponse")

        let bankAccount = HyperwalletBankAccount
            .Builder(transferMethodCountry: "US",
                     transferMethodCurrency: "USD",
                     transferMethodProfileType: "INDIVIDUAL",
                     transferMethodType: HyperwalletTransferMethod.TransferMethodType.bankAccount.rawValue)
            .bankName("US BANK NA")
            .bankAccountId("7861012347")
            .build()

        transferMethodRepository.createTransferMethod(bankAccount) { result in
            switch result {
            case .failure(let error):
                bankAccountError = error

            case .success(let createResult):
                bankAccountResult = createResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        XCTAssertNil(bankAccountError, "The bankAccountError should be nil")
        XCTAssertNotNil(bankAccountResult, "The bankAccountResult should not be nil")
        XCTAssertEqual(bankAccountResult?
            .getField(HyperwalletTransferMethod.TransferMethodField.bankName.rawValue)!,
                       "US BANK NA",
                       "The bankName should be US BANK NA")
        XCTAssertEqual(bankAccountResult?
            .getField(HyperwalletTransferMethod.TransferMethodField.bankAccountId.rawValue)!,
                       "7861012347",
                       "The bankAccountId should be 7861012347")
    }

    func testCreateTransferMethod_bankCard() {
        let expectation = self.expectation(description: "Create bank card completed")
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

        transferMethodRepository.createTransferMethod(bankCard) { result in
            switch result {
            case .failure(let error):
                bankCardError = error

            case .success(let createResult):
                bankCardResult = createResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1000)

        XCTAssertNil(bankCardError, "The bankCardError should be nil")
        XCTAssertNotNil(bankCardResult, "The bankCardResult should not be nil")
        XCTAssertEqual(bankCardResult?
            .getField(HyperwalletTransferMethod.TransferMethodField.cardNumber.rawValue)!,
                       "************0114",
                       "The cardNumber should be ************0114")
        XCTAssertEqual(bankCardResult?
            .getField(HyperwalletTransferMethod.TransferMethodField.dateOfExpiry.rawValue)!,
                       "2022-12",
                       "The dateOfExpiry should be 2022-12")
    }

    func testCreateTransferMethod_payPalAccount() {
        let expectation = self.expectation(description: "Create PayPal account completed")
        var payPalAccountResult: HyperwalletTransferMethod?
        var payPalAccountError: HyperwalletErrorType?

        setupOkResponseMockServer(endpoint: "/paypal-accounts", responseDataFile: "PayPalAccountResponse")

        let payPalAccount = HyperwalletPayPalAccount
            .Builder(transferMethodCountry: "US",
                     transferMethodCurrency: "USD",
                     transferMethodProfileType: "INDIVIDUAL")
            .email("carroll.lynn@byteme.com")
            .build()

        transferMethodRepository.createTransferMethod(payPalAccount) { result in
            switch result {
            case .failure(let error):
                payPalAccountError = error

            case .success(let createResult):
                payPalAccountResult = createResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1000)

        XCTAssertNil(payPalAccountError, "The payPalAccountError should be nil")
        XCTAssertNotNil(payPalAccountResult, "The payPalAccountError should not be nil")
        XCTAssertEqual(payPalAccountResult?
            .getField(HyperwalletTransferMethod.TransferMethodField.email.rawValue)!,
                       "carroll.lynn@byteme.com",
                       "The email should be carroll.lynn@byteme.com")
    }

    func testCreateTransferMethod_wireAccount() {
        let expectation = self.expectation(description: "Create wire account completed")
        var wireAccountResult: HyperwalletTransferMethod?
        var wireAccountError: HyperwalletErrorType?

        setupOkResponseMockServer(endpoint: "/bank-accounts", responseDataFile: "WireAccountIndividualResponse")

        let wireAccount = HyperwalletBankAccount
            .Builder(transferMethodCountry: "US",
                     transferMethodCurrency: "USD",
                     transferMethodProfileType: "INDIVIDUAL",
                     transferMethodType: HyperwalletTransferMethod.TransferMethodType.wireAccount.rawValue)
            .intermediaryBankAccountId("246810")
            .intermediaryBankId("12345678901")
            .build()

        transferMethodRepository.createTransferMethod(wireAccount) { result in
            switch result {
            case .failure(let error):
                wireAccountError = error

            case .success(let createResult):
                wireAccountResult = createResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        XCTAssertNil(wireAccountError, "The wireAccountError should be nil")
        XCTAssertNotNil(wireAccountResult, "The wireAccountResult should not be nil")
        XCTAssertEqual(wireAccountResult?
            .getField(HyperwalletTransferMethod.TransferMethodField.intermediaryBankAccountId.rawValue),
                       "246810",
                       "The intermediaryBankAccountId should be 246810")
        XCTAssertEqual(wireAccountResult?
            .getField(HyperwalletTransferMethod.TransferMethodField.intermediaryBankId.rawValue)!,
                       "12345678901",
                       "The intermediaryBankId should be 12345678901")
    }

    func testCreateTransferMethod_venmoAccount() {
        let expectation = self.expectation(description: "Create Venmo account completed")
        var venmoAccountResult: HyperwalletTransferMethod?
        var venmoAccountError: HyperwalletErrorType?

        setupOkResponseMockServer(endpoint: "/venmo-accounts", responseDataFile: "VenmoAccountResponse")

        let venmoAccount = HyperwalletVenmoAccount
            .Builder(transferMethodCountry: "US",
                     transferMethodCurrency: "USD",
                     transferMethodProfileType: "INDIVIDUAL")
            .accountId("9876543210")
            .build()

        transferMethodRepository.createTransferMethod(venmoAccount) { result in
            switch result {
            case .failure(let error):
                    venmoAccountError = error

            case .success(let createResult):
                    venmoAccountResult = createResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1000)

        XCTAssertNil(venmoAccountError, "The venmoAccountError should be nil")
        XCTAssertNotNil(venmoAccountResult, "The venmoAccountError should not be nil")
        XCTAssertEqual(venmoAccountResult?
            .getField(HyperwalletTransferMethod.TransferMethodField.accountId.rawValue)!,
                       "9876543210",
                       "The venmoAccountId should be 9876543210")
    }

    func testCreateTransferMethod_paperCheck() {
        let expectation = self.expectation(description: "Create PaperCheck account completed")
        var papercheckResult: HyperwalletTransferMethod?
        var papercheckError: HyperwalletErrorType?

        setupOkResponseMockServer(endpoint: "/paper-checks", responseDataFile: "PapercheckAccountResponse")

        let papercheckAccount = HyperwalletPaperCheck
            .Builder(transferMethodCountry: "US",
                     transferMethodCurrency: "USD",
                     transferMethodProfileType: "INDIVIDUAL",
                     transferMethodType: HyperwalletTransferMethod.TransferMethodType.paperCheck.rawValue)
            .postalCode("10030")
            .build()

        transferMethodRepository.createTransferMethod(papercheckAccount) { result in
            switch result {
            case .failure(let error):
                    papercheckError = error

            case .success(let createResult):
                    papercheckResult = createResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1000)

        XCTAssertNil(papercheckError, "The paperCheckAccountError should be nil")
        XCTAssertNotNil(papercheckResult, "The paperCheckAccountError should not be nil")
        XCTAssertEqual(papercheckResult?
            .getField(HyperwalletTransferMethod.TransferMethodField.postalCode.rawValue)!,
                       "10030",
                       "The papercheckAccountId should be 10030")
    }

    func testCreateTransferMethod_failure() {
        let expectation = self.expectation(description: "Create bank account failed")
        var bankAccountResult: HyperwalletTransferMethod?
        var bankAccountError: HyperwalletErrorType?

        setupBadResponseMockServer(endpoint: "/bank-accounts",
                                   responseDataFile: "BankAccountErrorResponseWithValidationError")

        let bankAccount = HyperwalletBankAccount
            .Builder(transferMethodCountry: "US",
                     transferMethodCurrency: "USD",
                     transferMethodProfileType: "INDIVIDUAL",
                     transferMethodType: HyperwalletTransferMethod.TransferMethodType.bankAccount.rawValue)
            .build()

        transferMethodRepository.createTransferMethod(bankAccount) { result in
            switch result {
            case .failure(let error):
                bankAccountError = error

            case .success(let createResult):
                bankAccountResult = createResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        XCTAssertNil(bankAccountResult, "The bankAccountResult should be nil")
        XCTAssertNotNil(bankAccountError, "The bankAccountError should not be nil")
        XCTAssertGreaterThan(bankAccountError!.getHyperwalletErrors()!.errorList!.count,
                             0,
                             "The bankAccountError!.getHyperwalletErrors()!.errorList!.count should be greater than 0")
    }

    func testDeactivateTransferMethod_bankAccount() {
        let expectation = self.expectation(description: "Deactivate bank account completed")
        var statusTransitionResult: HyperwalletStatusTransition?
        var statusTransitionError: HyperwalletErrorType?

        setupOkResponseMockServer(endpoint: "/bank-accounts/trm-123456789/status-transitions",
                                  responseDataFile: "StatusTransitionResponseSuccess")

        let bankAccount = HyperwalletBankAccount
            .Builder(transferMethodCountry: "US",
                     transferMethodCurrency: "USD",
                     transferMethodProfileType: "INDIVIDUAL",
                     transferMethodType: HyperwalletTransferMethod.TransferMethodType.bankAccount.rawValue)
            .build()
        bankAccount.setField(key: "token", value: "trm-123456789")

        transferMethodRepository.deactivateTransferMethod(bankAccount) { result in
            switch result {
            case .failure(let error):
                statusTransitionError = error

            case .success(let deactivateResult):
                statusTransitionResult = deactivateResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        XCTAssertNil(statusTransitionError, "The statusTransitionError should be nil")
        XCTAssertNotNil(statusTransitionResult, "The statusTransitionResult should not be nil")
        XCTAssertEqual(statusTransitionResult?.fromStatus,
                       HyperwalletStatusTransition.Status.activated,
                       "The statusTransitionResult?.fromStatus should be activated")
        XCTAssertEqual(statusTransitionResult?.toStatus,
                       HyperwalletStatusTransition.Status.deactivated,
                       "The statusTransitionResult?.toStatus should be deactivated")
    }

    func testDeactivateTransferMethod_bankCard() {
        let expectation = self.expectation(description: "Deactivate bank card completed")
        var statusTransitionResult: HyperwalletStatusTransition?
        var statusTransitionError: HyperwalletErrorType?

        setupOkResponseMockServer(endpoint: "/bank-cards/trm-123456789/status-transitions",
                                  responseDataFile: "StatusTransitionResponseSuccess")

        let bankCard = HyperwalletBankCard
            .Builder(transferMethodCountry: "US",
                     transferMethodCurrency: "USD",
                     transferMethodProfileType: "INDIVIDUAL")
            .build()
        bankCard.setField(key: "token", value: "trm-123456789")

        transferMethodRepository.deactivateTransferMethod(bankCard) { result in
            switch result {
            case .failure(let error):
                statusTransitionError = error

            case .success(let deactivateResult):
                statusTransitionResult = deactivateResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        XCTAssertNil(statusTransitionError, "The statusTransitionError should be nil")
        XCTAssertNotNil(statusTransitionResult, "The statusTransitionResult should not be nil")
        XCTAssertEqual(statusTransitionResult?.fromStatus,
                       HyperwalletStatusTransition.Status.activated,
                       "The statusTransitionResult?.fromStatus should be activated")
        XCTAssertEqual(statusTransitionResult?.toStatus,
                       HyperwalletStatusTransition.Status.deactivated,
                       "The statusTransitionResult?.toStatus should be deactivated")
    }

    func testDeactivateTransferMethod_wireAccount() {
        let expectation = self.expectation(description: "Deactivate wire account completed")
        var statusTransitionResult: HyperwalletStatusTransition?
        var statusTransitionError: HyperwalletErrorType?

        setupOkResponseMockServer(endpoint: "/bank-accounts/trm-123456789/status-transitions",
                                  responseDataFile: "StatusTransitionResponseSuccess")

        let wireAccount = HyperwalletBankAccount
            .Builder(transferMethodCountry: "US",
                     transferMethodCurrency: "USD",
                     transferMethodProfileType: "INDIVIDUAL",
                     transferMethodType: HyperwalletTransferMethod.TransferMethodType.wireAccount.rawValue)
            .build()
        wireAccount.setField(key: "token", value: "trm-123456789")

        transferMethodRepository.deactivateTransferMethod(wireAccount) { result in
            switch result {
            case .failure(let error):
                statusTransitionError = error

            case .success(let deactivateResult):
                statusTransitionResult = deactivateResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        XCTAssertNil(statusTransitionError, "The statusTransitionError should be nil")
        XCTAssertNotNil(statusTransitionResult, "The statusTransitionResult should not be nil")
        XCTAssertEqual(statusTransitionResult?.fromStatus,
                       HyperwalletStatusTransition.Status.activated,
                       "The statusTransitionResult?.fromStatus should be activated")
        XCTAssertEqual(statusTransitionResult?.toStatus,
                       HyperwalletStatusTransition.Status.deactivated,
                       "The statusTransitionResult?.toStatus should be deactivated")
    }

    func testDeactivateTransferMethod_payPalAccount() {
        let expectation = self.expectation(description: "Deactivate PayPal Account completed")
        var statusTransitionResult: HyperwalletStatusTransition?
        var statusTransitionError: HyperwalletErrorType?

        setupOkResponseMockServer(endpoint: "/paypal-accounts/trm-123456789/status-transitions",
                                  responseDataFile: "StatusTransitionResponseSuccess")

        let paypalAccount = HyperwalletPayPalAccount
            .Builder(transferMethodCountry: "US",
                     transferMethodCurrency: "USD",
                     transferMethodProfileType: "INDIVIDUAL")
            .build()
        paypalAccount.setField(key: "token", value: "trm-123456789")

        transferMethodRepository.deactivateTransferMethod(paypalAccount) { result in
            switch result {
            case .failure(let error):
                statusTransitionError = error

            case .success(let deactivateResult):
                statusTransitionResult = deactivateResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        XCTAssertNil(statusTransitionError, "The statusTransitionError should be nil")
        XCTAssertNotNil(statusTransitionResult, "The statusTransitionResult should not be nil")
        XCTAssertEqual(statusTransitionResult?.fromStatus,
                       HyperwalletStatusTransition.Status.activated,
                       "The statusTransitionResult?.fromStatus should be activated")
        XCTAssertEqual(statusTransitionResult?.toStatus,
                       HyperwalletStatusTransition.Status.deactivated,
                       "The statusTransitionResult?.toStatus should be deactivated")
    }

    func testDeactivateTransferMethod_venmoAccount() {
        let expectation = self.expectation(description: "Deactivate Venmo Account completed")
        var statusTransitionResult: HyperwalletStatusTransition?
        var statusTransitionError: HyperwalletErrorType?

        setupOkResponseMockServer(endpoint: "/venmo-accounts/trm-123456789/status-transitions",
                                  responseDataFile: "StatusTransitionResponseSuccess")

        let venmoAccount = HyperwalletVenmoAccount
            .Builder(transferMethodCountry: "US",
                     transferMethodCurrency: "USD",
                     transferMethodProfileType: "INDIVIDUAL")
            .build()
        venmoAccount.setField(key: "token", value: "trm-123456789")

        transferMethodRepository.deactivateTransferMethod(venmoAccount) { result in
            switch result {
            case .failure(let error):
                    statusTransitionError = error

            case .success(let deactivateResult):
                    statusTransitionResult = deactivateResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        XCTAssertNil(statusTransitionError, "The statusTransitionError should be nil")
        XCTAssertNotNil(statusTransitionResult, "The statusTransitionResult should not be nil")
        XCTAssertEqual(statusTransitionResult?.fromStatus,
                       HyperwalletStatusTransition.Status.activated,
                       "The statusTransitionResult?.fromStatus should be activated")
        XCTAssertEqual(statusTransitionResult?.toStatus,
                       HyperwalletStatusTransition.Status.deactivated,
                       "The statusTransitionResult?.toStatus should be deactivated")
    }

    func testDeactivateTransferMethod_paperCheck() {
        let expectation = self.expectation(description: "Deactivate PaperCheck Account completed")
        var statusTransitionResult: HyperwalletStatusTransition?
        var statusTransitionError: HyperwalletErrorType?

        setupOkResponseMockServer(endpoint: "/paper-checks/trm-123456789/status-transitions",
                                  responseDataFile: "StatusTransitionResponseSuccess")

        let papercheck = HyperwalletPaperCheck
            .Builder(transferMethodCountry: "US",
                     transferMethodCurrency: "USD",
                     transferMethodProfileType: "INDIVIDUAL",
                     transferMethodType: HyperwalletTransferMethod.TransferMethodType.paperCheck.rawValue)
            .build()
        papercheck.setField(key: "token", value: "trm-123456789")

        transferMethodRepository.deactivateTransferMethod(papercheck) { result in
            switch result {
            case .failure(let error):
                    statusTransitionError = error

            case .success(let deactivateResult):
                    statusTransitionResult = deactivateResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        XCTAssertNil(statusTransitionError, "The statusTransitionError should be nil")
        XCTAssertNotNil(statusTransitionResult, "The statusTransitionResult should not be nil")
        XCTAssertEqual(statusTransitionResult?.fromStatus,
                       HyperwalletStatusTransition.Status.activated,
                       "The statusTransitionResult?.fromStatus should be activated")
        XCTAssertEqual(statusTransitionResult?.toStatus,
                       HyperwalletStatusTransition.Status.deactivated,
                       "The statusTransitionResult?.toStatus should be deactivated")
    }

    func testDeactivateTransferMethod_notSupportedTransferMethod() {
        var statusTransitionResult: HyperwalletStatusTransition?
        var statusTransitionError: HyperwalletErrorType?

        let prepaidCard = HyperwalletPrepaidCard.Builder(transferMethodProfileType: "INDIVIDUAL")
            .build()
        prepaidCard.setField(key: "token", value: "trm-123456789")

        transferMethodRepository.deactivateTransferMethod(prepaidCard) { result in
            switch result {
            case .failure(let error):
                statusTransitionError = error

            case .success(let createResult):
                statusTransitionResult = createResult
            }
        }

        XCTAssertNotNil(statusTransitionError, "The statusTransitionError should be not nil")
        XCTAssertNil(statusTransitionResult, "The statusTransitionResult should be nil")
    }

    func testDeactivateTransferMethod_failure() {
        let url = String(format: "%@%@",
                         HyperwalletTestHelper.userRestURL,
                         "/paypal-accounts/trm-123456789/status-transitions")
        let response = StubResponse.Builder()
            .defaultResponse()
            .stubResponse(withError: NSError(domain: "", code: -1009, userInfo: nil))
            .build()
        let request = HyperwalletTestHelper.buildPostRequest(baseUrl: url, response)
        HyperwalletTestHelper.setUpMockServer(request: request)
        let expectation = self.expectation(description: "deactivate bank card failed")
        let transferMethodRepository = TransferMethodRepositoryFactory.shared.transferMethodRepository()
        var statusTransitionResult: HyperwalletStatusTransition?
        var statusTransitionError: HyperwalletErrorType?

        let paypalAccount = HyperwalletPayPalAccount
            .Builder(transferMethodCountry: "US",
                     transferMethodCurrency: "USD",
                     transferMethodProfileType: "INDIVIDUAL")
            .build()
        paypalAccount.setField(key: "token", value: "trm-123456789")

        transferMethodRepository.deactivateTransferMethod(paypalAccount) { result in
            switch result {
            case .failure(let error):
                statusTransitionError = error

            case .success(let deactivateResult):
                statusTransitionResult = deactivateResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        XCTAssertNil(statusTransitionResult, "The statusTransitionResult should be nil")
        XCTAssertNotNil(statusTransitionError, "The statusTransitionError should not be nil")
        XCTAssertGreaterThan(
            statusTransitionError!.getHyperwalletErrors()!.errorList!.count,
            0,
            "The statusTransitionError!.getHyperwalletErrors()!.errorList!.count should be greater than 0")
    }

    func testDeactivateTransferMethod_tokenNotPresented() {
        let expectation = self.expectation(description: "Deactivate wire account completed")
        // expectation should not be fulfilled
        expectation.isInverted = true
        let transferMethodRepository = TransferMethodRepositoryFactory.shared.transferMethodRepository()

        let bankAccount = HyperwalletBankAccount
            .Builder(transferMethodCountry: "US",
                     transferMethodCurrency: "USD",
                     transferMethodProfileType: "INDIVIDUAL",
                     transferMethodType: HyperwalletTransferMethod.TransferMethodType.wireAccount.rawValue)
            .build()

        transferMethodRepository.deactivateTransferMethod(bankAccount) { _ in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testListTransferMethods_returnsBankAccount() {
        let expectation = self.expectation(description: "List transfer methods completed")
        var listTransferMethodsResult: HyperwalletPageList<HyperwalletTransferMethod>?
        var listTransferMethodsError: HyperwalletErrorType?

        let listTransferMethodData = HyperwalletTestHelper.getDataFromJson("ListTransferMethodSuccessResponse")
        let response = HyperwalletTestHelper.setUpMockedResponse(payload: listTransferMethodData)
        let url = String(format: "%@%@", HyperwalletTestHelper.userRestURL, "/transfer-methods?")
        let request = HyperwalletTestHelper.buildGetRequestRegexMatcher(pattern: url, response)
        HyperwalletTestHelper.setUpMockServer(request: request)

        transferMethodRepository.listTransferMethods { (result) in
            switch result {
            case .failure(let error):
                listTransferMethodsError = error

            case .success(let listResult):
                listTransferMethodsResult = listResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        XCTAssertNil(listTransferMethodsError, "The listTransferMethodsError should be nil")
        XCTAssertNotNil(listTransferMethodsResult, "The listTransferMethodsResult should not be nil")
        XCTAssertGreaterThan(listTransferMethodsResult!.data!.count,
                             0,
                             "The listTransferMethodsResult!.data.count should be greater than 0")

        let expectationListSecondTime = self.expectation(description: "List transfer methods again completed")
        listTransferMethodsResult = nil
        transferMethodRepository.listTransferMethods { (result) in
            listTransferMethodsResult = try? result.get()
            expectationListSecondTime.fulfill()
        }

        wait(for: [expectationListSecondTime], timeout: 1)
        XCTAssertNotNil(listTransferMethodsResult)
    }

    func testListTransferMethods_returnsNoAccounts() {
        let expectation = self.expectation(description: "List transfer methods completed")
        var listTransferMethodsResult: HyperwalletPageList<HyperwalletTransferMethod>?
        var listTransferMethodsError: HyperwalletErrorType?

        // ListTransferMethodSuccessResponse
        let response = HyperwalletTestHelper.noContentHTTPResponse()
        let url = String(format: "%@%@", HyperwalletTestHelper.userRestURL, "/transfer-methods?")
        let request = HyperwalletTestHelper.buildGetRequestRegexMatcher(pattern: url, response)
        HyperwalletTestHelper.setUpMockServer(request: request)
        transferMethodRepository.listTransferMethods { (result) in
            switch result {
            case .failure(let error):
                listTransferMethodsError = error

            case .success(let listResult):
                listTransferMethodsResult = listResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        XCTAssertNil(listTransferMethodsError, "The listTransferMethodsError should be nil")
        XCTAssertNil(listTransferMethodsResult, "The listTransferMethodsResult should be nil")
    }

    private func setupOkResponseMockServer(endpoint: String, responseDataFile: String ) {
        let url = String(format: "%@%@", HyperwalletTestHelper.userRestURL, endpoint)
        let response = HyperwalletTestHelper.okHTTPResponse(for: responseDataFile)
        let request = HyperwalletTestHelper.buildPostRequest(baseUrl: url, response)
        HyperwalletTestHelper.setUpMockServer(request: request)
    }

    private func setupBadResponseMockServer(endpoint: String, responseDataFile: String ) {
        let url = String(format: "%@%@", HyperwalletTestHelper.userRestURL, endpoint)
        let response = HyperwalletTestHelper.badRequestHTTPResponse(for: responseDataFile)
        let request = HyperwalletTestHelper.buildPostRequest(baseUrl: url, response)
        HyperwalletTestHelper.setUpMockServer(request: request)
    }
}
