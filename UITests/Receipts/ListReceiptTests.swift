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

        verifyCellExists("Bank Account", "May 10, 2019", "-5.00", "USD", at: 0)
        verifyCellExists("Payment", "May 8, 2019", "6.00", "USD", at: 1)
        verifyCellExists("Bank Account", "May 6, 2019", "-5.00", "USD", at: 2)
        verifyCellExists("Payment", "May 4, 2019", "6.00", "USD", at: 3)
        verifyCellExists("Payment", "May 3, 2019", "20.00", "USD", at: 4)

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

        verifyCellExists("Payment", "Mar 24, 2019", "5.00", "USD", at: 20)
        verifyCellExists("Payment", "Mar 24, 2019", "6.00", "USD", at: 21)
        verifyCellExists("Bank Account", "Mar 24, 2019", "-5.00", "USD", at: 22)
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
        verifyCellExists("Bank Account", "May 10, 2019", "-5.00", "USD", at: 0)
        verifyCellExists("Payment", "May 8, 2019", "6.00", "USD", at: 1)
        verifyCellExists("Bank Account", "May 6, 2019", "-5.00", "USD", at: 2)
        verifyCellExists("Payment", "May 4, 2019", "6.00", "USD", at: 3)
        verifyCellExists("Payment", "May 3, 2019", "20.00", "USD", at: 4)
        verifyCellExists("Bank Account", "Apr 14, 2019", "-7.50", "USD", at: 5)
        verifyCellExists("Payment", "May 25, 2019", "6.00", "USD", at: 6)
        verifyCellExists("Payment", "May 18, 2019", "6.00", "USD", at: 7)
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
        let expectedDateValue = "Fri, May 24, 2019, 6:16 PM"
        openupReceiptsListScreenForFewMonths()
        transactionDetails.openReceipt(row: 0)
        waitForExistence(transactionDetails.detailHeaderTitle)

        verifyPayment("Payment", "May 24, 2019", "6.00", "\(currency)")

        // DETAILS Section
        verifyDetailSection(receiptIdVal: "55176992", dateVal: expectedDateValue, clientIdVal: "DyClk0VG9a")

        // FEE Section
        verifyFeeSection(amountVal: "6.00 USD", feeVal: "0.00 USD", transactionVal: "6.00 USD")
    }

    // Debit Transaction
    func testReceiptDetail_verifyDebitTransaction() {
        let expectedDateValue = "Sun, May 12, 2019, 6:16 PM" // Sun, May 12, 2019, 6:16 PM
        openupReceiptsListScreenForFewMonths()
        transactionDetails.openReceipt(row: 1)
        waitForExistence(transactionDetails.detailHeaderTitle)

        verifyPayment("Bank Account", "May 12, 2019", "-5.00", "\(currency)")

        // DETAILS Section
        verifyDetailSection(receiptIdVal: "55176991", dateVal: expectedDateValue, clientIdVal: nil)

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
        XCTAssertEqual(transactionDetails.websiteValue.label, "https://localhost")
        XCTAssertEqual(transactionDetails.notesValue.label, "Sample payment notes")
        XCTAssertEqual(transactionDetails.dateValue.label, "Fri, May 3, 2019, 5:08 PM")
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
        XCTAssertEqual(createdOnLabel, createdOn)
        XCTAssertEqual(currencyLabel, currency)
    }

    // Detail section verification
    private func verifyDetailSection(receiptIdVal: String, dateVal: String, clientIdVal: String?) {
        XCTAssertEqual(transactionDetails.detailSection.label, "Details")
        XCTAssertEqual(transactionDetails.receiptIdLabel.label, "Receipt ID:")
        XCTAssertEqual(transactionDetails.dateLabel.label, "Date:")
        XCTAssertEqual(transactionDetails.receiptIdValue.label, receiptIdVal)
        XCTAssertEqual(transactionDetails.receiptIdValue.label, receiptIdVal)
        XCTAssertEqual(transactionDetails.dateValue.label, dateVal)

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
        XCTAssertEqual(transactionDetails.feeLabel.label, "Fee:")
        XCTAssertEqual(transactionDetails.transactionLabel.label, "Transaction:")

        XCTAssertEqual(transactionDetails.amountValue.label, amountVal)
        XCTAssertEqual(transactionDetails.feeValue.label, feeVal)
        XCTAssertEqual(transactionDetails.transactionValue.label, transactionVal)
    }
}
