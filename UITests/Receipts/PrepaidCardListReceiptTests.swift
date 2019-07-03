import XCTest
class PrepaidCardListReceiptTests: BaseTests {
    var prepaidCardReceiptMenu: XCUIElement!

    override func setUp() {
        profileType = .individual
        super.setUp()
        spinner = app.activityIndicators["activityIndicator"]
        prepaidCardReceiptMenu = app.tables.cells.containing(.staticText, identifier: "List Prepaid Card Receipts").element(boundBy: 0)
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

        XCTAssertTrue(prepaidCardReceiptMenu.exists)
        prepaidCardReceiptMenu.tap()
        waitForNonExistence(spinner)

        XCTAssertEqual(app.tables.cells.count, expectedNumberOfCells)

        if #available(iOS 12, *) {
            verifyCellLabels(with: "Funds Deposit\nJun 20, 2019", moneyTitle: "10.00\nUSD", by: 0)
            verifyCellLabels(with: "Funds Deposit\nJun 21, 2019", moneyTitle: "20.00\nUSD", by: 1)
            verifyCellLabels(with: "Balance Adjustment\nJun 23, 2019", moneyTitle: "-7.00\nUSD", by: 2)
            verifyCellLabels(with: "Balance Adjustment\nJun 24, 2019", moneyTitle: "-500.99\nUSD", by: 3)
        } else {
            verifyCellLabels(with: "Funds Deposit Jun 20, 2019", moneyTitle: "10.00 USD", by: 0)
            verifyCellLabels(with: "Funds Deposit Jun 21, 2019", moneyTitle: "20.00 USD", by: 1)
            verifyCellLabels(with: "Balance Adjustment Jun 23, 2019", moneyTitle: "-7.00 USD", by: 2)
            verifyCellLabels(with: "Balance Adjustment Jun 24, 2019", moneyTitle: "-500.99 USD", by: 3)
        }
    }

    func testReceiptsList_verifyPrepaidCardReceiptsSectionHeaders() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/prepaid-cards/trm-token/receipts",
                             filename: "PrepaidCardReceiptsForFewMonths",
                             method: HTTPMethod.get)

        XCTAssertTrue(prepaidCardReceiptMenu.exists)
        prepaidCardReceiptMenu.tap()
        waitForNonExistence(spinner)

        XCTAssertTrue(app.tables.staticTexts["April 2019"].exists)
        XCTAssertTrue(app.tables.staticTexts["May 2019"].exists)
        XCTAssertTrue(app.tables.staticTexts["June 2019"].exists)
    }

    /*
    func testPrepaidCardReceiptsList_verifyPagingBySwipe() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/prepaid-cards/trm-token/receipts",
                             filename: "PrepaidCardReceiptsPaging",
                             method: HTTPMethod.get)

        XCTAssertTrue(prepaidCardReceiptMenu.exists)
        prepaidCardReceiptMenu.tap()
        waitForNonExistence(spinner)

        app.swipeUp()
        app.swipeUp()
        let lastRow = app.tables.element.children(matching: .cell).element(boundBy: 10)
        let lastRowLabel = lastRow.staticTexts["ListReceiptTableViewCellTextLabel"].label

        XCTAssertTrue(lastRow.exists)
        XCTAssertTrue(lastRowLabel.contains("Jun 8, 2019"))
    } */

    func testPrepaidCardReceiptsList_verifyCreditTransaction() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/prepaid-cards/trm-token/receipts",
                             filename: "PrepaidCardReceiptsForOneMonth",
                             method: HTTPMethod.get)

        XCTAssertTrue(prepaidCardReceiptMenu.exists)
        prepaidCardReceiptMenu.tap()
        waitForNonExistence(spinner)

        if #available(iOS 12, *) {
            verifyCellLabels(with: "Funds Deposit\nJun 20, 2019", moneyTitle: "10.00\nUSD", by: 0)
        } else {
            verifyCellLabels(with: "Funds Deposit Jun 20, 2019", moneyTitle: "10.00 USD", by: 0)
        }
    }

    func testPrepaidCardReceiptsList_verifyDebitTransaction() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/prepaid-cards/trm-token/receipts",
                             filename: "PrepaidCardReceiptsForOneMonth",
                             method: HTTPMethod.get)

        XCTAssertTrue(prepaidCardReceiptMenu.exists)
        prepaidCardReceiptMenu.tap()
        waitForNonExistence(spinner)
        if #available(iOS 12, *) {
            verifyCellLabels(with: "Balance Adjustment\nJun 23, 2019", moneyTitle: "-7.00\nUSD", by: 2)
        } else {
            verifyCellLabels(with: "Balance Adjustment Jun 23, 2019", moneyTitle: "-7.00 USD", by: 2)
        }
    }

    func testPrepaidCardReceiptsList_userHasNoTransactions() {
        mockServer.setUpEmptyResponse(url: "/rest/v3/users/usr-token/prepaid-cards/trm-token/receipts")
        XCTAssertTrue(prepaidCardReceiptMenu.exists)
        prepaidCardReceiptMenu.tap()
        waitForNonExistence(spinner)

        XCTAssertTrue(app.staticTexts["Seems like, you don’t have any Transactions, yet."].exists)
        XCTAssertEqual(app.tables.cells.count, 0)
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
