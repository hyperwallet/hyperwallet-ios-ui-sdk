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

        emailPatternError = updateTransferMethod.getEmailPatternError(label: "Email")
        emailLengthError = updateTransferMethod.getLengthConstraintError(label: "Email", min: 3, max: 200)
        emailEmptyError = updateTransferMethod.getEmptyError(label: "Email")

        otherElements = updateTransferMethod.updateTransferMethodTableView.otherElements

        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)
        app.tables.cells.staticTexts["Update Transfer Method"].tap()
        waitForExistence(updateTransferMethod.navBarPaypal)
    }

//    func testAddTransferMethod_createPayPalAccountValidResponse() {
//        mockServer.setupStub(url: "/rest/v3/users/usr-token/paypal-accounts/trm-0001",
//                             filename: "PayPalUpdateResposne",
//                             method: HTTPMethod.post)
//
//        updateTransferMethod.setEmail("hello1@hw.com")
//        updateTransferMethod.clicUpdateTransferMethodButton()
//        waitForNonExistence(spinner)
//
//        XCTAssert(app.navigationBars["Account Settings"].exists)
//    }
}
