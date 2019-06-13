import XCTest

class SelectTransferMethodTypeTests: BaseTests {
    var selectTransferMethodType: SelectTransferMethodType!
    let bankAccount = NSPredicate(format: "label CONTAINS[c] 'Bank Account'")
    let debitCard = NSPredicate(format: "label CONTAINS[c] 'Debit Card'")
    let processingTime = NSPredicate(format: "label CONTAINS[c] 'Processing Time'")
    let transactionFee = NSPredicate(format: "label CONTAINS[c] 'Transaction Fees'")

    override func setUp() {
        profileType = .individual
        super.setUp()
        setUpSelectTransferMethodTypeScreen()
        validateSelectTransferMethodScreen()
    }

    override func tearDown() {
        mockServer.tearDown()
    }

    private func setUpSelectTransferMethodTypeScreen() {
        selectTransferMethodType = SelectTransferMethodType(app: app)
        app.tables.cells.containing(.staticText, identifier: "Add Transfer Method").element(boundBy: 0).tap()

        let spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)
    }

    override var userResponseFileName: String {
        return "UserIndividualCountryCanadaResponse"
    }

    private func validateSelectTransferMethodScreen() {
        XCTAssertNotNil(app.cells.images)
        XCTAssertTrue(app.navigationBars["Add Account"].exists)
        XCTAssertTrue(app.tables.staticTexts["Canada"].exists)
        XCTAssertTrue(app.tables.staticTexts["CAD"].exists)
        XCTAssertEqual(app.cells.staticTexts["PayPal Account"].label, "PayPal Account")
        if #available(iOS 11.2, *) {
            XCTAssert(app.cells.staticTexts["Transaction Fees: CAD 2.20\nProcessing Time: 1-2 Business days"].exists)
        } else {
            XCTAssert(app.cells.staticTexts["Transaction Fees: CAD 2.20 Processing Time: 1-2 Business days"].exists)
        }

        XCTAssertTrue(selectTransferMethodType.countrySelect.exists &&
            selectTransferMethodType.navigationBar.exists &&
            selectTransferMethodType.currencySelect.exists)
    }

    private func validateBankAccountCell () {
        XCTAssertTrue(app.tables["transferMethodTableView"].staticTexts.element(matching: bankAccount).exists)
    }

    func testAppClickHomeAndRelaunch() {
        XCUIDevice.shared.clickHomeAndRelaunch(app: app)
        setUpSelectTransferMethodTypeScreen()
        validateSelectTransferMethodScreen()
    }

    func testAppResumeFromRecents() {
        XCUIDevice.shared.resumeFromRecents(app: app)
        validateSelectTransferMethodScreen()
    }

    func testAppClickBackButton() {
        selectTransferMethodType.clickBackButton()
        XCTAssertTrue(app.navigationBars["Account Settings"].exists)
    }

    func testAppRotateScreen() {
        XCUIDevice.shared.rotateScreen(times: 3)
        validateSelectTransferMethodScreen()
    }

    func testAppSendToBackground() {
        XCUIDevice.shared.sendToBackground(app: app)
        validateSelectTransferMethodScreen()
    }

    func testAppWakeFromSleep() {
        XCUIDevice.shared.wakeFromSleep(app: app)
        validateSelectTransferMethodScreen()
    }

    func testSelectTransferMethodType_verifyCountrySelection() {
        selectTransferMethodType.tapCountry()

        XCTAssert(app.tables.staticTexts["United States"].exists)
        XCTAssertEqual(app.tables.cells.count, 5)
    }

    func testSelectTransferMethodType_verifyCurrencySelection() {
        selectTransferMethodType.selectCountry(country: "United States")
        selectTransferMethodType.tapCurrency()

        XCTAssertEqual(app.tables.cells.count, 1)
        XCTAssert(app.tables.staticTexts["United States Dollar"].exists)
    }

    func testSelectTransferMethodType_verifyTransferMethodSelection() {
        selectTransferMethodType.selectCountry(country: "United States")
        selectTransferMethodType.selectCurrency(currency: "United States Dollar")

        XCTAssertEqual(app.tables["transferMethodTableView"].cells.count, 6)
        XCTAssertTrue(app.tables["transferMethodTableView"].staticTexts.element(matching: bankAccount).exists)

        app.tables["transferMethodTableView"].staticTexts.element(matching: bankAccount).tap()
        XCTAssertTrue(app.navigationBars["Bank Account"].exists)
        XCTAssertTrue(app.tables["addTransferMethodTable"].exists)
        XCTAssertTrue(app.tables.staticTexts["Account Information - United States (USD)"].exists)
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

        app.tables["transferMethodTableView"].staticTexts.element(matching: bankAccount).tap()
        XCTAssert(app.navigationBars.staticTexts["Bank Account"].exists)
    }

    func testSelectTransferMethod_clickBankCardOpensAddTransferMethodUi () {
        selectTransferMethodType.selectCountry(country: "United States")

        app.tables["transferMethodTableView"].staticTexts.element(matching: debitCard).tap()
        XCTAssert(app.navigationBars.staticTexts["Debit Card"].exists)
    }

    func testSelectTransferMethod_verifyTransferMethodsListEmptyFee () {
        selectTransferMethodType.selectCountry(country: "United Kingdom")

        validateBankAccountCell()
        XCTAssertFalse(app.tables["transferMethodTableView"].staticTexts.element(matching: transactionFee).exists)
    }

    func testSelectTransferMethod_verifyTransferMethodsListEmptyProcessing () {
        selectTransferMethodType.selectCountry(country: "United Kingdom")

        validateBankAccountCell()
        XCTAssertFalse(app.tables["transferMethodTableView"].staticTexts.element(matching: processingTime).exists)
    }
}
