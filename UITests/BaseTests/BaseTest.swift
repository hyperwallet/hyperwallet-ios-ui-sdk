import XCTest

class BaseTests: XCTestCase {
    var app: XCUIApplication!
    var mockServer: HyperwalletMockWebServer!
    var spinner: XCUIElement!
    var table: XCUIElement!

    var elementquery: XCUIElementQuery {
        if #available(iOS 13.0, *) {
            return table.buttons
        } else {
            return table.staticTexts
        }
    }

    override func setUp() {
        mockServer = HyperwalletMockWebServer()
        mockServer.setUp()

        mockServer.setupStub(url: "/rest/v3/users/usr-token/authentication-token",
                             filename: "AuthenticationTokenResponse",
                             method: HTTPMethod.post)

        mockServer.setupStub(url: "/rest/v3/users/usr-token",
                             filename: "UserIndividualResponse",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: "/track/events",
                             filename: "InsightsSuccessResponse",
                             method: HTTPMethod.post)
        // speed up UI
        UIApplication.shared.keyWindow?.layer.speed = 100
        UIView.setAnimationsEnabled(false)
    }

    override func tearDown() {
        mockServer.tearDown()
    }
}
