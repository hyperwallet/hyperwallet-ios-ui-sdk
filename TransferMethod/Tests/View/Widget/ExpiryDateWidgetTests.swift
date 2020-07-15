import HyperwalletSDK
@testable import TransferMethod
import XCTest

class ExpiryDateWidgetTests: XCTestCase {
    private var expiryDateWidget: ExpiryDateWidget!
    private var inputText: String?
    private var pattern: String?
    private var expectedFormattedText: String?
    private var expectedFormattedTextForApi: String?

    override func setUp() {
        let coder = NSKeyedUnarchiver(forReadingWith: NSMutableData() as Data)
        expiryDateWidget = ExpiryDateWidget(coder: coder)
    }

    func testFormat() {
        let formattedText = expiryDateWidget.formatDisplayString(with: pattern ?? "", inputText: inputText ?? "")
        XCTAssertEqual(formattedText,
                       self.expectedFormattedText,
                       "formatted text should be \(self.expectedFormattedText!)")
        // Now format the text to be compatible with API
        let formattedTextForApi = expiryDateWidget.formatExpiryDateForApi(formattedText)
        XCTAssertEqual(formattedTextForApi,
                       self.expectedFormattedTextForApi,
                       "Text for API should be \(self.expectedFormattedTextForApi!)")
    }

    override static var defaultTestSuite: XCTestSuite {
        let testSuite = XCTestSuite(name: String(describing: self))
        let testParameters = getTestParameters()

        for testParameter in testParameters {
            addTest(pattern: testParameter[0],
                    inputText: testParameter[1],
                    expectedFormattedText: testParameter[2],
                    expectedFormattedTextForApi: testParameter[3],
                    toTestSuite: testSuite)
        }
        return testSuite
    }

    private static func addTest(pattern: String,
                                inputText: String,
                                expectedFormattedText: String,
                                expectedFormattedTextForApi: String,
                                toTestSuite testSuite: XCTestSuite) {
        testInvocations.forEach { invocation in
            let testCase = ExpiryDateWidgetTests(invocation: invocation)
            testCase.inputText = inputText
            testCase.pattern = pattern
            testCase.expectedFormattedText = expectedFormattedText
            testCase.expectedFormattedTextForApi = expectedFormattedTextForApi
            testSuite.addTest(testCase)
        }
    }

    private static func getTestParameters() -> [[String]] {
        let pattern = "##/##"
        // Each test parameter describes: pattern, inputText, expectedFormattedText, expectedFormattedTextForApi
        let testParameters = [
            [pattern, "", "", ""],
            [pattern, "1", "1", ""],
            [pattern, "11", "11", ""],
            [pattern, "111", "11/1", "0001-11"],
            [pattern, "1111", "11/11", "2011-11"],
            [pattern, "11/11", "11/11", "2011-11"],
            [pattern, "11/111", "11/11", "2011-11"]
        ]
        return testParameters
    }
}
