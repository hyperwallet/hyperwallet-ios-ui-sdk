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

@testable import Common
import Hippolyte
import Insights
import XCTest

class HyperwalletInsightsTests: XCTestCase {
    private var hyperwalletInsights: HyperwalletInsights?
    private let pageName = "transfer-method:add:select-transfer-method"
    private let pageGroup = "transfer-method"
    private let country = "US"
    private let currency = "USD"
    private let countryTag = "hyperwallet_ea_country"
    private let currencyTag = "hyperwallet_ea_currency"
    private let link = "test.link"
    private var insightsMock: InsightsMock!

    override func setUp() {
        if self.name.contains("testTrackError_ConfigNotInitialized") {
            return
        }
        HyperwalletUI.setup(HyperwalletTestHelper.authenticationProvider)
        HyperwalletInsights.setup()
        hyperwalletInsights = HyperwalletInsights.shared
        insightsMock = InsightsMock()
        hyperwalletInsights?.insights = insightsMock
    }

    override func tearDown() {
        insightsMock = nil
        hyperwalletInsights?.insights = nil
        hyperwalletInsights = nil
        AuthenticationTokenGeneratorMock.isConfigValid = true
        super.tearDown()
    }

    func testTrackImpression() {
        XCTAssertNotNil(HyperwalletInsights.shared, "HyperwalletInsights should be initialized")
        let params = [countryTag: country, currencyTag: currency]
        let expectation = self.expectation(description: InsightsMock.trackImpressionExpectation)
        insightsMock.expectations = [InsightsMock.trackImpressionExpectation: expectation]

        HyperwalletInsights.shared.trackImpression(pageName: pageName, pageGroup: pageGroup, params: params)
        wait(for: [expectation], timeout: 1)

        XCTAssertTrue(insightsMock.didTrackImpression, "HyperwalletInsights.trackImpression should be called")
        XCTAssertEqual(insightsMock.pageName, pageName, "Page name should be as expected")
        XCTAssertEqual(insightsMock.pageGroup, pageGroup, "Page group should as expected")
        XCTAssertNotNil(insightsMock.params[countryTag], "Params should have country")
        XCTAssertNotNil(insightsMock.params[currencyTag], "Params should have currency")
    }

    func testTrackClick() {
        XCTAssertNotNil(HyperwalletInsights.shared, "HyperwalletInsights should be initialized")
        let params = [countryTag: country, currencyTag: currency]
        let expectation = self.expectation(description: InsightsMock.trackClickExpectation)
        insightsMock.expectations = [InsightsMock.trackClickExpectation: expectation]

        HyperwalletInsights.shared.trackClick(pageName: pageName, pageGroup: pageGroup, link: link, params: params)
        wait(for: [expectation], timeout: 1)

        XCTAssertTrue(insightsMock.didTrackClick, "HyperwalletInsights.trackClick should be called")
        XCTAssertEqual(insightsMock.pageName, pageName, "Page name should be as expected")
        XCTAssertEqual(insightsMock.pageGroup, pageGroup, "Page group should as expected")
        XCTAssertEqual(insightsMock.link, link, "Link should be as expected")
        XCTAssertNotNil(insightsMock.params[countryTag], "Params should have country")
        XCTAssertNotNil(insightsMock.params[currencyTag], "Params should have currency")
    }

    func testTrackError() {
        XCTAssertNotNil(HyperwalletInsights.shared, "HyperwalletInsights should be initialized")
        let errorInfo = ErrorInfoBuilder(type: "errorInfo_type", message: "errorInfo_message")
            .fieldName("errorInfo_fieldName")
            .code("errorInfo_code")
            .build()
        let expectation = self.expectation(description: InsightsMock.trackErrorExpectation)
        insightsMock.expectations = [InsightsMock.trackErrorExpectation: expectation]

        HyperwalletInsights.shared.trackError(pageName: pageName, pageGroup: pageGroup, errorInfo: errorInfo)
        wait(for: [expectation], timeout: 1)

        XCTAssertTrue(insightsMock.didTrackError, "HyperwalletInsights.trackError should be called")
        XCTAssertEqual(insightsMock.pageName, pageName, "Page name should be as expected")
        XCTAssertEqual(insightsMock.pageGroup, pageGroup, "Page group should be as expected")
        XCTAssertNotNil(insightsMock.errorInfo, "ErrorInfo shouldn't be empty")
    }

