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

import Foundation

import Hippolyte
import HyperwalletSDK
@testable import TransferMethodRepository
import XCTest

class TransferMethodUpdateConfigurationRepositoryTests: XCTestCase {
    private let transferMethodToken = "trm-00000001"
    private lazy var fieldsResponseData = HyperwalletTestHelper
        .getDataFromJson("TransferMethodUpdateConfigurationFieldsResponse")
    private static var userResponseData = HyperwalletTestHelper
        .getDataFromJson("UserIndividualResponse")

    override func setUp() {
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
    }

    override func tearDown() {
        if Hippolyte.shared.isStarted {
            Hippolyte.shared.stop()
        }
    }

    func testGetFields_success() {
        TransferMethodConfigurationRepositoryTests
            .setupResponseMockServer(fieldsResponseData)
        let expectation = self.expectation(description: "Get transfer method update configuration fields")
        let repository = RemoteTransferMethodUpdateConfigurationRepository()
        var transferMethodConfigurationField: HyperwalletTransferMethodUpdateConfigurationField?
        var error: HyperwalletErrorType?

        // When
        repository.getFields(transferMethodToken) { (result) in
            switch result {
            case .success(let resultField):
                transferMethodConfigurationField = resultField

            case .failure(let resultError):
                error = resultError
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)

        let fieldGroups = transferMethodConfigurationField!.transferMethodUpdateConfiguration()?.fieldGroups?.nodes
        let transferMethodType = transferMethodConfigurationField?
            .transferMethodUpdateConfiguration()?.transferMethodType

        XCTAssertNil(error, "The error should be nil")
        XCTAssertNotNil(transferMethodConfigurationField, "The result should not be nil")
        XCTAssertEqual(fieldGroups?.count,
                       1,
                       "`fieldGroups()` should be 1")
        XCTAssertEqual(transferMethodType,
                       HyperwalletTransferMethod.TransferMethodType.bankCard.rawValue,
                       "The transferMethodType()!.name` should be Bank Card")
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
        let refreshResponseData = HyperwalletTestHelper.getDataFromJson(jsonFileName)
        setupResponseMockServer(refreshResponseData)
    }
}
