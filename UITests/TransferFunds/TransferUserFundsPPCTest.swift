import XCTest

class TransferUserFundsPPCTest: BaseTests {
    var transferFundPPCMenu: XCUIElement!
    var transferFunds: TransferFunds!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launchArguments.append("-disableAnimations")
        app.launch()
        spinner = app.activityIndicators["activityIndicator"]
        transferFundPPCMenu = app.tables.cells
            .containing(.staticText, identifier: "Transfer Funds PPC")
            .element(boundBy: 0)
        transferFunds = TransferFunds(app: app)
    }

    /*
     Given that Transfer methods exist that contains prepaid cards as well
     AND PrepaidCards will automatically be removed from Transfer methods list
     AND next available transfer method in this case Bank Account is selected
     When Payee enters the amount and Notes
     Then Next button is enabled
     */
    func testTransferFunds_createTransferPrepaidCardWithNotes_transferDestinationContainsPrepaidCards() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/prepaid-cards/trm-token",
                             filename: "GetPrepaidCardSuccessResponse",
                             method: HTTPMethod.get)
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferDestinationsUSD",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.post)

        XCTAssertTrue(transferFundPPCMenu.exists)
        transferFundPPCMenu.tap()
        waitForNonExistence(spinner)

        // Verify Transfer from is Prepaid Card
        transferFunds.verifyTransferFrom(isAvailableFunds: false)

        // Transfer Destination Section
        transferFunds.verifyTransferFundsTitle()
        transferFunds.verifyBankAccountDestination(type: "Bank Account", endingDigit: "1234")

        // Transfer Section
        XCTAssertTrue(transferFunds.transferSectionLabel.exists)
        // Amount
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "0.00")
        XCTAssertEqual(transferFunds.transferCurrency.value as? String, "USD")
        XCTAssertEqual(transferFunds.transferAmountLabel.label,
                       String(format: "mobileAvailableBalance".localized(), "$", "452.14", "USD"))
        // Transfer max funds
        XCTAssertTrue(transferFunds.transferMaxAllFunds.exists, "Transfer all funds switch should exist")

        // NOTE
        XCTAssertTrue(transferFunds.notesSectionLabel.exists)
        transferFunds.verifyNotes()

        // Continue Button
        XCTAssertTrue(transferFunds.nextLabel.exists)
    }

    func testTransferFunds_createTransferPrepaidCardWithNotes_transferDestinationContainsOnlyPrepaidCards() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/prepaid-cards/trm-token",
                             filename: "GetPrepaidCardSuccessResponse",
                             method: HTTPMethod.get)
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferDestinationPrepaidCardsOnly",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.post)

        XCTAssertTrue(transferFundPPCMenu.exists)
        transferFundPPCMenu.tap()
        waitForNonExistence(spinner)

        // Verify Transfer from is Prepaid Card
        transferFunds.verifyTransferFrom(isAvailableFunds: false)

        // Add Destination Section
        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertEqual(transferFunds.addSelectDestinationLabel.label, "mobileAddTransferMethod".localized())

        // Transfer Section
        XCTAssertTrue(transferFunds.transferSectionLabel.exists)
        // Amount
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "0", "Input Transfer Amount should be 0")
        XCTAssertEqual(transferFunds.transferCurrency.value as? String, String(repeating: " ", count: 3))
        XCTAssertTrue(transferFunds.transferAmountLabel.exists, "naAvailableBalance".localized())

        // NOTE
        XCTAssertTrue(transferFunds.notesSectionLabel.exists)

        // Continue Button
        XCTAssertTrue(transferFunds.nextLabel.exists)
    }
}
