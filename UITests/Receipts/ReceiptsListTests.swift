import XCTest

class ReceiptsListTests: BaseTests {
    var selectTransferMethodType: SelectTransferMethodType!
    var receiptsList: ReceiptsList!
    let debitCard = NSPredicate(format: "label CONTAINS[c] 'Debit Card'")

    override func setUp() {
        profileType = .individual
        super.setUp()
        receiptsList = ReceiptsList(app: app)
        setupReceiptsListScreen()
    }

    override func tearDown() {
        mockServer.tearDown()
    }

    func testReceiptsList_verifyReceiptsOrder() {
        validateListOrder()
    }

    func testReceiptsList_verifySectionHeaders() {
        validateSectionsHeaders()
    }

    func testReceiptsList_verifyNumberOfReceipts() {
        let expectedNumberOfCells = 10
        XCTAssertEqual(app.tables.cells.count, expectedNumberOfCells)
    }

    func testReceiptsList_verifyReceiptsListForOneMonth() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/receipts",
                             filename: "ReceiptsForOneMonth",
                             method: HTTPMethod.get)
        let expectedNumberOfCells = 4
        receiptsList.clickBackButton()
        app.tables.cells.containing(.staticText, identifier: "List Receipts").element(boundBy: 0).tap()
        waitForNonExistence(spinner)

        if #available(iOS 12, *) {
            verifyCellExists(with: "Payment\nMay 4, 2019", moneyTitle: "+6.00\nUSD", by: 0)
            verifyCellExists(with: "Bank Account\nMay 6, 2019", moneyTitle: "-5.00\nUSD", by: 1)
            verifyCellExists(with: "Payment\nMay 8, 2019", moneyTitle: "+6.00\nUSD", by: 2)
            verifyCellExists(with: "Bank Account\nMay 10, 2019", moneyTitle: "-5.00\nUSD", by: 3)
        } else {
            verifyCellExists(with: "Payment May 4, 2019", moneyTitle: "+6.00 USD", by: 0)
            verifyCellExists(with: "Bank Account May 6, 2019", moneyTitle: "-5.00 USD", by: 1)
            verifyCellExists(with: "Payment May 8, 2019", moneyTitle: "+6.00 USD", by: 2)
            verifyCellExists(with: "Bank Account May 10, 2019", moneyTitle: "-5.00 USD", by: 3)
        }
        XCTAssertEqual(app.tables.cells.count, expectedNumberOfCells)
        XCTAssertTrue(app.tables.staticTexts["May 2019"].exists)
        XCTAssertFalse(app.tables.cells.containing(.staticText, identifier: "May 2019").element.exists)
    }

    func testReceiptsList_verifyEmptyScreen() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/receipts",
                             filename: "ReceiptsEmptyList",
                             method: HTTPMethod.get)
        receiptsList.clickBackButton()
        app.tables.cells.containing(.staticText, identifier: "List Receipts").element(boundBy: 0).tap()
        waitForNonExistence(spinner)

        XCTAssertTrue(app.staticTexts["Seems like, you don’t have any Transactions, yet."].exists)
        XCTAssertEqual(app.tables.cells.count, 0)
    }

    func testReceiptsList_verifyLazyLoading() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/receipts",
                             filename: "ReceiptsForLazyLoading",
                             method: HTTPMethod.get)
        receiptsList.clickBackButton()
        app.tables.cells.containing(.staticText, identifier: "List Receipts").element(boundBy: 0).tap()
        waitForNonExistence(spinner)
        mockServer.setupStub(url: "/rest/v3/users/usr-token/receipts?offset=10&limit=10",
                             filename: "ReceiptsForLazyLoadingNextPage",
                             method: HTTPMethod.get)
        
        if #available(iOS 12, *) {
            verifyCellDoesNotExist(with: "Payment\nMar 24, 2019", moneyTitle: "+5.00\nUSD", by: 20)
            verifyCellDoesNotExist(with: "Payment\nMar 24, 2019", moneyTitle: "+6.00\nUSD", by: 21)
            verifyCellDoesNotExist(with: "Bank Account\nMar 24, 2019", moneyTitle: "-5.00\nUSD", by: 22)
        } else {
            verifyCellDoesNotExist(with: "Payment Mar 24, 2019", moneyTitle: "+5.00 USD", by: 20)
            verifyCellDoesNotExist(with: "Payment Mar 24, 2019", moneyTitle: "+6.00 USD", by: 21)
            verifyCellDoesNotExist(with: "Bank Account Mar 24, 2019", moneyTitle: "-5.00 USD", by: 22)
        }
        
        
        app.swipeUp()
        app.swipeUp()
        waitForNonExistence(spinner)
        
        if #available(iOS 12, *) {
            verifyCellExists(with: "Payment\nMar 24, 2019", moneyTitle: "+5.00\nUSD", by: 20)
            verifyCellExists(with: "Payment\nMar 24, 2019", moneyTitle: "+6.00\nUSD", by: 21)
            verifyCellExists(with: "Bank Account\nMar 24, 2019", moneyTitle: "-5.00\nUSD", by: 22)
        } else {
            verifyCellExists(with: "Payment Mar 24, 2019", moneyTitle: "+5.00 USD", by: 20)
            verifyCellExists(with: "Payment Mar 24, 2019", moneyTitle: "+6.00 USD", by: 21)
            verifyCellExists(with: "Bank Account Mar 24, 2019", moneyTitle: "-5.00 USD", by: 22)
        }
    }

    func testReceiptsList_verifyAfterRelaunch() {
        validatetestReceiptsListScreen()
        XCUIDevice.shared.clickHomeAndRelaunch(app: app)
        setupReceiptsListScreen()
        validatetestReceiptsListScreen()
    }

    func testReceiptsList_verifyRotateScreen() {
        XCUIDevice.shared.rotateScreen(times: 3)
        validatetestReceiptsListScreen()
    }

    func testReceiptsList_verifyWakeFromSleep() {
        XCUIDevice.shared.wakeFromSleep(app: app)
        waitForNonExistence(receiptsList.navigationBar)
        validatetestReceiptsListScreen()
    }

    func testReceiptsList_verifyResumeFromRecents() {
        XCUIDevice.shared.resumeFromRecents(app: app)
        waitForNonExistence(receiptsList.navigationBar)
        validatetestReceiptsListScreen()
    }

    func testReceiptsList_verifyAppToBackground() {
        XCUIDevice.shared.sendToBackground(app: app)
        validatetestReceiptsListScreen()
    }

    func testReceiptsList_verifyPressBackButton() {
        receiptsList.clickBackButton()
        XCTAssertTrue(app.navigationBars["Account Settings"].exists)
    }

    private func verifyCellExists(with text: String, moneyTitle: String, by index: Int) {
        XCTAssertTrue(app.cells.element(boundBy: index).staticTexts[text].exists)
    }
    
    private func verifyCellDoesNotExist(with text: String, moneyTitle: String, by index: Int) {
        XCTAssertFalse(app.cells.element(boundBy: index).staticTexts[text].exists)
    }

    private func validateListOrder() {
        if #available(iOS 12, *) {
            verifyCellExists(with: "Payment\nMay 4, 2019", moneyTitle: "+6.00\nUSD", by: 0)
            verifyCellExists(with: "Bank Account\nMay 12, 2019", moneyTitle: "-5.00\nUSD", by: 1)
            verifyCellExists(with: "Payment\nMay 24, 2019", moneyTitle: "+6.00\nUSD", by: 2)
            verifyCellExists(with: "Bank Account\nApr 14, 2019", moneyTitle: "-7.50.00\nUSD", by: 3)
            verifyCellExists(with: "Payment\nApr 19, 2019", moneyTitle: "+6.00\nUSD", by: 4)
            verifyCellExists(with: "Payment\nApr 27, 2019", moneyTitle: "+6.00\nUSD", by: 5)
            verifyCellExists(with: "Payment\nMar 18, 2019", moneyTitle: "+6.00\nUSD", by: 6)
            verifyCellExists(with: "Payment\nMar 25, 2019", moneyTitle: "+6.00\nUSD", by: 7)
        } else {
            verifyCellExists(with: "Payment May 4, 2019", moneyTitle: "+6.00 USD", by: 0)
            verifyCellExists(with: "Bank Account May 12, 2019", moneyTitle: "-5.00 USD", by: 1)
            verifyCellExists(with: "Payment May 24, 2019", moneyTitle: "+6.00 USD", by: 2)
            verifyCellExists(with: "Bank Account Apr 14, 2019", moneyTitle: "-7.50 USD", by: 3)
            verifyCellExists(with: "Payment Apr 19, 2019", moneyTitle: "+6.00 USD", by: 4)
            verifyCellExists(with: "Payment Apr 27, 2019", moneyTitle: "+6.00 USD", by: 5)
            verifyCellExists(with: "Payment Mar 18, 2019", moneyTitle: "+6.00 USD", by: 6)
            verifyCellExists(with: "Payment Mar 25, 2019", moneyTitle: "+6.00 USD", by: 7)
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

    private func setupReceiptsListScreen() {
        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)
        mockServer.setupStub(url: "/rest/v3/users/usr-token/receipts",
                             filename: "ReceiptsForFewMonths",
                             method: HTTPMethod.get)
        app.tables.cells.containing(.staticText, identifier: "List Receipts").element(boundBy: 0).tap()
        waitForNonExistence(spinner)
    }
}
