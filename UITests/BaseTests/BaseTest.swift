import XCTest

class BaseTests: XCTestCase {
    var app: XCUIApplication!
    var mockServer: HyperwalletMockWebServer!
    var spinner: XCUIElement!

    public struct Dialog {
         // Dialog buttons
         static let remove = "remove_button_label".localized()
         static let cancel = "cancel_button_label".localized()
         static let done = "doneButtonLabel".localized()
         static let tryAgain = "try_again_button_label".localized()
     }

    public struct TransferMethods {
         // Transfer methods
         static let bankAccount = "Bank Account"
         static let debitCard = "Debit Card"
         static let paperCheck = "Paper Check"
         static let prepaidCard = "Prepaid Card"
         static let wireTransfer = "Wire Transfer"
         static let paypal = "PayPal"
     }

    public struct Common {
         // Navigation Bar
        static let navBackButton = "Back".localized()
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

    func verifyUnexpectedError() {
        let title = "unexpected_title".localized()
        let message = "unexpected_error_message".localized()
        let alert = app.alerts[title]
        XCTAssert(alert.exists)
        XCTAssert(alert.staticTexts[message].exists)
        alert.buttons[Dialog.done].tap()
        XCTAssertFalse(alert.exists)
    }

    func clickBackButton() {
        app.navigationBars.buttons[Common.navBackButton].tap()
    }

    override func tearDown() {
        mockServer.tearDown()
    }

}
