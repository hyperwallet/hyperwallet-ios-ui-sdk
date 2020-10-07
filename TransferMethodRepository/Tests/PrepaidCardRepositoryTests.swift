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

class PrepaidCardRepositoryTests: XCTestCase {
    private var prepaidCardRepository: PrepaidCardRepository!

    override func setUp() {
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        prepaidCardRepository = TransferMethodRepositoryFactory.shared.prepaidCardRepository()
    }

    override func tearDown() {
        prepaidCardRepository.refreshPrepaidCard()
        prepaidCardRepository.refreshPrepaidCards()
        if Hippolyte.shared.isStarted {
            Hippolyte.shared.stop()
        }
    }

    func testGetPrepaidCard_success() {
        // Given
        let expectation = self.expectation(description: "Get prepaid card completed")
        let response = HyperwalletTestHelper.okHTTPResponse(for: "PrepaidCardResponse")
        let url = String(format: "%@/prepaid-cards/trm-123", HyperwalletTestHelper.userRestURL)
        let request = HyperwalletTestHelper.buildGetRequest(baseUrl: url, response)
        HyperwalletTestHelper.setUpMockServer(request: request)

        var prepaidCard: HyperwalletPrepaidCard?
        var errorType: HyperwalletErrorType?

        // When
        Hyperwallet.shared.getPrepaidCard(transferMethodToken: "trm-123") { (result, error) in
            prepaidCard = result
            errorType = error
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertNil(errorType, "The `errorType` should be nil")
        XCTAssertEqual(prepaidCard?.cardBrand, "VISA")
        XCTAssertEqual(prepaidCard?.type, HyperwalletTransferMethod.TransferMethodType.prepaidCard.rawValue)
        XCTAssertEqual(prepaidCard?.token, "trm-123", "The token should be trm-123")
        XCTAssertEqual(prepaidCard?.status,
                       HyperwalletPrepaidCardQueryParam.QueryStatus.activated.rawValue,
                       "The status should be ACTIVATED")
        XCTAssertEqual(prepaidCard?.transferMethodCountry, "CA", "The country code should be CA")
        XCTAssertEqual(prepaidCard?.transferMethodCurrency, "USD", "The currency code should be USD")

        XCTAssertEqual(prepaidCard?.cardNumber, "************6198", "The cardNumber should be ************6198")
        XCTAssertEqual(prepaidCard?.dateOfExpiry, "2023-06", "The dateOfExpiry should be 2023-06")
        XCTAssertEqual(prepaidCard?.cardPackage, "L1", "The cardPackage should be L1")
        XCTAssertEqual(prepaidCard?.createdOn,
                       "2019-06-20T21:21:43",
                       "The createdOn should be 2019-06-20T21:21:43")
    }

    func testGetPrepaidCard_emptyResult() {
        // Given
        let expectation = self.expectation(description: "Get prepaid card completed")
        let response = HyperwalletTestHelper.noContentHTTPResponse()
        let url = String(format: "%@/prepaid-cards/trm-123", HyperwalletTestHelper.userRestURL)
        let request = HyperwalletTestHelper.buildGetRequest(baseUrl: url, response)
        HyperwalletTestHelper.setUpMockServer(request: request)

        var prepaidCard: HyperwalletPrepaidCard?
        var errorType: HyperwalletErrorType?

        Hyperwallet.shared.getPrepaidCard(transferMethodToken: "trm-123") { (result, error) in
            prepaidCard = result
            errorType = error
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertNil(errorType, "The `errorType` response should be nil")
        XCTAssertNil(prepaidCard, "The `prepaidCard` should be nil")
    }

    func testListPrepaidCards_success() {
        // Given
        let expectation = self.expectation(description: "List prepaid cards completed")
        let response = HyperwalletTestHelper.okHTTPResponse(for: "ListPrepaidCardResponse")
        let url = String(format: "%@/prepaid-cards?+", HyperwalletTestHelper.userRestURL)
        let request = HyperwalletTestHelper.buildGetRequestRegexMatcher(pattern: url, response)
        HyperwalletTestHelper.setUpMockServer(request: request)

        var prepaidCardList: HyperwalletPageList<HyperwalletPrepaidCard>?
        var errorType: HyperwalletErrorType?

        // When
        let prepaidCardQueryParam = HyperwalletPrepaidCardQueryParam()
        prepaidCardQueryParam.status = .activated

        Hyperwallet.shared.listPrepaidCards(queryParam: prepaidCardQueryParam) { (result, error) in
            prepaidCardList = result
            errorType = error
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertNil(errorType, "The `errorType` should be nil")
        XCTAssertNotNil(prepaidCardList, "The `prepaidCardList` should not be nil")
        XCTAssertEqual(prepaidCardList?.count, 2, "The `count` should be 2")
        XCTAssertNotNil(prepaidCardList?.data, "The `data` should be not nil")

        XCTAssertNotNil(prepaidCardList?.links, "The `links` should be not nil")

        let firstPrepaidCard = prepaidCardList?.data?.first
        XCTAssertEqual(firstPrepaidCard?.type, "PREPAID_CARD", "The type should be PREPAID_CARD")
        XCTAssertEqual(firstPrepaidCard?.token, "trm-123", "The token should be trm-123")
        XCTAssertEqual(firstPrepaidCard?.status,
                       HyperwalletPrepaidCardQueryParam.QueryStatus.activated.rawValue,
                       "The status should be ACTIVATED")
        XCTAssertEqual(firstPrepaidCard?.transferMethodCountry, "CA", "The country code should be CA")
        XCTAssertEqual(firstPrepaidCard?.transferMethodCurrency, "USD", "The currency code should be USD")

        XCTAssertEqual(firstPrepaidCard?.cardNumber, "************6198", "The cardNumber should be ************6198")
        XCTAssertEqual(firstPrepaidCard?.dateOfExpiry, "2023-06", "The dateOfExpiry should be 2023-06")
        XCTAssertEqual(firstPrepaidCard?.cardPackage, "L1", "The cardPackage should be L1")
        XCTAssertEqual(firstPrepaidCard?.createdOn,
                       "2019-06-20T21:21:43",
                       "The createdOn should be 2019-06-20T21:21:43")
    }

    func testListPrepaidCards_emptyResult() {
        // Given
        let expectation = self.expectation(description: "List prepaid cards completed")
        let response = HyperwalletTestHelper.noContentHTTPResponse()
        let url = String(format: "%@/prepaid-cards?+", HyperwalletTestHelper.userRestURL)
        let request = HyperwalletTestHelper.buildGetRequestRegexMatcher(pattern: url, response)
        HyperwalletTestHelper.setUpMockServer(request: request)

        var prepaidCardList: HyperwalletPageList<HyperwalletPrepaidCard>?
        var errorType: HyperwalletErrorType?

        // When
        let prepaidCardQueryParam = HyperwalletPrepaidCardQueryParam()
        prepaidCardQueryParam.status = HyperwalletPrepaidCardQueryParam.QueryStatus.activated
        prepaidCardQueryParam.sortBy = HyperwalletPrepaidCardQueryParam.QuerySortable.ascendantCreatedOn.rawValue
        prepaidCardQueryParam.createdAfter = ISO8601DateFormatter.ignoreTimeZone.date(from: "2019-01-01T00:30:11")

        Hyperwallet.shared.listPrepaidCards(queryParam: prepaidCardQueryParam) { (result, error) in
            prepaidCardList = result
            errorType = error
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertNil(errorType, "The `errorType` should be nil")
        XCTAssertNil(prepaidCardList, "The `prepaidCardList` should be nil")
    }
}
