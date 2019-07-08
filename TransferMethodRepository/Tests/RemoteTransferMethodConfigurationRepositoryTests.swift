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

import Common
import Hippolyte
import HyperwalletSDK
@testable import TransferMethodRepository
import TransferMethodRepository
import XCTest

class TransferMethodConfigurationrepositoryTests: XCTestCase {
    private let country = "US"
    private let currency = "USD"
    private let transferMethodType = "BANK_ACCOUNT"
    private let profileType = "INDIVIDUAL"
    //TODO: Review if the responses files should be shared in the common module
    private lazy var fieldsResponseData = HyperwalletTestHelper
        .getDataFromJson("TransferMethodConfigurationFieldsResponse")
    private lazy var keyResponseData = HyperwalletTestHelper.getDataFromJson("TransferMethodConfigurationKeysResponse")
    private lazy var userResponseData = HyperwalletTestHelper.getDataFromJson("UserIndividualResponse")

    override func setUp() {
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
    }

    override func tearDown() {
        RepositoryFactory.clearInstance()
        if Hippolyte.shared.isStarted {
            Hippolyte.shared.stop()
        }
    }

    func testGetKeys_success() {
        setupTransferMethodConfigurationMockServer(keyResponseData)
        let expectation = self.expectation(description: "Get transfer methods keys")
        var transferMethodConfigurationKey: HyperwalletTransferMethodConfigurationKey?
        var error: HyperwalletErrorType?
        let repository = RepositoryFactory.shared.transferMethodConfigurationRepository()

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
        XCTAssertGreaterThan(repository.countries()!.count, 0)
        XCTAssertGreaterThan(repository.currencies(country)!.count, 0)
    }

    func testGetKeys_failureWithError() {
        setupTransferMethodConfigurationMockServer(keyResponseData, NSError(domain: "", code: -1009, userInfo: nil))
        let expectation = self.expectation(description: "Get transfer methods keys")
        var transferMethodConfigurationKey: HyperwalletTransferMethodConfigurationKey?
        var error: HyperwalletErrorType?
        let repository = RepositoryFactory.shared.transferMethodConfigurationRepository()

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
        XCTAssertNil(repository.countries())
        XCTAssertNil(repository.currencies(country))
    }

    func testGetKeys_successWithKeyResultWhenNotNil() {
        setupTransferMethodConfigurationMockServer(keyResponseData)
        let repository = RepositoryFactory.shared.transferMethodConfigurationRepository()

        // Get data from the server
        let expectation = self.expectation(description: "Get transfer method keys")
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
        XCTAssertGreaterThan(transferMethodConfigurationKey!.countries()!.count, 0)
    }

    func testGetFields_success() {
        setupTransferMethodConfigurationMockServer(fieldsResponseData)
        let expectation = self.expectation(description: "Get transfer method fields")
        let repository = RepositoryFactory.shared.transferMethodConfigurationRepository()
        //RemoteTransferMethodConfigurationRepository()
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
                       "transferMethodType()!.name` should be Bank Account")
    }

    func testGetFields_successWithFieldResultFromCacheWhenNotNil() {
        setupTransferMethodConfigurationMockServer(fieldsResponseData)
        let expectation = self.expectation(description: "Get transfer method fields")
        let repository = RepositoryFactory.shared.transferMethodConfigurationRepository()
            //RemoteTransferMethodConfigurationRepository()
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
        XCTAssertEqual(transferMethodConfigurationField!.fieldGroups()!.count, 2, "`fieldGroups()` should be 2")
        XCTAssertEqual(transferMethodConfigurationField!.transferMethodType()!.name,
                       "Bank Account",
                       "transferMethodType()!.name` should be Bank Account")
    }

    func testGetFields_failureWithError() {
        setupTransferMethodConfigurationMockServer(fieldsResponseData, NSError(domain: "", code: -1009, userInfo: nil))
        let expectation = self.expectation(description: "Get transfer method fields")
        let repository = RepositoryFactory.shared.transferMethodConfigurationRepository()
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
        XCTAssertNil(transferMethodConfigurationField, "The result should be nil")
    }

    func testRefreshKeys_cleanRepositoryCache() {
        setupTransferMethodConfigurationMockServer(keyResponseData)

        // Get data from the server
        let expectation = self.expectation(description: "Get transfer method keys")
        let repository = RepositoryFactory.shared.transferMethodConfigurationRepository()
        repository.getKeys { (_) in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        XCTAssertGreaterThan(repository.countries()!.count, 0)
        XCTAssertGreaterThan(repository.currencies(country)!.count, 0)

        // When
        repository.refreshKeys()

        XCTAssertNil(repository.countries())
        XCTAssertNil(repository.currencies(country))
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
