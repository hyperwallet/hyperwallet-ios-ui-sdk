import XCTest

class AddTransferMethodBankCardTests: BaseTests {
    var selectTransferMethodType: SelectTransferMethodType!
    var addTransferMethod: AddTransferMethod!
    let debitCard = NSPredicate(format: "label CONTAINS[c] 'Debit Card'")
    var elementQuery: XCUIElementQuery!
    override func setUp() {
        super.setUp()

        app = XCUIApplication()
        selectTransferMethodType = SelectTransferMethodType(app: app)
        addTransferMethod = AddTransferMethod(app: app)

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

        if #available(iOS 13.0, *) {
            elementQuery = app.tables["addTransferMethodTable"].buttons
        } else {
            elementQuery = app.tables["addTransferMethodTable"].staticTexts
        }
    }

    func testAddTransferMethod_displaysElementsOnTmcResponse() {
        XCTAssert(addTransferMethod.navBarDebitCard.exists)

        XCTAssert(addTransferMethod.addTransferMethodTableView
            .staticTexts["mobileAccountInfoLabel".localized() + ": United States (USD)"].exists)
        XCTAssertEqual(addTransferMethod.cardNumberLabel.label, "Card Number")
        XCTAssert(addTransferMethod.cardNumberInput.exists)
        XCTAssertEqual(addTransferMethod.dateOfExpiryLabel.label, "Expiry Date")
        XCTAssert(addTransferMethod.dateOfExpiryInput.exists)
        XCTAssertEqual(addTransferMethod.cvvLabel.label, "CVV (Card Security Code)")
        XCTAssert(addTransferMethod.cvvInput.exists)

        XCTAssert(addTransferMethod.transferMethodInformationHeader.exists)
        XCTAssert(app.staticTexts["$1.75 fee \u{2022} 1-2 Business days"].exists)

        addTransferMethod.addTransferMethodTableView.scroll(to: addTransferMethod.createTransferMethodButton)
        XCTAssert(addTransferMethod.createTransferMethodButton.exists)
    }

    func testAddTransferMethod_returnsErrorOnInvalidPattern() {
        addTransferMethod.setCardNumber("1234567890@#$")
        addTransferMethod.setCvv("99-a11")
        addTransferMethod.clickCreateTransferMethodButton()

        XCTAssert(elementQuery["cardNumber_error"].exists)
        XCTAssert(elementQuery["cvv_error"].exists)
    }

    func testAddTransferMethod_returnsErrorOnInvalidLength() {
        addTransferMethod.setCardNumber("10112919191919111111")
        addTransferMethod.setCvv("990011")
        addTransferMethod.clickCreateTransferMethodButton()

        XCTAssert(elementQuery["cardNumber_error"].exists)
        XCTAssert(elementQuery["cvv_error"].exists)
    }

    func testAddTransferMethod_returnsErrorOnInvalidPresence() {
        addTransferMethod.setCardNumber("")
        addTransferMethod.setCvv("")
        addTransferMethod.clickCreateTransferMethodButton()

        XCTAssert(elementQuery["cardNumber_error"].exists)
        XCTAssert(elementQuery["cvv_error"].exists)
    }

    func testAddTransferMethod_createBankCardValidResponse() {
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

    func testAddTransferMethod_createBankCardInvalidCardCVV() {
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

    func testAddTransferMethod_createBankCardDuplicateBankCard() {
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
}
