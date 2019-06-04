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

    private func verifyCell(with text: String, by index: Int) {
        XCTAssertTrue(app.cells.element(boundBy: index).staticTexts[text].exists)
    }

    private func validateListOrder() {
        verifyCell(with: "Payment May 4, 2019", by: 0)
        verifyCell(with: "Bank Account May 12, 2019", by: 1)
        verifyCell(with: "Payment May 24, 2019", by: 2)
        verifyCell(with: "Bank Account Apr 14, 2019", by: 3)
        verifyCell(with: "Payment Apr 19, 2019", by: 4)
        verifyCell(with: "Payment Apr 27, 2019", by: 5)
        verifyCell(with: "Payment Mar 18, 2019", by: 6)
        verifyCell(with: "Payment Mar 25, 2019", by: 7)
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
        mockServer.setupStub(url: "/rest/v3/users/usr-token/receipts",
                             filename: "TransactionsForFewMonths",
                             method: HTTPMethod.get)
        app.tables.cells.containing(.staticText, identifier: "List Receipts").element(boundBy: 0).tap()
    }
}
