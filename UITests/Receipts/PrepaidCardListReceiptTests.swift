import XCTest
class PrepaidCardListReceiptTests: BaseTests {
    var prepaidCardReceiptMenu: XCUIElement!
    var transactionDetails: TransactionDetails!

    override func setUp() {
        profileType = .individual
        super.setUp()
        spinner = app.activityIndicators["activityIndicator"]
        prepaidCardReceiptMenu = app.tables.cells
            .containing(.staticText, identifier: "List Prepaid Card Receipts")
            .element(boundBy: 0)
        transactionDetails = TransactionDetails(app: app)
    }

    override func tearDown() {
        mockServer.tearDown()
    }

    // MARK: Prepaid Card List Receipt TestCases
    func testPrepaidCardReceiptsList_verifyReceiptsOrder() {
        let expectedNumberOfCells = 5

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

    // MARK: Detail View
    func testPrepaidReceiptDetail_verifyCredit() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/prepaid-cards/trm-token/receipts",
                             filename: "PrepaidCardReceiptsForOneMonth",
                             method: HTTPMethod.get)
        XCTAssertTrue(prepaidCardReceiptMenu.exists)
        prepaidCardReceiptMenu.tap()
        waitForNonExistence(spinner)
        transactionDetails.openReceipt(row: 0)
        waitForExistence(transactionDetails.detailHeaderTitle)
        // Transaction
        XCTAssertEqual(transactionDetails.transactionSection.label, "Transaction")
        if #available(iOS 12, *) {
            XCTAssertEqual(transactionDetails.paymentLabel.label, "Funds Deposit\nJun 20, 2019")
            XCTAssertEqual(transactionDetails.paymentAmountLabel.label, "10.00\nUSD")
        } else {
            XCTAssertEqual(transactionDetails.paymentLabel.label, "Funds Deposit Jun 20, 2019")
            XCTAssertEqual(transactionDetails.paymentAmountLabel.label, "10.00 USD")
        }

        // Details
        XCTAssertEqual(transactionDetails.detailSection.label, "Details")
        XCTAssertEqual(transactionDetails.receiptIdLabel.label, "Receipt ID:")
        XCTAssertEqual(transactionDetails.dateLabel.label, "Date:")
        XCTAssertEqual(transactionDetails.receiptIdValue.label, "FISVL_5269000")
        XCTAssertEqual(transactionDetails.dateValue.label, "Thu, Jun 20, 2019, 9:23 PM")

        // Fee
        XCTAssertEqual(transactionDetails.feeSection.label, "Fee Specification")
        XCTAssertEqual(transactionDetails.amountLabel.label, "Amount:")
        XCTAssertEqual(transactionDetails.transactionLabel.label, "Transaction:")
        XCTAssertEqual(transactionDetails.amountValue.label, "10.00 USD")
        XCTAssertEqual(transactionDetails.transactionValue.label, "10.00 USD")
    }

    func testPrepadReceiptDetail_verifyDebit() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/prepaid-cards/trm-token/receipts",
                             filename: "PrepaidCardReceiptsForOneMonth",
                             method: HTTPMethod.get)
        XCTAssertTrue(prepaidCardReceiptMenu.exists)
        prepaidCardReceiptMenu.tap()
        waitForNonExistence(spinner)
        transactionDetails.openReceipt(row: 2)
        waitForExistence(transactionDetails.detailHeaderTitle)

        // Transaction
        XCTAssertEqual(transactionDetails.transactionSection.label, "Transaction")
        if #available(iOS 12, *) {
            XCTAssertEqual(transactionDetails.paymentLabel.label, "Balance Adjustment\nJun 23, 2019")
            XCTAssertEqual(transactionDetails.paymentAmountLabel.label, "-7.00\nUSD")
        } else {
            XCTAssertEqual(transactionDetails.paymentLabel.label, "Balance Adjustment Jun 23, 2019")
            XCTAssertEqual(transactionDetails.paymentAmountLabel.label, "-7.00 USD")
        }

        // Details
        XCTAssertEqual(transactionDetails.detailSection.label, "Details")
        XCTAssertEqual(transactionDetails.receiptIdLabel.label, "Receipt ID:")
        XCTAssertEqual(transactionDetails.dateLabel.label, "Date:")
        XCTAssertEqual(transactionDetails.receiptIdValue.label, "FISA_5269017")
        XCTAssertEqual(transactionDetails.dateValue.label, "Sun, Jun 23, 2019, 9:25 PM")

        // Fee
        XCTAssertEqual(transactionDetails.feeSection.label, "Fee Specification")
        XCTAssertEqual(transactionDetails.amountLabel.label, "Amount:")
        XCTAssertEqual(transactionDetails.transactionLabel.label, "Transaction:")
        XCTAssertEqual(transactionDetails.amountValue.label, "-7.00 USD")
        XCTAssertEqual(transactionDetails.transactionValue.label, "-7.00 USD")
    }

    // MARK: Detail View Testcases
    func testPrepaidReceiptDetail_verifyTransactionOptionalFields() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/prepaid-cards/trm-token/receipts",
                             filename: "PrepaidCardReceiptsForOneMonth",
                             method: HTTPMethod.get)
        XCTAssertTrue(prepaidCardReceiptMenu.exists)
        prepaidCardReceiptMenu.tap()
        waitForNonExistence(spinner)
        transactionDetails.openReceipt(row: 4)
        waitForExistence(transactionDetails.detailHeaderTitle)

        // Transaction
        XCTAssertEqual(transactionDetails.transactionSection.label, "Transaction")
        if #available(iOS 12, *) {
            XCTAssertEqual(transactionDetails.paymentLabel.label, "Transaction\nJun 25, 2019")
            XCTAssertEqual(transactionDetails.paymentAmountLabel.label, "-10.00\nUSD")
        } else {
            XCTAssertEqual(transactionDetails.paymentLabel.label, "Transaction Jun 25, 2019")
            XCTAssertEqual(transactionDetails.paymentAmountLabel.label, "-10.00 USD")
        }

        // Details
        XCTAssertEqual(transactionDetails.clientTransactionIdLabel.label, "Client Transaction ID:")
        XCTAssertEqual(transactionDetails.detailSection.label, "Details")
        XCTAssertEqual(transactionDetails.receiptIdLabel.label, "Receipt ID:")
        XCTAssertEqual(transactionDetails.dateLabel.label, "Date:")
        XCTAssertEqual(transactionDetails.charityNameLabel.label, "Charity Name:")
        XCTAssertEqual(transactionDetails.promoWebSiteLabel.label, "Promo Website:")
        XCTAssertEqual(transactionDetails.receiptIdValue.label, "FISVL_5240220")
        XCTAssertEqual(transactionDetails.dateValue.label, "Tue, Jun 25, 2019, 10:48 PM")
        XCTAssertEqual(transactionDetails.charityNameValue.label, "Sample Charity")
        XCTAssertEqual(transactionDetails.checkNumValue.label, "Sample Check Number")
        XCTAssertEqual(transactionDetails.clientTransactionIdValue.label, "AOxXefx9")
        XCTAssertEqual(transactionDetails.websiteValue.label, "https://localhost.com")

        // Notes
        XCTAssertEqual(transactionDetails.noteSectionLabel.label, "Notes")
        XCTAssertEqual(transactionDetails.notesValue.label, "Sample prepaid card payment")

        // Fee
        XCTAssertEqual(transactionDetails.feeSection.label, "Fee Specification")
        XCTAssertEqual(transactionDetails.amountLabel.label, "Amount:")
        XCTAssertEqual(transactionDetails.feeLabel.label, "Fee:")
        XCTAssertEqual(transactionDetails.transactionLabel.label, "Transaction:")
        XCTAssertEqual(transactionDetails.amountValue.label, "-10.00 USD")
        XCTAssertEqual(transactionDetails.feeValue.label, "3.00 USD")
        XCTAssertEqual(transactionDetails.transactionValue.label, "-13.00 USD")
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
