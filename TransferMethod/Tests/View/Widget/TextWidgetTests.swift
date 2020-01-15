import HyperwalletSDK
@testable import TransferMethod
import XCTest

class TextWidgetTests: XCTestCase {
    private var textWidget: TextWidget!
    private var inputText: String?
    private var pattern: String?
    private var expectedFormattedText: String?
    private var scrubRegex: String?
    private var expectedScrubbedText: String?

    override func setUp() {
        let coder = NSKeyedUnarchiver(forReadingWith: NSMutableData() as Data)
        textWidget = TextWidget(coder: coder)
    }

    func testFormatAndScrub() {
        let formattedText = textWidget.formatDisplayString(with: pattern ?? "", inputText: inputText ?? "")
        XCTAssertEqual(formattedText,
                       self.expectedFormattedText,
                       "formatted text should be \(self.expectedFormattedText!)")
        // Now scrub the formatted text
        let scrubbedText = textWidget.getScrubbedText(formattedText: formattedText, scrubRegex: self.scrubRegex ?? "")
        XCTAssertEqual(scrubbedText, self.expectedScrubbedText, "Scrubbed text should be \(self.expectedScrubbedText!)")
    }

    func testGetApplicablePattern() {
        let fieldData = HyperwalletTestHelper.getDataFromJson("HyperwalletFieldResponseWithPattern")
        guard let field = try? JSONDecoder().decode(HyperwalletField.self, from: fieldData) else {
            XCTFail("Can't decode HyperwalletField from test data")
            return
        }
        let textWidget = TextWidget(field: field,
                                    pageName: AddTransferMethodPresenter.addTransferMethodPageName,
                                    pageGroup: AddTransferMethodPresenter.addTransferMethodPageGroup)

        var returnedPattern = textWidget.getFormatPattern(inputText: "41")
        XCTAssertEqual(returnedPattern, "######## ########", "Formatted text should be ######## ########")
        returnedPattern = textWidget.getFormatPattern(inputText: "46")
        XCTAssertEqual(returnedPattern, "# ###############", "Formatted text should be # ###############")
        returnedPattern = textWidget.getFormatPattern(inputText: "50")
        XCTAssertEqual(returnedPattern, "### ######### ####", "Formatted text should be ### ######### ####")
        returnedPattern = textWidget.getFormatPattern(inputText: "56")
        XCTAssertEqual(returnedPattern, "#### #### #### ####", "Formatted text should be #### #### #### ####")
    }

    override static var defaultTestSuite: XCTestSuite {
        let testSuite = XCTestSuite(name: String(describing: self))
        let testParameters = getTestParameters()

        for testParameter in testParameters {
            addTest(pattern: testParameter[0],
                    inputText: testParameter[1],
                    expectedFormattedText: testParameter[2],
                    scrubRegex: testParameter[3],
                    expectedScrubbedText: testParameter[4],
                    toTestSuite: testSuite)
        }
        return testSuite
    }

    // swiftlint:disable function_parameter_count
    private static func addTest(pattern: String,
                                inputText: String,
                                expectedFormattedText: String,
                                scrubRegex: String,
                                expectedScrubbedText: String,
                                toTestSuite testSuite: XCTestSuite) {
        testInvocations.forEach { invocation in
            let testCase = TextWidgetTests(invocation: invocation)
            testCase.inputText = inputText
            testCase.pattern = pattern
            testCase.expectedFormattedText = expectedFormattedText
            testCase.scrubRegex = scrubRegex
            testCase.expectedScrubbedText = expectedScrubbedText
            testSuite.addTest(testCase)
        }
    }

