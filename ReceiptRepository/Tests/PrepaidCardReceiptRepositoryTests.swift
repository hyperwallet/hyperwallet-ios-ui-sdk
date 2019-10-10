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
@testable import ReceiptRepository
import XCTest

class PrepaidCardReceiptRepositoryTests: XCTestCase {
    private lazy var listPrepaidCardReceiptPayload = HyperwalletTestHelper.getDataFromJson("PrepaidCardReceiptResponse")
    private var prepaidCardReceiptRepository: PrepaidCardReceiptRepository!
    private var receiptExpectation: XCTestExpectation!

    override func setUp() {
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        prepaidCardReceiptRepository = ReceiptRepositoryFactory.shared.prepaidCardReceiptRepository()
        receiptExpectation = self.expectation(description: "load prepaid card receipts")
    }

    override func tearDown() {
        ReceiptRepositoryFactory.clearInstance()
        if Hippolyte.shared.isStarted {
            Hippolyte.shared.stop()
        }
    }

    func testListPrepaidCardReceipt_success() {
        var prepaidCardReceiptList = [HyperwalletReceipt]()
        HyperwalletTestHelper.setUpMockServer(
            request: ReceiptRequestHelper.setUpRequest(listPrepaidCardReceiptPayload,
                                                       nil,
                                                       "trm-123456789"))
        prepaidCardReceiptRepository.listPrepaidCardReceipts(
            prepaidCardToken: "trm-123456789"
        ) { [weak receiptExpectation ] result in
            switch result {
            case .success(let receiptPageList):
                guard let receiptPageList = receiptPageList else {
                    XCTFail("The Prepaid Card receipt list should not be empty")
                    return
                }
                prepaidCardReceiptList = receiptPageList.data!
                receiptExpectation?.fulfill()

            case .failure:
                XCTFail("Unexpected error")
            }
        }
        wait(for: [receiptExpectation], timeout: 1)
        XCTAssertFalse(prepaidCardReceiptList.isEmpty, "The Prepaid Card receipt list should not be empty")
    }

    func testListPrepaidCardReceipt_failure() {
        HyperwalletTestHelper.setUpMockServer(
            request: ReceiptRequestHelper.setUpRequest(listPrepaidCardReceiptPayload,
                                                       NSError(domain: NSURLErrorDomain, code: 500, userInfo: nil),
                                                       "trm-123456789"))
        prepaidCardReceiptRepository.listPrepaidCardReceipts(
            prepaidCardToken: "trm-123456789"
        ) { [weak receiptExpectation ] result in
            switch result {
            case .success:
                XCTFail("The listPrepaidCardReceipts method should return Error")

            case .failure(let error):
                XCTAssertNotNil(error, "Error should not be nil")
                receiptExpectation?.fulfill()
            }
        }
        wait(for: [receiptExpectation], timeout: 1)
    }
}
