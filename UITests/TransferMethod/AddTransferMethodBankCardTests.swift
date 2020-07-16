import XCTest

class AddTransferMethodBankCardTests: BaseTests {
    var selectTransferMethodType: SelectTransferMethodType!
    var addTransferMethod: AddTransferMethod!
    var otherElements: XCUIElementQuery!
    let debitCard = NSPredicate(format: "label CONTAINS[c] 'Debit Card'")
    let debitCardDuplicateError = "The card is already registered."
    let debitCardInvalidCvvError = "The card cannot be registered - The CVV entered is invalid."
    var cardNumberEmptyError: String!
    var expiryDateEmptyError: String!
    var cvvEmptyError: String!

    var cardNumberPatternError: String!
    var expiryDatePatternError: String!
    var cvvPatternError: String!

    var cardLengthError: String!
    var cvvLengthError: String!

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

        cardNumberEmptyError = addTransferMethod.getEmptyError(label: addTransferMethod.cardNumber
        )
        expiryDateEmptyError = addTransferMethod.getEmptyError(label: addTransferMethod.expiryDate
        )

        cvvEmptyError = addTransferMethod.getEmptyError(label: addTransferMethod.cvvSecurityCode
        )

        cardNumberPatternError = addTransferMethod.getPatternError(label: addTransferMethod.cardNumber)
        cvvPatternError = addTransferMethod.getPatternError(label: addTransferMethod.cvvSecurityCode)

        cardLengthError = addTransferMethod.getLengthConstraintError(label: addTransferMethod.cardNumber, min: 13, max: 19)

        cvvLengthError = addTransferMethod.getLengthConstraintError(label: addTransferMethod.cvvSecurityCode, min: 3, max: 4)