    // swiftlint:disable function_body_length
    private static func getTestParameters() -> [[String]] {
        // Each test parameter describes: pattern, inputText, expectedFormattedText, scrubRegex, expectedScrubbedText
        let testParameters = [
            ["#", "1", "1", "\\s", "1"],
            ["#", "11", "1", "\\s", "1"],
            ["#", "a", "", "\\s", ""],
            ["#", "a1", "1", "\\s", "1"],
            ["#", "", "", "\\s", ""],
            ["##", "11", "11", "\\s", "11"],
            ["##", "1111", "11", "\\s", "11"],
            ["##", "aa11", "11", "\\s", "11"],
            ["##", "1a1a", "11", "\\s", "11"],
            ["##", "", "", "\\s", ""],
            ["##-##", "11", "11", "\\s", "11"],
            ["##-##", "1111", "11-11", "\\-", "1111"],
            ["##-##", "aa11aa11", "11-11", "\\-", "1111"],
            ["##-##", "11-11", "11-11", "\\-", "1111"],
            ["##-##", "aa-aa-1111", "11-11", "\\s", "11-11"],
            ["A##B##", "11", "A11", "\\s", "A11"],
            ["A##B##", "111", "A11B1", "\\s", "A11B1"],
            ["A##B##", "A11B11", "A11B11", "\\s", "A11B11"],
            ["A##B##", "AAA11BBB11", "A11B11", "\\s", "A11B11"],
            ["A##B##", "", "", "\\s", ""],
            ["##\\###", "11", "11", "\\#", "11"],
            ["##\\###", "1111", "11#11", "\\#", "1111"],
            ["##\\###", "aa11aa11", "11#11", "\\s", "11#11"],
            ["##\\###", "11-11", "11#11", "\\s", "11#11"],
            ["##\\###", "aa-aa-1111", "11#11", "\\s", "11#11"],
            ["@", "a", "a", "\\s", "a"],
            ["@", "aa", "a", "\\s", "a"],
            ["@", "1", "", "\\s", ""],
            ["@", "1a", "a", "\\s", "a"],
            ["@", "", "", "\\s", ""],
            ["@@", "aa", "aa", "\\s", "aa"],
            ["@@", "aaaa", "aa", "\\s", "aa"],
            ["@@", "11aa", "aa", "\\s", "aa"],
            ["@@", "a1a1", "aa", "\\s", "aa"],
            ["@@", "", "", "\\s", ""],
            ["@@-@@", "aa", "aa", "\\s", "aa"],
            ["@@-@@", "aaaa", "aa-aa", "\\-", "aaaa"],
            ["@@-@@", "11aa11aa", "aa-aa", "\\s", "aa-aa"],
            ["@@-@@", "aa-aa", "aa-aa", "\\-", "aaaa"],
            ["@@-@@", "11-11-aaaa", "aa-aa", "\\-", "aaaa"],
            ["1@@2@@", "aa", "1aa", "1", "aa"],
            ["1@@2@@", "aaa", "1aa2a", "\\s", "1aa2a"],
            ["1@@2@@", "1aa2aa", "1aa2aa", "\\s", "1aa2aa"],
            ["1@@2@@", "111aa222bb", "1aa2bb", "2", "1aabb"],
            ["1@@2@@", "", "", "\\s", ""],
            ["@@\\@@@", "aa", "aa", "\\s", "aa"],
            ["@@\\@@@", "aaaa", "aa@aa", "\\@", "aaaa"],
            ["@@\\@@@", "11aa11aa", "aa@aa", "\\@", "aaaa"],
            ["@@\\@@@", "aa-aa", "aa@aa", "\\@", "aaaa"],
            ["@@\\@@@", "11-11-aaaa", "aa@aa", "\\@", "aaaa"],
            ["*", "1", "1", "\\s", "1"],
            ["*", "11", "1", "\\s", "1"],
            ["*", "a", "a", "\\s", "a"],
            ["*", "a1", "a", "\\s", "a"],
            ["*", "", "", "\\s", ""],
            ["**", "aa", "aa", "\\s", "aa"],
            ["**", "aaaa", "aa", "\\s", "aa"],
            ["**", "11aa", "11", "\\s", "11"],
            ["**", "a1a1", "a1", "\\s", "a1"],
            ["**", "", "", "\\s", ""],
            ["**-**", "11", "11", "\\s", "11"],
            ["**-**", "1111", "11-11", "\\-", "1111"],
            ["**-**", "aa11aa11", "aa-11", "\\-", "aa11"],
            ["**-**", "11-11", "11-11", "\\s", "11-11"],
            ["**-**", "aa-aa-1111", "aa-aa", "\\-", "aaaa"],
            ["**-**", "11-", "11", "\\s", "11"],
            ["1**A**", "aa", "1aa", "\\s", "1aa"],
            ["1**A**", "aaa", "1aaAa", "\\s", "1aaAa"],
            ["1**A**", "1aa2aa", "1aaA2a", "A", "1aa2a"],
            ["1**A**", "111aa222bb", "111Aaa", "\\s", "111Aaa"],
            ["1**A**", "", "", "\\s", ""],
            ["**\\***", "11", "11", "\\s", "11"],
            ["**\\***", "1111", "11*11", "\\s", "11*11"],
            ["**\\***", "aa11aa11", "aa*11", "\\s", "aa*11"],
            ["**\\***", "11-NOV", "11*NO", "\\*", "11NO"],
            ["**\\***", "aa-aa-1111", "aa*aa", "\\*", "aaaa"],
            ["#@*", "aaa", "", "\\s", ""],
            ["#@*", "111", "1", "\\s", "1"],
            ["#@*", "1ab", "1ab", "\\s", "1ab"],
            ["#@*", "ba1", "1", "\\s", "1"],
            ["#@*", "1ab1", "1ab", "\\s", "1ab"],
            ["#@*#@*", "aaaaaa", "", "\\s", ""],
            ["#@*#@*", "111111", "1", "\\s", "1"],
            ["#@*#@*", "1a11a1", "1a11a1", "a", "1111"],
            ["#@*#@*", "a1aa1a", "1aa1a", "\\s", "1aa1a"],
            ["#@*#@*", "-1a-", "1a", "\\s", "1a"],
            ["#@*-@#*", "aaaaaa", "", "\\s", ""],
            ["#@*-@#*", "111111", "1", "\\s", "1"],
            ["#@*-@#*", "1a11a1", "1a1-a1", "\\-", "1a1a1"],
            ["#@*-@#*", "-12ab-12ab", "1ab-a", "\\-", "1aba"],
            ["#@*-@#*", "", "", "\\s", ""],
            ["^#@*-@#*", "aaaaaa", "", "\\s", ""],
            ["^#@*-@#*", "111111", "^1", "\\s", "^1"],
            ["^#@*-@#*", "1a11a1", "^1a1-a1", "\\s", "^1a1-a1"],
            ["^#@*-@#*", "-12ab-12ab", "^1ab-a", "\\s", "^1ab-a"],
            ["^#@*-@#*", "", "", "\\s", ""],
            ["\\@@#*\\#@#*\\*@#*", "aaaaaa", "@a", "\\s", "@a"],
            ["\\@@#*\\#@#*\\*@#*", "111111", "@", "\\s", "@"],
            ["\\@@#*\\#@#*\\*@#*", "a1aa1a", "@a1a#a1a", "\\s", "@a1a#a1a"],
            ["\\@@#*\\#@#*\\*@#*", "@a1a#a1a*a1a", "@a1a#a1a*a1a", "\\s", "@a1a#a1a*a1a"],
            ["@#@ #@#", "V1B2N3", "V1B 2N3", "\\s", "V1B2N3"],
            ["###", "A123", "123", "", "123"],
            ["#### #### #### ####", "4123567891234567", "4123 5678 9123 4567", "\\s", "4123567891234567"],
            ["####-####-####-####", "4123567891234567", "4123-5678-9123-4567", "\\-", "4123567891234567"],
            ["#### ###### #####", "347356789134567", "3473 567891 34567", "\\s", "347356789134567"],
            ["Hello: @@@@@", "Hello: abcde", "Hello: abcde", "\\s", "Hello:abcde"],
            ["", "", "", "", ""],
            ["###-##\\", "12345", "123-45", "", "123-45"],
            ["###-##\\\\", "123456", "123-45\\", "", "123-45\\"],
            ["##\\\\##", "1111", "11\\11", "", "11\\11"],
            ["###-##\\\\9", "123459", "123-45\\9", "", "123-45\\9"],
            ["(###)###-####", "1234591111", "(123)459-1111", "([()-])", "1234591111"],
            ["#(604)-######", "6123", "6(604)-123", "([()-])", "6604123"],
            ["#(604)-######", "6abc45678", "6(604)-45678", "([()-])", "660445678"],
            ["778-###-####", "1237777", "778-123-7777", "([()-])", "7781237777"]
        ]
        return testParameters
    }
}
