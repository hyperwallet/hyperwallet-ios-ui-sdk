import XCTest
class ListAllReceiptsTests: BaseTests {
    var receiptsList: ReceiptsList!
    private var transactionDetails: TransactionDetails!
    let ppcURL = "/rest/v3/users/usr-token/prepaid-cards"
    let receiptsURL = "/rest/v3/users/usr-token/receipts"
    let ppcPrimaryReceiptsURL = "/rest/v3/users/usr-token/prepaid-cards/trm-token/receipts"
    let ppcSecondaryReceiptsURL = "/rest/v3/users/usr-token/prepaid-cards/trm-token2/receipts"

    override func setUp() {
        super.setUp()

        app = XCUIApplication()
        app.launchArguments.append("enable-testing")
        app.launch()

        receiptsList = ReceiptsList(app: app)
        transactionDetails = TransactionDetails(app: app)
        spinner = app.activityIndicators["activityIndicator"]
    }

    // selects the List All Receipts
    private func openListAllReceiptsScreen() {
        app.tables.cells.containing(.staticText, identifier: "List All Receipts").element(boundBy: 0).tap()
        waitForNonExistence(spinner)
        let title = app.navigationBars["Transactions"].staticTexts["Transactions"]
        XCTAssertTrue(title.exists, "Title Transactions validated")
    }

    /*
     Given user has Available funds and Primary PPC and Available funds has receipts
     When user selects the "Transaction" tab
     Then user can see the tabs for Available funds and receipts
     */

    func testListAllReceipts_NavigateToTransactionsVerifyAvailblefundsTabs() {
        waitForNonExistence(spinner)
        mockServer.setupStub(url: ppcURL,
                             filename: "PrepaidCardPrimarycardOnlyResponse",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: receiptsURL,
                             filename: "ReceiptsForOneMonth",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: ppcPrimaryReceiptsURL,
                             filename: "PrepaidCardOneYearReceiptsResponse",
                             method: HTTPMethod.get)

        openListAllReceiptsScreen()
        waitForNonExistence(spinner)
        XCTAssertTrue(getTransactionsAvailableFundsTab().isSelected, "Available Funds tab should be selected")

        // Assert
        verifyCellExists_ListAll("Bank Account", "2019-05-10T18:16:17", "-$5.00", "USD", at: 0)
        verifyCellExists_ListAll("Payment", "2019-05-08T18:16:19", "$6.00", "USD", at: 1)
        verifyCellExists_ListAll("Bank Account", "2019-05-06T18:16:17", "-$5.00", "USD", at: 2)
        verifyCellExists_ListAll("Payment", "2019-05-04T18:16:14", "$6.00", "USD", at: 3)
        verifyCellExists_ListAll("Payment", "2019-05-03T17:08:58", "$20.00", "USD", at: 4)
        verifyCellExists_ListAll("PayPal", "2019-05-02T18:16:17", "$5.00", "USD", at: 5)
        verifyCellExists_ListAll("Debit Card", "2019-05-01T18:16:17", "$5.00", "USD", at: 6)
    }
    /*
     Given user has Available funds and Primary PPC
     When user selects the "Transaction" tab
     Then user can see the tabs for Primary PPC and receipts
     */

    func testListAllReceipts_NavigateToTransactionsPPCTabs() {
        waitForNonExistence(spinner)
        mockServer.setupStub(url: ppcURL,
                             filename: "PrepaidCardPrimarycardOnlyResponse",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: receiptsURL,
                             filename: "ReceiptsForOneMonth",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: ppcPrimaryReceiptsURL,
                             filename: "PrepaidCardOneYearReceiptsResponse",
                             method: HTTPMethod.get)

        openListAllReceiptsScreen()
        waitForNonExistence(spinner)
        XCTAssertTrue(getTransactionsAvailableFundsTab().isSelected, "Available Funds tab is selected")

        let primaryPPC = transactionDetails.getPPCInfoTab(digit: "9285", type: transactionDetails.prepaidCardVisa)
        let primardCardTab = transactionDetails.getTransactionsPPCTabBy(label: primaryPPC)

        // Assert
        verifyCellExists_ListAll("Bank Account", "2019-05-10T18:16:17", "-$5.00", "USD", at: 0)
        verifyCellExists_ListAll("Payment", "2019-05-08T18:16:19", "$6.00", "USD", at: 1)
        verifyCellExists_ListAll("Bank Account", "2019-05-06T18:16:17", "-$5.00", "USD", at: 2)
        verifyCellExists_ListAll("Payment", "2019-05-04T18:16:14", "$6.00", "USD", at: 3)
        verifyCellExists_ListAll("Payment", "2019-05-03T17:08:58", "$20.00", "USD", at: 4)
        verifyCellExists_ListAll("PayPal", "2019-05-02T18:16:17", "$5.00", "USD", at: 5)
        verifyCellExists_ListAll("Debit Card", "2019-05-01T18:16:17", "$5.00", "USD", at: 6)

        primardCardTab.tap()
        waitForNonExistence(spinner)
        XCTAssertTrue(primardCardTab.isSelected, "Primary Card tab should be selected")
        // Assert PPC receipts
        verifyCellExists_ListAll("Balance Adjustment", "2020-09-26T18:16:12", "-$20.99", "USD", at: 0)
        verifyCellExists_ListAll("Payment", "2020-08-26T17:46:28", "$998.15", "USD", at: 1)
        verifyCellExists_ListAll("Purchase", "2020-07-22T18:16:10", "-$6.47", "USD", at: 2)
        verifyCellExists_ListAll("Purchase", "2020-07-12T18:16:08", "-$6.47", "USD", at: 3)
        verifyCellExists_ListAll("Purchase", "2020-07-12T18:16:12", "-$6.47", "USD", at: 4)
        verifyCellExists_ListAll("Purchase", "2020-07-11T18:16:12", "-$6.47", "USD", at: 5)
        verifyCellExists_ListAll("Purchase", "2020-06-26T18:16:12", "-$6.47", "USD", at: 6)
    }

