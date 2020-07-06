import XCTest

class AddTransferMethodPayPalAccountTests: BaseTests {
    var selectTransferMethodType: SelectTransferMethodType!
    var addTransferMethod: AddTransferMethod!
    let payPalAccount = NSPredicate(format: "label CONTAINS[c] 'PayPal'")
    var elementQuery: XCUIElementQuery!
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

        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodConfigurationPayPalAccountResponse",
                             method: HTTPMethod.post)

        app.tables.cells.staticTexts["Add Transfer Method"].tap()
        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)
        selectTransferMethodType = SelectTransferMethodType(app: app)
        addTransferMethod = AddTransferMethod(app: app)
        if #available(iOS 13.0, *) {
            elementQuery = app.tables["addTransferMethodTable"].buttons
        } else {
            elementQuery = app.tables["addTransferMethodTable"].staticTexts
        }
    }

    func testAddTransferMethod_displaysElementsOnTmcResponse() {
        XCTAssert(addTransferMethod.navBarPaypal.exists)

        XCTAssert(addTransferMethod.addTransferMethodTableView
            .staticTexts["Account Information - United States (USD)"].exists)
        XCTAssertEqual(addTransferMethod.emailLabel.label, "Email")
        XCTAssert(addTransferMethod.emailInput.exists)

        XCTAssert(addTransferMethod.transferMethodInformationHeader.exists)
        XCTAssert(app.staticTexts["Transaction Fees: USD 0.25 Processing Time: 1-2 Business days"].exists)

        addTransferMethod.addTransferMethodTableView.scroll(to: addTransferMethod.createTransferMethodButton)
        XCTAssert(addTransferMethod.createTransferMethodButton.exists)
    }

    func testAddTransferMethod_returnsErrorOnInvalidPattern() {
        addTransferMethod.setEmail("abc@testcom")
        addTransferMethod.clickCreateTransferMethodButton()

        XCTAssert(elementQuery["email_error"].exists)
    }

    func testAddTransferMethod_returnsErrorOnInvalidLength() {
        addTransferMethod.setEmail("ab")
        addTransferMethod.clickCreateTransferMethodButton()

        XCTAssert(elementQuery["email_error"].exists)
    }

    func testAddTransferMethod_returnsErrorOnInvalidPresence() {
        addTransferMethod.setEmail("")
        addTransferMethod.clickCreateTransferMethodButton()

        XCTAssert(elementQuery["email_error"].exists)
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

        XCTAssert(app.alerts["Error"].exists)
        XCTAssert(app.alerts["Error"].staticTexts[
                "PayPal transfer method email address should be same as profile email address."].exists)
    }

    func testAddTransferMethod_createPaypalAccountDuplicateAccount() {
        mockServer.setupStubError(url: "/rest/v3/users/usr-token/paypal-accounts",
                                  filename: "PayPalAccountDuplicateResponse",
                                  method: HTTPMethod.post)

        addTransferMethod.setEmail("abc@test.com")
        addTransferMethod.clickCreateTransferMethodButton()
        waitForNonExistence(spinner)
        XCTAssert(app.alerts["Error"].exists)
        let predicate = NSPredicate(format:
            "label CONTAINS[c] 'The account information you provided is already registered'")
        XCTAssert(app.alerts["Error"].staticTexts.element(matching: predicate).exists)
        XCTAssertTrue(app.navigationBars["PayPal"].exists)
        app.alerts["Error"].buttons[Dialog.done].tap()
        XCTAssertTrue(app.navigationBars["PayPal"].exists)
    }
}
