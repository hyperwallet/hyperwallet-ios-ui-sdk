import XCTest

class TransactionsListTests: BaseTests {
    var selectTransferMethodType: SelectTransferMethodType!
    var transactionsList: TransactionsList!
    let debitCard = NSPredicate(format: "label CONTAINS[c] 'Debit Card'")

    override func setUp() {
        profileType = .individual
        super.setUp()
        transactionsList = TransactionsList(app: app)
        setupTransactionsListScreen()
    }

    override func tearDown() {
        mockServer.tearDown()
    }

    func testTransactionsList_verifyTransactionsOrder() {
        validateListOrder()
    }

    func testTransactionsList_verifySectionHeaders() {
        validateSectionsHeaders()
    }

    func testTransactionsList_verifyNumberOfTransactions() {
        let expectedNumberOfCells = 8
        XCTAssertEqual(app.tables.cells.count, expectedNumberOfCells)
    }

    func testTransactionsList_verifyTransactionsListForOneMonth() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/receipts",
                             filename: "TransactionsForOneMonth",
                             method: HTTPMethod.get)
        let expectedNumberOfCells = 4
        transactionsList.clickBackButton()
        app.tables.cells.containing(.staticText, identifier: "List Receipts").element(boundBy: 0).tap()
        waitForNonExistence(spinner)

        if #available(iOS 12, *) {
            verifyCell(with: "Payment\nMay 4, 2019", moneyTitle: "+6.00\nUSD", by: 0)
            verifyCell(with: "Bank Account\nMay 6, 2019", moneyTitle: "-5.00\nUSD", by: 1)
            verifyCell(with: "Payment\nMay 8, 2019", moneyTitle: "+6.00\nUSD", by: 2)
            verifyCell(with: "Bank Account\nMay 10, 2019", moneyTitle: "-5.00\nUSD", by: 3)
        } else {
            verifyCell(with: "Payment May 4, 2019", moneyTitle: "+6.00 USD", by: 0)
            verifyCell(with: "Bank Account May 6, 2019", moneyTitle: "-5.00 USD", by: 1)
            verifyCell(with: "Payment May 8, 2019", moneyTitle: "+6.00 USD", by: 2)
            verifyCell(with: "Bank Account May 10, 2019", moneyTitle: "-5.00 USD", by: 3)
        }
        XCTAssertEqual(app.tables.cells.count, expectedNumberOfCells)
        XCTAssertTrue(app.tables.staticTexts["May 2019"].exists)
        XCTAssertFalse(app.tables.cells.containing(.staticText, identifier: "May 2019").element.exists)
    }

    func testTransactionsList_verifyAfterRelaunch() {
        validatetestTransactionsListScreen()
        XCUIDevice.shared.clickHomeAndRelaunch(app: app)
        setupTransactionsListScreen()
        validatetestTransactionsListScreen()
    }

    func testTransactionsList_verifyRotateScreen() {
        XCUIDevice.shared.rotateScreen(times: 3)
        validatetestTransactionsListScreen()
    }

    func testTransactionsList_verifyWakeFromSleep() {
        XCUIDevice.shared.wakeFromSleep(app: app)
        waitForNonExistence(transactionsList.navigationBar)
        validatetestTransactionsListScreen()
    }

    func testTransactionsList_verifyResumeFromRecents() {
        XCUIDevice.shared.resumeFromRecents(app: app)
        waitForNonExistence(transactionsList.navigationBar)
        validatetestTransactionsListScreen()
    }

    func testTransactionsList_verifyAppToBackground() {
        XCUIDevice.shared.sendToBackground(app: app)
        validatetestTransactionsListScreen()
    }

    func testTransactionsList_verifyPressBackButton() {
        transactionsList.clickBackButton()
        XCTAssertTrue(app.navigationBars["Account Settings"].exists)
    }

    private func verifyCell(with text: String, moneyTitle: String, by index: Int) {
        XCTAssertTrue(app.cells.element(boundBy: index).staticTexts[text].exists)
    }

    private func validateListOrder() {
        if #available(iOS 12, *) {
            verifyCell(with: "Payment\nMay 4, 2019", moneyTitle: "+6.00\nUSD", by: 0)
            verifyCell(with: "Bank Account\nMay 12, 2019", moneyTitle: "-5.00\nUSD", by: 1)
            verifyCell(with: "Payment\nMay 24, 2019", moneyTitle: "+6.00\nUSD", by: 2)
            verifyCell(with: "Bank Account\nApr 14, 2019", moneyTitle: "-7.50.00\nUSD", by: 3)
            verifyCell(with: "Payment\nApr 19, 2019", moneyTitle: "+6.00\nUSD", by: 4)
            verifyCell(with: "Payment\nApr 27, 2019", moneyTitle: "+6.00\nUSD", by: 5)
            verifyCell(with: "Payment\nMar 18, 2019", moneyTitle: "+6.00\nUSD", by: 6)
            verifyCell(with: "Payment\nMar 25, 2019", moneyTitle: "+6.00\nUSD", by: 7)
        } else {
            verifyCell(with: "Payment May 4, 2019", moneyTitle: "+6.00 USD", by: 0)
            verifyCell(with: "Bank Account May 12, 2019", moneyTitle: "-5.00 USD", by: 1)
            verifyCell(with: "Payment May 24, 2019", moneyTitle: "+6.00 USD", by: 2)
            verifyCell(with: "Bank Account Apr 14, 2019", moneyTitle: "-7.50 USD", by: 3)
            verifyCell(with: "Payment Apr 19, 2019", moneyTitle: "+6.00 USD", by: 4)
            verifyCell(with: "Payment Apr 27, 2019", moneyTitle: "+6.00 USD", by: 5)
            verifyCell(with: "Payment Mar 18, 2019", moneyTitle: "+6.00 USD", by: 6)
            verifyCell(with: "Payment Mar 25, 2019", moneyTitle: "+6.00 USD", by: 7)
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

    private func validatetestTransactionsListScreen() {
        XCTAssertTrue(transactionsList.navigationBar.exists)
        validateListOrder()
        validateSectionsHeaders()
    }

    private func setupTransactionsListScreen() {
        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)
        mockServer.setupStub(url: "/rest/v3/users/usr-token/receipts",
                             filename: "TransactionsForFewMonths",
                             method: HTTPMethod.get)
        app.tables.cells.containing(.staticText, identifier: "List Receipts").element(boundBy: 0).tap()
        waitForNonExistence(spinner)
    }
}
