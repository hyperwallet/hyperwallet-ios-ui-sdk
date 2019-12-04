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
        let formattedText = textWidget.formatDisplayString(with: pattern ?? "", inputText: inputText ?? "")
        XCTAssertEqual(formattedText, self.expectedFormattedText)
    }

    override static var defaultTestSuite: XCTestSuite {
        let testSuite = XCTestSuite(name: NSStringFromClass(self))
        let testParameters = getTestParameters()

        for testParameter in testParameters {
            addTest(pattern: testParameter[0],
                    inputText: testParameter[1],
                    expectedFormattedText: testParameter[2],
                    toTestSuite: testSuite)
        }
        return testSuite
    }

    private static func addTest(pattern: String,
                                inputText: String,
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

    // swiftlint:disable function_body_length
    private static func getTestParameters() -> [[String]] {
        let testParameters = [
            ["#", "1", "1"],
            ["#", "11", "1"],
            ["#", "a", ""],
            ["#", "a1", "1"],
            ["#", "", ""],
            ["##", "11", "11"],
            ["##", "1111", "11"],
            ["##", "aa11", "11"],
            ["##", "1a1a", "11"],
            ["##", "", ""],
            ["##-##", "11", "11"],
            ["##-##", "1111", "11-11"],
            ["##-##", "aa11aa11", "11-11"],
            ["##-##", "11-11", "11-11"],
            ["##-##", "aa-aa-1111", "11-11"],
            ["A##B##", "11", "A11"],
            ["A##B##", "111", "A11B1"],
            ["A##B##", "A11B11", "A11B11"],
            ["A##B##", "AAA11BBB11", "A11B11"],
            ["A##B##", "", ""],
            ["##\\###", "111", "11#1"], // fixed
            ["##\\###", "1111", "11#11"],
            ["##\\###", "aa11aa11", "11#11"],
            ["##\\###", "11-11", "11#11"],
            ["##\\###", "aa-aa-1111", "11#11"],
            ["@", "a", "a"],
            ["@", "aa", "a"],
            ["@", "1", ""],
            ["@", "1a", "a"],
            ["@", "", ""],
            ["@@", "aa", "aa"],
            ["@@", "aaaa", "aa"],
            ["@@", "11aa", "aa"],
            ["@@", "a1a1", "aa"],
            ["@@", "", ""],
            ["@@-@@", "aa", "aa"],
            ["@@-@@", "aaaa", "aa-aa"],
            ["@@-@@", "11aa11aa", "aa-aa"],
            ["@@-@@", "aa-aa", "aa-aa"],
            ["@@-@@", "11-11-aaaa", "aa-aa"],
            ["1@@2@@", "aa", "1aa"],
            ["1@@2@@", "aaa", "1aa2a"],
            ["1@@2@@", "1aa2aa", "1aa2aa"],
            ["1@@2@@", "111aa222bb", "1aa2bb"],
            ["1@@2@@", "", ""],
            ["@@\\@@@", "aaa", "aa@a"], // fixed
            ["@@\\@@@", "aaaa", "aa@aa"],
            ["@@\\@@@", "11aa11aa", "aa@aa"],
            ["@@\\@@@", "aa-aa", "aa@aa"],
            ["@@\\@@@", "11-11-aaaa", "aa@aa"],
            ["*", "1", "1"], ["*", "11", "1"],
            ["*", "a", "a"], ["*", "a1", "a"],
            ["*", "", ""], ["**", "aa", "aa"],
            ["**", "aaaa", "aa"],
            ["**", "11aa", "11"],
            ["**", "a1a1", "a1"],
            ["**", "", ""],
            ["**-**", "11", "11"],
            ["**-**", "1111", "11-11"],
            ["**-**", "aa11aa11", "aa-11"],
            ["**-**", "11-11", "11-11"],
            ["**-**", "aa-aa-1111", "aa-aa"],
            ["**-**", "11-", "11"],
            ["1**A**", "aa", "1aa"],
            ["1**A**", "aaa", "1aaAa"],
            ["1**A**", "1aa2aa", "1aaA2a"],
            ["1**A**", "111aa222bb", "111Aaa"],
            ["1**A**", "", ""],
            ["**\\***", "111", "11*1"], // fixed
            ["**\\***", "1111", "11*11"],
            ["**\\***", "aa11aa11", "aa*11"],
            ["**\\***", "11-NOV", "11*NO"], // fixed
            ["**\\***", "aa-aa-1111", "aa*aa"], // fixed
            ["#@*", "aaa", ""],
            ["#@*", "111", "1"],
            ["#@*", "1ab", "1ab"],
            ["#@*", "ba1", "1"],
            ["#@*", "1ab1", "1ab"],
            ["#@*#@*", "aaaaaa", ""],
            ["#@*#@*", "111111", "1"],
            ["#@*#@*", "1a11a1", "1a11a1"],
            ["#@*#@*", "a1aa1a", "1aa1a"],
            ["#@*#@*", "-1a-", "1a"],
            ["#@*-@#*", "aaaaaa", ""],
            ["#@*-@#*", "111111", "1"],
            ["#@*-@#*", "1a11a1", "1a1-a1"],
            ["#@*-@#*", "-12ab-12ab", "1ab-a"],
            ["#@*-@#*", "", ""],
            ["^#@*-@#*", "aaaaaa", ""],
            ["^#@*-@#*", "111111", "^1"],
            ["^#@*-@#*", "1a11a1", "^1a1-a1"],
            ["^#@*-@#*", "-12ab-12ab", "^1ab-a"],
            ["^#@*-@#*", "", ""],
            ["\\@@#*\\#@#*\\*@#*", "aaaaaa", "@a"],
            ["\\@@#*\\#@#*\\*@#*", "111111", "@"],
            ["\\@@#*\\#@#*\\*@#*", "a1aa1a", "@a1a#a1a"],
            ["\\@@#*\\#@#*\\*@#*", "@a1a#a1a*a1a", "@a1a#a1a*a1a"],
            ["@#@ #@#", "V1B2N3", "V1B 2N3"],
            ["###", "A123", "123"],
            ["#### #### #### ####", "4123567891234567", "4123 5678 9123 4567"],
            ["#### ###### #####", "347356789134567", "3473 567891 34567"],
            ["Hello: @@@@@", "Hello: abcde", "Hello: abcde"],
            ["", "", ""],
            ["###-##\\", "12345", "123-45"],
            ["###-##\\\\", "123456", "123-45\\"],
            ["###-##\\\\9", "123459", "123-45\\9"],
            ["###-##\\9", "123459", "123-459"]
        ]
        return testParameters
    }
}
