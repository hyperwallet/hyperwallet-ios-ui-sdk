import XCTest
class PrepaidCardListReceiptTests: BaseTests {
    override func setUp() {
        profileType = .individual
        super.setUp()
        spinner = app.activityIndicators["activityIndicator"]
    }

    override func tearDown() {
        mockServer.tearDown()
    }

    // MARK: Prepaid Card List Receipt TestCases
    func testPrepaidCardReceiptsList_verifyReceiptsOrder() {
        let expectedNumberOfCells = 4

        mockServer.setupStub(url: "/rest/v3/users/usr-token/prepaid-cards/trm-token/receipts",
                             filename: "PrepaidCardReceiptsForOneMonth",
                             method: HTTPMethod.get)
        let prepaidCardMenu = "List Prepaid Card Receipts"
        let prepaidCardReceiptMenu = app.tables.cells.containing(.staticText, identifier: prepaidCardMenu).element(boundBy: 0)

        XCTAssertTrue(prepaidCardReceiptMenu.exists)
        prepaidCardReceiptMenu.tap()
        waitForNonExistence(spinner)

        XCTAssertEqual(app.tables.cells.count, expectedNumberOfCells)

        if #available(iOS 12, *) {
            verifyCellLabels(with: "Funds Deposit\nJun 20, 2019", moneyTitle: "+10.00\nUSD", by: 0)
            verifyCellLabels(with: "Funds Deposit\nJun 21, 2019", moneyTitle: "+20.00\nUSD", by: 1)
            verifyCellLabels(with: "Balance Adjustment\nJun 23, 2019", moneyTitle: "-7.00\nUSD", by: 2)
            verifyCellLabels(with: "Balance Adjustment\nJun 24, 2019", moneyTitle: "-500.99\nUSD", by: 3)
        } else {
            verifyCellLabels(with: "Funds Deposit Jun 20, 2019", moneyTitle: "+10.00 USD", by: 0)
            verifyCellLabels(with: "Funds Deposit Jun 21, 2019", moneyTitle: "+20.00 USD", by: 1)
            verifyCellLabels(with: "Balance Adjustment Jun 23, 2019", moneyTitle: "-7.00 USD", by: 2)
            verifyCellLabels(with: "Balance Adjustment Jun 24, 2019", moneyTitle: "-500.99 USD", by: 3)
        }
    }

    func testReceiptsList_verifyPrepaidCardReceiptsSectionHeaders() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/prepaid-cards/trm-token/receipts",
                             filename: "PrepaidCardReceiptsForFewMonths",
                             method: HTTPMethod.get)
        let prepaidCardMenu = "List Prepaid Card Receipts"
        let prepaidCardReceiptMenu = app.tables.cells.containing(.staticText, identifier: prepaidCardMenu).element(boundBy: 0)

        XCTAssertTrue(prepaidCardReceiptMenu.exists)
        prepaidCardReceiptMenu.tap()
        waitForNonExistence(spinner)

        XCTAssertTrue(app.tables.staticTexts["April 2019"].exists)
        XCTAssertTrue(app.tables.staticTexts["May 2019"].exists)
        XCTAssertTrue(app.tables.staticTexts["June 2019"].exists)
    }

    func testPrepaidCardReceiptsList_verifyPagingBySwipe() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/prepaid-cards/trm-token/receipts",
                             filename: "PrepaidCardReceiptsPaging",
                             method: HTTPMethod.get)
        let prepaidCardMenu = "List Prepaid Card Receipts"
        let prepaidCardReceiptMenu = app.tables.cells.containing(.staticText, identifier: prepaidCardMenu).element(boundBy: 0)

        XCTAssertTrue(prepaidCardReceiptMenu.exists)
        prepaidCardReceiptMenu.tap()
        waitForNonExistence(spinner)

        app.swipeUp()
        app.swipeUp()
        let lastRow = app.tables.element.children(matching: .cell).element(boundBy: 10)
        let lastRowLabel = lastRow.staticTexts["ListReceiptTableViewCellTextLabel"].label

        XCTAssertTrue(lastRow.exists)
        XCTAssertTrue(lastRowLabel.contains("Jun 8, 2019"))
    }

    // MARK: helper functions
    private func verifyCellLabels(with text: String, moneyTitle: String, by index: Int) {
        let row = app.tables.element.children(matching: .cell).element(boundBy: index)
        let actualPaymentLabel = row.staticTexts["ListReceiptTableViewCellTextLabel"].label
        XCTAssertEqual(text, actualPaymentLabel)
        let actualMoneyLabel = row.staticTexts["ListReceiptTableViewCellDetailTextLabel"].label
        XCTAssertEqual(moneyTitle, actualMoneyLabel)
    }
}
