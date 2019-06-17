import XCTest

class TransactionDetailTests: BaseTests {

    var transactionDetails:TransactionDetails!

    override func setUp() {
        profileType = .individual
        super.setUp()
        transactionDetails = TransactionDetails(app: app)
        spinner = app.activityIndicators["activityIndicator"]
    }

    override func tearDown() {
        mockServer.tearDown()
    }

    // Verify transaction is displayed in the top section (Credit Icon, Transaction Title, Date, Amount, Currency) match the item selected
    func testReceiptDetail_verifyCreditTransaction() {
        let receiptdetailtableviewTable = transactionDetails.receiptdetailtableviewTable
        let currency = "USD"
        let transactionPaymentDate = "Payment\nMay 24, 2019"
        let transactionAmt = "-5.00\n\(currency)"

        openupReceiptsListScreenForFewMonths()
        openReceipt(row: 0)

        verifyPaymentSection(payment:transactionPaymentDate, amount:transactionAmt)

        // DETAILS Section
        verifyDetailSection(receiptID: "55176992", date: "Fri, May 24, 2019, 11:16 AM", clientID: "DyClk0VG9a")

        // FEE Section
        verifyFeeSection(amount: "+6.00 USD", fee: "0.00 USD", trans: "6.00 USD")
    }

    // Verify transaction is displayed in the top section (Debit Icon, Transaction Title, Date, Amount, Currency) match the item selected
    func testReceiptDetail_verifyDebitTransaction() {
        let receiptdetailtableviewTable = transactionDetails.receiptdetailtableviewTable
        let currency = "USD"
        let transactionPaymentDate = "Payment\nMay 12, 2019"
        let transactionAmt = "-5.00\n\(currency)"

        openupReceiptsListScreenForFewMonths()
        openReceipt(row: 1)

        verifyPaymentSection(payment:transactionPaymentDate, amount:transactionAmt)

        // DETAILS Section
        verifyDetailSection(receiptID: "55176991", date: "Sun, May 12, 2019, 11:16 AM", clientID: nil)

        // FEE Section
        verifyFeeSection(amount: "-5.00 USD", fee: "2.00 USD", trans: "-7.00 USD")
    }

    // Verify that upon rotating the device - the same Transaction Details is displayed
    func testReceiptDetail_verifyTransactionReceiptSectionRotate() {
        let currency = "USD"
        let transactionPaymentDate = "Payment\nMay 24, 2019"
        let transactionAmt = "-5.00\n\(currency)"
        openupReceiptsListScreenForFewMonths()
        openReceipt(row: 0)
        
        XCUIDevice.shared.rotateScreen(times: 3)
        verifyPaymentSection(payment:transactionPaymentDate, amount:transactionAmt)

        // DETAILS Section
        verifyDetailSection(receiptID: "55176992", date: "Fri, May 24, 2019, 11:16 AM", clientID: "DyClk0VG9a")

        // FEE Section
        verifyFeeSection(amount: "+6.00 USD", fee: "0.00 USD", trans: "6.00 USD")

    }

    // Verify that upon resuming the application (send the app to background and reopen using the recent apps) - the same Transaction Details is displayed
    func testReceiptDetail_verifyTransactionReceiptSectionAppToBackground() {
        let currency = "USD"
        let transactionPaymentDate = "Payment\nMay 24, 2019"
        let transactionAmt = "-5.00\n\(currency)"
        openupReceiptsListScreenForFewMonths()
        openReceipt(row: 0)

        XCUIDevice.shared.sendToBackground(app: app)
        verifyPaymentSection(payment:transactionPaymentDate, amount:transactionAmt)
        // DETAILS Section
        verifyDetailSection(receiptID: "55176992", date: "Fri, May 24, 2019, 11:16 AM", clientID: "DyClk0VG9a")

        // FEE Section
        verifyFeeSection(amount: "+6.00 USD", fee: "0.00 USD", trans: "6.00 USD")
    }

    // Verify back button navigation - can go to previous page
    func testReceiptDetail_verifyTransactionReceiptSectionPressBackButton() {
        openupReceiptsListScreenForFewMonths()
        openReceipt(row: 0)
        let backButton = transactionDetails.backButton
        backButton.tap()
        let transactionLabel = app.navigationBars["Transactions"].staticTexts["Transactions"]
        XCTAssertTrue(transactionLabel.exists)
    }

