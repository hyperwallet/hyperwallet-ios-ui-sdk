@testable import TransferMethod
import XCTest

class TextWidgetTests: XCTestCase {
    private var textWidget: TextWidget!
    private var inputText: String?
    private var pattern: String?
    private var expectedFormattedText: String?

    override func setUp() {
        let coder = NSKeyedUnarchiver(forReadingWith: NSMutableData() as Data)
        textWidget = TextWidget(coder: coder)
    }

    func testInputs() {
        let formattedText = textWidget.formatDisplayString(inputText: inputText ?? "", pattern: pattern ?? "")
        XCTAssertEqual(formattedText, self.expectedFormattedText)
    }

    override static var defaultTestSuite: XCTestSuite {
        let testSuite = XCTestSuite(name: NSStringFromClass(self))
        let testParameters = getTestParameters()

        for testParameter in testParameters {
            addTest(inputText: testParameter[0],
                    pattern: testParameter[1],
                    expectedFormattedText: testParameter[2],
                    toTestSuite: testSuite)
        }
        return testSuite
    }

    private static func addTest(inputText: String,
                                pattern: String,
                                expectedFormattedText: String,
                                toTestSuite testSuite: XCTestSuite) {
        testInvocations.forEach { invocation in
            let testCase = TextWidgetTests(invocation: invocation)
            testCase.inputText = inputText
            testCase.pattern = pattern
            testCase.expectedFormattedText = expectedFormattedText
            testSuite.addTest(testCase)
        }
    }

    private static func getTestParameters() -> [[String]] {
        var testParameters = [[String]]()
        testParameters.append(["1", "#", "1"])
        testParameters.append(["11", "#", "1"])
        testParameters.append(["a", "#", ""])
        testParameters.append(["a1", "#", "1"])
        testParameters.append(["", "#", ""])
        testParameters.append(["11", "##", "11"])
        testParameters.append(["1111", "##", "11"])
        testParameters.append(["aa11", "##", "11"])
        testParameters.append(["1a1a", "##", "11"])
        testParameters.append(["", "##", ""])
        testParameters.append(["11", "##-##", "11"])
        testParameters.append(["1111", "##-##", "11-11"])
        testParameters.append(["aa11aa11", "##-##", "11-11"])
        testParameters.append(["11-11", "##-##", "11-11"])
        testParameters.append(["aa-aa-1111", "##-##", "11-11"])
        return testParameters
    }
}
