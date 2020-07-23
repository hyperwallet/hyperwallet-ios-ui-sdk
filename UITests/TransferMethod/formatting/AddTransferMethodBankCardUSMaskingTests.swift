import XCTest

class AddTransferMethodBankCardUSMaskingTests: BaseTests {
    var selectTransferMethodType: SelectTransferMethodType!
    var addTransferMethod: AddTransferMethod!
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
                             filename: "TransferMethodConfigurationUSBankCardResponseWithMask",
                             method: HTTPMethod.post)

        app.tables.cells.staticTexts["Add Transfer Method"].tap()
        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)
        addTransferMethod = AddTransferMethod(app: app)
    }

    func testAddTransferMethod_cardNumberDefaultPattern() {
        verifyHeaders()
        addTransferMethod.setCardNumber("1111222233334444")
        checkSelectFieldValueIsEqualTo("1111 2222 3333 4444", addTransferMethod.cardNumberInput)

        addTransferMethod.setCardNumber("1111 2222 3333 4444")
        checkSelectFieldValueIsEqualTo("1111 2222 3333 4444", addTransferMethod.cardNumberInput)
    }

    func testAddTransferMethod_cardNumberDefaultPatternByPaste() {
        verifyHeaders()
        addTransferMethod.cardNumberInput.enterByPaste(
            text: "1111222233334444", field: addTransferMethod.cardNumberInput, app: app)
        checkSelectFieldValueIsEqualTo("1111 2222 3333 4444", addTransferMethod.cardNumberInput)
    }

    func testAddTransferMethod_cardNumberMaskingInvalidInput() {
        verifyHeaders()
        addTransferMethod.setCardNumber("a111a1b22b223a333 4a444aaa")
        checkSelectFieldValueIsEqualTo("1111 2222 3333 4444", addTransferMethod.cardNumberInput)

        addTransferMethod.setCardNumber("1111$2222$3333$4444$")
        checkSelectFieldValueIsEqualTo("1111 2222 3333 4444", addTransferMethod.cardNumberInput)

        addTransferMethod.setCardNumber("aa aa 11112222")
        checkSelectFieldValueIsEqualTo("1111 2222", addTransferMethod.cardNumberInput)

        addTransferMethod.setCardNumber("aa-aa11112222")
        checkSelectFieldValueIsEqualTo("1111 2222", addTransferMethod.cardNumberInput)

        addTransferMethod.setCardNumber("Aa")
        checkSelectFieldValueIsEqualTo("", addTransferMethod.cardNumberInput)
    }

    func testAddTransferMethod_cardNumberMaskingInvalidLength() {
        verifyHeaders()

        addTransferMethod.setCardNumber("11112222333344444")
        checkSelectFieldValueIsEqualTo("1111 2222 3333 4444", addTransferMethod.cardNumberInput)

        addTransferMethod.setCardNumber("111a 12222333344445555")
        checkSelectFieldValueIsEqualTo("1111 2222 3333 4444", addTransferMethod.cardNumberInput)
    }

    func testAddTransferMethod_cvvDefaultPattern() {
        verifyHeaders()
        addTransferMethod.setCvv("999")
        checkSelectFieldValueIsEqualTo("•••", addTransferMethod.cvvInput)
    }

    func testAddTransferMethod_cvvMaskInvalidInput() {
        verifyHeaders()
        addTransferMethod.setCvv("9#@")
        checkSelectFieldValueIsEqualTo("•", addTransferMethod.cvvInput)

        addTransferMethod.setCvv("!#@")
        checkSelectFieldValueIsEqualTo("", addTransferMethod.cvvInput)
    }

    func testAddTransferMethod_cvvMaskInvalidLength() {
        verifyHeaders()
        addTransferMethod.setCvv("9999")
        checkSelectFieldValueIsEqualTo("•••", addTransferMethod.cvvInput)
    }

    func testAddTransferMethod_cardNumberConditionalPattern() {
        verifyHeaders()
        addTransferMethod.setCardNumber("411111123")
        checkSelectFieldValueIsEqualTo("411111 123", addTransferMethod.cardNumberInput)

        addTransferMethod.setCardNumber("4111111230000")
        checkSelectFieldValueIsEqualTo("411111 123", addTransferMethod.cardNumberInput)

        addTransferMethod.setCardNumber("50566666555")
        checkSelectFieldValueIsEqualTo("505 66666 555", addTransferMethod.cardNumberInput)

        addTransferMethod.setCardNumber("58001231234")
        checkSelectFieldValueIsEqualTo("5800 123 1234", addTransferMethod.cardNumberInput)

        addTransferMethod.setCardNumber("5600123412340000")
        checkSelectFieldValueIsEqualTo("5600 1234 1234 0000", addTransferMethod.cardNumberInput)

        addTransferMethod.setCardNumber("1111222233334444")
        checkSelectFieldValueIsEqualTo(
            "1111 2222 3333 4444", addTransferMethod.cardNumberInput)
    }

    private func verifyHeaders() {
        XCTAssert(addTransferMethod.navBarDebitCard.exists)
        XCTAssert(addTransferMethod.transferMethodInformationHeader.exists)
    }
}