    /*
     Given user has Available funds and Primary PPC and Available funds has no transactions
     When user selects the "Transaction" tab
     Then user can see the tabs for Available funds and Place holder text
     */

    func testListAllReceipts_NavigateToTransactionsAvailbleFundsNoTransactions() {
        waitForNonExistence(spinner)
        mockServer.setupStub(url: ppcURL,
                             filename: "PrepaidCardPrimarycardOnlyResponse",
                             method: HTTPMethod.get)

        mockServer.setupStubEmpty(url: receiptsURL, statusCode: 204, method: HTTPMethod.get)

        mockServer.setupStub(url: ppcPrimaryReceiptsURL,
                             filename: "PrepaidCardOneYearReceiptsResponse",
                             method: HTTPMethod.get)

        openListAllReceiptsScreen()
        waitForNonExistence(spinner)

        let primaryPPC = transactionDetails.getPPCInfoTab(digit: "9285", type: transactionDetails.prepaidCardVisa)
        let primardCardTab = transactionDetails.getTransactionsPPCTabBy(label: primaryPPC)

        XCTAssertTrue(primardCardTab.exists, "Primary Card tab is exists")
        XCTAssertTrue(getTransactionsAvailableFundsTab().isSelected, "Available Funds tab is selected")

        // Assert empty placeholder text for Available funds
        let noTransaction = transactionDetails.getNoTransactionStrings()
        XCTAssertTrue(app.tables[noTransaction].exists)
    }

    /*
     Given user has Available funds and Primary PPC and PPC has no transactions
     When user selects the "Transaction" tab
     Then user can see the tabs for PPC and Place holder text
     */

    func testNavigateToTransactionsPPCNoTransactions() {
        waitForNonExistence(spinner)
        mockServer.setupStub(url: ppcURL,
                             filename: "PrepaidCardPrimarycardOnlyResponse",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: receiptsURL,
                             filename: "ReceiptsForOneMonth",
                             method: HTTPMethod.get)

        mockServer.setupStubEmpty(url: ppcPrimaryReceiptsURL, statusCode: 204, method: HTTPMethod.get)

        openListAllReceiptsScreen()
        waitForNonExistence(spinner)

        let primaryPPC = transactionDetails.getPPCInfoTab(digit: "9285", type: transactionDetails.prepaidCardVisa)
        let primardCardTab = transactionDetails.getTransactionsPPCTabBy(label: primaryPPC)

        // Assert empty placeholder text for PPC
        XCTAssertTrue(getTransactionsAvailableFundsTab().isSelected, "Available Funds tab is selected")
        verifyCellExists_ListAll("Bank Account", "2019-05-10T18:16:17", "-$5.00", "USD", at: 0)

        primardCardTab.tap()
        waitForNonExistence(spinner)

        let noTransaction = transactionDetails.getPPCNoTransactionStringYear()
        XCTAssertTrue(app.tables[noTransaction].exists)
    }

