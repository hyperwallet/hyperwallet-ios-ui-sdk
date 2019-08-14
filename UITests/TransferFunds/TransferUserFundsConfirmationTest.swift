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
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "5,855.17")

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundMultiCurrencies",
                             method: HTTPMethod.post)

        transferFunds.nextLabel.tap()

        // TODO: Assert the Confirmation Page
        // 1.  Add Destination Section
        // 2.  Exchange Rate Section
        // 3. Summary Section
        // >>> Please insert your assertion codes here

         XCTAssertTrue(app.tables["scheduleTransferTableView"].cells.staticTexts["9,992.50 MYR"].exists)

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
        XCTAssert(app.alerts["Error"].exists)
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
