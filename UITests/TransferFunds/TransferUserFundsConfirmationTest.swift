import XCTest

class TransferUserFundsConfirmationTest: BaseTests {
    var transferFundMenu: XCUIElement! {
        return app.tables.cells.containing(.staticText, identifier: "Transfer Funds").element(boundBy: 0)
    }
    var transferFunds: TransferFunds!
    var transferFundSourceMenu: XCUIElement!
    var transferFundsConfirmation: TransferFundsConfirmation!
    let listppcUrl = "/rest/v3/users/usr-token/prepaid-cards"
    let venmoAccount = "Venmo Account"

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
        spinner = app.activityIndicators["activityIndicator"]

        transferFunds = TransferFunds(app: app)
        transferFundSourceMenu = app.tables.cells
            .containing(.staticText, identifier: "Transfer Funds Source")
            .element(boundBy: 0)
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
        XCTAssertEqual(transferFunds.transferAmountLabel.label,
                       String(format: "mobileAvailableBalance".localized(), "$", "452.14", "USD"))
        // Transfer max funds
        XCTAssertTrue(transferFunds.transferMaxAllFunds.exists, "Transfer all funds switch should exist")
        // tap Transfer max funds
        transferFunds.transferMaxAllFunds.doubleTap()

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

        let button = transferFundsConfirmation.scheduleTable.buttons["scheduleTransferLabel"]
        app.scroll(to: button)
        button.tap()

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
        XCTAssertEqual(transferFunds.transferAmountLabel.label,
                       String(format: "mobileAvailableBalance".localized(), "$", "5,855.17", "USD"))

        transferFunds.transferMaxAllFunds.doubleTap()

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
        XCTAssertTrue(app.cells.element(boundBy: 2).staticTexts[youSell].exists)
        XCTAssertTrue(app.cells.element(boundBy: 2).staticTexts["9,992.50 MYR"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 3).staticTexts[youBuy].exists)
        XCTAssertTrue(app.cells.element(boundBy: 3).staticTexts["2,337.93 USD"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 4).staticTexts[exchangeRate].exists)
        XCTAssertTrue(app.cells.element(boundBy: 4).staticTexts["1 MYR = 0.233968 USD"].exists)

        XCTAssertTrue(app.cells.element(boundBy: 6).staticTexts[youSell].exists)
        XCTAssertTrue(app.cells.element(boundBy: 6).staticTexts["1,464.53 CAD"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 7).staticTexts[youBuy].exists)
        XCTAssertTrue(app.cells.element(boundBy: 7).staticTexts["1,134.13 USD"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 8).staticTexts[exchangeRate].exists)
        XCTAssertTrue(app.cells.element(boundBy: 8).staticTexts["1 CAD = 0.774399 USD"].exists)

        XCTAssertTrue(app.cells.element(boundBy: 10).staticTexts[youSell].exists)
        XCTAssertTrue(app.cells.element(boundBy: 10).staticTexts["50,000 KRW"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 11).staticTexts[youBuy].exists)
        XCTAssertTrue(app.cells.element(boundBy: 11).staticTexts["42.76 USD"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 12).staticTexts[exchangeRate].exists)
        XCTAssertTrue(app.cells.element(boundBy: 12).staticTexts["1 KRW = 0.000855 USD"].exists)

        XCTAssertTrue(app.cells.element(boundBy: 14).staticTexts[youSell].exists)
        XCTAssertTrue(app.cells.element(boundBy: 14).staticTexts["1,000.00 EUR"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 15).staticTexts[youBuy].exists)
        XCTAssertTrue(app.cells.element(boundBy: 15).staticTexts["1,135.96 USD"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 16).staticTexts[exchangeRate].exists)
        XCTAssertTrue(app.cells.element(boundBy: 16).staticTexts["1 EUR = 1.135960 USD"].exists)