    func testTrackClick_InsightsNotInitialized() {
        hyperwalletInsights?.insights = nil
        XCTAssertNotNil(HyperwalletInsights.shared, "HyperwalletInsights should be initialized")
        let params = [countryTag: country, currencyTag: currency]
        HyperwalletInsights.shared.trackClick(pageName: pageName, pageGroup: pageGroup, link: link, params: params)
        sleep(2)
        XCTAssertNotNil(hyperwalletInsights?.insights, "Insights should be reloaded if nil")
    }

    func testTrackImpression_InsightsNotInitialized() {
        hyperwalletInsights?.insights = nil
        XCTAssertNotNil(HyperwalletInsights.shared, "HyperwalletInsights should be initialized")
        let params = [countryTag: country, currencyTag: currency]
        HyperwalletInsights.shared.trackImpression(pageName: pageName, pageGroup: pageGroup, params: params)
        sleep(2)
        XCTAssertNotNil(hyperwalletInsights?.insights, "Insights should be reloaded if nil")
    }

    func testTrackError_InsightsNotInitialized() {
        hyperwalletInsights?.insights = nil
        XCTAssertNotNil(HyperwalletInsights.shared, "HyperwalletInsights should be initialized")
        let errorInfo = ErrorInfoBuilder(type: "errorInfo_type", message: "errorInfo_message")
            .fieldName("errorInfo_fieldName")
            .code("errorInfo_code")
            .build()
        HyperwalletInsights.shared.trackError(pageName: pageName, pageGroup: pageGroup, errorInfo: errorInfo)
        sleep(2)
        XCTAssertNotNil(hyperwalletInsights?.insights, "Insights should be reloaded if nil")
    }

    func testTrackError_ConfigNotInitialized() {
        AuthenticationTokenGeneratorMock.isConfigValid = false
        HyperwalletUI.setup(HyperwalletTestHelper.authenticationProvider)
        HyperwalletInsights.setup()

        XCTAssertNotNil(HyperwalletInsights.shared, "HyperwalletInsights should be initialized")
        XCTAssertNil(HyperwalletInsights.shared.insights, "Insights should be empty because of the wrong config")

        let errorInfo = ErrorInfoBuilder(type: "errorInfo_type", message: "errorInfo_message")
            .fieldName("errorInfo_fieldName")
            .code("errorInfo_code")
            .build()
        HyperwalletInsights.shared.trackError(pageName: pageName, pageGroup: pageGroup, errorInfo: errorInfo)

        sleep(2)

        XCTAssertNil(hyperwalletInsights?.insights, "Insights shouldn't be reloaded because of the wrong config")
    }
}

class InsightsMock: InsightsProtocol {
    static let trackClickExpectation = "trackClickExpectation"
    static let trackImpressionExpectation = "trackImpressionExpectation"
    static let trackErrorExpectation = "trackErrorExpectation"

    var didTrackClick = false
    var didTrackImpression = false
    var didTrackError = false
    var pageName = ""
    var pageGroup = ""
    var params = [String: String]()
    var link = ""
    var errorInfo: ErrorInfo!
    var expectations: [String: XCTestExpectation]?

    func trackClick(pageName: String, pageGroup: String, link: String, params: [String: String]) {
        self.pageGroup = pageGroup
        self.pageName = pageName
        self.link = link
        self.params = params
        didTrackClick = true
        expectations?[InsightsMock.trackClickExpectation]?.fulfill()
    }

    func trackImpression(pageName: String, pageGroup: String, params: [String: String]) {
        self.pageGroup = pageGroup
        self.pageName = pageName
        self.params = params
        didTrackImpression = true
        expectations?[InsightsMock.trackImpressionExpectation]?.fulfill()
    }

    func trackError(pageName: String, pageGroup: String, errorInfo: ErrorInfo) {
        self.pageGroup = pageGroup
        self.pageName = pageName
        self.errorInfo = errorInfo
        didTrackError = true
        expectations?[InsightsMock.trackErrorExpectation]?.fulfill()
    }

    func resetStates() {
        didTrackClick = false
        didTrackImpression = false
        didTrackError = false
        pageName = ""
        pageGroup = ""
        params = [String: String]()
        link = ""
        expectations = nil
    }
}
