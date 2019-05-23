import XCTest

class AddTransferMethodBankCardTests: BaseTests {
    var selectTransferMethodType: SelectTransferMethodType!
    var addTransferMethod: AddTransferMethod!
    let debitCard = NSPredicate(format: "label CONTAINS[c] 'Debit Card'")

    override func setUp() {
        super.setUp()
        setUpAddTransferMethodBankCardScreen()
    }

    override func tearDown() {
        mockServer.tearDown()
    }

    private func setUpAddTransferMethodBankCardScreen() {
        selectTransferMethodType = SelectTransferMethodType(app: app)
        addTransferMethod = AddTransferMethod(app: app, for: .debitCard)

        app.tables.cells.containing(.staticText, identifier: "Add Transfer Method").element(boundBy: 0).tap()
        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)
        selectTransferMethodType.selectCountry(country: "UNITED STATES")
        selectTransferMethodType.selectCurrency(currency: "USD")

        app.tables["transferMethodTableView"].staticTexts.element(matching: debitCard).tap()
        waitForNonExistence(spinner)
    }

    func testAddTransferMethod_createDebitCard() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/bank-cards",
                             filename: "BankCardResponse",
                             method: HTTPMethod.post)

        addTransferMethod.setCardNumber(cardNumber: "4895142232120006")
        addTransferMethod.setDateOfExpiry(expiryMonth: "March", expiryYear: "2020")

        XCTAssertEqual(app.textFields["dateOfExpiry"].value as? String, "03/20")

        addTransferMethod.setCvv(cvvNumber: "022")
        addTransferMethod.selectRelationship(type: "Self")

        addTransferMethod.clickCreateTransferMethodButton()

        //Todo - check process indicator 
    }

    func testAddTransferMethod_returnsErrorOnInvalidPattern() {
        addTransferMethod.setCardNumber(cardNumber: "1234567890@#$")
        XCTAssert(app.tables["addTransferMethodTable"].staticTexts["label_cardNumber_error"].exists)
    }

    func testAddTransferMethod_returnsErrorOnInvalidLength() {
        addTransferMethod.setCardNumber(cardNumber: "10100101010")
        XCTAssert(app.tables["addTransferMethodTable"].staticTexts["label_cardNumber_error"].exists)

        addTransferMethod.setCardNumber(cardNumber: "101001010102221234323")
        XCTAssert(app.tables["addTransferMethodTable"].staticTexts["label_cardNumber_error"].exists)
    }

    func testAddTransferMethod_returnsErrorEmptyRequiredFields() {
        addTransferMethod.setCardNumber(cardNumber: "")
        addTransferMethod.setCvv(cvvNumber: "")

        XCTAssert(app.tables["addTransferMethodTable"].staticTexts["label_cardNumber_error"].exists)
        XCTAssert(app.tables["addTransferMethodTable"].staticTexts["label_cvv_error"].exists)

        addTransferMethod.clickCreateTransferMethodButton()
    }

    func testAddTransferMethod_returnsErrorOnInvalidCardCVV() {
        mockServer.setupStubError(url: "/rest/v3/users/usr-token/bank-cards",
                                  filename: "BankCardInvalidCvvResponse",
                                  method: HTTPMethod.post)

        addTransferMethod.setCardNumber(cardNumber: "101001010102221234")
        addTransferMethod.setDateOfExpiry(expiryMonth: "January", expiryYear: "2020")
        addTransferMethod.setCvv(cvvNumber: "2222")

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

        addTransferMethod.setCardNumber(cardNumber: "4895142232120006")
        addTransferMethod.setDateOfExpiry(expiryMonth: "March", expiryYear: "2020")
        addTransferMethod.setCvv(cvvNumber: "022")
        addTransferMethod.clickCreateTransferMethodButton()
        waitForNonExistence(spinner)
        XCTAssertNotNil(app.tables.otherElements
            .containing(NSPredicate(format: "label CONTAINS %@", "The card is already registered.")))
    }

    func testAddTransferMethod_returnsGraphQLFlatFee() {
        XCTAssert(app.tables["addTransferMethodTable"]
            .staticTexts["Transaction Fees: USD 1.75 Processing Time: 30 minutes"]
            .exists)
    }
}
