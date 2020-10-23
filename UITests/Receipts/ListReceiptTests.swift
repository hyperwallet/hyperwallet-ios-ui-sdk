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
        openUpReceiptsListScreenForFewMonths()
        validateListOrder()
    }

    func testReceiptsList_verifySectionHeaders() {
        openUpReceiptsListScreenForFewMonths()
        validateSectionsHeaders()
    }

    func testReceiptsList_verifyNumberOfReceipts() {
        openUpReceiptsListScreenForFewMonths()
        let expectedNumberOfCells = 8
        XCTAssertEqual(app.tables.cells.count, expectedNumberOfCells)
    }

    func testReceiptsList_verifyReceiptsListForOneMonth() {
        let expectedNumberOfCells = 7
        mockServer.setupStub(url: "/rest/v3/users/usr-token/receipts",
                             filename: "ReceiptsForOneMonth",
                             method: HTTPMethod.get)
        openReceiptsListScreen()

        verifyCellExists("Bank Account", "2019-05-10T18:16:17", "-$5.00", "USD", at: 0)
        verifyCellExists("Payment", "2019-05-08T18:16:19", "$6.00", "USD", at: 1)
        verifyCellExists("Bank Account", "2019-05-06T18:16:17", "-$5.00", "USD", at: 2)
        verifyCellExists("Payment", "2019-05-04T18:16:14", "$6.00", "USD", at: 3)
        verifyCellExists("Payment", "2019-05-03T17:08:58", "$20.00", "USD", at: 4)
        verifyCellExists("PayPal", "2019-05-02T18:16:17", "$5.00", "USD", at: 5)
        verifyCellExists("Debit Card", "2019-05-01T18:16:17", "$5.00", "USD", at: 6)

        XCTAssertEqual(app.tables.cells.count, expectedNumberOfCells)
        XCTAssertTrue(app.tables.staticTexts["May 2019"].exists)
        XCTAssertFalse(app.tables.cells.containing(.staticText, identifier: "May 2019").element.exists)
    }

    func testReceiptsList_verifyEmptyScreen() {
        mockServer.setUpEmptyResponse(url: "/rest/v3/users/usr-token/receipts")
        openReceiptsListScreen()

        let emptyPlaceHolder = "mobileNoTransactions".localized()
        XCTAssertTrue(app.staticTexts[emptyPlaceHolder].exists)
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

        verifyCellDoesNotExist("Payment", "Mar 24, 2019", "$5.00", "USD", at: 20)
        verifyCellDoesNotExist("Payment", "Mar 24, 2019", "$6.00", "USD", at: 21)
        verifyCellDoesNotExist("Bank Account", "Mar 24, 2019", "-$5.00", "USD", at: 22)

        app.swipeUp()
        app.swipeUp()
        waitForNonExistence(spinner)

        verifyCellExists("Payment", "2019-03-24T17:35:20", "$5.00", "USD", at: 20)
        verifyCellExists("Payment", "2019-03-24T17:39:19", "$6.00", "USD", at: 21)
        verifyCellExists("Bank Account", "2019-03-24T17:46:28", "-$5.00", "USD", at: 22)
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

    private func verifyCurrencyAndCurrencyCode(_ type: String, _ amount: String, _ currency: String, at index: Int) {
        let cell = app.cells.element(boundBy: index)
        app.scroll(to: cell)
        XCTAssertTrue(cell.staticTexts["receiptTransactionTypeLabel"].exists)
        XCTAssertTrue(cell.staticTexts["receiptTransactionAmountLabel"].exists)
        XCTAssertTrue(cell.staticTexts["receiptTransactionCurrencyLabel"].exists)

        XCTAssertEqual(type, cell.staticTexts["receiptTransactionTypeLabel"].label)
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
        verifyCellExists("Payment", "2019-05-24T18:16:19", "$6.00", "USD", at: 0)
        verifyCellExists("Bank Account", "2019-05-12T18:16:17", "-$5.00", "USD", at: 1)
        verifyCellExists("Payment", "2019-05-04T18:16:14", "$6.00", "USD", at: 2)
        verifyCellExists("Payment", "2019-04-27T18:16:12", "$6.00", "USD", at: 3)
        verifyCellExists("Payment", "2019-04-19T18:16:10", "$6.00", "USD", at: 4)
        verifyCellExists("Bank Account", "2019-04-14T17:46:28", "-$7.50", "USD", at: 5)
        verifyCellExists("Payment", "2019-03-25T18:16:08", "$6.00", "USD", at: 6)
        verifyCellExists("Payment", "2019-03-18T18:16:04", "$6.00", "USD", at: 7)
    }

    private func validateSectionsHeaders() {
        XCTAssertTrue(app.tables.staticTexts["May 2019"].exists)
        XCTAssertTrue(app.tables.staticTexts["April 2019"].exists)
        XCTAssertTrue(app.tables.staticTexts["March 2019"].exists)

        XCTAssertFalse(app.tables.cells.containing(.staticText, identifier: "May 2019").element.exists)
        XCTAssertFalse(app.tables.cells.containing(.staticText, identifier: "April 2019").element.exists)
        XCTAssertFalse(app.tables.cells.containing(.staticText, identifier: "March 2019").element.exists)
    }

    private func validateTestReceiptsListScreen() {
        XCTAssertTrue(receiptsList.navigationBar.exists)
        validateListOrder()
        validateSectionsHeaders()
    }

    private func openUpReceiptsListScreenForFewMonths() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/receipts",
                             filename: "ReceiptsForFewMonths",
                             method: HTTPMethod.get)
        openReceiptsListScreen()
    }

    private func openReceiptsListScreen() {
        app.tables.cells.containing(.staticText, identifier: "List User Receipts").element(boundBy: 0).tap()
        waitForNonExistence(spinner)
    }

    // MARK: Detail Page Test cases

    // Credit Transaction
    func testReceiptDetail_verifyCreditTransaction() {
        openUpReceiptsListScreenForFewMonths()
        transactionDetails.openReceipt(row: 0)
        waitForExistence(transactionDetails.detailHeaderTitle)
        verifyPayment("Payment", "2019-05-24T18:16:19", "$6.00", "\(currency)")

        // DETAILS Section
        verifyDetailSection(receiptIdVal: "55176992", dateVal: "2019-05-24T18:16:19", clientIdVal: "DyClk0VG9a")

        // FEE Section
        XCTAssertFalse(transactionDetails.feeSection.exists)
    }

    // Debit Transaction
    func testReceiptDetail_verifyDebitTransaction() {
        openUpReceiptsListScreenForFewMonths()
        transactionDetails.openReceipt(row: 1)
        waitForExistence(transactionDetails.detailHeaderTitle)

        verifyPayment("Bank Account", "2019-05-12T18:16:17", "-$5.00", "\(currency)")

        // DETAILS Section
        verifyDetailSection(receiptIdVal: "55176991", dateVal: "2019-05-12T18:16:17", clientIdVal: nil)

        // FEE Section
        verifyFeeSection(amountVal: "-$5.00 USD", feeVal: "$2.00 USD", transactionVal: "$3.00 USD")
    }

    // Debit to Venmo Transaction
    func testReceiptDetail_verifyDebitVenmoTransaction() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/receipts",
                             filename: "VenmoReceiptsForFewMonths",
                             method: HTTPMethod.get)
        openReceiptsListScreen()
        transactionDetails.openReceipt(row: 0)
        waitForExistence(transactionDetails.detailHeaderTitle)

        verifyPayment("Unknown Transaction Type", "2020-10-12T18:16:17", "-$5.00", "\(currency)")

        // DETAILS Section
        verifyDetailSection(receiptIdVal: "64287013", dateVal: "2020-10-12T18:16:17", clientIdVal: nil)

        // FEE Section
        verifyFeeSection(amountVal: "-$5.00 USD", feeVal: "$2.00 USD", transactionVal: "$3.00 USD")
    }

    func testReceiptDetail_verifyTransactionOptionalFields() {
        openUpReceiptsListScreenForOneMonth()
        transactionDetails.openReceipt(row: 4)
        waitForExistence(transactionDetails.detailHeaderTitle)

        XCTAssertEqual(transactionDetails.clientTransactionIdLabel.label, "mobileTransactionIdLabel".localized())
        XCTAssertEqual(transactionDetails.detailSection.label, "mobileTransactionDetailsLabel".localized())
        XCTAssertEqual(transactionDetails.receiptIdLabel.label, "mobileJournalNumberLabel".localized())
        XCTAssertEqual(transactionDetails.dateLabel.label, "date".localized())
        XCTAssertEqual(transactionDetails.charityNameLabel.label, "mobileCharityName".localized())
        XCTAssertEqual(transactionDetails.checkNumLabel.label, "mobileCheckNumber".localized())
        XCTAssertEqual(transactionDetails.promoWebSiteLabel.label, "mobilePromoWebsite".localized())
        XCTAssertEqual(transactionDetails.noteSectionLabel.label, "mobileConfirmNotesLabel".localized())

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
        openUpReceiptsListScreenForOneMonth()
        transactionDetails.openReceipt(row: 2)
        let transactionDetailHeaderLabel = transactionDetails.detailHeaderTitle
        waitForNonExistence(transactionDetailHeaderLabel)

        // Assert No Note and Fee sections
        let noteSection = transactionDetails.noteSectionLabel
        let feeLabel = transactionDetails.feeLabel
        XCTAssertFalse(noteSection.exists)
        XCTAssertFalse(feeLabel.exists)
    }

     // MARK: Currencies Test
     // Test format an amount to a currency format with currency code
     func testReceiptDetail_verifyTransactionReceiptWithUSD() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/receipts",
                             filename: "ReceiptsMultipleCurrenciesRespsonse",
                             method: HTTPMethod.get)

        openReceiptsListScreen()

        verifyCurrencyAndCurrencyCode("Bank Account", "-"+CurrencyCode.USD.1 + "0.00", CurrencyCode.USD.0, at: 0)
        verifyCurrencyAndCurrencyCode("Payment", CurrencyCode.USD.1 + "1,000,000.99", CurrencyCode.USD.0, at: 1)
        verifyCurrencyAndCurrencyCode("Bank Account",
                                      "-"+CurrencyCode.USD.1 + "1,000,000,000.99",
                                      CurrencyCode.USD.0,
                                      at: 2)
        verifyCurrencyAndCurrencyCode("Bank Account",
                                      "-"+CurrencyCode.USD.1 + "10,000,000,000,000,000,000.00",
                                      CurrencyCode.USD.0,
                                      at: 3)
        verifyCellExists("Debit Card", "2019-05-01T17:35:20", "¥1,000,000,000", "JPY", at: 11)
        verifyCellExists("Debit Card", "2019-05-01T17:35:20", "₫1,000,000,000", "VND", at: 12)

        transactionDetails.openReceipt(row: 2)
        waitForExistence(transactionDetails.detailHeaderTitle)

        verifyPayment("Bank Account", "2019-5-10T18:16:17", "-$1,000,000,000.99", "\(currency)")

        // DETAILS Section
        verifyDetailSection(receiptIdVal: "55176994", dateVal: "2019-5-10T18:16:17", clientIdVal: nil)

        // FEE Section
        verifyFeeSection(amountVal: "-$1,000,000,000.99 USD",
                         feeVal: "$2.00 USD",
                         transactionVal: "$999,999,998.99 USD")
     }

    func testReceiptDetail_verifyTransactionReceiptWithOtherCurrencies() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/receipts",
                             filename: "ReceiptsMultipleCurrenciesRespsonse",
                             method: HTTPMethod.get)

        openReceiptsListScreen()

        // add back asssertions
        verifyCurrencyAndCurrencyCode("Bank Account", "-"+CurrencyCode.USD.1 + "0.00", CurrencyCode.USD.0, at: 0)
        verifyCurrencyAndCurrencyCode("Payment", CurrencyCode.USD.1 + "1,000,000.99", CurrencyCode.USD.0, at: 1)
        verifyCurrencyAndCurrencyCode("Bank Account",
                                      "-"+CurrencyCode.USD.1 + "1,000,000,000.99",
                                      CurrencyCode.USD.0,
                                      at: 2)
        verifyCurrencyAndCurrencyCode("Bank Account",
                                      "-"+CurrencyCode.USD.1 + "10,000,000,000,000,000,000.00",
                                      CurrencyCode.USD.0,
                                      at: 3)
        verifyCurrencyAndCurrencyCode("Payment", CurrencyCode.CAD.1 + "1,000,000,000.99", CurrencyCode.CAD.0, at: 4)
        verifyCurrencyAndCurrencyCode("Payment", CurrencyCode.EURO.1 + "1,000,000,000.99", CurrencyCode.EURO.0, at: 5)
        verifyCurrencyAndCurrencyCode("Payment", CurrencyCode.JOD.1 + " 1,000,000,000.990", CurrencyCode.JOD.0, at: 6)
        verifyCurrencyAndCurrencyCode("Payment", CurrencyCode.ZAR.1 + " 1,000,000,000.00", CurrencyCode.ZAR.0, at: 7)
        verifyCurrencyAndCurrencyCode("Payment", CurrencyCode.SEK.1 + " 10,000,000,000.00", CurrencyCode.SEK.0, at: 8)
        verifyCurrencyAndCurrencyCode("Payment", CurrencyCode.TND.1 + "1,000,000,000.000", CurrencyCode.TND.0, at: 9)
        verifyCurrencyAndCurrencyCode("PayPal", CurrencyCode.INR.1 + "1,000,000,000.99", CurrencyCode.INR.0, at: 10)
        verifyCurrencyAndCurrencyCode("Debit Card", CurrencyCode.JPY.1 + "1,000,000,000", CurrencyCode.JPY.0, at: 11)
        verifyCurrencyAndCurrencyCode("Debit Card", CurrencyCode.VND.1 + "1,000,000,000", CurrencyCode.VND.0, at: 12)
    }

    // MARK: Helper methods
    private func openUpReceiptsListScreenForOneMonth() {
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
        XCTAssertEqual(transactionDetails.detailSection.label, "mobileTransactionDetailsLabel".localized())
        XCTAssertEqual(transactionDetails.receiptIdLabel.label, "mobileJournalNumberLabel".localized())
        XCTAssertEqual(transactionDetails.dateLabel.label, "date".localized())
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
        XCTAssertEqual(transactionDetails.feeSection.label, "mobileFeeInfoLabel".localized())
        XCTAssertEqual(transactionDetails.amountLabel.label, "amount".localized())
        XCTAssertEqual(transactionDetails.amountValue.label, amountVal)
        XCTAssertEqual(transactionDetails.transactionLabel.label, "mobileTransactionDetailsTotal".localized())
        XCTAssertEqual(transactionDetails.transactionValue.label, transactionVal)
        XCTAssertEqual(transactionDetails.feeLabel.label, "mobileFeeLabel".localized())
        XCTAssertEqual(transactionDetails.feeValue.label, feeVal)
    }
}
