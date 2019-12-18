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

class TransferRepositoryTests: XCTestCase {
    private var transfer: HyperwalletTransfer!

    override func setUp() {
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        transfer = getTransfer(from: HyperwalletTestHelper.getDataFromJson("CreateTransferResponse"))!
    }

    override func tearDown() {
        if Hippolyte.shared.isStarted {
            Hippolyte.shared.stop()
        }
    }

    func testCreateTransfer_success() {
        // Given
        let requestUrl = String(format: "%@transfers", HyperwalletTestHelper.restURL)
        TransferRepositoryRequestHelper.setupSuccessRequest("CreateTransferResponse", requestUrl)
        let expectation = self.expectation(description: "create a transfer")

        var createdTransfer: HyperwalletTransfer?
        var error: HyperwalletErrorType?
        let transferRepository = RemoteTransferRepository()

        // When
        transferRepository.createTransfer(transfer) { (result) in
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
        XCTAssertEqual(createdTransfer?.clientTransferId, "6712348070812")
    }

    func testCreateTransfer_failure_badRequest() {
        // Given
        let requestUrl = String(format: "%@transfers", HyperwalletTestHelper.restURL)
        TransferRepositoryRequestHelper.setupFailureRequest("CreateTransferBadRequestResponse", requestUrl)
        let expectation = self.expectation(description: "create a transfer")

        var createdTransfer: HyperwalletTransfer?
        var error: HyperwalletErrorType?
        let transferRepository = RemoteTransferRepository()

        // When
        transferRepository.createTransfer(transfer) { (result) in
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
        XCTAssertNotNil(error, "The error should not be nil")
        XCTAssertNil(createdTransfer, "The result should be nil")
        XCTAssertEqual(TransferRepositoryRequestHelper.getResponseError(error!).message,
                       "The destination token you provided doesn’t exist or is not a valid destination.")
        XCTAssertEqual(TransferRepositoryRequestHelper.getResponseError(error!).code, "INVALID_DESTINATION_TOKEN")
    }

    func testScheduleTransfer_success() {
        // Given
        let requestUrl = String(format: "%@transfers/trf-123456/status-transitions", HyperwalletTestHelper.restURL)
        TransferRepositoryRequestHelper.setupSuccessRequest("ScheduleTransferResponse", requestUrl)
        let expectation = self.expectation(description: "schedule a transfer")

        var statusTransition: HyperwalletStatusTransition?
        var error: HyperwalletErrorType?
        let transferRepository = RemoteTransferRepository()

        // When
        transferRepository.scheduleTransfer(transfer) { (result) in
            switch result {
            case .success(let successResult):
                statusTransition = successResult

            case .failure(let errorResult):
                error = errorResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertNil(error, "The error should be nil")
        XCTAssertNotNil(statusTransition, "The result should not be nil")
        XCTAssertEqual(statusTransition?.fromStatus, HyperwalletStatusTransition.Status.quoted)
        XCTAssertEqual(statusTransition?.toStatus, HyperwalletStatusTransition.Status.scheduled)
    }

    func testScheduleTransfer_failure_badRequest() {
        // Given
        let requestUrl = String(format: "%@transfers/trf-123456/status-transitions", HyperwalletTestHelper.restURL)
        TransferRepositoryRequestHelper.setupFailureRequest("ScheduleTransferBadRequestResponse", requestUrl)
        let expectation = self.expectation(description: "schedule a transfer")

        var statusTransition: HyperwalletStatusTransition?
        var error: HyperwalletErrorType?
        let transferRepository = RemoteTransferRepository()

        // When
        transferRepository.scheduleTransfer(transfer) { (result) in
            switch result {
            case .success(let successResult):
                statusTransition = successResult

            case .failure(let errorResult):
                error = errorResult
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertNotNil(error, "The error should not be nil")
        XCTAssertNil(statusTransition, "The result should be nil")
        XCTAssertEqual(TransferRepositoryRequestHelper.getResponseError(error!).code, "EXPIRED_TRANSFER")
    }

    private func getTransfer(from jsonData: Data) -> HyperwalletTransfer? {
        let decoder = JSONDecoder()
        return try? decoder.decode(HyperwalletTransfer.self, from: jsonData)
    }
}
