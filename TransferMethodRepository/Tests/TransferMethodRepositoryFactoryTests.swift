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
        XCTAssertNotNil(repositoryFactory.transferMethodRepository(),
                        "The transferMethodRepository should not be nil")
        XCTAssertNotNil(repositoryFactory.prepaidCardRepository(),
                        "The prepaidCardRepository should not be nil")
    }

    func testClearInstance() {
        let factoryInstance = TransferMethodRepositoryFactory.shared
        let transferMethodConfigurationRepositoryInstance = factoryInstance.transferMethodConfigurationRepository()
        let transferMethodRepositoryInstance = factoryInstance.transferMethodRepository()
        let prepaidCardRepositoryInstance = factoryInstance.prepaidCardRepository()

        XCTAssertNotNil(TransferMethodRepositoryFactory.instance, "instance should not be nil")
        XCTAssertNotNil(factoryInstance, "The factoryInstance should not be nil")
        XCTAssertNotNil(transferMethodConfigurationRepositoryInstance,
                        "The transferMethodConfigurationRepositoryInstance should not be nil")
        XCTAssertNotNil(transferMethodRepositoryInstance,
                        "The transferMethodRepositoryInstance should not be nil")
        XCTAssertNotNil(prepaidCardRepositoryInstance,
                        "The prepaidCardRepositoryInstance1 should not be nil")

        // When
        TransferMethodRepositoryFactory.clearInstance()

        XCTAssertNil(TransferMethodRepositoryFactory.instance, "instance should be nil")
    }
}
