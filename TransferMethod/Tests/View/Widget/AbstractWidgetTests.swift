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

#if !COCOAPODS
import Common
#endif
import HyperwalletSDK
@testable import TransferMethod
import XCTest

class AbstractWidgetTests: XCTestCase {
    private var hyperwalletInsightsMock = HyperwalletInsightsMock()
    let fieldData = HyperwalletTestHelper.getDataFromJson("HyperwalletFieldResponse")
    var textWidget: AbstractWidget!
    private var inputHandler: () -> Void = {}

    override func setUp() {
        guard let field = try? JSONDecoder().decode(HyperwalletField.self, from: fieldData) else {
            XCTFail("Can't decode HyperwalletField from test data")
            return
        }
        textWidget = TextWidget(field: field,
                                pageName: AddTransferMethodPresenter.addTransferMethodPageName,
                                pageGroup: AddTransferMethodPresenter.addTransferMethodPageGroup,
                                inputHandler: inputHandler)
        textWidget.hyperwalletInsights = hyperwalletInsightsMock
    }

    override func tearDown() {
        hyperwalletInsightsMock.resetStates()
    }

    func testWidgetFieldShouldNotBeEmpty() {
        XCTAssertNotNil(textWidget.field, "Field value was not initialized")
    }

    func testIsValid_false() {
        let isValid = textWidget.isValid()
        XCTAssertFalse(isValid, "Should be invalid")
        XCTAssertTrue(hyperwalletInsightsMock.didTrackError, "Track error should be called")
    }
}
