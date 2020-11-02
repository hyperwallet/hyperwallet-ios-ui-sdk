import XCTest

class AddTransferMethodPayPalAccountTests: BaseTests {
    var addTransferMethod: AddTransferMethod!
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

        addTransferMethod = AddTransferMethod(app: app)
        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodConfigurationPayPalAccountResponse",
                             method: HTTPMethod.post)

        emailPatternError = addTransferMethod.getEmailPatternError(label: "Email")
        emailLengthError = addTransferMethod.getLengthConstraintError(label: "Email", min: 3, max: 200)
        emailEmptyError = addTransferMethod.getEmptyError(label: "Email")

        otherElements = addTransferMethod.addTransferMethodTableView.otherElements

        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)
        app.tables.cells.staticTexts["Add Transfer Method"].tap()
        waitForExistence(addTransferMethod.navBarPaypal)
    }

    func testAddTransferMethod_displaysElementsOnTmcResponse() {
        XCTAssert(addTransferMethod.navBarPaypal.exists)

        XCTAssert(addTransferMethod.contactInformationHeader.exists)
        XCTAssertEqual(addTransferMethod.emailLabel.label, "Email")
        XCTAssert(addTransferMethod.emailInput.exists)

        XCTAssert(addTransferMethod.transferMethodInformationHeader.exists)
        XCTAssert(app.staticTexts["$0.25 fee \u{2022} 1-2 Business days"].exists)

        addTransferMethod.addTransferMethodTableView.scroll(to: addTransferMethod.createTransferMethodButton)
        XCTAssert(addTransferMethod.createTransferMethodButton.exists)
    }

    func testAddTransferMethod_returnsErrorOnInvalidPattern() {
        addTransferMethod.setEmail("abc@testcom")
        addTransferMethod.clickCreateTransferMethodButton()

        XCTAssert(addTransferMethod.elementQuery["email_error"].exists)

        XCTAssert(otherElements.containing(NSPredicate(format: "label CONTAINS %@", emailPatternError)).count == 1)
    }

    func testAddTransferMethod_returnsErrorOnInvalidLength() {
        addTransferMethod.setEmail("ab")
        addTransferMethod.clickCreateTransferMethodButton()

        XCTAssert(addTransferMethod.elementQuery["email_error"].exists)
        XCTAssert(otherElements.containing(NSPredicate(format: "label CONTAINS %@", emailLengthError)).count == 1)
    }

    func testAddTransferMethod_returnsErrorOnInvalidPresence() {
        addTransferMethod.setEmail("")
        addTransferMethod.clickCreateTransferMethodButton()

        XCTAssert(addTransferMethod.elementQuery["email_error"].exists)
        XCTAssert(otherElements.containing(NSPredicate(format: "label CONTAINS %@", emailEmptyError)).count == 1)
    }

    func testAddTransferMethod_createPayPalAccountValidResponse() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/paypal-accounts",
                             filename: "PayPalAccountResponse",
                             method: HTTPMethod.post)

        addTransferMethod.setEmail("abc@test.com")
        addTransferMethod.clickCreateTransferMethodButton()
        waitForNonExistence(spinner)

        XCTAssert(app.navigationBars["Account Settings"].exists)
    }

    func testAddTransferMethod_createPaypalAccountInvalidEmailId() {
        mockServer.setupStubError(url: "/rest/v3/users/usr-token/paypal-accounts",
                                  filename: "PayPalAccountInvalidEmailResponse",
                                  method: HTTPMethod.post)

        addTransferMethod.setEmail("abc@test.com")
        addTransferMethod.clickCreateTransferMethodButton()
        waitForNonExistence(spinner)

        verifyBusinessError(errorMessage: paypalEmailError, dismiss: true)
        XCTAssertTrue(app.navigationBars["paypal_account".localized()].exists)
    }

    func testAddTransferMethod_createPaypalAccountDuplicateAccount() {
        mockServer.setupStubError(url: "/rest/v3/users/usr-token/paypal-accounts",
                                  filename: "PayPalAccountDuplicateResponse",
                                  method: HTTPMethod.post)

        addTransferMethod.setEmail("abc@test.com")
        addTransferMethod.clickCreateTransferMethodButton()
        waitForNonExistence(spinner)

        verifyBusinessError(errorMessage: duplicateAccountError, dismiss: true)
        XCTAssertTrue(app.navigationBars["paypal_account".localized()].exists)
    }
}
