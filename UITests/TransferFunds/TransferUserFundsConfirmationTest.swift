import XCTest

class TransferUserFundsConfirmationTest: BaseTests {
    var transferFundMenu: XCUIElement!
    var transferFunds: TransferFunds!
    var transferFundsConfirmation: TransferFundsConfirmation!
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
        spinner = app.activityIndicators["activityIndicator"]
        transferFundMenu = app.tables.cells
            .containing(.staticText, identifier: "Transfer Funds")
            .element(boundBy: 0)

        transferFunds = TransferFunds(app: app)
        transferFundsConfirmation = TransferFundsConfirmation(app: app)
    }

    override func tearDown() {
        mockServer.tearDown()
    }

    func testTransferFundsConfirmation_noFX() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListMoreThanOneTransferMethod",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.post)

        transferFundMenu.tap()
        waitForNonExistence(spinner)

        if #available(iOS 11.4, *) {
            XCTAssertTrue(transferFunds.transferFundTitle.exists)
        } else {
            XCTAssertTrue(app.navigationBars["Transfer Funds"].exists)
        }

        // Add Destination Section
        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertEqual(transferFunds.addSelectDestinationLabel.label, "Bank Account")

        // Turn on the Transfer All Funds Switch
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "")
        transferFunds.transferAllFundsSwitch.tap()
        // Assert Destination Amount is automatically insert into the amount field
        // XCTAssertEqual(transferFunds.transferAmount.value as? String, "452.14")

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.post)
        transferFunds.nextLabel.tap()

        XCTAssertTrue(transferFundsConfirmation.addSelectDestinationLabel.exists)
        XCTAssertTrue(transferFundsConfirmation.addSelectDestinationDetailLabel.exists)

        XCTAssertTrue(transferFundsConfirmation.summaryTitle.label == "SUMMARY")
        XCTAssertTrue(transferFundsConfirmation.summaryAmountLabel.label == "Amount:")
        XCTAssertTrue(transferFundsConfirmation.summaryFeeLabel.label == "Fee:")
        XCTAssertTrue(transferFundsConfirmation.summaryReceiveLabel.label == "You will receive:")

        // TODO: Assert the Confirmation Page
        XCTAssertTrue(app.tables["scheduleTransferTableView"].staticTexts["454.14"].exists)
        XCTAssertTrue(app.tables["scheduleTransferTableView"].staticTexts["2.00"].exists)
        XCTAssertTrue(app.tables["scheduleTransferTableView"].staticTexts["452.14"].exists)

        XCTAssertTrue(transferFundsConfirmation.noteLabel.exists)
        // TODO: add back assertion for description when we have the accessibilityID

        //tab Confirm button
        XCTAssertTrue(transferFundsConfirmation.confirmButton.exists)
        transferFundsConfirmation.confirmButton.tap()
        // TODO: fix the endpoint URL later...
