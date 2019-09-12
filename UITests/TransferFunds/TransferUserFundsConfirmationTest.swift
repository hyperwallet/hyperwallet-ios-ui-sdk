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

    //swiftlint:disable function_body_length
    func testTransferFundsConfirmation_withoutFX() {
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
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "452.14")

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.post)
        transferFunds.nextLabel.tap()

        waitForExistence(transferFundsConfirmation.transferDestinationLabel)
        XCTAssertTrue(transferFundsConfirmation.transferDestinationLabel.exists)
        XCTAssertTrue(transferFundsConfirmation.transferDestinationDetailLabel.exists)
        let destinationDetail = transferFundsConfirmation.transferDestinationDetailLabel.label
        XCTAssertTrue(destinationDetail == "United States\nEnding on 1234"
            || destinationDetail == "United States Ending on 1234")

        XCTAssertEqual(transferFundsConfirmation.summaryTitle.label, "SUMMARY")
        XCTAssertEqual(transferFundsConfirmation.summaryAmountLabel.label, "Amount:")
        XCTAssertEqual(transferFundsConfirmation.summaryFeeLabel.label, "Fee:")
        XCTAssertEqual(transferFundsConfirmation.summaryReceiveLabel.label, "You will receive:")

        // Assert the Confirmation Page
        XCTAssertFalse(transferFundsConfirmation.foreignExchangeSectionLabel.exists)

        XCTAssertTrue(app.tables["scheduleTransferTableView"].staticTexts["454.14"].exists)
        XCTAssertTrue(app.tables["scheduleTransferTableView"].staticTexts["2.00"].exists)
        XCTAssertTrue(app.tables["scheduleTransferTableView"].staticTexts["452.14"].exists)

        XCTAssertTrue(transferFundsConfirmation.noteLabel.exists)
        XCTAssertEqual(transferFundsConfirmation.noteDescription.value as? String, "Partial-Balance Transfer888")

        mockServer.setupStub(url: "/rest/v3/transfers/trf-token/status-transitions",
                             filename: "TransferStatusQuoted",
                             method: HTTPMethod.post)

        XCTAssertTrue(transferFundsConfirmation.confirmButton.exists)
        transferFundsConfirmation.confirmButton.tap()

        // Assert go back to the menu page
        waitForExistence(transferFundMenu)
        XCTAssertTrue(transferFundMenu.exists)
    }

    //swiftlint:disable function_body_length
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
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "5,855.17")

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundMultiCurrencies",
                             method: HTTPMethod.post)

        transferFunds.nextLabel.tap()

        waitForExistence(transferFundsConfirmation.transferDestinationLabel)
        // 1.  Add Destination Section
        XCTAssertTrue(transferFundsConfirmation.transferDestinationLabel.exists)
        XCTAssertTrue(transferFundsConfirmation.transferDestinationDetailLabel.exists)
        let destinationDetail = transferFundsConfirmation.transferDestinationDetailLabel.label
        XCTAssertTrue(destinationDetail == "United States\nEnding on 1234"
            || destinationDetail == "United States Ending on 1234")

        // 2.Exchange Rate Section
        XCTAssertTrue(transferFundsConfirmation.foreignExchangeSectionLabel.label == "FOREIGN EXCHANGE")
        XCTAssertTrue(app.cells.element(boundBy: 1).staticTexts["You sell:"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 1).staticTexts["9,992.50 MYR"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 2).staticTexts["You buy:"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 2).staticTexts["2,337.93 USD"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 3).staticTexts["Exchange Rate:"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 3).staticTexts["1 MYR = 0.233968 USD"].exists)

        XCTAssertTrue(app.cells.element(boundBy: 5).staticTexts["You sell:"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 5).staticTexts["1,464.53 CAD"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 6).staticTexts["You buy:"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 6).staticTexts["1,134.13 USD"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 7).staticTexts["Exchange Rate:"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 7).staticTexts["1 CAD = 0.774399 USD"].exists)

        XCTAssertTrue(app.cells.element(boundBy: 9).staticTexts["You sell:"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 9).staticTexts["50,000 KRW"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 10).staticTexts["You buy:"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 10).staticTexts["42.76 USD"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 11).staticTexts["Exchange Rate:"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 11).staticTexts["1 KRW = 0.000855 USD"].exists)

        XCTAssertTrue(app.cells.element(boundBy: 13).staticTexts["You sell:"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 13).staticTexts["1,000.00 EUR"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 14).staticTexts["You buy:"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 14).staticTexts["1,135.96 USD"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 15).staticTexts["Exchange Rate:"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 15).staticTexts["1 EUR = 1.135960 USD"].exists)

        // 3. Summary Section
        XCTAssertTrue(transferFundsConfirmation.summaryTitle.label == "SUMMARY")
        XCTAssertEqual(app.cells.element(boundBy: 16)
            .staticTexts["scheduleTransferSummaryTextLabel"].label, "Amount:")
        XCTAssertEqual(app.cells.element(boundBy: 16)
            .staticTexts["scheduleTransferSummaryTextValue"].label, "5,857.17")

        XCTAssertEqual(app.cells.element(boundBy: 17)
            .staticTexts["scheduleTransferSummaryTextLabel"].label, "Fee:")
        XCTAssertEqual(app.cells.element(boundBy: 17)
            .staticTexts["scheduleTransferSummaryTextValue"].label, "2.00")

        XCTAssertEqual(app.cells.element(boundBy: 18)
            .staticTexts["scheduleTransferSummaryTextLabel"].label, "You will receive:")
        XCTAssertEqual(app.cells.element(boundBy: 18)
            .staticTexts["scheduleTransferSummaryTextValue"].label, "5,855.17")

        XCTAssertTrue(transferFundsConfirmation.noteLabel.exists)
        XCTAssertEqual(transferFundsConfirmation.noteDescription.value as? String, "Transfer All")

        mockServer.setupStub(url: "/rest/v3/transfers/trf-token/status-transitions",
                             filename: "TransferStatusQuoted",
                             method: HTTPMethod.post)

        XCTAssertTrue(transferFundsConfirmation.confirmButton.exists)
        transferFundsConfirmation.confirmButton.tap()

        // Assert go back to the menu page
        waitForExistence(transferFundMenu)
        app.scroll(to: transferFundMenu)
        XCTAssertTrue(transferFundMenu.exists)
    }

    //swiftlint:disable line_length
    func testTransferFundsConfirmation_timeOutError() {
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
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "5,855.17")

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundMultiCurrencies",
                             method: HTTPMethod.post)

        transferFunds.nextLabel.tap()

        waitForExistence(transferFundsConfirmation.foreignExchangeSectionLabel)
        XCTAssertEqual(transferFundsConfirmation.foreignExchangeSectionLabel.label, "FOREIGN EXCHANGE")
        XCTAssertEqual(transferFundsConfirmation.summaryTitle.label, "SUMMARY")
        XCTAssertEqual(transferFundsConfirmation.noteLabel.label, "NOTES")

        mockServer.setupStubError(url: "/rest/v3/transfers/trf-token/status-transitions",
                                  filename: "TransferErrorQuoteExpired",
                                  method: HTTPMethod.post)

        transferFundsConfirmation.confirmButton.tap()

        // Assert Transfer Quote Expire error
        waitForExistence(app.alerts["Error"])
        let predicate = NSPredicate(format:
            "label CONTAINS[c] 'The transfer request has expired on Wed Jul 24 21:38:58 GMT 2019. Please create a new transfer and commit it before 120 seconds.'")
        XCTAssert(app.alerts["Error"]
            .staticTexts.element(matching: predicate).exists)
    }

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
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "452.14")

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "CreateTransferWithNoFee",
                             method: HTTPMethod.post)
        transferFunds.nextLabel.tap()

        waitForExistence(transferFundsConfirmation.transferDestinationLabel)
        // Assert confirmation page has no FEE section
        XCTAssertFalse(transferFundsConfirmation.summaryFeeLabel.exists)

        // Summary Section
        XCTAssertTrue(transferFundsConfirmation.summaryTitle.label == "SUMMARY")
        XCTAssertEqual(app.cells.element(boundBy: 8)
            .staticTexts["scheduleTransferSummaryTextLabel"].label, "Amount:")
        XCTAssertEqual(app.cells.element(boundBy: 8).staticTexts["scheduleTransferSummaryTextValue"].label, "5,855.17")
    }

    func testTransferFundsConfirmation_FxChanged() {
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
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "5,855.17")

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundMultiCurrenciesFxChange",
                             method: HTTPMethod.post)

        transferFunds.nextLabel.tap()

        waitForExistence(transferFundsConfirmation.foreignExchangeSectionLabel)
        app.scroll(to: transferFundsConfirmation.confirmButton)
        // Assert the message showing the final amount to be transferred has changed
        XCTAssertTrue(app.otherElements["Due to changes in the FX rate, you will now receive: 5,855.66 USD"].exists)
    }

    /*
     // After the bug fix the test should work
     func testTransferFundsConfirmation_verifySummaryWithZeroFee() {
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
     XCTAssertEqual(transferFunds.transferAmount.value as? String, "452.14")

     mockServer.setupStub(url: "/rest/v3/transfers",
     filename: "CreateTransferWithZeroFee",
     method: HTTPMethod.post)
     transferFunds.nextLabel.tap()

     waitForExistence(transferFundsConfirmation.addSelectDestinationLabel)
     // Assert confirmation page has no FEE section
     XCTAssertFalse(transferFundsConfirmation.summaryFeeLabel.exists)

     // Summary Section
     XCTAssertTrue(transferFundsConfirmation.summaryTitle.label == "SUMMARY")
     XCTAssertEqual(app.cells.element(boundBy: 8)
     .staticTexts["scheduleTransferSummaryTextLabel"].label, "Amount:")
     XCTAssertEqual(app.cells.element(boundBy: 8).staticTexts["scheduleTransferSummaryTextValue"].label, "5,855.17")

     XCTAssertEqual(app.cells.element(boundBy: 9)
     .staticTexts["scheduleTransferSummaryTextLabel"].label, "You will receive:")
     XCTAssertEqual(app.cells.element(boundBy: 9).staticTexts["scheduleTransferSummaryTextValue"].label, "5,855.17")
     }
     */
}
