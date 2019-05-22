import XCTest

class AddTransferMethodBankCardTests: BaseIndividualTests {
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

        XCTAssert(app.navigationBars.staticTexts["Account Settings"].exists)
    }

    func testAddTransferMethod_createBankCardBusiness() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/bank-cards",
                             filename: "BankCardResponse",
                             method: HTTPMethod.post)

        addTransferMethod.setCardNumber("4895142232120006")
        addTransferMethod.setDateOfExpiry(expiryMonth: "March", expiryYear: "2020")

        XCTAssertEqual(app.textFields["dateOfExpiry"].value as? String, "03/20")

        addTransferMethod.setCvv("022")
        addTransferMethod.clickCreateTransferMethodButton()

        waitForNonExistence(spinner)

        XCTAssert(app.navigationBars.staticTexts["Account Settings"].exists)
    }

    func testAddTransferMethod_returnsErrorOnInvalidPattern() {
        addTransferMethod.setCardNumber("1234567890@#$")
        XCTAssert(app.tables["addTransferMethodTable"].staticTexts["label_cardNumber_error"].exists)
    }

    func testAddTransferMethod_returnsErrorOnInvalidLength() {
        addTransferMethod.setCardNumber("10100101010")
        XCTAssert(app.tables["addTransferMethodTable"].staticTexts["label_cardNumber_error"].exists)

        addTransferMethod.setCardNumber("101001010102221234323")
        XCTAssert(app.tables["addTransferMethodTable"].staticTexts["label_cardNumber_error"].exists)
    }

    func testAddTransferMethod_returnsErrorEmptyRequiredFields() {
        addTransferMethod.setCardNumber("")
        addTransferMethod.setCvv("")

        XCTAssert(app.tables["addTransferMethodTable"].staticTexts["label_cardNumber_error"].exists)
        XCTAssert(app.tables["addTransferMethodTable"].staticTexts["label_cvv_error"].exists)

        addTransferMethod.clickCreateTransferMethodButton()
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
        XCTAssert(app.tables["addTransferMethodTable"]
            .staticTexts["Transaction Fees: USD 1.75 Processing Time: 30 minutes"]
            .exists)
    }

    func testAddTransferMethod_displaysElementsOnIndividualProfileTmcResponse() {
        XCTAssert(app.navigationBars.staticTexts["Debit Card"].exists)

        verifyAccountInformationSection()

        let infoSection = addTransferMethod.addTMTableView.otherElements["TRANSFER METHOD INFORMATION"]

        addTransferMethod.addTMTableView.scrollToElement(element: infoSection)
        XCTAssert(infoSection.exists)

        addTransferMethod.addTMTableView.scrollToElement(element: addTransferMethod.createTransferMethodButton)
        XCTAssert(addTransferMethod.createTransferMethodButton.exists)
    }

    func testAddTransferMethod_displaysElementsOnBusinessProfileTmcResponse() {
        XCTAssert(app.navigationBars.staticTexts["Debit Card"].exists)

        verifyAccountInformationSection()

        let infoSection = addTransferMethod.addTMTableView.otherElements["TRANSFER METHOD INFORMATION"]

        addTransferMethod.addTMTableView.scrollToElement(element: infoSection)
        XCTAssert(infoSection.exists)

        addTransferMethod.addTMTableView.scrollToElement(element: addTransferMethod.createTransferMethodButton)
        XCTAssert(addTransferMethod.createTransferMethodButton.exists)
    }
}

private extension AddTransferMethodBankCardTests {
    func setUpAddTransferMethodBankCardScreen() {
        selectTransferMethodType = SelectTransferMethodType(app: app)
        addTransferMethod = AddTransferMethod(app: app, for: .debitCard)

        app.tables.cells.containing(.staticText, identifier: "Add Transfer Method").element(boundBy: 0).tap()
        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)
        selectTransferMethodType.selectCountry(country: "United States")
        selectTransferMethodType.selectCurrency(currency: "US Dollar")

        app.tables["transferMethodTableView"].staticTexts.element(matching: debitCard).tap()
        waitForNonExistence(spinner)
    }

    func verifyAccountInformationSection() {
        XCTAssert(addTransferMethod.title.exists)

        XCTAssert(addTransferMethod.addTMTableView.cells.staticTexts["Card Number"].exists)
        XCTAssert(addTransferMethod.cardNumberInput.exists)

        XCTAssert(addTransferMethod.addTMTableView.staticTexts["Expiry Date"].exists)
        XCTAssert(addTransferMethod.dateOfExpiryInput.exists)

        XCTAssert(addTransferMethod.addTMTableView.staticTexts["CVV (Card Security Code)"].exists)
        XCTAssert(addTransferMethod.cvvInput.exists)

        XCTAssert(addTransferMethod.addTMTableView.staticTexts["CVV is a 3 digit number, typically found on the back of the card."].exists)
    }
}
