import XCTest

class SelectTransferMethodCountryTypeTests: BaseTests {
    var selectTransferMethodType: SelectTransferMethodType!
    var selectTransferMethodCountryType: SelectTransferMethodCountryType!

    override func setUp() {
        profileType = .individual
        super.setUp()
        setUpSelectTransferMethodCountryTypeScreen()
        validateSelectionWidgetScreen()
    }

    override func tearDown() {
        mockServer.tearDown()
    }

    private func setUpSelectTransferMethodCountryTypeScreen() {
        selectTransferMethodType = SelectTransferMethodType(app: app)
        selectTransferMethodCountryType = SelectTransferMethodCountryType(app: app)
        app.tables.cells.containing(.staticText, identifier: "Add Transfer Method").element(boundBy: 0).tap()

        let spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)
        selectTransferMethodType.tapCountry()
    }

    private func validateSelectionWidgetScreen() {
        XCTAssertTrue(app.navigationBars["Select Country"].exists)
        XCTAssertTrue(app.tables.staticTexts["United States"].exists)
        XCTAssertTrue(app.tables.staticTexts["Canada"].exists)
        XCTAssertEqual(app.tables.cells.count, 30)
        XCTAssertTrue(selectTransferMethodCountryType.countryTable.exists)
    }

    func testAppClickHomeAndRelaunch() {
        XCUIDevice.shared.clickHomeAndRelaunch(app: app)
        setUpSelectTransferMethodCountryTypeScreen()
        validateSelectionWidgetScreen()
    }

    func testAppResumeFromRecents() {
        XCUIDevice.shared.resumeFromRecents(app: app)
        validateSelectionWidgetScreen()
    }

    func testAppClickBackButton() {
        selectTransferMethodCountryType.clickBackButton()
        XCTAssertTrue(app.navigationBars["Add Account"].exists)
    }

    func testAppRotateScreen() {
        XCUIDevice.shared.rotateScreen(times: 3)
        validateSelectionWidgetScreen()
    }

    func testAppSendToBackground() {
        XCUIDevice.shared.sendToBackground(app: app)
        validateSelectionWidgetScreen()
    }

    func testAppWakeFromSleep() {
        XCUIDevice.shared.wakeFromSleep(app: app)
        validateSelectionWidgetScreen()
    }
}
