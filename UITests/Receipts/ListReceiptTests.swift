import XCTest

class ListReceiptTests: BaseTests {
    private let currency = "USD"
    var receiptsList: ReceiptsList!
    private var transactionDetails: TransactionDetails!

    override func setUp() {
        super.setUp()

        app = XCUIApplication()
        app.launch()

        receiptsList = ReceiptsList(app: app)
        transactionDetails = TransactionDetails(app: app)
        spinner = app.activityIndicators["activityIndicator"]
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
        let expectedNumberOfCells = 7
        mockServer.setupStub(url: "/rest/v3/users/usr-token/receipts",
                             filename: "ReceiptsForOneMonth",
                             method: HTTPMethod.get)
        openReceiptsListScreen()

        verifyCellExists("Bank Account", "2019-05-10T18:16:17", "-5.00", "USD", at: 0)
        verifyCellExists("Payment", "2019-05-08T18:16:19", "6.00", "USD", at: 1)
        verifyCellExists("Bank Account", "2019-05-06T18:16:17", "-5.00", "USD", at: 2)
        verifyCellExists("Payment", "2019-05-04T18:16:14", "6.00", "USD", at: 3)
        verifyCellExists("Payment", "2019-05-03T17:08:58", "20.00", "USD", at: 4)
        verifyCellExists("PayPal", "2019-05-02T18:16:17", "5.00", "USD", at: 5)
        verifyCellExists("Debit Card", "2019-05-01T18:16:17", "5.00", "USD", at: 6)

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

        verifyCellDoesNotExist("Payment", "Mar 24, 2019", "5.00", "USD", at: 20)
        verifyCellDoesNotExist("Payment", "Mar 24, 2019", "6.00", "USD", at: 21)
        verifyCellDoesNotExist("Bank Account", "Mar 24, 2019", "-5.00", "USD", at: 22)

        app.swipeUp()
        app.swipeUp()
        waitForNonExistence(spinner)

        verifyCellExists("Payment", "2019-03-24T17:35:20", "5.00", "USD", at: 20)
        verifyCellExists("Payment", "2019-03-24T17:39:19", "6.00", "USD", at: 21)
        verifyCellExists("Bank Account", "2019-03-24T17:46:28", "-5.00", "USD", at: 22)
    }

    private func verifyCellExists(_ type: String,
                                  _ createdOn: String,
                                  _ amount: String,

                                  _ currency: String,
                                  at index: Int) {
        let cell = app.cells.element(boundBy: index)
        app.scroll(to: cell)
        XCTAssertTrue(cell.staticTexts["receiptTransactionTypeLabel"].exists)
        XCTAssertTrue(cell.staticTexts["receiptTransactionAmountLabel"].exists)
        XCTAssertTrue(cell.staticTexts["receiptTransactionCreatedOnLabel"].exists)
        XCTAssertTrue(cell.staticTexts["receiptTransactionCurrencyLabel"].exists)

        XCTAssertEqual(type, cell.staticTexts["receiptTransactionTypeLabel"].label)
        XCTAssertEqual(transactionDetails.getExpectedDate(date: createdOn),
                       cell.staticTexts["receiptTransactionCreatedOnLabel"].label)
        XCTAssertEqual(amount, cell.staticTexts["receiptTransactionAmountLabel"].label)
        XCTAssertEqual(currency, cell.staticTexts["receiptTransactionCurrencyLabel"].label)
    }

    private func verifyCellDoesNotExist(_ type: String,
                                        _ createdOn: String,
                                        _ amount: String,

                                        _ currency: String,
                                        at index: Int) {
        let cell = app.cells.element(boundBy: index)
        XCTAssertFalse(cell.staticTexts["receiptTransactionTypeLabel"].exists)
        XCTAssertFalse(cell.staticTexts["receiptTransactionAmountLabel"].exists)
        XCTAssertFalse(cell.staticTexts["receiptTransactionCreatedOnLabel"].exists)
        XCTAssertFalse(cell.staticTexts["receiptTransactionCurrencyLabel"].exists)
    }

