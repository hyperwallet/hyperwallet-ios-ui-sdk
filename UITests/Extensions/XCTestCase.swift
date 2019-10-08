import XCTest

extension XCTestCase {
    func waitForNonExistence(_ element: XCUIElement) {
        let predicate = NSPredicate(format: "exists == false")
        let expectation1 = expectation(for: predicate,
                                       evaluatedWith: element,
                                       handler: nil)

        XCTWaiter().wait(for: [expectation1], timeout: 5)
    }

    func waitForExistence(_ element: XCUIElement) {
        let predicate = NSPredicate(format: "exists == true")
        let expectation1 = expectation(for: predicate,
                                       evaluatedWith: element,
                                       handler: nil)

        XCTWaiter().wait(for: [expectation1], timeout: 5 )
    }

    func waitForExistenceWithFailure(_ element: XCUIElement) -> Bool {
        let predicate = NSPredicate(format: "exists == true")
        let expectation1 = expectation(for: predicate,
                                       evaluatedWith: element,
                                       handler: nil)

        let result = XCTWaiter().wait(for: [expectation1], timeout: 10 )
        return result == .completed
    }
}
