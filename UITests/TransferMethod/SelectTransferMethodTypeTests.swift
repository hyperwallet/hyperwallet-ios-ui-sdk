import XCTest

class SelectTransferMethodTypeTests: BaseIndividualTests {
    var selectTransferMethodType: SelectTransferMethodType!
    let bankAccount = NSPredicate(format: "label CONTAINS[c] 'Bank Account'")

    override func setUp() {
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

    override func stubGetUserDetailsResponse() -> String {
        return "UserIndividualCountryCanadaResponse"
    }

    private func validateSelectTransferMethodScreen() {
        XCTAssertNotNil(app.cells.images)
        XCTAssertTrue(app.navigationBars["Add Account"].exists)
        XCTAssertTrue(app.tables.staticTexts["United States"].exists)
        XCTAssertTrue(app.tables.staticTexts["CAD"].exists)
        XCTAssertEqual(app.cells.staticTexts["PayPal Account"].label, "PayPal Account")
        if #available(iOS 11.2, *) {
            XCTAssert(app.cells.staticTexts["Transaction Fees: CAD 0.25\nProcessing Time: 1-2 Business days"].exists)
        } else {
            XCTAssert(app.cells.staticTexts["Transaction Fees: CAD 0.25 Processing Time: 1-2 Business days"].exists)
        }

        XCTAssertTrue(selectTransferMethodType.countrySelect.exists &&
            selectTransferMethodType.navigationBar.exists &&
            selectTransferMethodType.currencySelect.exists)
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

        XCTAssert(app.tables.staticTexts["UNITED STATES"].exists)
        XCTAssertEqual(app.tables.cells.count, 3)
    }

    func testSelectTransferMethodType_verifyCurrencySelection() {
        selectTransferMethodType.selectCountry(country: "UNITED STATES")
        selectTransferMethodType.tapCurrency()

        XCTAssertEqual(app.tables.cells.count, 2)
        XCTAssert(app.tables.staticTexts["USD"].exists)
    }

    func testSelectTransferMethodType_verifyTransferMethodSelection() {
        selectTransferMethodType.selectCountry(country: "UNITED STATES")
        selectTransferMethodType.selectCurrency(currency: "USD")

        XCTAssertEqual(app.tables["transferMethodTableView"].cells.count, 5)
        XCTAssertTrue(app.tables["transferMethodTableView"].staticTexts.element(matching: bankAccount).exists)

        app.tables["transferMethodTableView"].staticTexts.element(matching: bankAccount).tap()
        XCTAssertTrue(app.navigationBars["Bank Account"].exists)
        XCTAssertTrue(app.tables["addTransferMethodTable"].exists)
        XCTAssertTrue(app.tables.staticTexts["Account Information - United States (USD)"].exists)
    }
}
