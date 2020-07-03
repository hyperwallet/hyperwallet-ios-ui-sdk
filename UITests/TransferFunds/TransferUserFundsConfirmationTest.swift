import XCTest

class TransferUserFundsConfirmationTest: BaseTests {
    var transferFundMenu: XCUIElement! {
        return app.tables.cells.containing(.staticText, identifier: "Transfer Funds").element(boundBy: 0)
    }
    var transferFunds: TransferFunds!
    var transferFundsConfirmation: TransferFundsConfirmation!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
        spinner = app.activityIndicators["activityIndicator"]

        transferFunds = TransferFunds(app: app)
        transferFundsConfirmation = TransferFundsConfirmation(app: app)
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

        transferFunds.verifyTransferFundsTitle()

        // Add Destination Section
        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertEqual(transferFunds.addSelectDestinationLabel.label, "Bank Account")

        // Amount row
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "0")
        XCTAssertEqual(transferFunds.transferCurrency.value as? String, "USD")
        XCTAssertEqual(transferFunds.transferAmountLabel.label, "Available funds $452.14 USD")
        // Transfer max funds
        XCTAssertTrue(transferFunds.transferMaxAllFunds.exists, "Transfer all funds switch should exist")
        // tap Transfer max funds
        transferFunds.transferMaxAllFunds.tap()

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.post)

        transferFunds.tapContinueButton()

        waitForExistence(transferFundsConfirmation.transferDestinationLabel)
        XCTAssertTrue(transferFundsConfirmation.tranferToSectionLabel.exists)
        transferFundsConfirmation.verifyDestination(country: "United States", endingDigit: "1234")

        // Assert Summary Section
        let amount = transferFundsConfirmation.getCell(row: 1)
        let fee = transferFundsConfirmation.getCell(row: 2)
        let willReceived = transferFundsConfirmation.getCell(row: 3)
        XCTAssertTrue(amount.exists)
        XCTAssertTrue(fee.exists)
        XCTAssertTrue(willReceived.exists)

        verifySummary()
        XCTAssertTrue(transferFundsConfirmation.scheduleTable.staticTexts["454.14"].exists)
        XCTAssertTrue(transferFundsConfirmation.scheduleTable.staticTexts["2.00"].exists)
        XCTAssertTrue(transferFundsConfirmation.scheduleTable.staticTexts["452.14"].exists)

        // Assert No FX Section
        XCTAssertFalse(transferFundsConfirmation.foreignExchangeSectionLabel.exists)

        XCTAssertTrue(transferFundsConfirmation.noteLabel.exists)
        XCTAssertEqual(transferFundsConfirmation.noteDescription.value as? String, "Partial-Balance Transfer888")

        mockServer.setupStub(url: "/rest/v3/transfers/trf-token/status-transitions",
                             filename: "TransferStatusQuoted",
                             method: HTTPMethod.post)

        // Assert go back to the menu page
        transferFundsConfirmation.scheduleTable.buttons["scheduleTransferLabel"].tap()
        // Assert confirmation alert dialog
        verifyConfirmationSuccess()
        waitForNonExistence(spinner)
    }

    //swiftlint:disable function_body_length
    func testTransferFundsConfirmation_withFX() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListMoreThanOneTransferMethod",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundMultiCurrencies",
                             method: HTTPMethod.post)

        mockServer.setupStub(url: "/rest/v3/transfers/trf-token/status-transitions",
                             filename: "TransferStatusQuoted",
                             method: HTTPMethod.post)

        transferFundMenu.tap()
        waitForNonExistence(spinner)

        transferFunds.verifyTransferFundsTitle()
        // Amount row
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "0")
        XCTAssertEqual(transferFunds.transferCurrency.value as? String, "USD")
        XCTAssertEqual(transferFunds.transferAmountLabel.label, "Available funds $5,855.17 USD")

        transferFunds.transferMaxAllFunds.tap()

        XCTAssertEqual(transferFunds.transferAmount.value as? String, "5,855.17")

        transferFunds.tapContinueButton()

        waitForExistence(transferFundsConfirmation.transferDestinationLabel)
        // 1.  Add Destination Section
        transferFundsConfirmation.verifyDestination(country: "United States", endingDigit: "1234")

        // 2.Exchange Rate Section
        let youSell = transferFundsConfirmation.foreignExchangeSellLabel
        let youBuy = transferFundsConfirmation.foreignExchangeBuyLabel
        let exchangeRate = transferFundsConfirmation.foreignExchangeRateLabel
        XCTAssertTrue(transferFundsConfirmation.foreignExchangeSectionLabel.label == "mobileFXlabel".localized())
        XCTAssertTrue(app.cells.element(boundBy: 1).staticTexts[youSell].exists)
        XCTAssertTrue(app.cells.element(boundBy: 1).staticTexts["9,992.50 MYR"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 2).staticTexts[youBuy].exists)
        XCTAssertTrue(app.cells.element(boundBy: 2).staticTexts["2,337.93 USD"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 3).staticTexts[exchangeRate].exists)
        XCTAssertTrue(app.cells.element(boundBy: 3).staticTexts["1 MYR = 0.233968 USD"].exists)

        XCTAssertTrue(app.cells.element(boundBy: 5).staticTexts[youSell].exists)
        XCTAssertTrue(app.cells.element(boundBy: 5).staticTexts["1,464.53 CAD"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 6).staticTexts[youBuy].exists)
        XCTAssertTrue(app.cells.element(boundBy: 6).staticTexts["1,134.13 USD"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 7).staticTexts[exchangeRate].exists)
        XCTAssertTrue(app.cells.element(boundBy: 7).staticTexts["1 CAD = 0.774399 USD"].exists)

        XCTAssertTrue(app.cells.element(boundBy: 9).staticTexts[youSell].exists)
        XCTAssertTrue(app.cells.element(boundBy: 9).staticTexts["50,000 KRW"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 10).staticTexts[youBuy].exists)
        XCTAssertTrue(app.cells.element(boundBy: 10).staticTexts["42.76 USD"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 11).staticTexts[exchangeRate].exists)
        XCTAssertTrue(app.cells.element(boundBy: 11).staticTexts["1 KRW = 0.000855 USD"].exists)

        XCTAssertTrue(app.cells.element(boundBy: 13).staticTexts[youSell].exists)
        XCTAssertTrue(app.cells.element(boundBy: 13).staticTexts["1,000.00 EUR"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 14).staticTexts[youBuy].exists)
        XCTAssertTrue(app.cells.element(boundBy: 14).staticTexts["1,135.96 USD"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 15).staticTexts[exchangeRate].exists)
        XCTAssertTrue(app.cells.element(boundBy: 15).staticTexts["1 EUR = 1.135960 USD"].exists)

        // 3. Summary Section
        verifySummary()
        XCTAssertEqual(app.cells.element(boundBy: 16)
            .staticTexts["scheduleTransferSummaryTextValue"].label, "5,857.17")
        XCTAssertEqual(app.cells.element(boundBy: 17)
            .staticTexts["scheduleTransferSummaryTextValue"].label, "2.00")
        XCTAssertEqual(app.cells.element(boundBy: 18)
            .staticTexts["scheduleTransferSummaryTextValue"].label, "5,855.17")

        XCTAssertTrue(transferFundsConfirmation.noteLabel.exists)
        XCTAssertEqual(transferFundsConfirmation.noteDescription.value as? String, "Transfer All")

        //transferFundsConfirmation.tapConfirmButton()
        let button = transferFundsConfirmation.scheduleTable.buttons["scheduleTransferLabel"]
        app.scroll(to: button)
        button.tap()

        verifyConfirmationSuccess()
        waitForNonExistence(spinner)
    }

    //swiftlint:disable line_length
    func testTransferFundsConfirmation_timeOutError() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListMoreThanOneTransferMethod",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundMultiCurrencies",
                             method: HTTPMethod.post)

        mockServer.setupStubError(url: "/rest/v3/transfers/trf-token/status-transitions",
                                  filename: "TransferErrorQuoteExpired",
                                  method: HTTPMethod.post)

        transferFundMenu.tap()
        waitForNonExistence(spinner)

        transferFunds.verifyTransferFundsTitle()
        // Amount row
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "0")
        XCTAssertEqual(transferFunds.transferCurrency.value as? String, "USD")
        XCTAssertEqual(transferFunds.transferAmountLabel.label, "Available funds $5,855.17 USD")

        transferFunds.transferMaxAllFunds.tap()
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "5,855.17")
        transferFunds.tapContinueButton()

        waitForExistence(transferFundsConfirmation.foreignExchangeSectionLabel)
        XCTAssertEqual(transferFundsConfirmation.foreignExchangeSectionLabel.label, "mobileFXlabel".localized())
        XCTAssertEqual(transferFundsConfirmation.summaryTitle.label, "mobileSummaryLabel".localized())
        XCTAssertEqual(transferFundsConfirmation.noteLabel.label, "mobileNoteLabel".localized())

        let button = transferFundsConfirmation.scheduleTable.buttons["scheduleTransferLabel"]
        app.scroll(to: button)
        button.tap()

        // Assert Transfer Quote Expire error
        waitForExistence(app.alerts["Error"])
        let predicate = NSPredicate(format:
            "label CONTAINS[c] 'The transfer request has expired on Wed Jul 24 21:38:58 GMT 2019. Please create a new transfer and commit it before 120 seconds.'")
        XCTAssert(app.alerts["Error"].staticTexts.element(matching: predicate).exists)
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

        transferFunds.verifyTransferFundsTitle()
        // Amount row
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "0")
        XCTAssertEqual(transferFunds.transferCurrency.value as? String, "USD")
        XCTAssertEqual(transferFunds.transferAmountLabel.label, "Available funds $452.14 USD")

        transferFunds.transferMaxAllFunds.tap()
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "452.14")
        transferFunds.tapContinueButton()

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "CreateTransferWithNoFee",
                             method: HTTPMethod.post)

        waitForExistence(transferFundsConfirmation.transferDestinationLabel)

        // Summary Section
        XCTAssertEqual(transferFundsConfirmation.summaryTitle.label, "mobileSummaryLabel".localized())
        XCTAssertEqual(transferFundsConfirmation.summaryAmount.label, transferFundsConfirmation.summaryAmountLabel)

        // Assert confirmation page has no FEE section
        XCTAssertFalse(transferFundsConfirmation.summaryFee.exists)

        let button = transferFundsConfirmation.scheduleTable.buttons["scheduleTransferLabel"]
        app.scroll(to: button)
        XCTAssertTrue(button.exists)
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

        transferFunds.verifyTransferFundsTitle()
        // Amount row
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "0")
        XCTAssertEqual(transferFunds.transferCurrency.value as? String, "USD")
        XCTAssertEqual(transferFunds.transferAmountLabel.label, "Available funds $5,855.17 USD")

        // Add Destination Section
        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertEqual(transferFunds.addSelectDestinationLabel.label, "Bank Account")

        transferFunds.transferMaxAllFunds.tap()
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "5,855.17")

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundMultiCurrenciesFxChange",
                             method: HTTPMethod.post)

        transferFunds.tapContinueButton()

        waitForExistence(transferFundsConfirmation.foreignExchangeSectionLabel)
        let button = transferFundsConfirmation.scheduleTable.buttons["scheduleTransferLabel"]
        app.scroll(to: button)
        XCTAssertTrue(button.exists)

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
     transferFunds.tapNextButton()
     
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

    private func verifySummary() {
        XCTAssertEqual(transferFundsConfirmation.summaryTitle.label, "mobileSummaryLabel".localized())
        XCTAssertEqual(transferFundsConfirmation.summaryAmount.label, transferFundsConfirmation.summaryAmountLabel)
        XCTAssertEqual(transferFundsConfirmation.summaryFee.label, transferFundsConfirmation.summaryFeeLabel)
        XCTAssertEqual(transferFundsConfirmation.summaryReceive.label, transferFundsConfirmation.summaryReceiveLabel)
    }

    private func verifyConfirmationSuccess() {
        let messageTitle = "mobileTransferSuccessMsg".localized()
        let messagePlaceholder = "mobileTransferSuccessDetails".localized()
        let message = String(format: messagePlaceholder, "Bank Account")
        let alert = app.alerts[messageTitle]
        waitForExistence(app.alerts[messageTitle])
        let predicate = NSPredicate(format:
            "label CONTAINS[c] '\(message)'")
        XCTAssert(alert.staticTexts.element(matching: predicate).exists)

        alert.buttons["doneButtonLabel".localized()].tap()
    }
}