//        mockServer.setupStub(url: "/rest/v3/transfers/trf-token/status-transitions",
//                             filename: "TransferStatusQuoted",
//                             method: HTTPMethod.post)

        // TODO: Assert the final landing page

    }

    func testTransferFundsConfirmation_withFX() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListMoreThanOneTransferMethod",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundMultiCurrencies",
                             method: HTTPMethod.post)

        transferFundMenu.tap()
        waitForNonExistence(spinner)

        if #available(iOS 11.4, *) {
            XCTAssertTrue(transferFunds.transferFundTitle.exists)
        } else {
            XCTAssertTrue(app.navigationBars["Transfer Funds"].exists)
        }

        // Add Destination Section
        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertEqual(transferFunds.addSelectDestinationLabel.label, "Bank Account")

        // Turn on the Transfer All Funds Switch
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "")
        transferFunds.transferAllFundsSwitch.tap()

        // Assert Destination Amount is automatically insert into the amount field
        //XCTAssertEqual(transferFunds.transferAmount.value as? String, "5,855.17")

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundMultiCurrencies",
                             method: HTTPMethod.post)

        transferFunds.nextLabel.tap()

        XCTAssertTrue(app.navigationBars["Transfer Funds"].exists)

        // 1.  Add Destination Section
        XCTAssertTrue(transferFundsConfirmation.addSelectDestinationLabel.exists)
        XCTAssertTrue(transferFundsConfirmation.addSelectDestinationDetailLabel.exists)

        // 2.  Exchange Rate Section
        XCTAssertTrue(transferFundsConfirmation.foreignExchangeSectionLabel.label == "FOREIGN EXCHANGE")
        XCTAssertTrue(app.navigationBars["Transfer Funds"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 1).staticTexts["You sell:"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 1).staticTexts["9,992.50 MYR"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 2).staticTexts["You buy:"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 2).staticTexts["2,337.93 USD"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 3).staticTexts["Exchange Rate:"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 3).staticTexts["1.00 = 0.23"].exists)

        XCTAssertTrue(app.cells.element(boundBy: 5).staticTexts["You sell:"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 5).staticTexts["1,464.53 CAD"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 6).staticTexts["You buy:"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 6).staticTexts["1,134.13 USD"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 7).staticTexts["Exchange Rate:"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 7).staticTexts["1.00 = 0.77"].exists)

        XCTAssertTrue(app.cells.element(boundBy: 9).staticTexts["You sell:"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 9).staticTexts["50,000.00 KRW"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 10).staticTexts["You buy:"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 10).staticTexts["42.76 USD"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 11).staticTexts["Exchange Rate:"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 11).staticTexts["1.00 = 0.00"].exists)

        XCTAssertTrue(app.cells.element(boundBy: 13).staticTexts["You sell:"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 13).staticTexts["1,000.00 EUR"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 14).staticTexts["You buy:"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 14).staticTexts["1,135.96 USD"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 15).staticTexts["Exchange Rate:"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 15).staticTexts["1.00 = 1.14"].exists)

        // 3. Summary Section
        XCTAssertTrue(transferFundsConfirmation.summaryTitle.label == "SUMMARY")
        XCTAssertTrue(app.cells.element(boundBy: 16).staticTexts["Amount:"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 16).staticTexts["5,857.17"].exists)

        XCTAssertTrue(app.cells.element(boundBy: 17).staticTexts["Fee:"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 17).staticTexts["2.00"].exists)

        XCTAssertTrue(app.cells.element(boundBy: 18).staticTexts["You will receive:"].exists)
    //XCTAssertTrue(app.tables["scheduleTransferTableView"].staticTexts["5,885.17"].exists)
        //XCTAssertTrue(app.cells.element(boundBy: 18).staticTexts["5,885.17"].exists)
        XCTAssertTrue(transferFundsConfirmation.noteLabel.exists)
        XCTAssertTrue(transferFundsConfirmation.confirmButton.exists)

        // TODO: Assert the Confirmation Page
        // 1.  Add Destination Section
        // 2.  Exchange Rate Section
        // 3. Summary Section
        // >>> Please insert your assertion codes here

        // TODO: TAB Confirm button
        // >>> please insert your assertion codes here

        // After Tab on confirm button - inject a mock response from the server
//        mockServer.setupStub(url: "/rest/v3/transfers/trf-token/status-transitions",
//                             filename: "TransferStatusQuoted",
//                             method: HTTPMethod.post)

        // TODO: Assert the final landing page
    }

    func testTransferFundsConfirmation_timeOutError() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListMoreThanOneTransferMethod",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.post)

        transferFundMenu.tap()
        waitForNonExistence(spinner)

        if #available(iOS 11.4, *) {
            XCTAssertTrue(transferFunds.transferFundTitle.exists)
        } else {
            XCTAssertTrue(app.navigationBars["Transfer Funds"].exists)
        }

        // Add Destination Section
        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertEqual(transferFunds.addSelectDestinationLabel.label, "Bank Account")

        // Turn on the Transfer All Funds Switch
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "")
        transferFunds.transferAllFundsSwitch.tap()
        // Assert Destination Amount is automatically insert into the amount field
        // XCTAssertEqual(transferFunds.transferAmount.value as? String, "452.14")

        transferFunds.nextLabel.tap()

        // Tab Confirm Button
        transferFundsConfirmation.confirmButton.tap()

        mockServer.setupStubError(url: "/rest/v3/transfers",
                                  filename: "TransferErrorQuoteExpired",
                                  method: HTTPMethod.post)

        // Assert Transfer Quote Expire error
//        XCTAssert(app.alerts["Error"].exists)
        let predicate = NSPredicate(format:
            "label CONTAINS[c] 'The transfer request has expired on Wed Jul 24 21:38:58 GMT 2019. Please create a new transfer and commit it before 120 seconds.'")
        XCTAssert(app.alerts["Error"].staticTexts.element(matching: predicate).exists)
    }

    // Assert Fee section is not display if transfer requires no fee
    func testTransferFundsConfirmation_verifySummaryWithNoFee() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListMoreThanOneTransferMethod",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.post)

        transferFundMenu.tap()
        waitForNonExistence(spinner)

        if #available(iOS 11.4, *) {
            XCTAssertTrue(transferFunds.transferFundTitle.exists)
        } else {
            XCTAssertTrue(app.navigationBars["Transfer Funds"].exists)
        }

        // Add Destination Section
        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertEqual(transferFunds.addSelectDestinationLabel.label, "Bank Account")

        // Turn on the Transfer All Funds Switch
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "")
        transferFunds.transferAllFundsSwitch.tap()
        // Assert Destination Amount is automatically insert into the amount field
        // XCTAssertEqual(transferFunds.transferAmount.value as? String, "452.14")

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "CreateTransferWithNoFee",
                             method: HTTPMethod.post)
        transferFunds.nextLabel.tap()

        // TODO: Assert confirmation page has no FEE section

    }
}
