import XCTest

class TransactionDetailTests: BaseTests {
    var transactDetails: TransactionDetails!
    let currency = "USD"

    override func setUp() {
        profileType = .individual
        super.setUp()
        transactDetails = TransactionDetails(app: app)
        spinner = app.activityIndicators["activityIndicator"]
    }

    override func tearDown() {
        mockServer.tearDown()
    }

    // Credit Transaction
    func testReceiptDetail_verifyCreditTransaction() {
        openupReceiptsListScreenForFewMonths(isOneMonth: false)
        transactDetails.openReceipt(row: 0)
        let transactionDetailHeaderLabel = transactDetails.detailHeaderTitle
        waitForNonExistence(transactionDetailHeaderLabel)
        if #available(iOS 12, *) {
            verifyPayment(payment: "Payment\nMay 24, 2019", amount: "+6.00\n\(currency)")
        } else {
            verifyPayment(payment: "Payment May 24, 2019", amount: "+6.00 \(currency)")
        }

        // DETAILS Section
        // note: iOS 10 Shows Date's time as 16:16 PM
        verifyDetailSection(receiptID: "55176992", date: "Fri, May 24, 2019, 11:16 AM", clientID: "DyClk0VG9a")

        // FEE Section
        verifyFeeSection(amount: "+6.00 USD", fee: "0.00 USD", trans: "6.00 USD")
    }

    // Debit Transaction
    func testReceiptDetail_verifyDebitTransaction() {
        openupReceiptsListScreenForFewMonths(isOneMonth: false)
        transactDetails.openReceipt(row: 1)
        let transactionDetailHeaderLabel = transactDetails.detailHeaderTitle
        waitForNonExistence(transactionDetailHeaderLabel)

        if #available(iOS 12, *) {
            verifyPayment(payment: "Bank Account\nMay 12, 2019", amount: "-5.00\n\(currency)")
        } else {
            verifyPayment(payment: "Bank Account May 12, 2019", amount: "-5.00 \(currency)")
        }

        // DETAILS Section
        verifyDetailSection(receiptID: "55176991", date: "Sun, May 12, 2019, 11:16 AM", clientID: nil)

        // FEE Section
        verifyFeeSection(amount: "-5.00 USD", fee: "2.00 USD", trans: "-7.00 USD")
    }

    func testReceiptDetail_verifyTransactionOptionalFields() {
        openupReceiptsListScreenForFewMonths(isOneMonth: true)
        transactDetails.openReceipt(row: 4)
        let transactionDetailHeaderLabel = transactDetails.detailHeaderTitle
        waitForNonExistence(transactionDetailHeaderLabel)

        verifyDetailSectionOptional()
    }

    // Verify when no Notes and Fee sections
    func testReceiptDetail_verifyTransactionReceiptNoNoteSectionAndFeeLabel() {
        openupReceiptsListScreenForFewMonths(isOneMonth: true)
        transactDetails.openReceipt(row: 2)
        let transactionDetailHeaderLabel = transactDetails.detailHeaderTitle
        waitForNonExistence(transactionDetailHeaderLabel)

         // Assert No Note and Fee sections
         let noteSection = transactDetails.noteSectionLabel
         let feeLabel = transactDetails.feeLabel
         XCTAssertTrue(!noteSection.exists)
         XCTAssertTrue(!feeLabel.exists)
    }

    // MARK: Helper methods
    private func openupReceiptsListScreenForFewMonths(isOneMonth: Bool) {
        if isOneMonth {
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

    private func verifyPayment(payment: String, amount: String) {
        let receiptdetailtableviewTable = transactDetails.receiptdetailtableviewTable
        let paymentlabel = receiptdetailtableviewTable.staticTexts["ListReceiptTableViewCellTextLabel"].label
        let amountlabel = receiptdetailtableviewTable.staticTexts["ListReceiptTableViewCellDetailTextLabel"].label

        XCTAssertTrue(paymentlabel == payment)
        XCTAssertTrue(amountlabel == amount)
    }

    // Detail section verification
    private func verifyDetailSection(receiptID: String, date: String, clientID: String?) {
        let receiptdetailtableviewTable = transactDetails.receiptdetailtableviewTable
        let detailsSectionLabel = transactDetails.detailSection
        let receiptLabel = transactDetails.receiptIdLabel
        let dateLabel = transactDetails.dateLabel
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
        if let clientID = clientID {
            let clientTransIDLabel = transactDetails.clientTransactionIdLabel
            XCTAssertTrue(clientTransIDLabel.exists)
            XCTAssertTrue(receiptdetailtableviewTable.staticTexts[clientID].exists)
        }
    }

    // Detail section verification
    private func verifyDetailSectionOptional() {
        let transactionVal = "8OxXefx5"
        let receiptVal = "3051579"
        let dateVal = "Fri, May 3, 2019, 10:08 AM"
        let charityNameVal = "Sample Charity"
        let checkNumVal = "Sample Check Number"
        let websiteVal = "https://api.sandbox.hyperwallet.com"
        let notesVal = "Sample payment for the period of June 15th, 2019 to July 23, 2019"

        let receiptdetailtableviewTable = transactDetails.receiptdetailtableviewTable
        let detailsSectionLabel = transactDetails.detailSection
        let receiptLabel = transactDetails.receiptIdLabel
        let dateLabel = transactDetails.dateLabel
        let charityLabel = transactDetails.charityNameLabel
        let checkNumLabel = transactDetails.checkNumLabel
        let websiteLabel = transactDetails.promoWebSiteLabel
        let noteSection = transactDetails.noteSectionLabel
        let receiptId = receiptdetailtableviewTable.staticTexts[receiptVal]
        let date = receiptdetailtableviewTable.staticTexts[dateVal]
        let transactionId = receiptdetailtableviewTable.staticTexts[transactionVal]
        let charityName = receiptdetailtableviewTable.staticTexts[charityNameVal]
        let checkNum = receiptdetailtableviewTable.staticTexts[checkNumVal]
        let website = receiptdetailtableviewTable.staticTexts[websiteVal]
        let notes = receiptdetailtableviewTable.staticTexts[notesVal]

        XCTAssertTrue(detailsSectionLabel.exists)
        XCTAssertTrue(receiptLabel.exists)
        XCTAssertTrue(dateLabel.exists)
        XCTAssertTrue(charityLabel.exists)
        XCTAssertTrue(checkNumLabel.exists)
        XCTAssertTrue(websiteLabel.exists)
        XCTAssertTrue(noteSection.exists)

        XCTAssertTrue(receiptId.exists)
        XCTAssertTrue(transactionId.exists)
        XCTAssertTrue(charityName.exists)
        XCTAssertTrue(checkNum.exists)
        XCTAssertTrue(website.exists)
        XCTAssertTrue(notes.exists)

        // skip the test on iOS 10 as simulator time is not correct - possible XCode's bug
        if #available(iOS 11, *) {
            XCTAssertTrue(dateLabel.exists)
            XCTAssertTrue(date.exists)
        }
    }

    // FEE section verification
    private func verifyFeeSection(amount: String, fee: String, trans: String) {
        let receiptdetailtableviewTable = transactDetails.receiptdetailtableviewTable
        let feeSectionLabel = transactDetails.feeSection
        let amountLabel = transactDetails.amountLabel
        let feeLabel = transactDetails.feeLabel
        let transactionLabel = transactDetails.transactionLabel
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
