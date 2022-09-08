import XCTest

class SelectTransferMethodTypeTests: BaseTests {
    var selectTransferMethodType: SelectTransferMethodType!
    let bankAccount = NSPredicate(format: "label CONTAINS[c] 'Bank Account'")
    let debitCard = NSPredicate(format: "label CONTAINS[c] 'Debit Card'")
    let processingTime = NSPredicate(format: "label CONTAINS[c] '\u{2022}'")
    let transactionFee = NSPredicate(format: "label CONTAINS[c] 'No fee'")
    let wireTransfer = NSPredicate(format: "label CONTAINS[c] 'Wire Transfer'")

    override func setUp() {
        super.setUp()

        app = XCUIApplication()
        app.launchArguments.append("enable-testing")
        app.launch()

        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodConfigurationKeysResponse",
                             method: HTTPMethod.post)
        mockServer.setupStub(url: "/rest/v3/users/usr-token",
                             filename: "UserIndividualResponse",
                             method: HTTPMethod.get)

        selectTransferMethodType = SelectTransferMethodType(app: app)
        app.tables.cells.staticTexts["Select Transfer Method"].tap()

        let spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)
    }

    func testSelectTransferMethodType_validateTransferMethodScreen() {
        XCTAssertNotNil(app.cells.images)
        XCTAssertTrue(app.navigationBars["mobileAddTransferMethodHeader".localized()].exists)
        XCTAssertTrue(app.tables.staticTexts["United States"].exists)
        XCTAssertTrue(app.tables.staticTexts["USD"].exists)
        XCTAssertEqual(app.tables["selectTransferMethodTypeTable"].cells.count, 6)
        XCTAssertTrue(app.tables["selectTransferMethodTypeTable"].staticTexts.element(matching: bankAccount).exists)
    }

    func testSelectTransferMethodType_verifyCountrySelection() {
        selectTransferMethodType.tapCountry()

        XCTAssert(app.tables.staticTexts["United States"].exists)
        XCTAssertEqual(app.tables.cells.count, 30)
    }

    func testSelectTransferMethodType_verifyCurrencySelection() {
        selectTransferMethodType.tapCurrency()

        XCTAssertEqual(app.tables.cells.count, 1)
        XCTAssert(app.tables.staticTexts["USD"].exists)
    }

    func testSelectTransferMethodType_verifyTransferMethodSelection() {
        selectTransferMethodType.selectCountry(country: "Canada")
        let spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)
        selectTransferMethodType.selectCurrency(currency: "CAD")

        XCTAssert(app.tables["selectTransferMethodTypeTable"]
            .staticTexts["Bank Account"]
            .exists)
        XCTAssert(app.tables["selectTransferMethodTypeTable"]
            .staticTexts["PayPal Account"]
            .exists)

        XCTAssert(app.tables["selectTransferMethodTypeTable"]
            .staticTexts[ "$2.20 fee \u{2022} 1-2 Business days"]
            .exists)
        XCTAssert(app.tables["selectTransferMethodTypeTable"]
            .staticTexts["$0.25 fee \u{2022} IMMEDIATE"]
            .exists)
    }

    func testSelectTransferMethodType_verifyCountrySelectionSearch() {
        selectTransferMethodType.tapCountry()

        selectTransferMethodType.typeSearch(input: "Mexico")
        XCTAssertEqual(app.tables.cells.count, 1)
        app.tables.staticTexts["Mexico"].tap()
        XCTAssert(app.tables.staticTexts["Mexico"].exists)
    }

    func testSelectTransferMethod_clickBankAccountOpensAddTransferMethodUi () {
        selectTransferMethodType.selectCountry(country: "United States")

        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodConfigurationBankAccountResponse",
                             method: HTTPMethod.post)

        app.tables["selectTransferMethodTypeTable"].staticTexts.element(matching: bankAccount).tap()
        XCTAssert(app.navigationBars["Bank Account"].exists)
    }
    
    func testSelectTransferMethod_graphQL_unauthenticatedError() {
        selectTransferMethodType.selectCountry(country: "United States")
        mockServer.setupStubError(url: "/graphql",
                                  filename: "JWTTokenRevolked",
                                  method: HTTPMethod.post,
                                  statusCode: 401)

        app.tables["selectTransferMethodTypeTable"].staticTexts.element(matching: bankAccount).tap()
        waitForNonExistence(app.activityIndicators["activityIndicator"])
        
        XCTAssertEqual(app.alerts.element.label, "Authentication Error")
    }

    func testSelectTransferMethod_clickBankCardOpensAddTransferMethodUi () {
        selectTransferMethodType.selectCountry(country: "United States")

        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodConfigurationBankCardResponse",
                             method: HTTPMethod.post)

        app.tables["selectTransferMethodTypeTable"].staticTexts.element(matching: debitCard).tap()
        XCTAssert(app.navigationBars["Debit Card"].exists)
    }

    func testSelectTransferMethod_verifyTransferMethodsListEmptyFee () {
        selectTransferMethodType.selectCountry(country: "THAILAND")

        let staticTexts = app.tables["selectTransferMethodTypeTable"].staticTexts;
        XCTAssertTrue(staticTexts.element(matching: wireTransfer).waitForExistence(timeout: 1))
        XCTAssertTrue(staticTexts.element(matching: transactionFee).waitForExistence(timeout: 1))
        XCTAssertFalse(staticTexts.element(matching: processingTime).waitForExistence(timeout: 1))
    }

    func testSelectTransferMethod_verifyTransferMethodsListEmptyProcessing () {
        selectTransferMethodType.selectCountry(country: "THAILAND")

        XCTAssertTrue(app.tables["selectTransferMethodTypeTable"].staticTexts.element(matching: wireTransfer).exists)
        XCTAssertTrue(app.tables["selectTransferMethodTypeTable"].staticTexts["No fee"].exists)
        XCTAssertFalse(app.tables["selectTransferMethodTypeTable"].staticTexts.element(matching: processingTime).exists)
    }
    
    func testSelectTransferMethod_verifyTransferMethodsZeroFee () {
        selectTransferMethodType.selectCountry(country: "SPAIN")
        
        let selectTransferMethodTypeTable: XCUIElement = app.tables["selectTransferMethodTypeTable"]
        let cells = selectTransferMethodTypeTable.cells
        
        let cellWire = cells.element(boundBy: 0)
        XCTAssert(cellWire.staticTexts["Wire Transfer"].waitForExistence(timeout: 1))
        XCTAssert(cellWire.staticTexts["$20.00 fee"].waitForExistence(timeout: 1))
        
        let cellBankAccount = cells.element(boundBy: 1)
        XCTAssert(cellBankAccount.staticTexts["Debit Card"].waitForExistence(timeout: 1))
        XCTAssert(cellBankAccount.staticTexts["No fee"].waitForExistence(timeout: 1))
        
        let cellDebitCard = cells.element(boundBy: 2)
        XCTAssert(cellDebitCard.staticTexts["Bank Account"].waitForExistence(timeout: 1))
        XCTAssert(cellDebitCard.staticTexts["No fee \u{2022} 1-2 Business days"].waitForExistence(timeout: 1))
    }
    
    func testSelectTransferMethod_verifyTransferMethodsFeeFormatting () {
        selectTransferMethodType.selectCountry(country: "SRI LANKA")

        assertUSDFeeFormatting()
        
        assertCADFeeFormatting()
        
        assertAUDFeeFormatting()
        
        assertINRFeeFormatting()
        
        assertJPYFeeFormatting()
    }
    
    private func assertCADFeeFormatting() {
        selectTransferMethodType.selectCurrency(currency: "CAD")
        
        let selectTransferMethodTypeTable: XCUIElement = app.tables["selectTransferMethodTypeTable"]
        let cells = selectTransferMethodTypeTable.cells
        
        let cellWire = cells.element(boundBy: 0)
        XCTAssert(cellWire.staticTexts["Wire Transfer"].waitForExistence(timeout: 1))
        XCTAssert(cellWire.staticTexts["2.00% (Min:$4.00, Max:$10.00) fee"].waitForExistence(timeout: 1))
        
        let cellPaypal = cells.element(boundBy: 1)
        XCTAssert(cellPaypal.staticTexts["PayPal Account"].waitForExistence(timeout: 1))
        XCTAssert(cellPaypal.staticTexts["No fee"].waitForExistence(timeout: 1))
        
        let cellBankAccount = cells.element(boundBy: 2)
        XCTAssert(cellBankAccount.staticTexts["Bank Account"].waitForExistence(timeout: 1))
        XCTAssert(cellBankAccount.staticTexts["2.00% (Min:$4.00) fee"].waitForExistence(timeout: 1))
        
        let cellDebit = cells.element(boundBy: 3)
        XCTAssert(cellDebit.staticTexts["Debit Card"].waitForExistence(timeout: 1))
        XCTAssert(cellDebit.staticTexts["$12 fee"].waitForExistence(timeout: 1))
    }
    
    private func assertAUDFeeFormatting() {
        selectTransferMethodType.selectCurrency(currency: "AUD")
        
        let selectTransferMethodTypeTable: XCUIElement = app.tables["selectTransferMethodTypeTable"]
        let cells = selectTransferMethodTypeTable.cells
        
        let cellWire = cells.element(boundBy: 0)
        XCTAssert(cellWire.staticTexts["Wire Transfer"].waitForExistence(timeout: 1))
        XCTAssert(cellWire.staticTexts["No fee"].waitForExistence(timeout: 1))
        
        let cellPaypal = cells.element(boundBy: 1)
        XCTAssert(cellPaypal.staticTexts["PayPal Account"].waitForExistence(timeout: 1))
        XCTAssert(cellPaypal.staticTexts["A$2.00 fee"].waitForExistence(timeout: 1))
        
        let cellBankAccount = cells.element(boundBy: 2)
        XCTAssert(cellBankAccount.staticTexts["Bank Account"].waitForExistence(timeout: 1))
        XCTAssert(cellBankAccount.staticTexts["2.00% (Max:A$8.00) fee"].waitForExistence(timeout: 1))
        
        let cellDebitCard = cells.element(boundBy: 3)
        XCTAssert(cellDebitCard.staticTexts["Debit Card"].waitForExistence(timeout: 1))
        XCTAssert(cellDebitCard.staticTexts["A$12 + 8% (Max:A$10.00) fee"].waitForExistence(timeout: 1))
    }
    
    private func assertINRFeeFormatting() {
        selectTransferMethodType.selectCurrency(currency: "INR")
        
        let selectTransferMethodTypeTable: XCUIElement = app.tables["selectTransferMethodTypeTable"]
        let cells = selectTransferMethodTypeTable.cells
        
        let cellWire = cells.element(boundBy: 0)
        XCTAssert(cellWire.staticTexts["Wire Transfer"].waitForExistence(timeout: 1))
        XCTAssert(cellWire.staticTexts["₹5.00 + 10.00% fee"].waitForExistence(timeout: 1))
        
        let cellPaypal = cells.element(boundBy: 1)
        XCTAssert(cellPaypal.staticTexts["PayPal Account"].waitForExistence(timeout: 1))
        XCTAssert(cellPaypal.staticTexts["₹2.00 fee"].waitForExistence(timeout: 1))
        
        let cellBankAccount = cells.element(boundBy: 2)
        XCTAssert(cellBankAccount.staticTexts["Bank Account"].waitForExistence(timeout: 1))
        XCTAssert(cellBankAccount.staticTexts["₹2.00 + 2.00% (Min:₹4.00) fee"].waitForExistence(timeout: 1))
        
        let cellDebitCard = cells.element(boundBy: 3)
        XCTAssert(cellDebitCard.staticTexts["Debit Card"].waitForExistence(timeout: 1))
        XCTAssert(cellDebitCard.staticTexts["No fee"].waitForExistence(timeout: 1))
    }
    
    private func assertJPYFeeFormatting() {
        selectTransferMethodType.selectCurrency(currency: "JPY")
        
        let selectTransferMethodTypeTable: XCUIElement = app.tables["selectTransferMethodTypeTable"]
        let cells = selectTransferMethodTypeTable.cells
        
        let cellWire = cells.element(boundBy: 0)
        XCTAssert(cellWire.staticTexts["Wire Transfer"].waitForExistence(timeout: 1))
        XCTAssert(cellWire.staticTexts["¥5.00 + 10.00% fee"].waitForExistence(timeout: 1))
        
        let cellPaypal = cells.element(boundBy: 1)
        XCTAssert(cellPaypal.staticTexts["PayPal Account"].waitForExistence(timeout: 1))
        XCTAssert(cellPaypal.staticTexts["No fee \u{2022} 1-3 Business days"].waitForExistence(timeout: 1))
        
        let cellBankAccount = cells.element(boundBy: 2)
        XCTAssert(cellBankAccount.staticTexts["Bank Account"].waitForExistence(timeout: 1))
        XCTAssert(cellBankAccount.staticTexts["No fee"].waitForExistence(timeout: 1))
        
        let cellDebitCard = cells.element(boundBy: 3)
        XCTAssert(cellDebitCard.staticTexts["Debit Card"].waitForExistence(timeout: 1))
        XCTAssert(cellDebitCard.staticTexts["5.00% fee \u{2022} 1-2 Business days"].waitForExistence(timeout: 1))
    }
    
    private func assertUSDFeeFormatting() {
        let selectTransferMethodTypeTable: XCUIElement = app.tables["selectTransferMethodTypeTable"]
        let cells = selectTransferMethodTypeTable.cells
        
        let cellWire = cells.element(boundBy: 0)
        XCTAssert(cellWire.staticTexts["Wire Transfer"].waitForExistence(timeout: 1))
        XCTAssert(cellWire.staticTexts["$2 + 15% (Min:$4.00, Max:$10.00) fee"].waitForExistence(timeout: 1))
        
        let cellPaypal = cells.element(boundBy: 1)
        XCTAssert(cellPaypal.staticTexts["PayPal Account"].waitForExistence(timeout: 1))
        XCTAssert(cellPaypal.staticTexts["No fee"].waitForExistence(timeout: 1))
        
        let cellBankAccount = cells.element(boundBy: 2)
        XCTAssert(cellBankAccount.staticTexts["Bank Account"].waitForExistence(timeout: 1))
        XCTAssert(cellBankAccount.staticTexts["2.00% fee"].waitForExistence(timeout: 1))
        
        let cellDebitCard = cells.element(boundBy: 3)
        XCTAssert(cellDebitCard.staticTexts["Debit Card"].waitForExistence(timeout: 1))
        XCTAssert(cellDebitCard.staticTexts["$12 fee"].waitForExistence(timeout: 1))
    }
}
