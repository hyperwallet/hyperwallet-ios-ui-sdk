import XCTest

class TransactionDetailTests: BaseTests {
    private var transactDetails: TransactionDetails!
    private let currency = "USD"

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
        let expectedDateValue = "Fri, May 24, 2019, 6:16 PM"
        openupReceiptsListScreenForFewMonths(isOneMonth: false)
        transactDetails.openReceipt(row: 0)
        let transactionDetailHeaderLabel = transactDetails.detailHeaderTitle
        waitForNonExistence(transactionDetailHeaderLabel)
        verifyPayment(payment: "Payment\nMay 24, 2019", amount: "+6.00\n\(currency)")

        // DETAILS Section
        verifyDetailSection(receiptIdVal: "55176992", dateVal: expectedDateValue, clientIdVal: "DyClk0VG9a")

        // FEE Section
        verifyFeeSection(amountVal: "+6.00 USD", feeVal: "0.00 USD", transactionVal: "6.00 USD")
    }

    // Debit Transaction
    func testReceiptDetail_verifyDebitTransaction() {
        let expectedDateValue = "Sun, May 12, 2019, 6:16 PM" // Sun, May 12, 2019, 6:16 PM
        openupReceiptsListScreenForFewMonths(isOneMonth: false)
        transactDetails.openReceipt(row: 1)
        let transactionDetailHeaderLabel = transactDetails.detailHeaderTitle
        waitForNonExistence(transactionDetailHeaderLabel)

        verifyPayment(payment: "Bank Account\nMay 12, 2019", amount: "-5.00\n\(currency)")

        // DETAILS Section
        verifyDetailSection(receiptIdVal: "55176991", dateVal: expectedDateValue, clientIdVal: nil)

        // FEE Section
        verifyFeeSection(amountVal: "-5.00 USD", feeVal: "2.00 USD", transactionVal: "-7.00 USD")
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
        XCTAssertFalse(noteSection.exists)
        XCTAssertFalse(feeLabel.exists)
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
        app.tables.cells.containing(.staticText, identifier: "List User Receipts").element(boundBy: 0).tap()
        waitForNonExistence(spinner)
    }

    private func verifyPayment(payment: String, amount: String) {
        let paymentlabel = transactDetails.cellTextLabel.label
        let amountlabel = transactDetails.detailTextLabel.label
        if #available(iOS 12, *) {
            XCTAssertEqual(paymentlabel, payment)
            XCTAssertEqual(amountlabel, amount)
        } else {
            XCTAssertEqual(paymentlabel, payment.replacingOccurrences(of: "\n", with: " "))
            XCTAssertEqual(amountlabel, amount.replacingOccurrences(of: "\n", with: " "))
        }
    }

    // Detail section verification
    private func verifyDetailSection(receiptIdVal: String, dateVal: String, clientIdVal: String?) {
        let receiptDetailTableviewTable = transactDetails.receiptDetailTableviewTable
        let detailsSectionLabel = transactDetails.detailSection
        let receiptLabel = transactDetails.receiptIdLabel
        let dateLabel = transactDetails.dateLabel
        let receiptID = transactDetails.receiptIdValue
        let date = transactDetails.dateValue

        XCTAssertTrue(detailsSectionLabel.exists)
        XCTAssertTrue(receiptLabel.exists)
        XCTAssertTrue(dateLabel.exists)
        XCTAssertTrue(receiptID.exists)
        XCTAssertEqual(receiptID.label, receiptIdVal)

        XCTAssertEqual(date.label, dateVal)

        if let clientIdVal = clientIdVal {
            let clientTransIDLabel = transactDetails.clientTransactionIdLabel
            XCTAssertTrue(clientTransIDLabel.exists)
            let clientID = receiptDetailTableviewTable.staticTexts[clientIdVal]
            XCTAssertTrue(clientID.exists)
            XCTAssertEqual(clientID.label, clientIdVal)
        }
    }

    // Detail section verification
    private func verifyDetailSectionOptional() {
        let transactionVal = "8OxXefx5"
        let receiptVal = "3051579"
        let dateVal = "Fri, May 3, 2019, 5:08 PM" // Fri, May 3, 2019, 5:08 PM in test environment
        let charityNameVal = "Sample Charity"
        let checkNumVal = "Sample Check Number"
        let websiteVal = "https://localhost"
        let notesVal = "Sample payment for the period of June 15th, 2019 to July 23, 2019"

        let receiptDetailTableviewTable = transactDetails.receiptDetailTableviewTable
        let detailsSectionLabel = transactDetails.detailSection
        let receiptLabel = transactDetails.receiptIdLabel
        let dateLabel = transactDetails.dateLabel
        let charityLabel = transactDetails.charityNameLabel
        let checkNumLabel = transactDetails.checkNumLabel
        let websiteLabel = transactDetails.promoWebSiteLabel
        let noteSection = transactDetails.noteSectionLabel
        let receiptId = receiptDetailTableviewTable.staticTexts[receiptVal]
        let date = receiptDetailTableviewTable.staticTexts[dateVal]
        let transactionId = receiptDetailTableviewTable.staticTexts[transactionVal]
        let charityName = receiptDetailTableviewTable.staticTexts[charityNameVal]
        let checkNum = receiptDetailTableviewTable.staticTexts[checkNumVal]
        let website = receiptDetailTableviewTable.staticTexts[websiteVal]
        let notes = receiptDetailTableviewTable.staticTexts[notesVal]

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

        XCTAssertEqual(date.label, dateVal)
    }

    // FEE section verification
    private func verifyFeeSection(amountVal: String, feeVal: String, transactionVal: String) {
        let receiptDetailTableviewTable = transactDetails.receiptDetailTableviewTable
        let feeSectionLabel = transactDetails.feeSection
        let amountLabel = transactDetails.amountLabel
        let feeLabel = transactDetails.feeLabel
        let transactionLabel = transactDetails.transactionLabel
        let amount = receiptDetailTableviewTable.staticTexts[amountVal]
        let fee = receiptDetailTableviewTable.staticTexts[feeVal]
        let transaction = receiptDetailTableviewTable.staticTexts[transactionVal]

        XCTAssertTrue(feeSectionLabel.exists)
        XCTAssertTrue(amountLabel.exists)
        XCTAssertTrue(feeLabel.exists)
        XCTAssertTrue(transactionLabel.exists)
        XCTAssertTrue(amount.exists)
        XCTAssertTrue(fee.exists)
        XCTAssertTrue(transaction.exists)
    }
}