    /*
     Given user has Available funds and Primary PPC and Secondary PPC has receipts
     When user selects the "Transaction" tab
     Then user can see the tabs for Secondary PPC and receipts
     */
    func testListAllReceipts_NavigateToTransactionsVerifySecondaryPPCTabs() {
        waitForNonExistence(spinner)
        mockServer.setupStub(url: ppcURL,
                             filename: "PrepaidCardSecondaryResponse",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: receiptsURL,
                             filename: "ReceiptsForOneMonth",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: ppcPrimaryReceiptsURL,
                             filename: "PrepaidCardOneYearReceiptsResponse",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: ppcSecondaryReceiptsURL,
                             filename: "PrepaidCardSecondaryReceiptsResponse",
                             method: HTTPMethod.get)

        openListAllReceiptsScreen()
        waitForNonExistence(spinner)

        XCTAssertTrue(getTransactionsAvailableFundsTab().isSelected, "Available Funds tab is selected")

        let primaryPPC = transactionDetails.getPPCInfoTab(digit: "9285", type: transactionDetails.prepaidCardVisa)
        let primardCardTab = transactionDetails.getTransactionsPPCTabBy(label: primaryPPC)

        let secondaryPPC = transactionDetails.getPPCInfoTab(digit: "8884", type: transactionDetails.prepaidCardVisa)
        let secondaryCardTab = transactionDetails.getTransactionsPPCTabBy(label: secondaryPPC )

        // Asserts AF
        verifyCellExists_ListAll("Bank Account", "2019-05-10T18:16:17", "-$5.00", "USD", at: 0)

        primardCardTab.tap()
        waitForNonExistence(spinner)
        XCTAssertTrue(primardCardTab.isSelected, "Primary Card tab isselected")
        // Assert PPC receipts
        verifyCellExists_ListAll("Balance Adjustment", "2020-09-26T18:16:12", "-$20.99", "USD", at: 0)

        // Assert PPC secondary
        secondaryCardTab.tap()
        waitForNonExistence(spinner)
        XCTAssertTrue(secondaryCardTab.isSelected, "Secondary Prepaid Card is selected")
        // Assert PPC secondary receipts
        verifyCellExists_ListAll("Purchase", "2020-09-26T18:16:12", "-$100.47", "USD", at: 0)
        verifyCellExists_ListAll("Purchase", "2020-08-27T18:16:12", "-$20.47", "USD", at: 1)
    }

    /*
     Given user has Available funds and Primary PPC and Secondary PPC has no receipts
     When user selects the "Transaction" tab
     Then user can see the tabs for Secondary PPC and No Transactions
     */
    func testListAllReceipts_NavigateToTransactionsVerifySecondaryPPCTabsNoTransactions() {
        waitForNonExistence(spinner)
        mockServer.setupStub(url: ppcURL,
                             filename: "PrepaidCardSecondaryResponse",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: receiptsURL,
                             filename: "ReceiptsForOneMonth",
                             method: HTTPMethod.get)

        mockServer.setupStubEmpty(url: ppcPrimaryReceiptsURL, statusCode: 204, method: HTTPMethod.get)

        mockServer.setupStubEmpty(url: ppcSecondaryReceiptsURL, statusCode: 204, method: HTTPMethod.get)
        openListAllReceiptsScreen()
        waitForNonExistence(spinner)

        let primaryPPC = transactionDetails.getPPCInfoTab(digit: "9285", type: transactionDetails.prepaidCardVisa)
        let primardCardTab = transactionDetails.getTransactionsPPCTabBy(label: primaryPPC)

        let secondaryPPC = transactionDetails.getPPCInfoTab(digit: "8884", type: transactionDetails.prepaidCardVisa)
        let secondaryCardTab = transactionDetails.getTransactionsPPCTabBy(label: secondaryPPC )

        XCTAssertTrue(getTransactionsAvailableFundsTab().isSelected, "Available Funds tab is selected")

        // Asserts AF
        verifyCellExists_ListAll("Bank Account", "2019-05-10T18:16:17", "-$5.00", "USD", at: 0)
        waitForNonExistence(spinner)

        // Assert PPC exxists
        XCTAssertTrue(primardCardTab.exists, "Primary Card tab is selected")

        // Assert PPC secondary
        secondaryCardTab.tap()
        waitForNonExistence(spinner)
        XCTAssertTrue(secondaryCardTab.isSelected, "Secondary Prepaid Card is selected")
//        XCUIApplication().tables["No transactions in the past 365 days."].tap()
        let noTransaction = transactionDetails.getPPCNoTransactionStringYear()
        XCTAssertTrue(app.tables[noTransaction].exists)
    }

    /*
     Given user has Available funds and No active PPC
     When user selects the "Transaction" tab
     Then user can see the No tabs for PPC
     */
    func testListAllReceipts_NavigateToTransactionsVerifyNoACtivePPCTabs() {
        waitForNonExistence(spinner)

        mockServer.setupStub(url: receiptsURL,
                             filename: "ReceiptsForOneMonth",
                             method: HTTPMethod.get)

        openListAllReceiptsScreen()
        waitForNonExistence(spinner)

        let primaryPPC = transactionDetails.getPPCInfoTab(digit: "9285", type: transactionDetails.prepaidCardVisa)
        let primardCardTab = transactionDetails.getTransactionsPPCTabBy(label: primaryPPC)

        let secondaryPPC = transactionDetails.getPPCInfoTab(digit: "8884", type: transactionDetails.prepaidCardVisa)
        let secondaryCardTab = transactionDetails.getTransactionsPPCTabBy(label: secondaryPPC )

        // Asserts AF
        verifyCellExists_ListAll("Bank Account", "2019-05-10T18:16:17", "-$5.00", "USD", at: 0)
        waitForNonExistence(spinner)

        XCTAssertFalse(primardCardTab.exists, "Primary Prepaid Card does not exists")

        XCTAssertFalse(secondaryCardTab.exists, "Secondary Prepaid Card does not exists")
    }

    // Asserts the transactions - List All Receipts
    func getTransactionsAvailableFundsTab() -> XCUIElement {
        app.tables.buttons["Available Funds"]
    }

    private func verifyCellExists_ListAll(_ type: String,
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
}
