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

    override func tearDown() {
       mockServer.tearDown()
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
        if #available(iOS 11.4, *) {
            XCTAssertTrue(transferFunds.transferFundTitle.exists)
        } else {
            XCTAssertTrue(app.navigationBars["Transfer Funds"].exists)
        }
        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertEqual(transferFunds.addSelectDestinationLabel.label, "Prepaid Card")

        if #available(iOS 11.4, *) {
            XCTAssertEqual(transferFunds.addSelectDestinationDetailLabel.label, "United States\nEnding on 4281")
        } else {
            XCTAssertEqual(transferFunds.addSelectDestinationDetailLabel.label, "United States Ending on 4281")
        }
        // Transfer Section
        XCTAssertTrue(transferFunds.transferSectionLabel.exists)
        // Amount
        XCTAssertEqual(transferFunds.transferAmountLabel.label, "Amount")
        XCTAssertEqual(transferFunds.transferCurrency.label, "USD")
        // Transfer all funds row
        XCTAssertEqual(transferFunds.transferAllFundsLabel.label, "Transfer all funds")
        XCTAssertTrue(transferFunds.transferAllFundsSwitch.exists, "Transfer all funds switch should exist")

        let availableFunds = app.tables["createTransferTableView"].staticTexts["Available for transfer: 452.14"]
        XCTAssertTrue(availableFunds.exists)

        XCTAssertEqual(transferFunds.notesSectionLabel.label, "NOTES")
        XCTAssertEqual(transferFunds.notesDescriptionTextField.placeholderValue, "Description")
        transferFunds.enterNotes(description: "testing")
        XCTAssertEqual(transferFunds.notesDescriptionTextField.value as? String, "testing")
    }
}
