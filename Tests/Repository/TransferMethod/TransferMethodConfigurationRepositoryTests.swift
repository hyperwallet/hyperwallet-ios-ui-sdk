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
@testable import HyperwalletUISDK
import XCTest

class TransferMethodConfigurationRepositoryTests: XCTestCase {
    private let country = "US"
    private let currency = "USD"
    private let transferMethodType = "BANK_ACCOUNT"
    private let profileType = "INDIVIDUAL"
    private lazy var fieldsResponseData = HyperwalletTestHelper
        .getDataFromJson("TransferMethodConfigurationFieldsResponse")
    private lazy var keyResponseData = HyperwalletTestHelper.getDataFromJson("TransferMethodConfigurationKeysResponse")
    private lazy var userResponseData = HyperwalletTestHelper.getDataFromJson("UserIndividualResponse")

    override func setUp() {
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
    }

    override func tearDown() {
        if Hippolyte.shared.isStarted {
            Hippolyte.shared.stop()
        }
    }

    func testGetKeys_success() {
        setupTransferMethodConfigurationMockServer(keyResponseData)
        let expectation = self.expectation(description: "Get transfer methods keys")
        var result: HyperwalletTransferMethodConfigurationKey?
        var error: HyperwalletErrorType?
        let repository = TransferMethodConfigurationRepository()

        // When
        repository.getKeys { (transferMethodConfigurationKey, hyperwalletError) in
            result = transferMethodConfigurationKey
            error = hyperwalletError
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        XCTAssertNil(error, "The error should be nil")
        XCTAssertNotNil(result, "The result should not be nil")
        XCTAssertGreaterThan(result!.countries()!.count, 0)
    }

    func testGetKeys_failureWithError() {
        setupTransferMethodConfigurationMockServer(keyResponseData, NSError(domain: "", code: -1009, userInfo: nil))
        let expectation = self.expectation(description: "Get transfer methods keys")
        var result: HyperwalletTransferMethodConfigurationKey?
        var error: HyperwalletErrorType?
        let repository = TransferMethodConfigurationRepository()

        // When
        repository.getKeys { (transferMethodConfigurationKey, hyperwalletError) in
            result = transferMethodConfigurationKey
            error = hyperwalletError
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        XCTAssertNotNil(error, "The error should not be nil")
        XCTAssertNil(result, "The result should be nil")
    }

    func testGetKeys_successWithKeyResultFromCacheWhenNotNil() {
        setupTransferMethodConfigurationMockServer(keyResponseData)
        let repository = TransferMethodConfigurationRepository()
        // Get data from the server
        let expectation = self.expectation(description: "Get transfer methods keys")
        repository.getKeys { (_, _) in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        var result: HyperwalletTransferMethodConfigurationKey?
        var error: HyperwalletErrorType?

        // When - Get from cache
        repository.getKeys { (transferMethodConfigurationKey, hyperwalletError) in
            result = transferMethodConfigurationKey
            error = hyperwalletError
        }

        XCTAssertNil(error, "The error should be nil")
        XCTAssertNotNil(result, "The result should not be nil")
        XCTAssertGreaterThan(result!.countries()!.count, 0)
    }

    func testGetFields_success() {
        setupTransferMethodConfigurationMockServer(fieldsResponseData)
        let expectation = self.expectation(description: "Get transfer methods fields")
        var result: HyperwalletTransferMethodConfigurationField?
        var error: HyperwalletErrorType?
        let repository = TransferMethodConfigurationRepository()

        // When
        repository.getFields(country: country,
                             currency: currency,
                             transferMethodType: transferMethodType,
                             transferMethodProfileType: profileType,
                             completion: { (transferMethodConfigurationField, hyperwalletError) in
                                result = transferMethodConfigurationField
                                dump(result)
                                error = hyperwalletError
                                expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)

        XCTAssertNil(error, "The error should be nil")
        XCTAssertNotNil(result, "The result should not be nil")
        XCTAssertEqual(result!.fieldGroups()!.count, 2, "`fieldGroups()` should be 2")
        XCTAssertEqual(result!.transferMethodType()!.name,
                       "Bank Account",
                       "transferMethodType()!.name` should be Bank Account")
    }

    func testGetFields_successWithFieldResultFromCacheWhenNotNil() {
        setupTransferMethodConfigurationMockServer(fieldsResponseData)
        let expectation = self.expectation(description: "Get transfer methods fields")
        var result: HyperwalletTransferMethodConfigurationField?
        var error: HyperwalletErrorType?
        let repository = TransferMethodConfigurationRepository()
        repository.getFields(country: country,
                             currency: currency,
                             transferMethodType: transferMethodType,
                             transferMethodProfileType: profileType,
                             completion: { (_, _) in expectation.fulfill() })
        wait(for: [expectation], timeout: 1)

        // When
        repository.getFields(country: country,
                             currency: currency,
                             transferMethodType: transferMethodType,
                             transferMethodProfileType: profileType,
                             completion: { (transferMethodConfigurationField, hyperwalletError) in
                                result = transferMethodConfigurationField
                                dump(result)
                                error = hyperwalletError
        })

        XCTAssertNil(error, "The error should be nil")
        XCTAssertNotNil(result, "The result should not be nil")
        XCTAssertEqual(result!.fieldGroups()!.count, 2, "`fieldGroups()` should be 2")
        XCTAssertEqual(result!.transferMethodType()!.name,
                       "Bank Account",
                       "transferMethodType()!.name` should be Bank Account")
    }

    func testGetFields_failureWithError() {
        setupTransferMethodConfigurationMockServer(fieldsResponseData, NSError(domain: "", code: -1009, userInfo: nil))
        let expectation = self.expectation(description: "Get transfer methods fields")
        var result: HyperwalletTransferMethodConfigurationField?
        var error: HyperwalletErrorType?
        let repository = TransferMethodConfigurationRepository()

        // When
        repository.getFields(country: country,
                             currency: currency,
                             transferMethodType: transferMethodType,
                             transferMethodProfileType: profileType,
                             completion: { (transferMethodConfigurationField, hyperwalletError) in
                                result = transferMethodConfigurationField
                                dump(result)
                                error = hyperwalletError
                                expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)

        XCTAssertNotNil(error, "The error should not be nil")
        XCTAssertNil(result, "The result should be nil")
    }

    private func setupTransferMethodConfigurationMockServer(_ data: Data, _ error: NSError? = nil) {
        let userResponse = HyperwalletTestHelper.setUpMockedResponse(payload: userResponseData, error: error)
        let userRequest = HyperwalletTestHelper
            .buildGetRequest(baseUrl: HyperwalletTestHelper.userRestURL, userResponse)
        Hippolyte.shared.add(stubbedRequest: userRequest)

        let dataResponse = HyperwalletTestHelper.setUpMockedResponse(payload: data, error: error)
        let dataRequest = HyperwalletTestHelper
            .buildPostRequest(baseUrl: HyperwalletTestHelper.graphQlURL, dataResponse)
        HyperwalletTestHelper.setUpMockServer(request: dataRequest)
    }
}