        otherElements = addTransferMethod.addTransferMethodTableView.otherElements
    }

    func testAddTransferMethod_displaysElementsOnTmcResponse() {
        let feeAndProcessingTime = app.staticTexts["$1.75 fee \u{2022} 1-2 Business days"]
        XCTAssert(addTransferMethod.navBarDebitCard.exists)

        XCTAssert(addTransferMethod.addTransferMethodTableView
            .staticTexts["mobileAccountInfoLabel".localized() + ": United States (USD)"].exists)

        XCTAssertEqual(addTransferMethod.cardNumberLabel.label, addTransferMethod.cardNumber)

        XCTAssert(addTransferMethod.cardNumberInput.exists)

        XCTAssertEqual(addTransferMethod.dateOfExpiryLabel.label, addTransferMethod.expiryDate)
        XCTAssert(addTransferMethod.dateOfExpiryInput.exists)
        XCTAssertEqual(addTransferMethod.dateOfExpiryInput.placeholderValue, addTransferMethod.expireDatePlaceholder)

        XCTAssertEqual(addTransferMethod.cvvLabel.label, addTransferMethod.cvvSecurityCode)
        XCTAssert(addTransferMethod.cvvInput.exists)

        XCTAssert(addTransferMethod.transferMethodInformationHeader.exists)
        XCTAssert(feeAndProcessingTime.exists)

        addTransferMethod.addTransferMethodTableView.scroll(to: addTransferMethod.createTransferMethodButton)
        XCTAssert(addTransferMethod.createTransferMethodButton.exists)
    }

    func testAddTransferMethod_returnsErrorOnInvalidPattern() {
        addTransferMethod.setCardNumber("1234567890@#$")
        addTransferMethod.setCvv("9#-")
        addTransferMethod.clickCreateTransferMethodButton()

        XCTAssert(addTransferMethod.cardNumberError.exists)
        XCTAssert(addTransferMethod.cvvNumberError.exists)

        XCTAssert(otherElements.containing(NSPredicate(format: "label CONTAINS %@", cardNumberPatternError)).count == 1)
        XCTAssert(otherElements.containing(NSPredicate(format: "label CONTAINS %@", expiryDateEmptyError)).count == 1)
        XCTAssert(otherElements.containing(NSPredicate(format: "label CONTAINS %@", cvvPatternError)).count == 1)
    }

    func testAddTransferMethod_returnsErrorOnInvalidLength() {
        addTransferMethod.setCardNumber("10112919191919111111")
        addTransferMethod.setCvv("990011")
        addTransferMethod.clickCreateTransferMethodButton()

        XCTAssert(addTransferMethod.cardNumberError.exists)
        XCTAssert(addTransferMethod.cvvNumberError.exists)

        XCTAssert(otherElements.containing(NSPredicate(format: "label CONTAINS %@", cardLengthError)).count == 1)
        XCTAssert(otherElements.containing(NSPredicate(format: "label CONTAINS %@", expiryDateEmptyError)).count == 1)
        XCTAssert(otherElements.containing(NSPredicate(format: "label CONTAINS %@", cvvLengthError)).count == 1)
    }

    func testAddTransferMethod_returnsErrorOnInvalidPresence() {
        addTransferMethod.setCardNumber("")
        addTransferMethod.setCvv("")
        addTransferMethod.clickCreateTransferMethodButton()

        XCTAssert(addTransferMethod.dateOfExpiryError.exists)
        XCTAssert(addTransferMethod.cardNumberError.exists)
        XCTAssert(addTransferMethod.cvvNumberError.exists)

        XCTAssert(otherElements.containing(NSPredicate(format: "label CONTAINS %@", cardNumberEmptyError)).count == 1)

        XCTAssert(otherElements.containing(NSPredicate(format: "label CONTAINS %@", expiryDateEmptyError)).count == 1)
        XCTAssert(otherElements.containing(NSPredicate(format: "label CONTAINS %@", cvvEmptyError)).count == 1)
    }

    func testAddTransferMethod_createBankCardValidResponse() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/bank-cards",
                             filename: "BankCardResponse",
                             method: HTTPMethod.post)

        addTransferMethod.setCardNumber("4895142232120006")
        // addTransferMethod.setDateOfExpiry(expiryMonth: "March", expiryYear: "2020")
        addTransferMethod.setDateOfExpiryByMMYY(expiryMonth: "03", expiryYear: "20")
        XCTAssertEqual(app.textFields["dateOfExpiry"].value as? String, "03/20")

        addTransferMethod.setCvv("022")
        addTransferMethod.clickCreateTransferMethodButton()
        waitForNonExistence(spinner)

        XCTAssert(app.navigationBars[addTransferMethod.title].exists)
    }

    func testAddTransferMethod_createBankCardInvalidCardCVV() {
        mockServer.setupStubError(url: "/rest/v3/users/usr-token/bank-cards",
                                  filename: "BankCardInvalidCvvResponse",
                                  method: HTTPMethod.post)

        addTransferMethod.setCardNumber("101001010102221234")
        //addTransferMethod.setDateOfExpiry(expiryMonth: "January", expiryYear: "2020")
        addTransferMethod.setDateOfExpiryByMMYY(expiryMonth: "01", expiryYear: "20")
        XCTAssertEqual(app.textFields["dateOfExpiry"].value as? String, "01/20")
        addTransferMethod.setCvv("2222")

        addTransferMethod.clickCreateTransferMethodButton()
        waitForNonExistence(spinner)

        let otherElements = addTransferMethod.addTransferMethodTableView.otherElements

        XCTAssert(otherElements.containing(NSPredicate(format: "label CONTAINS %@", debitCardInvalidCvvError)).count == 1)
    }

    func testAddTransferMethod_createBankCardDuplicateBankCard() {
        mockServer.setupStubError(url: "/rest/v3/users/usr-token/bank-cards",
                                  filename: "BankCardDuplicateResponse",
                                  method: HTTPMethod.post)

        addTransferMethod.setCardNumber("4895142232120006")
        // addTransferMethod.setDateOfExpiry(expiryMonth: "March", expiryYear: "2020")
        addTransferMethod.setDateOfExpiryByMMYY(expiryMonth: "03", expiryYear: "20")
        XCTAssertEqual(app.textFields["dateOfExpiry"].value as? String, "03/20")
        addTransferMethod.setCvv("022")
        addTransferMethod.clickCreateTransferMethodButton()
        waitForNonExistence(spinner)

        XCTAssert(otherElements.containing(NSPredicate(format: "label CONTAINS %@", debitCardDuplicateError)).count == 1)
    }
}
