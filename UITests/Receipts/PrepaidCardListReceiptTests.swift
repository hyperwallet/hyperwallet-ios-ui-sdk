import XCTest
class PrepaidCardListReceiptTests: BaseTests {
    var prepaidCardReceiptMenu: XCUIElement!
    var transactionDetails: TransactionDetails!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
        spinner = app.activityIndicators["activityIndicator"]
        prepaidCardReceiptMenu = app.tables.cells
            .containing(.staticText, identifier: "List Prepaid Card Receipts")
            .element(boundBy: 0)
        transactionDetails = TransactionDetails(app: app)
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

        verifyCellLabels(with: "Funds Deposit",
                         createdOn: "2019-06-20T21:23:51",
                         amount: "10.00",
                         currency: "USD",
                         by: 0)
        verifyCellLabels(with: "Funds Deposit",
                         createdOn: "2019-06-21T21:24:02",
                         amount: "20.00",
                         currency: "USD",
                         by: 1)
        verifyCellLabels(with: "Balance Adjustment",
                         createdOn: "2019-06-23T21:25:09",
                         amount: "-7.00",
                         currency: "USD",
                         by: 2)
        verifyCellLabels(with: "Balance Adjustment",
                         createdOn: "2019-06-24T21:25:23",
                         amount: "-500.99",
                         currency: "USD",
                         by: 3)
        verifyCellLabels(with: "Balance Adjustment",
                         createdOn: "2019-06-25T22:48:41",
                         amount: "-10.00",
                         currency: "USD",
                         by: 4)
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

    func testPrepaidCardReceiptsList_verifyCreditTransaction() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/prepaid-cards/trm-token/receipts",
                             filename: "PrepaidCardReceiptsForOneMonth",
                             method: HTTPMethod.get)

        XCTAssertTrue(prepaidCardReceiptMenu.exists)
        prepaidCardReceiptMenu.tap()
        waitForNonExistence(spinner)

        verifyCellLabels(with: "Funds Deposit",
                         createdOn: "2019-06-20T21:23:51",
                         amount: "10.00",
                         currency: "USD",
                         by: 0)
    }

    func testPrepaidCardReceiptsList_verifyDebitTransaction() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/prepaid-cards/trm-token/receipts",
                             filename: "PrepaidCardReceiptsForOneMonth",
                             method: HTTPMethod.get)

        XCTAssertTrue(prepaidCardReceiptMenu.exists)
        prepaidCardReceiptMenu.tap()
        waitForNonExistence(spinner)
        verifyCellLabels(with: "Balance Adjustment",
                         createdOn: "2019-06-23T21:25:09",
                         amount: "-7.00",
                         currency: "USD",
                         by: 2)
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

        XCTAssertEqual(transactionDetails.typeLabel.label, "Funds Deposit")
        XCTAssertEqual(transactionDetails.paymentAmountLabel.label, "10.00")
        XCTAssertEqual(transactionDetails.createdOnLabel.label,
                       transactionDetails.getExpectedDate(date: "2019-06-20T21:23:51"))
        XCTAssertEqual(transactionDetails.currencyLabel.label, "USD")

        // Details
        XCTAssertEqual(transactionDetails.detailSection.label, "Details")
        XCTAssertEqual(transactionDetails.receiptIdLabel.label, "Receipt ID:")
        XCTAssertEqual(transactionDetails.dateLabel.label, "Date:")
        XCTAssertEqual(transactionDetails.receiptIdValue.label, "FISVL_5269000")

        XCTAssertEqual(transactionDetails.dateValue.label,
                       transactionDetails.getExpectedDateTimeFormat(datetime: "2019-06-20T21:23:51"))

        // Fee
        XCTAssertFalse(transactionDetails.feeSection.exists)
    }

    func testPrepaidReceiptDetail_verifyDebit() {
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
        XCTAssertEqual(transactionDetails.typeLabel.label, "Balance Adjustment")
        XCTAssertEqual(transactionDetails.paymentAmountLabel.label, "-7.00")
        XCTAssertEqual(transactionDetails.createdOnLabel.label,
                       transactionDetails.getExpectedDate(date: "2019-06-23T21:25:09"))
        XCTAssertEqual(transactionDetails.currencyLabel.label, "USD")

        // Details
        XCTAssertEqual(transactionDetails.detailSection.label, "Details")
        XCTAssertEqual(transactionDetails.receiptIdLabel.label, "Receipt ID:")
        XCTAssertEqual(transactionDetails.dateLabel.label, "Date:")
        XCTAssertEqual(transactionDetails.receiptIdValue.label, "FISA_5269017")

        XCTAssertEqual(transactionDetails.dateValue.label,
                       transactionDetails.getExpectedDateTimeFormat(datetime: "2019-06-23T21:25:09"))

        // Fee
        XCTAssertFalse(transactionDetails.feeSection.exists)
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
        XCTAssertEqual(transactionDetails.typeLabel.label, "Balance Adjustment")
        XCTAssertEqual(transactionDetails.paymentAmountLabel.label, "-10.00")
        XCTAssertEqual(transactionDetails.createdOnLabel.label,
                       transactionDetails.getExpectedDate(date: "2019-06-25T22:48:41"))
        XCTAssertEqual(transactionDetails.currencyLabel.label, "USD")

        // Details
        XCTAssertEqual(transactionDetails.clientTransactionIdLabel.label, "Client Transaction ID:")
        XCTAssertEqual(transactionDetails.detailSection.label, "Details")
        XCTAssertEqual(transactionDetails.receiptIdLabel.label, "Receipt ID:")
        XCTAssertEqual(transactionDetails.dateLabel.label, "Date:")
        XCTAssertEqual(transactionDetails.charityNameLabel.label, "Charity Name:")
        XCTAssertEqual(transactionDetails.promoWebSiteLabel.label, "Promo Website:")
        XCTAssertEqual(transactionDetails.receiptIdValue.label, "FISVL_5240220")
        XCTAssertEqual(transactionDetails.charityNameValue.label, "Sample Charity")
        XCTAssertEqual(transactionDetails.checkNumValue.label, "Sample Check Number")
        XCTAssertEqual(transactionDetails.clientTransactionIdValue.label, "AOxXefx9")
        XCTAssertEqual(transactionDetails.promoWebSiteValue.label, "https://localhost.com")
        XCTAssertEqual(transactionDetails.dateValue.label,
                       transactionDetails.getExpectedDateTimeFormat(datetime: "2019-06-25T22:48:41"))
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
        XCTAssertEqual(transactionDetails.transactionValue.label, "7.00 USD")
    }

    // MARK: helper functions
    private func verifyCellLabels(with type: String,
                                  createdOn: String,
                                  amount: String,
                                  currency: String,
                                  by index: Int) {
        let row = app.tables.element.children(matching: .cell).element(boundBy: index)
        XCTAssertEqual(type, row.staticTexts["receiptTransactionTypeLabel"].label)
        XCTAssertEqual( transactionDetails.getExpectedDate(date: createdOn),
                        row.staticTexts["receiptTransactionCreatedOnLabel"].label)
        XCTAssertEqual(amount, row.staticTexts["receiptTransactionAmountLabel"].label)
        XCTAssertEqual(currency, row.staticTexts["receiptTransactionCurrencyLabel"].label)
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
}