        // 3. Summary Section
        verifySummary()
        XCTAssertEqual(app.cells.element(boundBy: 17)
            .staticTexts["scheduleTransferSummaryTextValue"].label, "5,857.17")
        XCTAssertEqual(app.cells.element(boundBy: 18)
            .staticTexts["scheduleTransferSummaryTextValue"].label, "2.00")
        XCTAssertEqual(app.cells.element(boundBy: 19)
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

    //Tranfer Venmo Manage method
    func testTransferFundsConfirmationVenmo_withFX() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodMoreThanOneVenmo",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundsVenmoDetails",
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
        XCTAssertEqual(transferFunds.transferAmountLabel.label,
                       String(format: "mobileAvailableBalance".localized(), "$", "5,855.17", "USD"))
        transferFunds.transferMaxAllFunds.doubleTap()

        //verify venmo destination
        waitForExistence(transferFunds.addSelectDestinationLabel)
        XCTAssertEqual(transferFunds.addSelectDestinationLabel.label, venmoAccount)

        XCTAssertEqual(transferFunds.transferAmount.value as? String, "5,855.17")

        transferFunds.tapContinueButton()

        waitForExistence(transferFundsConfirmation.transferDestinationLabel)

        // 1.  Add Destination Section
        XCTAssertEqual(transferFundsConfirmation.transferDestinationLabel.label, venmoAccount)
        transferFundsConfirmation.verifyDestination(country: "United States", endingDigit: "5555")

        // 3. Summary Section
        verifySummary()

        XCTAssertTrue(transferFundsConfirmation.noteLabel.exists)
        XCTAssertEqual(transferFundsConfirmation.noteDescription.value as? String, "Transfer All")

        //transferFundsConfirmation.tapConfirmButton()
        let button = transferFundsConfirmation.scheduleTable.buttons["scheduleTransferLabel"]
        app.scroll(to: button)
        button.tap()

        verifyConfirmationSuccessVenmo()
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
        XCTAssertEqual(transferFunds.transferAmountLabel.label,
                       String(format: "mobileAvailableBalance".localized(), "$", "5,855.17", "USD"))

        transferFunds.transferMaxAllFunds.doubleTap()
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
        XCTAssertEqual(transferFunds.transferAmountLabel.label,
                       String(format: "mobileAvailableBalance".localized(), "$", "5,855.17", "USD"))

        // Add Destination Section
        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertEqual(transferFunds.addSelectDestinationLabel.label, "Bank Account")

        transferFunds.transferMaxAllFunds.doubleTap()
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
        XCTAssertTrue(app.otherElements["Due to changes in the exchange rate, you'll now receive: 5,855.66 USD"].exists)
    }

    // Transfer with no fee section test
    func testTransferFundsConfirmation_verifySummaryWithZeroFee() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods", filename: "ListMoreThanOneTransferMethod", method: HTTPMethod.get)
        mockServer.setupStub(url: "/rest/v3/transfers", filename: "AvailableFundUSD", method: HTTPMethod.post)

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

        // Tap to insert max amounts to transfer
        transferFunds.transferMaxAllFunds.doubleTap()

