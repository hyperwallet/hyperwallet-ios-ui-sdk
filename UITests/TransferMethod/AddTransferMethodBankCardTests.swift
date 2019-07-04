import XCTest

class AddTransferMethodBankCardTests: BaseTests {
    var selectTransferMethodType: SelectTransferMethodType!
    var addTransferMethod: AddTransferMethod!
    let debitCard = NSPredicate(format: "label CONTAINS[c] 'Debit Card'")

    override func setUp() {
        super.setUp()

        app = XCUIApplication()
        app.launchEnvironment = [
            "COUNTRY": "US",
            "CURRENCY": "USD",
            "ACCOUNT_TYPE": "BANK_CARD",
            "PROFILE_TYPE": "INDIVIDUAL"
        ]
        app.launch()

        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodConfigurationBankCardResponse",
                             method: HTTPMethod.post)

        app.tables.cells.staticTexts["Add Transfer Method"].tap()
        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)
        addTransferMethod = AddTransferMethod(app: app, for: .debitCard)
    }

    func testAddTransferMethod_createBankCard() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/bank-cards",
                             filename: "BankCardResponse",
                             method: HTTPMethod.post)

        addTransferMethod.setCardNumber("4895142232120006")
        addTransferMethod.setDateOfExpiry(expiryMonth: "March", expiryYear: "2020")

        XCTAssertEqual(app.textFields["dateOfExpiry"].value as? String, "03/20")

        addTransferMethod.setCvv("022")
        addTransferMethod.clickCreateTransferMethodButton()

        waitForNonExistence(spinner)

        XCTAssert(app.navigationBars["Account Settings"].exists)
    }

    func testAddTransferMethod_returnsErrorOnInvalidPattern() {
        addTransferMethod.setCardNumber("1234567890@#$")
        addTransferMethod.setCvv("99-a11")
        addTransferMethod.clickCreateTransferMethodButton()

        XCTAssert(app.tables["addTransferMethodTable"].staticTexts["cardNumber_error"].exists)
        XCTAssert(app.tables["addTransferMethodTable"].staticTexts["cvv_error"].exists)
    }

    func testAddTransferMethod_returnsErrorOnInvalidLength() {
        addTransferMethod.setCardNumber("10112919191919111111")
        addTransferMethod.setCvv("990011")
        addTransferMethod.clickCreateTransferMethodButton()

        XCTAssert(app.tables["addTransferMethodTable"].staticTexts["cardNumber_error"].exists)
        XCTAssert(app.tables["addTransferMethodTable"].staticTexts["cvv_error"].exists)
    }

    func testAddTransferMethod_returnsErrorEmptyRequiredFields() {
        addTransferMethod.setCardNumber("")
        addTransferMethod.setCvv("")
        addTransferMethod.clickCreateTransferMethodButton()

        XCTAssert(app.tables["addTransferMethodTable"].staticTexts["cardNumber_error"].exists)
        XCTAssert(app.tables["addTransferMethodTable"].staticTexts["cvv_error"].exists)
    }

    func testAddTransferMethod_returnsErrorOnInvalidCardCVV() {
        mockServer.setupStubError(url: "/rest/v3/users/usr-token/bank-cards",
                                  filename: "BankCardInvalidCvvResponse",
                                  method: HTTPMethod.post)

        addTransferMethod.setCardNumber("101001010102221234")
        addTransferMethod.setDateOfExpiry(expiryMonth: "January", expiryYear: "2020")
        addTransferMethod.setCvv("2222")

        addTransferMethod.clickCreateTransferMethodButton()
        waitForNonExistence(spinner)

        XCTAssertNotNil(app.tables.otherElements
            .containing(NSPredicate(format: "label CONTAINS %@",
                                    "The card cannot be registered - The CVV entered is invalid.")))
    }

    func testAddTransferMethod_returnsErrorOnDuplicateBankCard() {
        mockServer.setupStubError(url: "/rest/v3/users/usr-token/bank-cards",
                                  filename: "BankCardDuplicateResponse",
                                  method: HTTPMethod.post)

        addTransferMethod.setCardNumber("4895142232120006")
        addTransferMethod.setDateOfExpiry(expiryMonth: "March", expiryYear: "2020")
        addTransferMethod.setCvv("022")
        addTransferMethod.clickCreateTransferMethodButton()
        waitForNonExistence(spinner)
        XCTAssertNotNil(app.tables.otherElements
            .containing(NSPredicate(format: "label CONTAINS %@", "The card is already registered.")))
    }

    func testAddTransferMethod_returnsGraphQLFlatFee() {
        let staticTexts = app.tables["addTransferMethodTable"].staticTexts
        XCTAssert(staticTexts["Transaction Fees: USD 1.75 Processing Time: 1-2 Business days"].exists)
    }

    func testAddTransferMethod_displaysElementsOnIndividualProfileTmcResponse() {
        XCTAssert(app.navigationBars["Debit Card"].exists)
        XCTAssert(addTransferMethod.addTransferMethodTableView.cells.staticTexts["Card Number"].exists)
        XCTAssert(addTransferMethod.cardNumberInput.exists)

        XCTAssert(addTransferMethod.addTransferMethodTableView.staticTexts["Expiry Date"].exists)
        XCTAssert(addTransferMethod.dateOfExpiryInput.exists)

        XCTAssert(addTransferMethod.addTransferMethodTableView.staticTexts["CVV (Card Security Code)"].exists)
        XCTAssert(addTransferMethod.cvvInput.exists)

        addTransferMethod.addTransferMethodTableView.scroll(to: addTransferMethod.createTransferMethodButton)
        XCTAssert(addTransferMethod.createTransferMethodButton.exists)

        XCTAssert(addTransferMethod.addTransferMethodTableView.otherElements["TRANSFER METHOD INFORMATION"].exists)
    }
}