    private func validateListOrder() {
        verifyCellExists("Payment", "2019-05-24T18:16:19", "6.00", "USD", at: 0)
        verifyCellExists("Bank Account", "2019-05-12T18:16:17", "-5.00", "USD", at: 1)
        verifyCellExists("Payment", "2019-05-04T18:16:14", "6.00", "USD", at: 2)
        verifyCellExists("Payment", "2019-04-27T18:16:12", "6.00", "USD", at: 3)
        verifyCellExists("Payment", "2019-04-19T18:16:10", "6.00", "USD", at: 4)
        verifyCellExists("Bank Account", "2019-04-14T17:46:28", "-7.50", "USD", at: 5)
        verifyCellExists("Payment", "2019-03-25T18:16:08", "6.00", "USD", at: 6)
        verifyCellExists("Payment", "2019-03-18T18:16:04", "6.00", "USD", at: 7)
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

    // MARK: Detail Page Testcases

    // Credit Transaction
    func testReceiptDetail_verifyCreditTransaction() {
        openupReceiptsListScreenForFewMonths()
        transactionDetails.openReceipt(row: 0)
        waitForExistence(transactionDetails.detailHeaderTitle)
        verifyPayment("Payment", "2019-05-24T18:16:19", "6.00", "\(currency)")

        // DETAILS Section
        verifyDetailSection(receiptIdVal: "55176992", dateVal: "2019-05-24T18:16:19", clientIdVal: "DyClk0VG9a")

        // FEE Section
        XCTAssertFalse(transactionDetails.feeSection.exists)
    }

    // Debit Transaction
    func testReceiptDetail_verifyDebitTransaction() {
        openupReceiptsListScreenForFewMonths()
        transactionDetails.openReceipt(row: 1)
        waitForExistence(transactionDetails.detailHeaderTitle)

        verifyPayment("Bank Account", "2019-05-12T18:16:17", "-5.00", "\(currency)")

        // DETAILS Section
        verifyDetailSection(receiptIdVal: "55176991", dateVal: "2019-05-12T18:16:17", clientIdVal: nil)

        // FEE Section
        verifyFeeSection(amountVal: "-5.00 USD", feeVal: "2.00 USD", transactionVal: "3.00 USD")
    }

    func testReceiptDetail_verifyTransactionOptionalFields() {
        openupReceiptsListScreenForOneMonth()
        transactionDetails.openReceipt(row: 4)
        waitForExistence(transactionDetails.detailHeaderTitle)

        XCTAssertEqual(transactionDetails.clientTransactionIdLabel.label, "Client Transaction ID:")
        XCTAssertEqual(transactionDetails.detailSection.label, "Details")
        XCTAssertEqual(transactionDetails.receiptIdLabel.label, "Receipt ID:")
        XCTAssertEqual(transactionDetails.dateLabel.label, "Date:")
        XCTAssertEqual(transactionDetails.charityNameLabel.label, "Charity Name:")
        XCTAssertEqual(transactionDetails.promoWebSiteLabel.label, "Promo Website:")
        XCTAssertEqual(transactionDetails.noteSectionLabel.label, "Notes")

        XCTAssertEqual(transactionDetails.receiptIdValue.label, "3051579")
        XCTAssertEqual(transactionDetails.clientTransactionIdValue.label, "8OxXefx5")
        XCTAssertEqual(transactionDetails.charityNameValue.label, "Sample Charity")
        XCTAssertEqual(transactionDetails.checkNumValue.label, "Sample Check Number")
        XCTAssertEqual(transactionDetails.promoWebSiteValue.label, "https://localhost")
        XCTAssertEqual(transactionDetails.notesValue.label, "Sample payment notes")
        XCTAssertEqual(transactionDetails.dateValue.label,
                       transactionDetails.getExpectedDateTimeFormat(datetime: "2019-05-03T17:08:58"))
    }

    // Verify when no Notes and Fee sections
    func testReceiptDetail_verifyTransactionReceiptNoNoteSectionAndFeeLabel() {
        openupReceiptsListScreenForOneMonth()
        transactionDetails.openReceipt(row: 2)
        let transactionDetailHeaderLabel = transactionDetails.detailHeaderTitle
        waitForNonExistence(transactionDetailHeaderLabel)

        // Assert No Note and Fee sections
        let noteSection = transactionDetails.noteSectionLabel
        let feeLabel = transactionDetails.feeLabel
        XCTAssertFalse(noteSection.exists)
        XCTAssertFalse(feeLabel.exists)
    }

    // MARK: Helper methods
    private func openupReceiptsListScreenForOneMonth() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/receipts",
                             filename: "ReceiptsForOneMonth",
                             method: HTTPMethod.get)

        openReceiptsListScreen()
    }

    private func verifyPayment(_ type: String, _ createdOn: String, _ amount: String, _ currency: String) {
        let typeLabel = app.tables["receiptDetailTableView"].staticTexts["receiptTransactionTypeLabel"].label
        let amountLabel = app.tables["receiptDetailTableView"].staticTexts["receiptTransactionAmountLabel"].label
        let createdOnLabel = app.tables["receiptDetailTableView"].staticTexts["receiptTransactionCreatedOnLabel"].label
        let currencyLabel = app.tables["receiptDetailTableView"].staticTexts["receiptTransactionCurrencyLabel"].label

        XCTAssertEqual(typeLabel, type)
        XCTAssertEqual(amountLabel, amount)
        XCTAssertEqual(createdOnLabel, transactionDetails.getExpectedDate(date: createdOn))
        XCTAssertEqual(currencyLabel, currency)
    }

    // Detail section verification
    private func verifyDetailSection(receiptIdVal: String, dateVal: String, clientIdVal: String?) {
        XCTAssertEqual(transactionDetails.detailSection.label, "Details")
        XCTAssertEqual(transactionDetails.receiptIdLabel.label, "Receipt ID:")
        XCTAssertEqual(transactionDetails.dateLabel.label, "Date:")
        XCTAssertEqual(transactionDetails.receiptIdValue.label, receiptIdVal)
        XCTAssertEqual(transactionDetails.receiptIdValue.label, receiptIdVal)
        XCTAssertEqual(transactionDetails.dateValue.label,
                       transactionDetails.getExpectedDateTimeFormat(datetime: dateVal))

        if let clientIdVal = clientIdVal {
            let clientTransIDLabel = transactionDetails.clientTransactionIdLabel
            XCTAssertTrue(clientTransIDLabel.exists)
            let clientID = transactionDetails.clientTransactionIdValue
            XCTAssertTrue(clientID.exists)
            XCTAssertEqual(clientID.label, clientIdVal)
        }
    }

    // FEE section verification
    private func verifyFeeSection(amountVal: String, feeVal: String, transactionVal: String) {
        XCTAssertEqual(transactionDetails.feeSection.label, "Fee Specification")
        XCTAssertEqual(transactionDetails.amountLabel.label, "Amount:")
        XCTAssertEqual(transactionDetails.amountValue.label, amountVal)
        XCTAssertEqual(transactionDetails.transactionLabel.label, "Transaction:")
        XCTAssertEqual(transactionDetails.transactionValue.label, transactionVal)
        XCTAssertEqual(transactionDetails.feeLabel.label, "Fee:")
        XCTAssertEqual(transactionDetails.feeValue.label, feeVal)
    }
}
