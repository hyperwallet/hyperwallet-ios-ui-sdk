import XCTest

class TransferUserFundsPPCTest: BaseTests {
    var transferFundPPCMenu: XCUIElement!
    var transferFunds: TransferFunds!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
        spinner = app.activityIndicators["activityIndicator"]
        transferFundPPCMenu = app.tables.cells
            .containing(.staticText, identifier: "Transfer Funds PPC")
            .element(boundBy: 0)
        transferFunds = TransferFunds(app: app)
    }

    /*
     Given thatTransfer methods exist
     AND PrepaidCard Transfer method is selected
     When Payee enters the amount and Notes
     Then Next button is enabled
     */
    func testTransferFunds_createTransferPrepaidCardWithNotes() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListPrepaidCardTransferUSD",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.post)

        XCTAssertTrue(transferFundPPCMenu.exists)
        transferFundPPCMenu.tap()
        waitForNonExistence(spinner)

        // Add Destination Section
        transferFunds.verifyTransferFundsTitle()
        transferFunds.verifyBankAccountDestination(type: "Prepaid Card", endingDigit: "4281")

        // Transfer Section
        XCTAssertTrue(transferFunds.transferSectionLabel.exists)
        // Amount
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "0")
        XCTAssertEqual(transferFunds.transferCurrency.value as? String, "USD")
        XCTAssertEqual(transferFunds.transferAmountLabel.label, "Available funds $452.14 USD")
        // Transfer max funds
        XCTAssertTrue(transferFunds.transferMaxAllFunds.exists, "Transfer all funds switch should exist")

        // NOTE
        XCTAssertTrue(transferFunds.notesSectionLabel.exists)
        transferFunds.verifyNotes()

        // Continue Button
        XCTAssertTrue(transferFunds.nextLabel.exists)
    }
}
