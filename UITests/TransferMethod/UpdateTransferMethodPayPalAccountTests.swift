import XCTest

class UpdateTransferMethodPayPalAccountTests: BaseTests {
    var updateTransferMethod: UpdateTransferMethod!
    let payPalAccount = NSPredicate(format: "label CONTAINS[c] 'PayPal'")
    var otherElements: XCUIElementQuery!
    var emailPatternError: String!
    var emailLengthError: String!
    var emailEmptyError: String!

    let paypalEmailError = "PayPal transfer method email address should be same as profile email address."
    let duplicateAccountError = "The account information you provided is already registered"

    override func setUp() {
        super.setUp()

        app = XCUIApplication()
        app.launchArguments.append("-disableAnimations")
        app.launchEnvironment = [
            "COUNTRY": "US",
            "CURRENCY": "USD",
            "ACCOUNT_TYPE": "PAYPAL_ACCOUNT",
            "PROFILE_TYPE": "INDIVIDUAL"
        ]
        app.launch()

        updateTransferMethod = UpdateTransferMethod(app: app)
        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodUpdateConfigurationFieldsPaypalResponse",
                             method: HTTPMethod.post)
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodResponsePaperCheck",
                             method: HTTPMethod.get)

        emailPatternError = updateTransferMethod.getEmailPatternError(label: "Email")
        emailLengthError = updateTransferMethod.getLengthConstraintError(label: "Email", min: 3, max: 200)
        emailEmptyError = updateTransferMethod.getEmptyError(label: "Email")

        otherElements = updateTransferMethod.updateTransferMethodTableView.otherElements

        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)
        app.tables.cells.staticTexts["List Transfer Methods"].tap()
        app.tables.cells.containing(.staticText, identifier: "paypal_account".localized()).element(boundBy: 0).tap()
        app.sheets.buttons["Edit"].tap()
        waitForExistence(updateTransferMethod.navBarPaypal)
    }

    func testUpdateTransferMethod_updatePayPalAccountValidResponse() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/paypal-accounts/trm-11111111-1111-1111-1111-000000000000",
                             filename: "PayPalUpdateResponse",
                             method: HTTPMethod.put)
        updateTransferMethod.setEmail("hello1@hw.com")
        updateTransferMethod.clickUpdateTransferMethodButton()
        waitForNonExistence(spinner)

        XCTAssert(app.navigationBars["Transfer methods"].exists)
    }

    func testUpdateTransferMethod_returnsErrorOnInvalidLength() {
        updateTransferMethod.setEmail("ab")
        updateTransferMethod.clickUpdateTransferMethodButton()

        XCTAssert(updateTransferMethod.elementQuery["email_error"].exists)
        XCTAssert(otherElements.containing(NSPredicate(format: "label CONTAINS %@", emailLengthError)).count == 1)
    }

    func testUpdateTransferMethod_returnsErrorOnEmptyEmail() {
        updateTransferMethod.setEmail("")
        updateTransferMethod.clickUpdateTransferMethodButton()

        XCTAssert(updateTransferMethod.elementQuery["email_error"].exists)
        XCTAssert(otherElements.containing(NSPredicate(format: "label CONTAINS %@", emailEmptyError)).count == 1)
    }
}