    func testReceiptDetail_verifyTransactionOptionalFields() {
        openupReceiptsListScreenForFewMonths()

        // Verify Receipt Id is correct (journalId from receipt)

        // Verify Date is displayed (createdOn from receipt)

        // Optional Fields

        //If receipt contains charityName - verify Charity Name is displayed in Transaction Details Receipt section

        //If receipt contains checkNumber - verify Check Number is displayed in Transaction Details Receipt section

        //If receipt contains clientPaymentId - verify Client Transaction ID is displayed in Transaction Details Receipt section

        // If receipt contains notes - verify Notes is displayed in Transaction Details Receipt section

        // If receipt contains website - verify Promo Website is displayed in Transaction Details Receipt section
    }

    private func openupReceiptsListScreenForFewMonths() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/receipts",
                             filename: "ReceiptsForFewMonths",
                             method: HTTPMethod.get)
        openReceiptsListScreen()
    }

    private func openReceiptsListScreen() {
        app.tables.cells.containing(.staticText, identifier: "List Receipts").element(boundBy: 0).tap()
        waitForNonExistence(spinner)
    }

    private func openReceipt(row:Int) {
        let row = app.tables.element.children(matching: .cell).element(boundBy:row)
        if row.exists {
            row.tap()
        }
    }

    private func verifyPaymentSection(payment:String, amount:String) {
        let receiptdetailtableviewTable = transactionDetails.receiptdetailtableviewTable
        let payment = receiptdetailtableviewTable/*@START_MENU_TOKEN@*/.staticTexts["ListReceiptTableViewCellTextLabel"]/*[[".cells",".staticTexts[\"Payment\\nMay 24, 2019\"]",".staticTexts[\"ListReceiptTableViewCellTextLabel\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        let amt = receiptdetailtableviewTable/*@START_MENU_TOKEN@*/.staticTexts["ListReceiptTableViewCellDetailTextLabel"]/*[[".cells",".staticTexts[\"+6.00\\nUSD\"]",".staticTexts[\"ListReceiptTableViewCellDetailTextLabel\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/

        XCTAssertTrue(payment.exists)
        XCTAssertTrue(amt.exists)
    }

    // Detail section verification
    private func verifyDetailSection(receiptID:String, date:String, clientID:String?) {
        let receiptdetailtableviewTable = transactionDetails.receiptdetailtableviewTable
        let detailsSectionLabel = transactionDetails.detailSection
        let receiptLabel = transactionDetails.receiptIdLabel
        let clientTransIDLabel = transactionDetails.clientTransactionIdLabel
        let dateLabel = transactionDetails.dateLabel
        let receiptID = receiptdetailtableviewTable.staticTexts[receiptID]
        let date = receiptdetailtableviewTable.staticTexts[date]

        XCTAssertTrue(receiptLabel.exists)
        XCTAssertTrue(dateLabel.exists)
        XCTAssertTrue(clientTransIDLabel.exists)
        XCTAssertTrue(receiptID.exists)
        XCTAssertTrue(date.exists)
        if let id = clientID {
            XCTAssertTrue(receiptdetailtableviewTable.staticTexts[id].exists)
        }
    }

    // FEE section verification
    private func verifyFeeSection(amount:String, fee:String, trans:String) {
        let receiptdetailtableviewTable = transactionDetails.receiptdetailtableviewTable
        let feeSectionLabel = transactionDetails.feeSection
        let amountLabel = transactionDetails.amountLabel
        let feeLabel = transactionDetails.feeLabel
        let transactionLabel = transactionDetails.transactionLabel
        let amount = receiptdetailtableviewTable.staticTexts[amount]
        let fee = receiptdetailtableviewTable.staticTexts[fee]
        let transaction = receiptdetailtableviewTable.staticTexts[trans]
        
        XCTAssertTrue(feeSectionLabel.exists)
        XCTAssertTrue(amountLabel.exists)
        XCTAssertTrue(feeLabel.exists)
        XCTAssertTrue(transactionLabel.exists)
        XCTAssertTrue(amount.exists)
        XCTAssertTrue(fee.exists)
        XCTAssertTrue(transaction.exists)
    }

}
