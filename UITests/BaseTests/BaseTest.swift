import XCTest

class BaseTests: XCTestCase {
    var app: XCUIApplication!
    var mockServer: HyperwalletMockWebServer!
    var spinner: XCUIElement!
    var runWithInsights = false

    override func setUp() {
        mockServer = HyperwalletMockWebServer()
        mockServer.setUp()

        if runWithInsights {
            mockServer.setupStub(url: "/rest/v3/users/usr-token/authentication-token",
                                 filename: "AuthenticationTokenResponse",
                                 method: HTTPMethod.post)
        } else {
            mockServer.setupStub(url: "/rest/v3/users/usr-token/authentication-token",
                                 filename: "AuthenticationTokenResponseWithoutInsights",
                                 method: HTTPMethod.post)
        }

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
        runWithInsights = false
        mockServer.tearDown()
    }

    func enableInsights() {
        runWithInsights = true
    }
}
