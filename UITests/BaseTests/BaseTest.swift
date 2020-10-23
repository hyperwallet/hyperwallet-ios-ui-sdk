import XCTest

class BaseTests: XCTestCase {
    var app: XCUIApplication!
    var mockServer: HyperwalletMockWebServer!
    var spinner: XCUIElement!

    public struct Dialog {
         // Dialog buttons
         static let remove = "remove".localized()
         static let cancel = "cancelButtonLabel".localized()
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
         static let venmo = "Venmo"
     }

    public struct CurrencyCode {
        // Currency Code , Symbol Tuple
        static let USD = ("USD", "$")
        static let CAD = ("CAD", "CA$")
        static let EURO = ("EUR", "€")
        static let JPY = ("JPY", "¥")
        static let INR = ("INR", "₹")
        static let VND = ("VND", "₫")
        static let SEK = ("SEK", "SEK")
        static let JOD = ("JOD", "JOD")
        // static let TND = ("TND", "د.ت")
        static let TND = ("TND", "TND ")
        static let ZAR = ("ZAR", "ZAR")
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

        mockServer.setupStubEmpty(url: "/rest/v3/users/usr-token/prepaid-cards",
                                  statusCode: 204,
                                  method: HTTPMethod.get)

        mockServer.setupStubEmpty(url: "/rest/v3/users/usr-token/prepaid-cards/trm-token/receipts",
                                  statusCode: 204,
                                  method: HTTPMethod.get)
        mockServer.setupStubEmpty(url: "/rest/v3/users/usr-token/receipts",
                                  statusCode: 204,
                                  method: HTTPMethod.get)

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

    func verifyBusinessError(errorMessage: String, dismiss: Bool) {
        XCTAssert(app.alerts["Error"].exists)
        let predicate = NSPredicate(format:
                  "label CONTAINS[c] '\(errorMessage)'")
        XCTAssert(app.alerts["Error"].staticTexts.element(matching: predicate).exists)
        if dismiss {
            app.alerts["Error"].buttons[Dialog.done].tap()
        }
    }

    func clickBackButton() {
        app.navigationBars.buttons[Common.navBackButton].tap()
    }

    override func tearDown() {
        mockServer.tearDown()
    }
}
