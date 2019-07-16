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

class TransferMethodRepositoryFactoryTests: XCTestCase {
    private lazy var keyResponseData = HyperwalletTestHelper.getDataFromJson("TransferMethodConfigurationKeysResponse")
    private let country = "US"
    private let currency = "USD"

    func testShared_verifyRepositoriesInitialized() {
        let repositoryFactory = TransferMethodRepositoryFactory.shared

        XCTAssertNotNil(repositoryFactory, "The repositoryFactory should not be nil")
        XCTAssertNotNil(repositoryFactory.transferMethodConfigurationRepository(),
                        "The transferMethodConfigurationRepository should not be nil")
    }
    // swiftlint:disable function_body_length
    func testShared_verifyRepositoriesCleared() {
        RemoteTransferMethodConfigurationRepositoryTests
            .setupResponseMockServer(keyResponseData)
        let expectation = self.expectation(description: "Get transfer method configuration keys")
        var transferMethodConfigurationKey: HyperwalletTransferMethodConfigurationKey?
        var error: HyperwalletErrorType?
        var refreshTransferMethodConfigurationKey: HyperwalletTransferMethodConfigurationKey?
        var refreshError: HyperwalletErrorType?
        TransferMethodRepositoryFactory.shared
            .transferMethodConfigurationRepository().getKeys { (result) in
            switch result {
            case .success(let resultKey):
                transferMethodConfigurationKey = resultKey

            case .failure(let resultError):
                error = resultError
            }
            expectation.fulfill()
            }
        wait(for: [expectation], timeout: 1)
        RemoteTransferMethodConfigurationRepositoryTests
            .refreshHippolyteResponse("TransferMethodConfigurationKeysOnlyPaypalAccountUsResponse")

        // When
        TransferMethodRepositoryFactory.clearInstance()

        let expectationReflesh = self.expectation(description: "Get transfer method configuration keys")
        TransferMethodRepositoryFactory.shared
            .transferMethodConfigurationRepository().getKeys { (result) in
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
                       "The transferMethodConfigurationKey!.countries() should be 4")
        XCTAssertEqual(transferMethodConfigurationKey!.currencies(from: country)!.count,
                       2,
                       "The transferMethodConfigurationKey!.currencies(from: country)!.count should be 2")
        XCTAssertEqual(transferMethodConfigurationKey!.currencies(from: country)!.first!.code,
                       "CAD",
                       "The transferMethodConfigurationKey!.currencies(from: country)!.first!.code should be CAD")
        XCTAssertNil(refreshError, "The error should be nil")
        XCTAssertNotNil(refreshTransferMethodConfigurationKey, "The result should not be nil")
        XCTAssertEqual(refreshTransferMethodConfigurationKey!.countries()!.count,
                       1,
                       "The refreshTransferMethodConfigurationKey!.countries()!.count should be 1")
        XCTAssertEqual(refreshTransferMethodConfigurationKey!.currencies(from: country)!.count,
                       1,
                       "The refreshTransferMethodConfigurationKey!.currencies(from: country)!.count should be 1")
        XCTAssertEqual(refreshTransferMethodConfigurationKey!.currencies(from: country)!.first!.code,
                       "USD",
                       "The refreshTransferMethodConfigurationKey!.currencies(from: country)!.first!.code should be USD"
                       )
    }
}
