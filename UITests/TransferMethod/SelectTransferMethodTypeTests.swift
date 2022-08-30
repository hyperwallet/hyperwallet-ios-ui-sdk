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
        selectTransferMethodType.selectCurrency(currency: "CAD")

        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 0).staticTexts[
            "Bank Account"].exists)
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 1).staticTexts[
            "PayPal Account"].exists)

        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 0).staticTexts[
            "$2.20 fee \u{2022} 1-2 Business days"].exists)
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 1).staticTexts[
            "$0.25 fee \u{2022} IMMEDIATE"].exists)
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

        XCTAssertTrue(app.tables["selectTransferMethodTypeTable"].staticTexts.element(matching: wireTransfer).exists)
        XCTAssertTrue(app.tables["selectTransferMethodTypeTable"].staticTexts.element(matching: transactionFee).exists)
        XCTAssertFalse(app.tables["selectTransferMethodTypeTable"].staticTexts.element(matching: processingTime).exists)
    }

    func testSelectTransferMethod_verifyTransferMethodsListEmptyProcessing () {
        selectTransferMethodType.selectCountry(country: "THAILAND")

        XCTAssertTrue(app.tables["selectTransferMethodTypeTable"].staticTexts.element(matching: wireTransfer).exists)
        XCTAssertTrue(app.tables["selectTransferMethodTypeTable"].staticTexts.element(matching: transactionFee).exists)
        XCTAssertFalse(app.tables["selectTransferMethodTypeTable"].staticTexts.element(matching: processingTime).exists)
    }
    
    func testSelectTransferMethod_verifyTransferMethodsZeroFee () {
        selectTransferMethodType.selectCountry(country: "SPAIN")

        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 0).staticTexts[
            "Wire Transfer"].exists)
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 1).staticTexts[
            "Debit Card"].exists)
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 2).staticTexts[
            "Bank Account"].exists)

        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 0).staticTexts[
            "$20.00 fee"].exists)
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 1).staticTexts[
            "No fee"].exists)
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 2).staticTexts[
            "No fee \u{2022} 1-2 Business days"].exists)
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
        
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 0).staticTexts[
                    "Wire Transfer"].exists)
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 0).staticTexts[
                    "2.00% (Min:$4.00, Max:$10.00) fee"].exists)
        
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 1).staticTexts[
                    "PayPal Account"].exists)
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 1).staticTexts[
                    "No fee"].exists)
        
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 2).staticTexts[
                    "Bank Account"].exists)
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 2).staticTexts[
                    "2.00% (Min:$4.00) fee"].exists)
        
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 3).staticTexts[
                    "Debit Card"].exists)
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 3).staticTexts[
                    "$12 fee"].exists)
    }
    
    private func assertAUDFeeFormatting() {
        selectTransferMethodType.selectCurrency(currency: "AUD")
        
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 0).staticTexts[
                    "Wire Transfer"].exists)
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 0).staticTexts[
                    "No fee"].exists)
        
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 1).staticTexts[
                    "PayPal Account"].exists)
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 1).staticTexts[
                    "A$2.00 fee"].exists)
        
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 2).staticTexts[
                    "Bank Account"].exists)
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 2).staticTexts[
                    "2.00% (Max:A$8.00) fee"].exists)
        
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 3).staticTexts[
                    "Debit Card"].exists)
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 3).staticTexts[
                    "A$12 + 8% (Max:A$10.00) fee"].exists)
    }
    
    private func assertINRFeeFormatting() {
        selectTransferMethodType.selectCurrency(currency: "INR")
        
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 0).staticTexts[
                    "Wire Transfer"].exists)
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 0).staticTexts[
                    "₹5.00 + 10.00% fee"].exists)
        
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 1).staticTexts[
                    "PayPal Account"].exists)
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 1).staticTexts[
                    "₹2.00 fee"].exists)
        
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 2).staticTexts[
                    "Bank Account"].exists)
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 2).staticTexts[
                    "₹2.00 + 2.00% (Min:₹4.00) fee"].exists)
        
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 3).staticTexts[
                    "Debit Card"].exists)
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 3).staticTexts[
                    "No fee"].exists)
    }
    
    private func assertJPYFeeFormatting() {
        selectTransferMethodType.selectCurrency(currency: "JPY")
        
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 0).staticTexts[
                    "Wire Transfer"].exists)
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 0).staticTexts[
                    "¥5.00 + 10.00% fee"].exists)
        
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 1).staticTexts[
                    "PayPal Account"].exists)
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 1).staticTexts[
                    "No fee \u{2022} 1-3 Business days"].exists)
        
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 2).staticTexts[
                    "Bank Account"].exists)
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 2).staticTexts[
                    "No fee"].exists)
        
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 3).staticTexts[
                    "Debit Card"].exists)
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 3).staticTexts[
                    "5.00% fee \u{2022} 1-2 Business days"].exists)
    }
    
    private func assertUSDFeeFormatting() {
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 0).staticTexts[
                    "Wire Transfer"].exists)
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 0).staticTexts[
                    "$2 + 15% (Min:$4.00, Max:$10.00) fee"].exists)
        
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 1).staticTexts[
                    "PayPal Account"].exists)
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 1).staticTexts[
                    "No fee"].exists)
        
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 2).staticTexts[
                    "Bank Account"].exists)
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 2).staticTexts[
                    "2.00% fee"].exists)
        
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 3).staticTexts[
                    "Debit Card"].exists)
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 3).staticTexts[
                    "$12 fee"].exists)
    }
}
