import XCTest

class TransferUserFundsTest: BaseTests {
    var transferFundMenu: XCUIElement!
    var transferFunds: TransferFunds!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
        spinner = app.activityIndicators["activityIndicator"]
        transferFundMenu = app.tables.cells
            .containing(.staticText, identifier: "Transfer Funds")
            .element(boundBy: 0)
        transferFunds = TransferFunds(app: app)
    }

    override func tearDown() {
        mockServer.tearDown()
    }

    /*
     Given that no Transfer methods have been created
     When module is loaded
     Then the user will have the ability to create a method
     */
    func testTransferFunds_noTransferMethod() {
        mockServer.setUpEmptyResponse(url: "/rest/v3/users/usr-token/transfer-methods")

        XCTAssertTrue(transferFundMenu.exists)
        transferFundMenu.tap()
        waitForNonExistence(spinner)

        // Assert Add Destination Section
        // how to we assert the icon
        XCTAssertTrue(transferFunds.transferFundTitle.exists)
        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertEqual(transferFunds.addSelectDestinationLabel.label, "Add Account")
        XCTAssertEqual(transferFunds.addSelectDestinationDetailLabel.label,
                       "An account hasn\'t been set up yet, please add an account first.")

        XCTAssertFalse(transferFunds.transferCurrency.exists, "Transfer Currency should not exist")
    }

    /*
     Given that Transfer methods exist
     When module is loaded
     Then first available transfer method will be selected
     */
    func testTransferFunds_firstAvailableMethodIsSelected() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListMoreThanOneTransferMethod",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.post)

        XCTAssertTrue(transferFundMenu.exists)
        transferFundMenu.tap()
        waitForNonExistence(spinner)

        // Add Destination Section
        XCTAssertTrue(transferFunds.transferFundTitle.exists)
        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertEqual(transferFunds.addSelectDestinationLabel.label, "Bank Account")

        if #available(iOS 11.0, *) {
            XCTAssertEqual(transferFunds.addSelectDestinationDetailLabel.label, "United States\nEnding on 1234")
        } else {
            XCTAssertEqual(transferFunds.addSelectDestinationDetailLabel.label, "United States Ending on 1234")
        }
        // Transfer Section
        XCTAssertTrue(transferFunds.transferSectionLabel.exists)
        // Amount row
        XCTAssertEqual(transferFunds.transferAmountLabel.label, "Amount")
        XCTAssertEqual(transferFunds.transferCurrency.label, "USD")
        // Transfer all funds row
        XCTAssertEqual(transferFunds.transferAllFundsLabel.label, "Transfer all funds")
        XCTAssertTrue(transferFunds.transferAllFundsSwitch.exists, "Transfer all funds switch should exist")

        // Notes
        XCTAssertTrue(transferFunds.notesSectionLabel.exists)
        XCTAssertEqual(transferFunds.notesDescriptionTextField.placeholderValue, "Description")

        let availableFunds = app.tables["createTransferTableView"].staticTexts["Available for transfer: 452.14"]
        XCTAssertTrue(availableFunds.exists)

        // Next Button
        XCTAssertTrue(transferFunds.nextLabel.exists)
    }

    /*
     Given that Transfer methods exist
     When user select a different transfer method with different currency
     Then the destination currency should be updated AND Then Payee can enter the amount
     */
    func testTransferFunds_switchTransferMethod_Currency() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListMoreThanOneTransferMethod",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.post)

        XCTAssertTrue(transferFundMenu.exists)
        transferFundMenu.tap()
        waitForNonExistence(spinner)

        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertEqual(transferFunds.addSelectDestinationLabel.label, "Bank Account")
        // Amount row
        XCTAssertEqual(transferFunds.transferAmountLabel.label, "Amount")
        XCTAssertEqual(transferFunds.transferCurrency.label, "USD")
        // Select Destination (CAD)
        let cadBankAccount = app.tables.element.children(matching: .cell).element(boundBy: 1)
        cadBankAccount.tap()
        XCTAssertEqual(transferFunds.transferCurrency.label, "CAD")
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

        XCTAssertTrue(transferFundMenu.exists)
        transferFundMenu.tap()
        waitForNonExistence(spinner)

        // Add Destination Section
        XCTAssertTrue(transferFunds.transferFundTitle.exists)
        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertEqual(transferFunds.addSelectDestinationLabel.label, "Prepaid Card")

        if #available(iOS 11.0, *) {
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

    func testTransferFund_createTransferWithAllFunds() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListOneBankAccountTransferUSD",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "CreateTransferWithFX",
                             method: HTTPMethod.post)

        XCTAssertTrue(transferFundMenu.exists)
        transferFundMenu.tap()
        waitForNonExistence(spinner)

        XCTAssertEqual(transferFunds.transferAmountLabel.label, "Amount")
        XCTAssertEqual(transferFunds.transferCurrency.label, "USD")
        // Transfer all funds row
        XCTAssertEqual(transferFunds.transferAllFundsLabel.label, "Transfer all funds")
        XCTAssertTrue(transferFunds.transferAllFundsSwitch.exists, "Transfer all funds switch should exist")
        // Assert the full amount
        let availableFunds = app.tables["createTransferTableView"].staticTexts["Available for transfer: 15.00"]
        XCTAssertTrue(availableFunds.exists)
        // Turn on the Transfer All Funds Switch
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "")
        transferFunds.transferAllFundsSwitch.tap()
        // Assert Destination Amount is automatically insert into the amount field
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "15.00")
    }

    /* Given that User has 2 bank accounts which has different Currency from the Source.
     When user transfer the fund
     Then the user should see 2 FX quotes
     */
    // Transfer Requiring more than 2 FX
    func testTransferFund_createTransferWithFX() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListOneBankAccountTransferUSD",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.post)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "CreateTransferWithFX",
                             method: HTTPMethod.get)

        XCTAssertTrue(transferFundMenu.exists)
        transferFundMenu.tap()
        waitForNonExistence(spinner)

        // Add Destination Section
        XCTAssertTrue(transferFunds.transferFundTitle.exists)
        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertEqual(transferFunds.addSelectDestinationLabel.label, "Bank Account")

        if #available(iOS 11.0, *) {
            XCTAssertEqual(transferFunds.addSelectDestinationDetailLabel.label, "United States\nEnding on 6789")
        } else {
            XCTAssertEqual(transferFunds.addSelectDestinationDetailLabel.label, "United States Ending on 6789")
        }
        // Transfer Section
        XCTAssertTrue(transferFunds.transferSectionLabel.exists)
        // Amount row
        XCTAssertEqual(transferFunds.transferAmountLabel.label, "Amount")
        XCTAssertEqual(transferFunds.transferCurrency.label, "USD")
        // Transfer all funds row
        XCTAssertEqual(transferFunds.transferAllFundsLabel.label, "Transfer all funds")
        XCTAssertTrue(transferFunds.transferAllFundsSwitch.exists, "Transfer all funds switch should exist")

        // Notes
        XCTAssertTrue(transferFunds.notesSectionLabel.exists)
        XCTAssertEqual(transferFunds.notesDescriptionTextField.placeholderValue, "Description")

        let availableFunds = app.tables["createTransferTableView"].staticTexts["Available for transfer: 452.14"]
        XCTAssertTrue(availableFunds.exists)

        // Next Button
        XCTAssertTrue(transferFunds.nextLabel.exists)
        // transferFunds.nextLabel.tap()
    }

    func testTransferFund_createTransferWithoutFX() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListOneBankAccountTransferUSD",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.post)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "CreateTransferWithoutFX",
                             method: HTTPMethod.get)

        XCTAssertTrue(transferFundMenu.exists)
        transferFundMenu.tap()
        waitForNonExistence(spinner)

        // Add Destination Section
        XCTAssertTrue(transferFunds.transferFundTitle.exists)
        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertEqual(transferFunds.addSelectDestinationLabel.label, "Bank Account")

        if #available(iOS 11.0, *) {
            XCTAssertEqual(transferFunds.addSelectDestinationDetailLabel.label, "United States\nEnding on 6789")
        } else {
            XCTAssertEqual(transferFunds.addSelectDestinationDetailLabel.label, "United States Ending on 6789")
        }
        // Transfer Section
        XCTAssertTrue(transferFunds.transferSectionLabel.exists)
        // Amount row
        XCTAssertEqual(transferFunds.transferAmountLabel.label, "Amount")
        XCTAssertTrue(transferFunds.transferAmount.exists)
        XCTAssertEqual(transferFunds.transferCurrency.label, "USD")
        // Transfer all funds row
        XCTAssertEqual(transferFunds.transferAllFundsLabel.label, "Transfer all funds")
        XCTAssertTrue(transferFunds.transferAllFundsSwitch.exists, "Transfer all funds switch should exist")

        // Notes
        XCTAssertTrue(transferFunds.notesSectionLabel.exists)
        XCTAssertEqual(transferFunds.notesDescriptionTextField.placeholderValue, "Description")

        let availableFunds = app.tables["createTransferTableView"].staticTexts["Available for transfer: 452.14"]
        XCTAssertTrue(availableFunds.exists)

        // Next Button
        XCTAssertTrue(transferFunds.nextLabel.exists)
        // transferFunds.nextLabel.tap()
    }

    /*
     Given thatTransfer methods exist
     AND PrepaidCard Transfer method is selected
     When Payee enters the amount
     Then Next button is enabled
     */
    func testTransferFunds_createTransferDestinationAmount_JPY() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListOneBankAccountTransferJPY",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundJPY",
                             method: HTTPMethod.get)

        XCTAssertTrue(transferFundMenu.exists)
        transferFundMenu.tap()
        waitForNonExistence(spinner)

        XCTAssertTrue(transferFunds.transferFundTitle.exists)
        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertEqual(transferFunds.addSelectDestinationLabel.label, "Bank Account")

        XCTAssertEqual(transferFunds.transferSectionLabel.label, "TRANSER")
        XCTAssertEqual(transferFunds.transferAmountLabel.label, "Amount")
        XCTAssertEqual(transferFunds.transferCurrency.label, "JPY")

        //let availableFunds = app.tables["createTransferTableView"].staticTexts["Available for transfer: 10000"]
        //XCTAssertTrue(availableFunds.exists)
    }

    /* Given that user is on the Transfer fund page and selected a Transfer Destination
     When user enter the digit for the transfer amount
     Then amount field will be formatted correctly
     */
    func testTransferFund_createTransferWhenDestinationAmountIsSet() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListOneBankAccountTransferUSD",
                             method: HTTPMethod.get)
        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.post)

        XCTAssertTrue(transferFundMenu.exists)
        transferFundMenu.tap()
        waitForNonExistence(spinner)

        XCTAssertTrue(transferFunds.transferFundTitle.exists)
        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertEqual(transferFunds.addSelectDestinationLabel.label, "Bank Account")

        XCTAssertTrue(transferFunds.transferAmount.exists)
        transferFunds.transferAmount.tap()
        transferFunds.transferAmount.typeText("9")
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "0.09")
        transferFunds.transferAmount.typeText("4")
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "0.94")
        transferFunds.transferAmount.typeText("2")
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "9.42")
        transferFunds.transferAmount.typeText("3")
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "94.23")
    }

    // This testcase for next sprint
    /*
    func testTransferFund_createTransferWhenDestinationAmountNotSet() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListOneBankAccountTransferUSD",
                             method: HTTPMethod.get)
        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.post)

        XCTAssertTrue(transferFundMenu.exists)
        transferFundMenu.tap()
        waitForNonExistence(spinner)

        // Assert NEXT button is disabled ??
    }
    */

    // This testcase for next sprint
    /*
    func testTransferFund_createTransferWhenDestinationNotSet() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListOneBankAccountTransferUSD",
                             method: HTTPMethod.get)
        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.post)

        XCTAssertTrue(transferFundMenu.exists)
        transferFundMenu.tap()
        waitForNonExistence(spinner)

        // Assert NEXT button is disabled ??
    }
    */

    /* Given that Transfer methods exist
     When user transfers the fund
     Then the over limit error occurs and the app should display the error
     (Your attempted transaction has exceeded the approved payout limit)
     If someone transfers > what is maximally transferable by the account eg, CAD limit is $99,999
     */
    func testTransferFunds_createTransferOverLimitError() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListOneBankAccountTransferUSD",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.post)

        XCTAssertTrue(transferFundMenu.exists)
        transferFundMenu.tap()
        waitForNonExistence(spinner)

        XCTAssertTrue(transferFunds.transferFundTitle.exists)
        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertTrue(transferFunds.transferAmount.exists)
        transferFunds.enterTransferAmount(amount: "10000000000")

        // Next Button
        XCTAssertTrue(transferFunds.nextLabel.exists)
        transferFunds.nextLabel.tap()

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "TransferErrorLimitExceeded",
                             method: HTTPMethod.post)

        XCTAssert(app.alerts["Error"].exists)
        let predicate = NSPredicate(format:
            "label CONTAINS[c] 'Your attempted transaction has exceeded the approved payout limit; please contact Hyperwallet for further assistance.'")
        XCTAssert(app.alerts["Error"].staticTexts.element(matching: predicate).exists)
    }

    /* Given that Transfer methods exist And insufficient funds to transfer
     When user transfers the fund
     Then Amount Less than fee error occurs and the app should display the error
     */
    func testTransferFund_createTransferInsufficientFundsError() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListMoreThanOneTransferMethod",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundInsufficient",
                             method: HTTPMethod.post)

        XCTAssertTrue(transferFundMenu.exists)
        transferFundMenu.tap()
        waitForNonExistence(spinner)

        XCTAssertTrue(transferFunds.transferFundTitle.exists)
        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertTrue(transferFunds.transferAmount.exists)
        transferFunds.enterTransferAmount(amount: "1000000")

        // Next Button
        XCTAssertTrue(transferFunds.nextLabel.exists)
        transferFunds.nextLabel.tap()

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "TransferErrorOverAvailableFund",
                             method: HTTPMethod.post)

        XCTAssert(app.alerts["Error"].exists)
        let predicate = NSPredicate(format:
            "label CONTAINS[c] 'You do not have enough funds in any single currency to complete this transfer'")
        XCTAssert(app.alerts["Error"].staticTexts.element(matching: predicate).exists)
    }

    /* Given that Transfer methods exist And there is NO available fund
     When user tabs on the Transfer Fund menu
     Then will see the error
     */
    func testTransferFund_createTransferMinimumAmountError() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListOneBankAccountTransferUSD",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundZero",
                             method: HTTPMethod.post)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "TransferErrorAmountLessThanFee",
                             method: HTTPMethod.post)

        XCTAssertTrue(transferFundMenu.exists)
        transferFundMenu.tap()
        waitForNonExistence(spinner)

        XCTAssert(app.alerts["Error"].exists)
        let predicate = NSPredicate(format:
            "label CONTAINS[c] 'Amount is less than the fee amount'")
        XCTAssert(app.alerts["Error"].staticTexts.element(matching: predicate).exists)
    }

    func testTransferFund_createTransferInvalidSourceError() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "InvalidSourceError",
                             method: HTTPMethod.get)

        XCTAssertTrue(transferFundMenu.exists)
        transferFundMenu.tap()
        waitForNonExistence(spinner)

        XCTAssert(app.alerts["Error"].exists)
        let predicate = NSPredicate(format:
            "label CONTAINS[c] 'The source token you provided doesn’t exist or is not a valid source.'")
        XCTAssert(app.alerts["Error"].staticTexts.element(matching: predicate).exists)
    }

    func testTransferFund_createTransferConnectionError() {
        mockServer.setupStubConnectionError(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListMoreThanOneTransferMethod",
                             method: HTTPMethod.get)

        XCTAssertTrue(transferFundMenu.exists)
        transferFundMenu.tap()
        waitForNonExistence(spinner)

        let predicate = NSPredicate(format:
            "label CONTAINS[c] 'We are encountering a problem processing the request. Please check your connectivity'")

        XCTAssertTrue(app.alerts["Connectivity Issue"].staticTexts.element(matching: predicate).exists)
    }
}
