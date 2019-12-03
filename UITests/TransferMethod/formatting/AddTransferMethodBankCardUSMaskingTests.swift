import XCTest

class AddTransferMethodBankCardUSMaskingTests: BaseTests {
    var selectTransferMethodType: SelectTransferMethodType!
    var addTransferMethod: AddTransferMethod!
    let bankCard = NSPredicate(format: "label CONTAINS[c] 'Bank Card'")

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

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddTransferMethod_cardNumberDefaultPattern() {
        XCTAssert(app.navigationBars["Debit Card"].exists)
        XCTAssert(addTransferMethod.transferMethodInformationHeader.exists)
        addTransferMethod.setCardNumber("1111222233334444")
        checkSelectFieldValueIsEqualTo("1111 2222 3333 4444", addTransferMethod.cardNumberInput)

        addTransferMethod.setCardNumber("1111 2222 3333 4444")
        checkSelectFieldValueIsEqualTo("1111 2222 3333 4444", addTransferMethod.cardNumberInput)
    }

    func testAddTransferMethod_cardNumberDefaultPatternByPaste() {
        XCTAssert(app.navigationBars["Debit Card"].exists)
        XCTAssert(addTransferMethod.transferMethodInformationHeader.exists)
        addTransferMethod.cardNumberInput.enterByPaste(
            text: "1111222233334444", field: addTransferMethod.cardNumberInput, app: app)
        checkSelectFieldValueIsEqualTo("1111 2222 3333 4444", addTransferMethod.cardNumberInput)
    }

    func testAddTransferMethod_cardNumberMaskingInvalidInput() {
       XCTAssert(app.navigationBars["Debit Card"].exists)
       XCTAssert(addTransferMethod.transferMethodInformationHeader.exists)
       addTransferMethod.setCardNumber("a111a1b22b223a333 4a444aaa")
       checkSelectFieldValueIsEqualTo("1111 2222 3333 4444", addTransferMethod.cardNumberInput)

        addTransferMethod.setCardNumber("1111$2222$3333$4444$")
        checkSelectFieldValueIsEqualTo("1111 2222 3333 4444", addTransferMethod.cardNumberInput)

        addTransferMethod.setCardNumber("Aa")
              checkSelectFieldValueIsEqualTo("", addTransferMethod.cardNumberInput)
    }

    func testAddTransferMethod_cardNumberMaskingInvalidLength() {
        XCTAssert(app.navigationBars["Debit Card"].exists)
        XCTAssert(addTransferMethod.transferMethodInformationHeader.exists)
        // length up to 19
        addTransferMethod.setCardNumber("11112222333344444")
        checkSelectFieldValueIsEqualTo("1111 2222 3333 4444", addTransferMethod.cardNumberInput)
        // length more than 19
        addTransferMethod.setCardNumber("111a 12222333344445555")
        checkSelectFieldValueIsEqualTo("1111 2222 3333 4444", addTransferMethod.cardNumberInput)
    }

    func testAddTransferMethod_cvvDefaultPattern() {
           XCTAssert(app.navigationBars["Debit Card"].exists)
           XCTAssert(addTransferMethod.transferMethodInformationHeader.exists)
           addTransferMethod.setCvv("999")
        checkSelectFieldValueIsEqualTo("999", addTransferMethod.cvvInput)
    }

    func testAddTransferMethod_cvvMaskInvalidInput() {
              XCTAssert(app.navigationBars["Debit Card"].exists)
              XCTAssert(addTransferMethod.transferMethodInformationHeader.exists)
              addTransferMethod.setCvv("9#4")
           checkSelectFieldValueIsEqualTo("9", addTransferMethod.cvvInput)
       }

    func testAddTransferMethod_cvvMaskInvalidLength() {
        XCTAssert(app.navigationBars["Debit Card"].exists)
        XCTAssert(addTransferMethod.transferMethodInformationHeader.exists)
        addTransferMethod.setCvv("9999")
        checkSelectFieldValueIsEqualTo("999", addTransferMethod.cvvInput)
    }

    func testAddTransferMethod_cardNumberConditionalPattern() {
        XCTAssert(app.navigationBars["Debit Card"].exists)
        XCTAssert(addTransferMethod.transferMethodInformationHeader.exists)
        addTransferMethod.setCardNumber("4111222233334444")
        checkSelectFieldValueIsEqualTo("4111 2222 3333 4444", addTransferMethod.cardNumberInput)

        addTransferMethod.setCardNumber("5111222233334444")
        checkSelectFieldValueIsEqualTo("5111 2222 3333 4444", addTransferMethod.cardNumberInput)

        addTransferMethod.setCardNumber("5211222233334444")
               checkSelectFieldValueIsEqualTo("5211 2222 3333 4444", addTransferMethod.cardNumberInput)
        addTransferMethod.setCardNumber("5311222233334444")
                     checkSelectFieldValueIsEqualTo("5311 2222 3333 4444", addTransferMethod.cardNumberInput)

        addTransferMethod.setCardNumber("5811222233334444")
                            checkSelectFieldValueIsEqualTo("5811 2222 3333 4444", addTransferMethod.cardNumberInput)

        addTransferMethod.setCardNumber("1111222233334444")
                                   checkSelectFieldValueIsEqualTo("1111 2222 3333 4444", addTransferMethod.cardNumberInput)
    }
}