        // Assert Destination Amount is automatically insert into the amount field
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "452.14")

        mockServer.setupStub(url: "/rest/v3/transfers", filename: "CreateTransferWithZeroFee", method: HTTPMethod.post)

        // Navigate to Confirmation Detail
        transferFunds.tapContinueButton()

        // 1.  Add Destination Section
        transferFundsConfirmation.verifyDestination(country: "United States", endingDigit: "1234")

        // Assert confirmation page has no FEE section)
        XCTAssertFalse(transferFundsConfirmation.summaryFee.exists)

        // NOTE Section
        XCTAssertTrue(transferFundsConfirmation.noteLabel.exists)
        XCTAssertEqual(transferFundsConfirmation.noteDescription.value as? String, "Transfer All without fee - show No fee!")
    }

    // MARK: PPC is the transfer source
    /*
     Given that user selects Prepaid Card for Transfer From
     When create transfer to a Bank Account with different currency from the PPC
     Then user can create transfer successfully
     */
    // swiftlint:disable function_body_length
    func testTransferFunds_TransferFromPrimaryPPCWithFX() {
        // Response for Transfer methods list
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListMoreThanOneTransferMethod",
                             method: HTTPMethod.get)

        // Quoted Available funds has different currencies
        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundMultiCurrencies",
                             method: HTTPMethod.post)

        // Quote response from Confirm button
        mockServer.setupStub(url: "/rest/v3/transfers/trf-token/status-transitions",
                             filename: "TransferStatusQuoted",
                             method: .post)

        // List the available PPC of the user to select from source
        mockServer.setupStub(url: listppcUrl,
                             filename: "PrepaidCardPrimaryOnlyResponse",
                             method: HTTPMethod.get)

        XCTAssertTrue(transferFundSourceMenu.exists)
        transferFundSourceMenu.tap()

        waitForNonExistence(spinner)
        transferFunds.verifyTransferFundsTitle()

        // Transfer From
        transferFunds.verifyTransferFrom(isAvailableFunds: true)

        // assert NOTE
        XCTAssertTrue(transferFunds.notesSectionLabel.exists)

        // assert Continue button
        app.scroll(to: transferFunds.nextLabel)
        XCTAssertTrue(transferFunds.nextLabel.exists)

        // Select PPC as transfer source
        transferFunds.transferSourceTitleLabel.tap()
        let ppcCell = app.tables.element.children(matching: .cell).element(boundBy: 1)
        ppcCell.tap()

        // Enter transfer amount
        transferFunds.transferMaxAllFunds.doubleTap()

        // Navigate to Confirmation Detail
        transferFunds.tapContinueButton()

        waitForNonExistence(spinner)

        waitForExistence(transferFundsConfirmation.tranferFromSectionLabel)
        // Transfer from
        transferFundsConfirmation.verifyTransferFrom(isAvailableFunds: false)
        transferFundsConfirmation.verifyPPCInfo(brandType: transferFunds.prepaidCardVisa, endingDigit: "9285")

        // 1.  Add Destination Section
        transferFundsConfirmation.verifyDestination(country: "United States", endingDigit: "1234")

        // 2.Exchange Rate Section
        verifyForeignExchangeSection()

        // 3. Summary Section
        transferFundsConfirmation.verifySummary()
        XCTAssertEqual(app.cells.element(boundBy: 17)
            .staticTexts["scheduleTransferSummaryTextValue"].label, "5,857.17")
        XCTAssertEqual(app.cells.element(boundBy: 18)
            .staticTexts["scheduleTransferSummaryTextValue"].label, "2.00")
        XCTAssertEqual(app.cells.element(boundBy: 19)
            .staticTexts["scheduleTransferSummaryTextValue"].label, "5,855.17")

        // 4. Note Section
        XCTAssertTrue(transferFundsConfirmation.noteLabel.exists)
        XCTAssertEqual(transferFundsConfirmation.noteDescription.value as? String, "Transfer All")

        mockServer.setupStub(url: "/rest/v3/transfers/trf-token/status-transitions",
                             filename: "TransferStatusQuoted",
                             method: HTTPMethod.post)

        // 5. Confirmation Button
        let button = transferFundsConfirmation.scheduleTable.buttons["scheduleTransferLabel"]
        app.scroll(to: button)
        button.tap()

        // Verify Confirmation Success Dialog
        waitForExistence(transferFundsConfirmation.successAlert)
        transferFundsConfirmation.verifyConfirmationSuccess()
    }

    // MARK: Helper methods
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

    private func verifyConfirmationSuccessVenmo() {
        let messageTitle = "mobileTransferSuccessMsg".localized()
        let messagePlaceholder = "mobileTransferSuccessDetails".localized()
        let message = String(format: messagePlaceholder, venmoAccount)
        let alert = app.alerts[messageTitle]
        waitForExistence(app.alerts[messageTitle])
        let predicate = NSPredicate(format:
            "label CONTAINS[c] '\(message)'")
        XCTAssert(alert.staticTexts.element(matching: predicate).exists)

        alert.buttons["doneButtonLabel".localized()].tap()
    }

    private func verifyForeignExchangeSection() {
        // 2.Exchange Rate Section
        // From
        let youSell = transferFundsConfirmation.foreignExchangeSellLabel
        // To
        let youBuy = transferFundsConfirmation.foreignExchangeBuyLabel
        let exchangeRate = transferFundsConfirmation.foreignExchangeRateLabel
        XCTAssertTrue(transferFundsConfirmation.foreignExchangeSectionLabel.label == "mobileFXlabel".localized())

        XCTAssertTrue(app.cells.element(boundBy: 2).staticTexts[youSell].exists)
        XCTAssertTrue(app.cells.element(boundBy: 2).staticTexts["9,992.50 MYR"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 3).staticTexts[youBuy].exists)
        XCTAssertTrue(app.cells.element(boundBy: 3).staticTexts["2,337.93 USD"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 4).staticTexts[exchangeRate].exists)
        XCTAssertTrue(app.cells.element(boundBy: 4).staticTexts["1 MYR = 0.233968 USD"].exists)

        XCTAssertTrue(app.cells.element(boundBy: 6).staticTexts[youSell].exists)
        XCTAssertTrue(app.cells.element(boundBy: 6).staticTexts["1,464.53 CAD"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 7).staticTexts[youBuy].exists)
        XCTAssertTrue(app.cells.element(boundBy: 7).staticTexts["1,134.13 USD"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 8).staticTexts[exchangeRate].exists)
        XCTAssertTrue(app.cells.element(boundBy: 8).staticTexts["1 CAD = 0.774399 USD"].exists)

        XCTAssertTrue(app.cells.element(boundBy: 10).staticTexts[youSell].exists)
        XCTAssertTrue(app.cells.element(boundBy: 10).staticTexts["50,000 KRW"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 11).staticTexts[youBuy].exists)
        XCTAssertTrue(app.cells.element(boundBy: 11).staticTexts["42.76 USD"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 12).staticTexts[exchangeRate].exists)
        XCTAssertTrue(app.cells.element(boundBy: 12).staticTexts["1 KRW = 0.000855 USD"].exists)

        XCTAssertTrue(app.cells.element(boundBy: 14).staticTexts[youSell].exists)
        XCTAssertTrue(app.cells.element(boundBy: 14).staticTexts["1,000.00 EUR"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 15).staticTexts[youBuy].exists)
        XCTAssertTrue(app.cells.element(boundBy: 15).staticTexts["1,135.96 USD"].exists)
        XCTAssertTrue(app.cells.element(boundBy: 16).staticTexts[exchangeRate].exists)
        XCTAssertTrue(app.cells.element(boundBy: 16).staticTexts["1 EUR = 1.135960 USD"].exists)
    }
}
