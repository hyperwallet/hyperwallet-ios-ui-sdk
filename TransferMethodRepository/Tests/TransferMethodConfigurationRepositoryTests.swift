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

class TransferMethodConfigurationRepositoryTests: XCTestCase {
    private let country = "US"
    private let currency = "USD"
    private let transferMethodType = "BANK_ACCOUNT"
    private let profileType = "INDIVIDUAL"
    private lazy var fieldsResponseData = HyperwalletTestHelper
        .getDataFromJson("TransferMethodConfigurationFieldsResponse")
    private lazy var keyResponseData = HyperwalletTestHelper.getDataFromJson("TransferMethodConfigurationKeysResponse")
    private static var userResponseData = HyperwalletTestHelper.getDataFromJson("UserIndividualResponse")

    override func setUp() {
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
    }

    override func tearDown() {
        if Hippolyte.shared.isStarted {
            Hippolyte.shared.stop()
        }
    }

    func testGetKeys_success() {
        TransferMethodConfigurationRepositoryTests
            .setupResponseMockServer(keyResponseData)
        let expectation = self.expectation(description: "Get transfer method configuration keys")
        var transferMethodConfigurationKey: HyperwalletTransferMethodConfigurationKey?
        var error: HyperwalletErrorType?
        let repository = RemoteTransferMethodConfigurationRepository()

        // When
        repository.getKeys { (result) in
            switch result {
            case .success(let resultKey):
                transferMethodConfigurationKey = resultKey

            case .failure(let resultError):
                error = resultError
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        XCTAssertNil(error, "The error should be nil")
        XCTAssertNotNil(transferMethodConfigurationKey, "The result should not be nil")
        XCTAssertGreaterThan(transferMethodConfigurationKey!.countries()!.count, 0)
        XCTAssertGreaterThan(transferMethodConfigurationKey!.currencies(from: country)!.count, 0)
    }

    func testGetKeys_failureWithError() {
        TransferMethodConfigurationRepositoryTests
            .setupResponseMockServer(keyResponseData, NSError(domain: "", code: -1009, userInfo: nil))
        let expectation = self.expectation(description: "Get transfer method configuration keys")
        var transferMethodConfigurationKey: HyperwalletTransferMethodConfigurationKey?
        var error: HyperwalletErrorType?
        let repository = RemoteTransferMethodConfigurationRepository()

        // When
        repository.getKeys { (result) in
            switch result {
            case .success(let resultKey):
                transferMethodConfigurationKey = resultKey

            case .failure(let resultError):
                error = resultError
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        XCTAssertNotNil(error, "The error should not be nil")
        XCTAssertNil(transferMethodConfigurationKey, "The result should be nil")
    }

    func testGetKeys_successWithKeyResultFromCache() {
        TransferMethodConfigurationRepositoryTests
            .setupResponseMockServer(keyResponseData)
        let repository = RemoteTransferMethodConfigurationRepository()

        // Get data from the server
        let expectation = self.expectation(description: "Get transfer method configuration keys")
        repository.getKeys { (_) in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        var transferMethodConfigurationKey: HyperwalletTransferMethodConfigurationKey?
        var error: HyperwalletErrorType?

        // When - Get from cache
        repository.getKeys { (result) in
            switch result {
            case .success(let resultKey):
                transferMethodConfigurationKey = resultKey

            case .failure(let resultError):
                error = resultError
            }
        }

        XCTAssertNil(error, "The error should be nil")
        XCTAssertNotNil(transferMethodConfigurationKey, "The result should not be nil")
        XCTAssertGreaterThan(transferMethodConfigurationKey!.countries()!.count,
                             0,
                             "The transferMethodConfigurationKey!.countries()!.count should be greater than 0")
    }

    func testGetFields_success() {
        TransferMethodConfigurationRepositoryTests
            .setupResponseMockServer(fieldsResponseData)
        let expectation = self.expectation(description: "Get transfer method configuration fields")
        let repository = RemoteTransferMethodConfigurationRepository()
        var transferMethodConfigurationField: HyperwalletTransferMethodConfigurationField?
        var error: HyperwalletErrorType?

        // When
        repository.getFields(country, currency, transferMethodType, profileType, completion: { (result) in
            switch result {
            case .success(let resultField):
                transferMethodConfigurationField = resultField

            case .failure(let resultError):
                error = resultError
            }

            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)

        XCTAssertNil(error, "The error should be nil")
        XCTAssertNotNil(transferMethodConfigurationField, "The result should not be nil")
        XCTAssertEqual(transferMethodConfigurationField!.fieldGroups()!.count, 2, "`fieldGroups()` should be 2")
        XCTAssertEqual(transferMethodConfigurationField!.transferMethodType()!.name,
                       "Bank Account",
                       "The transferMethodType()!.name` should be Bank Account")
    }

    func testGetFields_successWithFieldResultFromCache() {
        TransferMethodConfigurationRepositoryTests
            .setupResponseMockServer(fieldsResponseData)
        let expectation = self.expectation(description: "Get transfer method configuration fields")
        let repository = RemoteTransferMethodConfigurationRepository()
        var transferMethodConfigurationField: HyperwalletTransferMethodConfigurationField?
        var error: HyperwalletErrorType?
        repository.getFields(country, currency, transferMethodType, profileType) { (_) in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)

        // When
        repository.getFields(country, currency, transferMethodType, profileType, completion: { (result) in
            switch result {
            case .success(let resultField):
                transferMethodConfigurationField = resultField

            case .failure(let resultError):
                error = resultError
            }
        })

        XCTAssertNil(error, "The error should be nil")
        XCTAssertNotNil(transferMethodConfigurationField, "The result should not be nil")
        XCTAssertEqual(transferMethodConfigurationField!.fieldGroups()!.count, 2, "The `fieldGroups()` should be 2")
        XCTAssertEqual(transferMethodConfigurationField!.transferMethodType()!.name,
                       "Bank Account",
                       "The transferMethodType()!.name` should be Bank Account")
    }

    func testGetFields_failureWithError() {
        TransferMethodConfigurationRepositoryTests
            .setupResponseMockServer(fieldsResponseData, NSError(domain: "", code: -1009, userInfo: nil))
        let expectation = self.expectation(description: "Get transfer method configuration fields")
        let repository = RemoteTransferMethodConfigurationRepository()
        var transferMethodConfigurationField: HyperwalletTransferMethodConfigurationField?
        var error: HyperwalletErrorType?

        // When
        repository.getFields(country, currency, transferMethodType, profileType, completion: { (result) in
            switch result {
            case .success(let resultField):
                transferMethodConfigurationField = resultField

            case .failure(let resultError):
                error = resultError
            }

            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)

        XCTAssertNotNil(error, "The error should not be nil")
        XCTAssertNil(transferMethodConfigurationField, "The transferMethodConfigurationField should be nil")
    }
    //swiftlint:disable function_body_length
    func testRefreshKeys_refreshKeysData() {
        TransferMethodConfigurationRepositoryTests
            .setupResponseMockServer(keyResponseData)
        let expectation = self.expectation(description: "Get transfer method keys")
        let repository = RemoteTransferMethodConfigurationRepository()
        var transferMethodConfigurationKey: HyperwalletTransferMethodConfigurationKey?
        var error: HyperwalletErrorType?
        var refreshTransferMethodConfigurationKey: HyperwalletTransferMethodConfigurationKey?
        var refreshError: HyperwalletErrorType?

        repository.getKeys { (result) in
            switch result {
            case .success(let resultKey):
                transferMethodConfigurationKey = resultKey

            case .failure(let resultError):
                error = resultError
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        TransferMethodConfigurationRepositoryTests
            .refreshHippolyteResponse("TransferMethodConfigurationKeysOnlyPaypalAccountUsResponse")

        // When
        repository.refreshKeys()

        let expectationReflesh = self.expectation(description: "Get transfer method keys")
        repository.getKeys { (result) in
            switch result {
            case .success(let resultKey):
                refreshTransferMethodConfigurationKey = resultKey

            case .failure(let resultError):
                refreshError = resultError
            }
            expectationReflesh.fulfill()
        }
        wait(for: [expectationReflesh], timeout: 1)
        XCTAssertNil(error, "The error should be nil")
        XCTAssertNotNil(transferMethodConfigurationKey, "The result should not be nil")
        XCTAssertEqual(transferMethodConfigurationKey!.countries()!.count,
                       4,
                       "The transferMethodConfigurationKey!.countries()!.count should be 4")
        XCTAssertEqual(transferMethodConfigurationKey!.currencies(from: country)!.count,
                       2,
                       "The transferMethodConfigurationKey!.currencies(from: country)!.count should be 2")
        XCTAssertEqual(transferMethodConfigurationKey!.currencies(from: country)!.first!.code, "CAD")

        XCTAssertNil(refreshError, "The error should be nil")
        XCTAssertNotNil(refreshTransferMethodConfigurationKey, "The result should not be nil")
        XCTAssertEqual(refreshTransferMethodConfigurationKey!.countries()!.count,
                       1,
                       "The refreshTransferMethodConfigurationKey!.countries()!.count should be 1")
        XCTAssertEqual(refreshTransferMethodConfigurationKey!.currencies(from: country)!.count, 1)
        XCTAssertEqual(refreshTransferMethodConfigurationKey!.currencies(from: country)!.first!.code, "USD")
    }

    func testRefreshFields_refreshFieldsData() {
        TransferMethodConfigurationRepositoryTests
            .setupResponseMockServer(fieldsResponseData)
        let expectation = self.expectation(description: "Get transfer method configuration fields")
        let repository = RemoteTransferMethodConfigurationRepository()
        var transferMethodConfigurationField: HyperwalletTransferMethodConfigurationField?
        var error: HyperwalletErrorType?

        var refeshTransferMethodConfigurationField: HyperwalletTransferMethodConfigurationField?
        var refeshError: HyperwalletErrorType?

        repository.getFields(country, currency, transferMethodType, profileType, completion: { (result) in
            switch result {
            case .success(let resultField):
                transferMethodConfigurationField = resultField

            case .failure(let resultError):
                error = resultError
            }
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
        TransferMethodConfigurationRepositoryTests
            .refreshHippolyteResponse("TransferMethodConfigurationFieldsOnlyPaypalAccountUsResponse")

        // When
        repository.refreshFields()

        let expectationReflesh = self.expectation(description: "Get transfer method configuration fields")
        repository.getFields(country, currency, transferMethodType, profileType, completion: { (result) in
            switch result {
            case .success(let resultField):
                refeshTransferMethodConfigurationField = resultField

            case .failure(let resultError):
                refeshError = resultError
            }
            expectationReflesh.fulfill()
        })
        wait(for: [expectationReflesh], timeout: 1)

        XCTAssertNil(error, "The error should be nil")
        XCTAssertNotNil(transferMethodConfigurationField, "The result should not be nil")
        XCTAssertEqual(transferMethodConfigurationField!.fieldGroups()!.count, 2, "`fieldGroups()` should be 2")
        XCTAssertEqual(transferMethodConfigurationField!.transferMethodType()!.name,
                       "Bank Account",
                       "transferMethodType()!.name` should be Bank Account")

        XCTAssertNil(refeshError, "The error should be nil")
        XCTAssertNotNil(refeshTransferMethodConfigurationField, "The result should not be nil")
        XCTAssertEqual(refeshTransferMethodConfigurationField!.fieldGroups()!.count, 1, "`fieldGroups()` should be 1")
        XCTAssertEqual(refeshTransferMethodConfigurationField!.transferMethodType()!.name,
                       "PayPal Account",
                       "transferMethodType()!.name` should be PayPal Account")
    }

    static func setupResponseMockServer(_ data: Data, _ error: NSError? = nil) {
        let userResponse = HyperwalletTestHelper.setUpMockedResponse(payload: userResponseData, error: error)
        let userRequest = HyperwalletTestHelper.buildGetRequest(baseUrl: HyperwalletTestHelper.userRestURL,
                                                                userResponse)
        Hippolyte.shared.add(stubbedRequest: userRequest)

        let dataResponse = HyperwalletTestHelper.setUpMockedResponse(payload: data, error: error)
        let dataRequest = HyperwalletTestHelper
            .buildPostRequest(baseUrl: HyperwalletTestHelper.graphQlURL, dataResponse)
        HyperwalletTestHelper.setUpMockServer(request: dataRequest)
    }

    static func refreshHippolyteResponse(_ jsonFileName: String) {
        Hippolyte.shared.clearStubs()
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        let refleshResponseData = HyperwalletTestHelper.getDataFromJson(jsonFileName)
        setupResponseMockServer(refleshResponseData)
    }
}
