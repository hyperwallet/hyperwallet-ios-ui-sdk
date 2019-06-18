import XCTest

class TransactionDetailTests: BaseTests {

    var transactionDetails:TransactionDetails!
    let currency = "USD"

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
        let payment:XCUIElement
        let amount:XCUIElement
        let receiptdetailtableviewTable = transactionDetails.receiptdetailtableviewTable
        openupReceiptsListScreenForFewMonths(isOptional: false)
        openReceipt(row: 0)
        let transactionDetailHeaderLabel = transactionDetails.detailHeaderTitle
        waitForNonExistence(transactionDetailHeaderLabel)

        if #available(iOS 12, *) {
            payment = receiptdetailtableviewTable/*@START_MENU_TOKEN@*/.staticTexts["ListReceiptTableViewCellTextLabel"]/*[[".cells",".staticTexts[\"Payment\\nMay 24, 2019\"]",".staticTexts[\"ListReceiptTableViewCellTextLabel\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
            amount = receiptdetailtableviewTable/*@START_MENU_TOKEN@*/.staticTexts["ListReceiptTableViewCellDetailTextLabel"]/*[[".cells",".staticTexts[\"+6.00\\nUSD\"]",".staticTexts[\"ListReceiptTableViewCellDetailTextLabel\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        } else {
            payment = receiptdetailtableviewTable/*@START_MENU_TOKEN@*/.staticTexts["ListReceiptTableViewCellTextLabel"]/*[[".cells",".staticTexts[\"Payment May 24, 2019\"]",".staticTexts[\"ListReceiptTableViewCellTextLabel\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
            amount = receiptdetailtableviewTable/*@START_MENU_TOKEN@*/.staticTexts["ListReceiptTableViewCellDetailTextLabel"]/*[[".cells.staticTexts[\"ListReceiptTableViewCellDetailTextLabel\"]",".staticTexts[\"ListReceiptTableViewCellDetailTextLabel\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        }
        XCTAssertTrue(payment.exists)
        XCTAssertTrue(amount.exists)

        // DETAILS Section
        // note: iOS 10 Shows Date's time as 16:16 PM
        verifyDetailSection(receiptID: "55176992", date: "Fri, May 24, 2019, 11:16 AM", clientID: "DyClk0VG9a")

        // FEE Section
        verifyFeeSection(amount: "+6.00 USD", fee: "0.00 USD", trans: "6.00 USD")
    }

    // Verify transaction is displayed in the top section (Debit Icon, Transaction Title, Date, Amount, Currency) match the item selected
    func testReceiptDetail_verifyDebitTransaction() {
        let payment:XCUIElement
        let amount:XCUIElement
        let receiptdetailtableviewTable = transactionDetails.receiptdetailtableviewTable
        openupReceiptsListScreenForFewMonths(isOptional: false)
        openReceipt(row: 1)
        let transactionDetailHeaderLabel = transactionDetails.detailHeaderTitle
        waitForNonExistence(transactionDetailHeaderLabel)

        if #available(iOS 12, *) {
            payment = receiptdetailtableviewTable/*@START_MENU_TOKEN@*/.staticTexts["ListReceiptTableViewCellTextLabel"]/*[[".cells",".staticTexts[\"Bank Account\\nMay 12, 2019\"]",".staticTexts[\"ListReceiptTableViewCellTextLabel\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
            amount = receiptdetailtableviewTable/*@START_MENU_TOKEN@*/.staticTexts["ListReceiptTableViewCellDetailTextLabel"]/*[[".cells",".staticTexts[\"-5.00\\nUSD\"]",".staticTexts[\"ListReceiptTableViewCellDetailTextLabel\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/

        } else {
            payment = receiptdetailtableviewTable/*@START_MENU_TOKEN@*/.staticTexts["ListReceiptTableViewCellTextLabel"]/*[[".cells",".staticTexts[\"Bank Account May 12, 2019\"]",".staticTexts[\"ListReceiptTableViewCellTextLabel\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
            amount = receiptdetailtableviewTable/*@START_MENU_TOKEN@*/.staticTexts["ListReceiptTableViewCellDetailTextLabel"]/*[[".cells.staticTexts[\"ListReceiptTableViewCellDetailTextLabel\"]",".staticTexts[\"ListReceiptTableViewCellDetailTextLabel\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        }
        XCTAssertTrue(payment.exists)
        XCTAssertTrue(amount.exists)

        // DETAILS Section
        verifyDetailSection(receiptID: "55176991", date: "Sun, May 12, 2019, 11:16 AM", clientID: nil)

        // FEE Section
        verifyFeeSection(amount: "-5.00 USD", fee: "2.00 USD", trans: "-7.00 USD")
    }

    // Verify that upon rotating the device - the same Transaction Details is displayed
    func testReceiptDetail_verifyTransactionReceiptSectionRotate() {
        let payment:XCUIElement
        let amount:XCUIElement
        openupReceiptsListScreenForFewMonths(isOptional: false)
        openReceipt(row: 0)
        let transactionDetailHeaderLabel = transactionDetails.detailHeaderTitle
        waitForNonExistence(transactionDetailHeaderLabel)

        // Rotate device 3 times
        XCUIDevice.shared.rotateScreen(times: 3)

        let receiptdetailtableviewTable = transactionDetails.receiptdetailtableviewTable
        if #available(iOS 12, *) {
            payment = receiptdetailtableviewTable/*@START_MENU_TOKEN@*/.staticTexts["ListReceiptTableViewCellTextLabel"]/*[[".cells",".staticTexts[\"Payment\\nMay 24, 2019\"]",".staticTexts[\"ListReceiptTableViewCellTextLabel\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
            amount = receiptdetailtableviewTable/*@START_MENU_TOKEN@*/.staticTexts["ListReceiptTableViewCellDetailTextLabel"]/*[[".cells",".staticTexts[\"+6.00\\nUSD\"]",".staticTexts[\"ListReceiptTableViewCellDetailTextLabel\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        } else {
            payment = receiptdetailtableviewTable/*@START_MENU_TOKEN@*/.staticTexts["ListReceiptTableViewCellTextLabel"]/*[[".cells",".staticTexts[\"Payment May 24, 2019\"]",".staticTexts[\"ListReceiptTableViewCellTextLabel\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
            amount = receiptdetailtableviewTable/*@START_MENU_TOKEN@*/.staticTexts["ListReceiptTableViewCellDetailTextLabel"]/*[[".cells.staticTexts[\"ListReceiptTableViewCellDetailTextLabel\"]",".staticTexts[\"ListReceiptTableViewCellDetailTextLabel\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        }
        XCTAssertTrue(payment.exists)
        XCTAssertTrue(amount.exists)

        // DETAILS Section
        verifyDetailSection(receiptID: "55176992", date: "Fri, May 24, 2019, 11:16 AM", clientID: "DyClk0VG9a")

        // FEE Section
        verifyFeeSection(amount: "+6.00 USD", fee: "0.00 USD", trans: "6.00 USD")

    }

    // Verify that upon resuming the application (send the app to background and reopen using the recent apps) - the same Transaction Details is displayed
    func testReceiptDetail_verifyTransactionReceiptSectionAppToBackground() {
        let payment:XCUIElement
        let amount:XCUIElement
        openupReceiptsListScreenForFewMonths(isOptional: false)
        openReceipt(row: 0)
        let transactionDetailHeaderLabel = transactionDetails.detailHeaderTitle
        waitForNonExistence(transactionDetailHeaderLabel)

        XCUIDevice.shared.sendToBackground(app: app)
        let receiptdetailtableviewTable = transactionDetails.receiptdetailtableviewTable
        if #available(iOS 12, *) {
            payment = receiptdetailtableviewTable/*@START_MENU_TOKEN@*/.staticTexts["ListReceiptTableViewCellTextLabel"]/*[[".cells",".staticTexts[\"Payment\\nMay 24, 2019\"]",".staticTexts[\"ListReceiptTableViewCellTextLabel\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
            amount = receiptdetailtableviewTable.staticTexts["ListReceiptTableViewCellDetailTextLabel"]
        } else {
            payment = receiptdetailtableviewTable/*@START_MENU_TOKEN@*/.staticTexts["ListReceiptTableViewCellTextLabel"]/*[[".cells",".staticTexts[\"Payment May 24, 2019\"]",".staticTexts[\"ListReceiptTableViewCellTextLabel\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
            amount = receiptdetailtableviewTable/*@START_MENU_TOKEN@*/.staticTexts["ListReceiptTableViewCellDetailTextLabel"]/*[[".cells.staticTexts[\"ListReceiptTableViewCellDetailTextLabel\"]",".staticTexts[\"ListReceiptTableViewCellDetailTextLabel\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        }
        XCTAssertTrue(payment.exists)
        XCTAssertTrue(amount.exists)

        // DETAILS Section
        verifyDetailSection(receiptID: "55176992", date: "Fri, May 24, 2019, 11:16 AM", clientID: "DyClk0VG9a")

        // FEE Section
        verifyFeeSection(amount: "+6.00 USD", fee: "0.00 USD", trans: "6.00 USD")
    }

    // Verify back button navigation - can go to previous page
    func testReceiptDetail_verifyTransactionReceiptSectionPressBackButton() {
        openupReceiptsListScreenForFewMonths(isOptional: false)
        openReceipt(row: 0)
        let transactionDetailHeaderLabel = transactionDetails.detailHeaderTitle
        waitForNonExistence(transactionDetailHeaderLabel)

        let backButton = transactionDetails.backButton
        backButton.tap()
        let transactionLabel = app.navigationBars["Transactions"].staticTexts["Transactions"]
        XCTAssertTrue(transactionLabel.exists)
    }

    func testReceiptDetail_verifyTransactionOptionalFields() {
        let transactionId = "8OxXefx5"
        let receiptId = "3051579"
        let date = "Fri, May 3, 2019, 10:08 AM"
        let charityName = "Sample Charity"
        let checkNum = "Sample Check Number"
        let website = "https://api.sandbox.hyperwallet.com"
        let notes = "Sample payment for the period of June 15th, 2019 to July 23, 2019"
        openupReceiptsListScreenForFewMonths(isOptional: true)
        openReceipt(row: 4)
        let transactionDetailHeaderLabel = transactionDetails.detailHeaderTitle
        waitForNonExistence(transactionDetailHeaderLabel)

        verifyDetailSectionOptional(receiptID: receiptId, date: date, transactionID:transactionId, charityName:charityName, checkNum:checkNum, website:website, notes:notes)
    }

    // MARK: Helper methods

    private func openupReceiptsListScreenForFewMonths(isOptional:Bool) {
        if isOptional {
            mockServer.setupStub(url: "/rest/v3/users/usr-token/receipts",
                                 filename: "ReceiptsForOneMonth",
                                 method: HTTPMethod.get)
        } else {
            mockServer.setupStub(url: "/rest/v3/users/usr-token/receipts",
                                 filename: "ReceiptsForFewMonths",
                                 method: HTTPMethod.get)
        }
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

    // Detail section verification
    private func verifyDetailSection(receiptID:String, date:String, clientID:String?) {
        let receiptdetailtableviewTable = transactionDetails.receiptdetailtableviewTable
        let detailsSectionLabel = transactionDetails.detailSection
        let receiptLabel = transactionDetails.receiptIdLabel
        let dateLabel = transactionDetails.dateLabel
        let receiptID = receiptdetailtableviewTable.staticTexts[receiptID]
        let date = receiptdetailtableviewTable.staticTexts[date]

        XCTAssertTrue(detailsSectionLabel.exists)
        XCTAssertTrue(receiptLabel.exists)

        XCTAssertTrue(dateLabel.exists)
        XCTAssertTrue(receiptID.exists)
        // skip the test on iOS 10 as simulator time is not correct - possible XCode's bug
        if #available(iOS 11, *) {
            XCTAssertTrue(date.exists)
        }
        if let id = clientID {
            let clientTransIDLabel = transactionDetails.clientTransactionIdLabel
            XCTAssertTrue(clientTransIDLabel.exists)
            XCTAssertTrue(receiptdetailtableviewTable.staticTexts[id].exists)
        }
    }

    // Detail section verification
    private func verifyDetailSectionOptional(receiptID:String, date:String, transactionID:String, charityName:String, checkNum:String, website:String,notes:String) {

        let receiptdetailtableviewTable = transactionDetails.receiptdetailtableviewTable
        let detailsSectionLabel = transactionDetails.detailSection
        let receiptLabel = transactionDetails.receiptIdLabel
        let dateLabel = transactionDetails.dateLabel
        let charityLabel = transactionDetails.charityNameLabel
        let checkNumLabel = transactionDetails.checkNumLabel
        let websiteLabel = transactionDetails.promoWebSiteLabel
        let noteSection = transactionDetails.noteSectionLabel
        let receiptID = receiptdetailtableviewTable.staticTexts[receiptID]
        let date = receiptdetailtableviewTable.staticTexts[date]
        let transactionID = receiptdetailtableviewTable.staticTexts[transactionID]
        let charityName = receiptdetailtableviewTable.staticTexts[charityName]
        let checkNum = receiptdetailtableviewTable.staticTexts[checkNum]
        let website = receiptdetailtableviewTable.staticTexts[website]
        let notes = receiptdetailtableviewTable.staticTexts[notes]

        XCTAssertTrue(detailsSectionLabel.exists)
        XCTAssertTrue(receiptLabel.exists)
        XCTAssertTrue(dateLabel.exists)
        XCTAssertTrue(charityLabel.exists)
        XCTAssertTrue(checkNumLabel.exists)
        XCTAssertTrue(websiteLabel.exists)
        XCTAssertTrue(noteSection.exists)

        XCTAssertTrue(receiptID.exists)
        XCTAssertTrue(transactionID.exists)
        XCTAssertTrue(charityLabel.exists)
        XCTAssertTrue(checkNum.exists)
        XCTAssertTrue(website.exists)
        XCTAssertTrue(notes.exists)

        // skip the test on iOS 10 as simulator time is not correct - possible XCode's bug
        if #available(iOS 11, *) {
            XCTAssertTrue(date.exists)
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
