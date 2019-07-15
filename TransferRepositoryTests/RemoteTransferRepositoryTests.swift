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
@testable import TransferRepository
import XCTest

class RemoteTransferRepositoryTests: XCTestCase {
    private let createTransferResponse = HyperwalletTestHelper.getDataFromJson("CreateTransferResponse")

    override func setUp() {
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
    }

    override func tearDown() {
        if Hippolyte.shared.isStarted {
            Hippolyte.shared.stop()
        }
    }

    func testCreateTransfer_success() {
        RemoteTransferRepositoryTests.setupResponseMockServer(createTransferResponse)
        let expectation = self.expectation(description: "create a transfer")
        var createdTransfer: HyperwalletTransfer?
        var error: HyperwalletErrorType?
        let transferRepository = RemoteTransferRepository()

        let transfer = HyperwalletTransfer.Builder(clientTransferId: "123",
                                                   sourceToken: "usr-123",
                                                   destinationToken: "trm-123")
        .build()
        // When
        transferRepository.create(transfer) { (result) in
            switch result {
            case .success(let successResult):
                createdTransfer = successResult

            case .failure(let errorResult):
                error = errorResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertNil(error, "The error should be nil")
        XCTAssertNotNil(createdTransfer, "The result should not be nil")
        XCTAssertEqual(createdTransfer?.token, "trf-123456")
    }

    static func setupResponseMockServer(_ data: Data, _ error: NSError? = nil) {
        let dataResponse = HyperwalletTestHelper.setUpMockedResponse(payload: data, error: error)
        let dataRequest = HyperwalletTestHelper
            .buildPostRequest(baseUrl: HyperwalletTestHelper.graphQlURL, dataResponse)
        HyperwalletTestHelper.setUpMockServer(request: dataRequest)
    }
}
