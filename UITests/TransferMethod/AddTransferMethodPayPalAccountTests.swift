import XCTest

class AddTransferMethodPayPalAccountTests: BaseTests {
    var selectTransferMethodType: SelectTransferMethodType!
    var addTransferMethod: AddTransferMethod!
    let payPalAccount = NSPredicate(format: "label CONTAINS[c] 'PayPal'")

    override func setUp() {
        super.setUp()
        setUpAddTransferMethodPayPalAccountScreen()
    }

    override func tearDown() {
        mockServer.tearDown()
    }

    private func setUpAddTransferMethodPayPalAccountScreen() {
        selectTransferMethodType = SelectTransferMethodType(app: app)
        addTransferMethod = AddTransferMethod(app: app, for: .payPalAccount)

        app.tables.cells.containing(.staticText, identifier: "Add Transfer Method").element(boundBy: 0).tap()
        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)
        selectTransferMethodType.selectCountry(country: "UNITED STATES")
        selectTransferMethodType.selectCurrency(currency: "USD")

        app.tables["transferMethodTableView"].staticTexts.element(matching: payPalAccount).tap()
        waitForNonExistence(spinner)
    }

    func testAddTransferMethod_createPayPalAccount() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/paypal-accounts",
                             filename: "PayPalAccountResponse",
                             method: HTTPMethod.post)

        addTransferMethod.setEmail(email: "abc@test.com")

        XCTAssertEqual(app.textFields["email"].value as? String, "abc@test.com")

        addTransferMethod.clickCreateTransferMethodButton()

        //Todo - check process indicator
    }

    func testAddTransferMethod_returnsErrorOnInvalidPattern() {
        addTransferMethod.setEmail(email: "abc@testcom")
        XCTAssert(app.tables["addTransferMethodTable"].staticTexts["label_email_error"].exists)
    }

    func testAddTransferMethod_returnsErrorEmptyRequiredFields() {
        addTransferMethod.setEmail(email: "")
        XCTAssert(app.tables["addTransferMethodTable"].staticTexts["label_email_error"].exists)

        addTransferMethod.clickCreateTransferMethodButton()
    }

    func testAddTransferMethod_returnsErrorOnInvalidEmailId() {
        mockServer.setupStubError(url: "/rest/v3/users/usr-token/paypal-accounts",
                                  filename: "PayPalAccountInvalidEmailResponse",
                                  method: HTTPMethod.post)

        addTransferMethod.setEmail(email: "abc@test.com")
        addTransferMethod.clickCreateTransferMethodButton()
        waitForNonExistence(spinner)

        XCTAssert(app.alerts["Error"].exists)
        XCTAssert(
            app.alerts["Error"].staticTexts[
                "PayPal transfer method email address should be same as profile email address."
                ].exists)
    }

    func testAddTransferMethod_returnsErrorOnDuplicatePayPalAccount() {
        mockServer.setupStubError(url: "/rest/v3/users/usr-token/paypal-accounts",
                                  filename: "PayPalAccountDuplicateResponse",
                                  method: HTTPMethod.post)

        addTransferMethod.setEmail(email: "abc@test.com")
        addTransferMethod.clickCreateTransferMethodButton()
        waitForNonExistence(spinner)
        XCTAssert(app.alerts["Error"].exists)
        let predicate = NSPredicate(format:
            "label CONTAINS[c] 'The account information you provided is already registered'")
        let label = app.alerts["Error"].staticTexts.element(matching: predicate)
        XCTAssert(label.exists)
    }
}
