import XCTest

extension XCTestCase {
    func waitForNonExistence(_ element: XCUIElement) {
        let predicate = NSPredicate(format: "exists == false")
        let expectation1 = expectation(for: predicate,
                                       evaluatedWith: element,
                                       handler: nil)

        XCTWaiter().wait(for: [expectation1], timeout: 10)
    }

    func waitForExistence(_ element: XCUIElement,
                          file: StaticString = #file,
                          line: UInt = #line ) {
        XCTAssertTrue(element.waitForExistence(timeout: 10), file: file, line: line)
    }
}
