import XCTest

class SelectTransferMethodTypeTests: BaseTests {
    var selectTransferMethodType: SelectTransferMethodType!
    let bankAccount = NSPredicate(format: "label CONTAINS[c] 'Bank Account'")
    let debitCard = NSPredicate(format: "label CONTAINS[c] 'Debit Card'")
    let processingTime = NSPredicate(format: "label CONTAINS[c] 'Processing Time'")
    let transactionFee = NSPredicate(format: "label CONTAINS[c] 'Transaction Fees'")
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
        XCTAssert(app.tables.staticTexts["United States Dollar"].exists)
    }

    func testSelectTransferMethodType_verifyTransferMethodSelection() {
        selectTransferMethodType.selectCountry(country: "Canada")
        selectTransferMethodType.selectCurrency(currency: "Canadian Dollar")

        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 0).staticTexts[
            "Bank Account"].exists)
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 1).staticTexts[
            "PayPal Account"].exists)

        XCTAssert(app.tables[" "].cells.element(boundBy: 0).staticTexts[
            "CA$2.20 \u{2022} 1-2 Business days"].exists)
        XCTAssert(app.tables["selectTransferMethodTypeTable"].cells.element(boundBy: 1).staticTexts[
            "CA$0.25 \u{2022} IMMEDIATE"].exists)
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
        XCTAssertFalse(app.tables["selectTransferMethodTypeTable"].staticTexts.element(matching: transactionFee).exists)
    }

    func testSelectTransferMethod_verifyTransferMethodsListEmptyProcessing () {
        selectTransferMethodType.selectCountry(country: "SPAIN")

        XCTAssertTrue(app.tables["selectTransferMethodTypeTable"].staticTexts.element(matching: wireTransfer).exists)
        XCTAssertFalse(app.tables["selectTransferMethodTypeTable"].staticTexts.element(matching: processingTime).exists)
        XCTAssertTrue(app.tables["selectTransferMethodTypeTable"].staticTexts.element(matching: transactionFee).exists)
    }
}
