import XCTest

class ReceiptDetailTests: BaseTests {
    
    override func setUp() {
        profileType = .individual
        super.setUp()
        // receiptsList = ReceiptsList(app: app)
        spinner = app.activityIndicators["activityIndicator"]
    }

    override func tearDown() {
        mockServer.tearDown()
    }


    func testReceiptDetail_verifyCreditTransaction() {
        openupReceiptsListScreenForFewMonths()

        // Open Transaction Details

        // Verify transaction is displayed in the top section (Credit Icon, Transaction Title, Date, Amount, Currency) match the item selected
    }


    func testReceiptDetail_verifyDebitTransaction() {
        openupReceiptsListScreenForFewMonths()

        // Open Transaction Details

        // Verify transaction is displayed in the top section (Debit Icon, Transaction Title, Date, Amount, Currency) match the item selected
    }

    func testReceiptDetail_verifyTransactionWithFee() {
        openupReceiptsListScreenForFewMonths()

        // Open Transaction Details with Fee Section

        //  Verify details section - Amount and Fee are displayed - Verify Transfer Amount is correct (Amount - Fee)
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
}
