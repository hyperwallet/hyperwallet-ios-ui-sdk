import XCTest

class BaseBusinessTests: XCTestCase {
    var app: XCUIApplication!
    var mockServer: HyperwalletMockWebServer!
    var spinner: XCUIElement!

    override func setUp() {
        continueAfterFailure = false

        mockServer = HyperwalletMockWebServer()
        mockServer.setUp()
    }

    override func tearDown() {
        mockServer.tearDown()
    }
}
