import XCTest

extension XCTestCase {
    func waitForNonExistence(_ element: XCUIElement) {
        let predicate = NSPredicate(format: "exists == false")
        let expectation1 = expectation(for: predicate,
                                       evaluatedWith: element,
                                       handler: nil)

        XCTWaiter().wait(for: [expectation1], timeout: 5)
    }

    func waitForExistence(_ element: XCUIElement,
                          file: StaticString = #file,
                          line: UInt = #line ) {
        XCTAssertTrue(element.waitForExistence(timeout: 5), file: file, line: line)
    }

    func checkFieldExists(_ value: String,
                          input: XCUIElement,
                          label: XCUIElement,
                          message: String = "",
                          file: StaticString = #file,
                          line: UInt = #line) {
        var assertMessage = message.isEmpty
            ? "Label's text doesn't equal to \"\(value)\""
            : message
        XCTAssertEqual(label.label, value, assertMessage, file: file, line: line)
        assertMessage = message.isEmpty
            ? "Input element doesn't exist"
            : message
        XCTAssert(input.exists, assertMessage, file: file, line: line)
    }

    func checkSelectFieldValueIsEqualTo(_ value: String,
                                        _  field: XCUIElement,
                                        _  message: String = "",
                                        file: StaticString = #file,
                                        line: UInt = #line) {
        var assertMessage = message.isEmpty
            ? "Field doesn't exist"
            : message
        XCTAssert(field.exists, assertMessage, file: file, line: line)
        assertMessage = message.isEmpty
            ? "Field's value doesn't equal to \"\(value)\""
            : message

        sleep(1)
        XCTAssertEqual(field.value as? String, value, assertMessage, file: file, line: line)
    }
}
