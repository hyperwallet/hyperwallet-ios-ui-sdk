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
    private var mockInsights = MockInsights()

    override func setUp() {
        HyperwalletUI.setup(HyperwalletTestHelper.authenticationProvider)
        HyperwalletInsights.setup()
        self.hyperwalletInsights = HyperwalletInsights.shared
        hyperwalletInsights?.insights = mockInsights
    }

    func testTrackImpression() {
        XCTAssertNotNil(HyperwalletInsights.shared, "HyperwalletInsights should be initialized")
        let params = [countryTag: country, currencyTag: currency]
        HyperwalletInsights.shared.trackImpression(pageName: pageName, pageGroup: pageGroup, params: params)
        XCTAssertTrue(mockInsights.didTrackImpression, "HyperwalletInsights.trackImpression should be called")
        XCTAssertEqual(mockInsights.pageName, pageName, "Page name should be as expected")
        XCTAssertEqual(mockInsights.pageGroup, pageGroup, "Page group should as expected")
        XCTAssertNotNil(mockInsights.params[countryTag], "Params should have country")
        XCTAssertNotNil(mockInsights.params[currencyTag], "Params should have currency")
    }

    func testTrackClick() {
        XCTAssertNotNil(HyperwalletInsights.shared, "HyperwalletInsights should be initialized")
        let params = [countryTag: country, currencyTag: currency]
        HyperwalletInsights.shared.trackClick(pageName: pageName, pageGroup: pageGroup, link: link, params: params)
        XCTAssertTrue(mockInsights.didTrackClick, "HyperwalletInsights.trackClick should be called")
        XCTAssertEqual(mockInsights.pageName, pageName, "Page name should be as expected")
        XCTAssertEqual(mockInsights.pageGroup, pageGroup, "Page group should as expected")
        XCTAssertEqual(mockInsights.link, link, "Link should be as expected")
        XCTAssertNotNil(mockInsights.params[countryTag], "Params should have country")
        XCTAssertNotNil(mockInsights.params[currencyTag], "Params should have currency")
    }

    func testTrackError() {
        XCTAssertNotNil(HyperwalletInsights.shared, "HyperwalletInsights should be initialized")
        let errorInfo = ErrorInfoBuilder(type: "errorInfo_type", message: "errorInfo_message")
            .fieldName("errorInfo_fieldName")
            .description("errorInfo_description")
            .code("errorInfo_code")
            .build()

        HyperwalletInsights.shared.trackError(pageName: pageName, pageGroup: pageGroup, errorInfo: errorInfo)

        XCTAssertTrue(mockInsights.didTrackError, "HyperwalletInsights.trackError should be called")
        XCTAssertEqual(mockInsights.pageName, pageName, "Page name should be as expected")
        XCTAssertEqual(mockInsights.pageGroup, pageGroup, "Page group should be as expected")
        XCTAssertNotNil(mockInsights.errorInfo, "ErrorInfo shouldn't be empty")
    }

    func testTrackClick_InsightsNotInitialized() {
        hyperwalletInsights?.insights = nil
        XCTAssertNotNil(HyperwalletInsights.shared, "HyperwalletInsights should be initialized")
        let params = [countryTag: country, currencyTag: currency]
        HyperwalletInsights.shared.trackClick(pageName: pageName, pageGroup: pageGroup, link: link, params: params)
        XCTAssertNotNil(hyperwalletInsights?.insights, "Insights should be reloaded if nil")
    }

    func testTrackImpression_InsightsNotInitialized() {
        hyperwalletInsights?.insights = nil
        XCTAssertNotNil(HyperwalletInsights.shared, "HyperwalletInsights should be initialized")
        let params = [countryTag: country, currencyTag: currency]
        HyperwalletInsights.shared.trackImpression(pageName: pageName, pageGroup: pageGroup, params: params)
        XCTAssertNotNil(hyperwalletInsights?.insights, "Insights should be reloaded if nil")
    }

    func testTrackError_InsightsNotInitialized() {
        hyperwalletInsights?.insights = nil
        XCTAssertNotNil(HyperwalletInsights.shared, "HyperwalletInsights should be initialized")
        let errorInfo = ErrorInfoBuilder(type: "errorInfo_type", message: "errorInfo_message")
            .fieldName("errorInfo_fieldName")
            .description("errorInfo_description")
            .code("errorInfo_code")
            .build()
        HyperwalletInsights.shared.trackError(pageName: pageName, pageGroup: pageGroup, errorInfo: errorInfo)
        XCTAssertNotNil(hyperwalletInsights?.insights, "Insights should be reloaded if nil")
    }
}

class MockInsights: InsightsProtocol {
    var didTrackClick = false
    var didTrackImpression = false
    var didTrackError = false
    var pageName = ""
    var pageGroup = ""
    var params = [String: String]()
    var link = ""
    var errorInfo: ErrorInfo!

    func trackClick(pageName: String, pageGroup: String, link: String, params: [String: String]) {
        self.pageGroup = pageGroup
        self.pageName = pageName
        self.link = link
        self.params = params
        didTrackClick = true
    }

    func trackImpression(pageName: String, pageGroup: String, params: [String: String]) {
        self.pageGroup = pageGroup
        self.pageName = pageName
        self.params = params
        didTrackImpression = true
    }

    func trackError(pageName: String, pageGroup: String, errorInfo: ErrorInfo) {
        self.pageGroup = pageGroup
        self.pageName = pageName
        self.errorInfo = errorInfo
        didTrackError = true
    }

    func resetStates() {
        didTrackClick = false
        didTrackImpression = false
        didTrackError = false
        pageName = ""
        pageGroup = ""
        params = [String: String]()
        link = ""
    }
}
