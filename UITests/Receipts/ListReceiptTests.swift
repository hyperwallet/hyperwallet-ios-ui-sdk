import XCTest

class ListReceiptTests: BaseTests {
    var receiptsList: ReceiptsList!

    override func setUp() {
        profileType = .individual
        super.setUp()
        receiptsList = ReceiptsList(app: app)
        spinner = app.activityIndicators["activityIndicator"]
    }

    override func tearDown() {
        mockServer.tearDown()
    }

    func testReceiptsList_verifyReceiptsOrder() {
        openupReceiptsListScreenForFewMonths()
        validateListOrder()
    }

    func testReceiptsList_verifySectionHeaders() {
        openupReceiptsListScreenForFewMonths()
        validateSectionsHeaders()
    }

    func testReceiptsList_verifyNumberOfReceipts() {
        openupReceiptsListScreenForFewMonths()
        let expectedNumberOfCells = 8
        XCTAssertEqual(app.tables.cells.count, expectedNumberOfCells)
    }

    func testReceiptsList_verifyReceiptsListForOneMonth() {
        let expectedNumberOfCells = 5
        mockServer.setupStub(url: "/rest/v3/users/usr-token/receipts",
                             filename: "ReceiptsForOneMonth",
                             method: HTTPMethod.get)
        openReceiptsListScreen()

        if #available(iOS 12, *) {
            verifyCellExists(with: "Bank Account\nMay 10, 2019", moneyTitle: "-5.00\nUSD", by: 0)
            verifyCellExists(with: "Payment\nMay 8, 2019", moneyTitle: "6.00\nUSD", by: 1)
            verifyCellExists(with: "Bank Account\nMay 6, 2019", moneyTitle: "-5.00\nUSD", by: 2)
            verifyCellExists(with: "Payment\nMay 4, 2019", moneyTitle: "6.00\nUSD", by: 3)
            verifyCellExists(with: "Payment\nMay 3, 2019", moneyTitle: "6.00\nUSD", by: 4)
        } else {
            verifyCellExists(with: "Bank Account May 10, 2019", moneyTitle: "-5.00\nUSD", by: 0)
            verifyCellExists(with: "Payment May 8, 2019", moneyTitle: "6.00\nUSD", by: 1)
            verifyCellExists(with: "Bank Account May 6, 2019", moneyTitle: "-5.00\nUSD", by: 2)
            verifyCellExists(with: "Payment May 4, 2019", moneyTitle: "6.00\nUSD", by: 3)
            verifyCellExists(with: "Payment May 3, 2019", moneyTitle: "20.00\nUSD", by: 4)
        }
        XCTAssertEqual(app.tables.cells.count, expectedNumberOfCells)
        XCTAssertTrue(app.tables.staticTexts["May 2019"].exists)
        XCTAssertFalse(app.tables.cells.containing(.staticText, identifier: "May 2019").element.exists)
    }

    func testReceiptsList_verifyEmptyScreen() {
        mockServer.setUpEmptyResponse(url: "/rest/v3/users/usr-token/receipts")
        openReceiptsListScreen()

        XCTAssertTrue(app.staticTexts["Seems like, you don’t have any Transactions, yet."].exists)
        XCTAssertEqual(app.tables.cells.count, 0)
    }

    func testReceiptsList_verifyLazyLoading() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/receipts",
                             filename: "ReceiptsForLazyLoading",
                             method: HTTPMethod.get)
        openReceiptsListScreen()
        mockServer.setupStub(url: "/rest/v3/users/usr-token/receipts?offset=10&limit=10",
                             filename: "ReceiptsForLazyLoadingNextPage",
                             method: HTTPMethod.get)

        if #available(iOS 12, *) {
            verifyCellDoesNotExist(with: "Payment\nMar 24, 2019", moneyTitle: "5.00\nUSD", by: 20)
            verifyCellDoesNotExist(with: "Payment\nMar 24, 2019", moneyTitle: "6.00\nUSD", by: 21)
            verifyCellDoesNotExist(with: "Bank Account\nMar 24, 2019", moneyTitle: "-5.00\nUSD", by: 22)
        } else {
            verifyCellDoesNotExist(with: "Payment Mar 24, 2019", moneyTitle: "5.00 USD", by: 20)
            verifyCellDoesNotExist(with: "Payment Mar 24, 2019", moneyTitle: "6.00 USD", by: 21)
            verifyCellDoesNotExist(with: "Bank Account Mar 24, 2019", moneyTitle: "-5.00 USD", by: 22)
        }

        app.swipeUp()
        app.swipeUp()
        waitForNonExistence(spinner)

        if #available(iOS 12, *) {
            verifyCellExists(with: "Payment\nMar 24, 2019", moneyTitle: "5.00\nUSD", by: 20)
            verifyCellExists(with: "Payment\nMar 24, 2019", moneyTitle: "6.00\nUSD", by: 21)
            verifyCellExists(with: "Bank Account\nMar 24, 2019", moneyTitle: "-5.00\nUSD", by: 22)
        } else {
            verifyCellExists(with: "Payment Mar 24, 2019", moneyTitle: "5.00 USD", by: 20)
            verifyCellExists(with: "Payment Mar 24, 2019", moneyTitle: "6.00 USD", by: 21)
            verifyCellExists(with: "Bank Account Mar 24, 2019", moneyTitle: "-5.00 USD", by: 22)
        }
    }

    func testReceiptsList_verifyAfterRelaunch() {
        openupReceiptsListScreenForFewMonths()
        validatetestReceiptsListScreen()
        XCUIDevice.shared.clickHomeAndRelaunch(app: app)
        openupReceiptsListScreenForFewMonths()
        validatetestReceiptsListScreen()
    }

    func testReceiptsList_verifyRotateScreen() {
        openupReceiptsListScreenForFewMonths()
        XCUIDevice.shared.rotateScreen(times: 3)
        validatetestReceiptsListScreen()
    }

    func testReceiptsList_verifyWakeFromSleep() {
        openupReceiptsListScreenForFewMonths()
        XCUIDevice.shared.wakeFromSleep(app: app)
        waitForNonExistence(receiptsList.navigationBar)
        validatetestReceiptsListScreen()
    }

    func testReceiptsList_verifyResumeFromRecents() {
        openupReceiptsListScreenForFewMonths()
        XCUIDevice.shared.resumeFromRecents(app: app)
        waitForNonExistence(receiptsList.navigationBar)
        validatetestReceiptsListScreen()
    }

    func testReceiptsList_verifyAppToBackground() {
        openupReceiptsListScreenForFewMonths()
        XCUIDevice.shared.sendToBackground(app: app)
        validatetestReceiptsListScreen()
    }

    func testReceiptsList_verifyPressBackButton() {
        openupReceiptsListScreenForFewMonths()
        receiptsList.clickBackButton()
        XCTAssertTrue(app.navigationBars["Account Settings"].exists)
    }

    private func verifyCellExists(with text: String, moneyTitle: String, by index: Int) {
        let cell = app.cells.element(boundBy: index)
        app.scroll(to: cell)
        XCTAssertTrue(cell.staticTexts[text].exists)
    }

    private func verifyCellDoesNotExist(with text: String, moneyTitle: String, by index: Int) {
        XCTAssertFalse(app.cells.element(boundBy: index).staticTexts[text].exists)
    }

    private func validateListOrder() {
        if #available(iOS 12, *) {
            verifyCellExists(with: "Payment\nMay 24, 2019", moneyTitle: "6.00\nUSD", by: 0)
            verifyCellExists(with: "Bank Account\nMay 12, 2019", moneyTitle: "-5.00\nUSD", by: 1)
            verifyCellExists(with: "Payment\nMay 4, 2019", moneyTitle: "6.00\nUSD", by: 2)
            verifyCellExists(with: "Payment\nApr 27, 2019", moneyTitle: "6.00\nUSD", by: 3)
            verifyCellExists(with: "Payment\nApr 19, 2019", moneyTitle: "6.00\nUSD", by: 4)
            verifyCellExists(with: "Bank Account\nApr 14, 2019", moneyTitle: "-7.50\nUSD", by: 5)
            verifyCellExists(with: "Payment\nMar 25, 2019", moneyTitle: "6.00\nUSD", by: 6)
            verifyCellExists(with: "Payment\nMar 18, 2019", moneyTitle: "6.00\nUSD", by: 7)
        } else {
            verifyCellExists(with: "Payment May 24, 2019", moneyTitle: "6.00 USD", by: 0)
            verifyCellExists(with: "Bank Account May 12, 2019", moneyTitle: "-5.00 USD", by: 1)
            verifyCellExists(with: "Payment May 4, 2019", moneyTitle: "6.00 USD", by: 2)
            verifyCellExists(with: "Payment Apr 27, 2019", moneyTitle: "6.00 USD", by: 3)
            verifyCellExists(with: "Payment Apr 19, 2019", moneyTitle: "6.00 USD", by: 4)
            verifyCellExists(with: "Bank Account Apr 14, 2019", moneyTitle: "-7.50 USD", by: 5)
            verifyCellExists(with: "Payment Mar 25, 2019", moneyTitle: "6.00 USD", by: 6)
            verifyCellExists(with: "Payment Mar 18, 2019", moneyTitle: "6.00 USD", by: 7)
        }
    }

    private func validateSectionsHeaders() {
        XCTAssertTrue(app.tables.staticTexts["May 2019"].exists)
        XCTAssertTrue(app.tables.staticTexts["April 2019"].exists)
        XCTAssertTrue(app.tables.staticTexts["March 2019"].exists)

        XCTAssertFalse(app.tables.cells.containing(.staticText, identifier: "May 2019").element.exists)
        XCTAssertFalse(app.tables.cells.containing(.staticText, identifier: "April 2019").element.exists)
        XCTAssertFalse(app.tables.cells.containing(.staticText, identifier: "March 2019").element.exists)
    }

    private func validatetestReceiptsListScreen() {
        XCTAssertTrue(receiptsList.navigationBar.exists)
        validateListOrder()
        validateSectionsHeaders()
    }

    private func openupReceiptsListScreenForFewMonths() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/receipts",
                             filename: "ReceiptsForFewMonths",
                             method: HTTPMethod.get)
        openReceiptsListScreen()
    }

    private func openReceiptsListScreen() {
        app.tables.cells.containing(.staticText, identifier: "List User Receipts").element(boundBy: 0).tap()
        waitForNonExistence(spinner)
    }
}
