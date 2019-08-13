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

        if #available(iOS 11.4, *) {
            XCTAssertTrue(transferFunds.transferFundTitle.exists)
        } else {
            XCTAssertTrue(app.navigationBars["Transfer Funds"].exists)
        }
        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertEqual(transferFunds.addSelectDestinationLabel.label, "Add Account")
        XCTAssertEqual(transferFunds.addSelectDestinationDetailLabel.label,
                       "An account hasn\'t been set up yet, please add an account first.")
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

        let destinationDetail = transferFunds.addSelectDestinationDetailLabel.label
        XCTAssertTrue(destinationDetail == "United States\nEnding on 1234"
            || destinationDetail == "United States Ending on 1234")

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
        // TODO: iOS 10.3.1 does work on the following - will investigate
        if #available(iOS 11.0, *) {
            transferFunds.enterNotes(description: "testing")
            XCTAssertEqual(transferFunds.notesDescriptionTextField.value as? String, "testing")
        }

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
    func testTransferFunds_switchTransferMethodCurrency() {
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

        transferFunds.addSelectDestinationLabel.tap()
        // Select Destination (CAD)
        let cadBankAccount = app.tables.element.children(matching: .cell).element(boundBy: 1)
        cadBankAccount.tap()

        XCTAssertEqual(transferFunds.transferCurrency.label, "CAD")
    }

    func testTransferFunds_createTransferWithAllFunds() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListMoreThanOneTransferMethod",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
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
        let availableFunds = app.tables["createTransferTableView"].staticTexts["Available for transfer: 452.14"]
        XCTAssertTrue(availableFunds.exists)
        // Turn on the Transfer All Funds Switch
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "")
        transferFunds.transferAllFundsSwitch.tap()
        // Assert Destination Amount is automatically insert into the amount field
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "452.14")
    }

    /* Given that User has 2 bank accounts which has different Currency from the Source.
     When user transfer the fund
     Then the user should see 2 FX quotes
     */
    // Transfer Requiring more than 2 FX
    func testTransferFunds_createTransferWithFX() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListMoreThanOneTransferMethod",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundMultiCurrencies",
                             method: HTTPMethod.post)

        XCTAssertTrue(transferFundMenu.exists)
        transferFundMenu.tap()
        waitForNonExistence(spinner)

        // Add Destination Section
        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertEqual(transferFunds.addSelectDestinationLabel.label, "Bank Account")

        let destinationDetail = transferFunds.addSelectDestinationDetailLabel.label
        XCTAssertTrue(destinationDetail == "United States\nEnding on 1234"
            || destinationDetail == "United States Ending on 1234")

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

        let availableFunds = app.tables["createTransferTableView"].staticTexts["Available for transfer: 5,855.17"]
        XCTAssertTrue(availableFunds.exists)

        // Turn the Transfer All Switch On
        transferFunds.toggleTransferAllFundsSwitch()
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "5,855.17")

        // Next Button
        XCTAssertTrue(transferFunds.nextLabel.exists)
        transferFunds.nextLabel.tap()

        // Assert Confirmation Page
        waitForExistence(app.tables["scheduleTransferTableView"].staticTexts["Confirm"])
        XCTAssertTrue(app.tables["scheduleTransferTableView"].staticTexts["Confirm"].exists)
    }

    func testTransferFunds_createTransferWithoutFX() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListOneBankAccountTransferUSD",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.post)

        XCTAssertTrue(transferFundMenu.exists)
        transferFundMenu.tap()
        waitForNonExistence(spinner)

        // Add Destination Section
        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertEqual(transferFunds.addSelectDestinationLabel.label, "Bank Account")

        let destinationDetail = transferFunds.addSelectDestinationDetailLabel.label
        XCTAssertTrue(destinationDetail == "United States\nEnding on 6789"
            || destinationDetail == "United States Ending on 6789")

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

        // Turn the Transfer All Switch On
        transferFunds.toggleTransferAllFundsSwitch()
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "452.14")

        // Next Button
        XCTAssertTrue(transferFunds.nextLabel.exists)
        transferFunds.nextLabel.tap()

        // Assert Confirmation Page
        waitForExistence(app.tables["scheduleTransferTableView"].staticTexts["Confirm"])
        XCTAssertTrue(app.tables["scheduleTransferTableView"].staticTexts["Confirm"].exists)
    }

    // This testcase for next sprint
    /*
     Given thatTransfer methods exist
     AND PrepaidCard Transfer method is selected
     When Payee enters the amount in non-digit amount currency for eg. JPY or KRW
     Then Next button is enabled
     */
    /*
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
     } */

    /* Given that user is on the Transfer fund page and selected a Transfer Destination
     When user enter the digit for the transfer amount
     Then amount field will be formatted correctly
     */
    func testTransferFunds_createTransferWhenDestinationAmountIsSet() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListOneBankAccountTransferUSD",
                             method: HTTPMethod.get)
        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.post)

        XCTAssertTrue(transferFundMenu.exists)
        transferFundMenu.tap()
        waitForNonExistence(spinner)

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

    // MARK: UI Error Handling
    /*
     When user's account has available fund but has no Transfer method
     when user tab "Next"
     Then "Add a transfer method first" footer shows under "Destination" section
     Then "Enter amount or select tranfer all funds" footer shows under "Transfer all funds" section
     */
    func testTransferFunds_createTransferWhenDestinationNotSet() {
        mockServer.setUpEmptyResponse(url: "/rest/v3/users/usr-token/transfer-methods")
        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.post)

        XCTAssertTrue(transferFundMenu.exists)
        transferFundMenu.tap()
        waitForNonExistence(spinner)

        if #available(iOS 11.4, *) {
            XCTAssertTrue(transferFunds.transferFundTitle.exists)
        } else {
            XCTAssertTrue(app.navigationBars["Transfer Funds"].exists)
        }
        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertEqual(transferFunds.addSelectDestinationLabel.label, "Add Account")
        XCTAssertEqual(transferFunds.addSelectDestinationDetailLabel.label,
                       "An account hasn\'t been set up yet, please add an account first.")

        XCTAssertTrue(transferFunds.nextLabel.exists)
        transferFunds.nextLabel.tap()

        let addTransferMethodPredicate = NSPredicate(format:
                    "label CONTAINS[c] 'Add a transfer method first'")
        XCTAssert(app.tables["createTransferTableView"].staticTexts.element(matching: addTransferMethodPredicate).exists)

        let transferAllFundPredicate = NSPredicate(format:
            "label CONTAINS[c] 'Enter amount or select tranfer all funds'")
        XCTAssert(app.tables["createTransferTableView"].staticTexts.element(matching: transferAllFundPredicate).exists)
    }

    /*
     When user's account has available fund AND selected a Transfer method
     when user tab "Next" without entering Transfer Amount
     Then "Add a transfer method first" footer shows under "Destination" section
     Then "Enter amount or select transfer all funds" footer shows under "Transfer all funds"
     */
    func testTransferFunds_createTransferWhenDestinationAmountNotSet() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListOneBankAccountTransferUSD",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.post)

        XCTAssertTrue(transferFundMenu.exists)
        transferFundMenu.tap()
        waitForNonExistence(spinner)

        if #available(iOS 11.4, *) {
            XCTAssertTrue(transferFunds.transferFundTitle.exists)
        } else {
            XCTAssertTrue(app.navigationBars["Transfer Funds"].exists)
        }

        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertTrue(transferFunds.transferAmount.exists)

        XCTAssertTrue(transferFunds.nextLabel.exists)
        transferFunds.nextLabel.tap()

        let error = app.tables["createTransferTableView"].staticTexts["transferFooterLabelIdentifier"].label
        if #available(iOS 11.4, *) {
            XCTAssertTrue(error.contains("Available for transfer: 452.14\nEnter amount or select tranfer all funds"))
        } else {
            XCTAssertTrue(error.contains("Available for transfer: 452.14 Enter amount or select tranfer all funds"))
        }
    }

    /*
     When user's account has available fund AND selected a Transfer method
     when user paste content only includes numbers to the Transfer Amount field
     THEN the value will be shown on the Transfer Amount field
     */
    func testTransferFunds_createTransferCopyAndPasteTransferAmountWithChars() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListOneBankAccountTransferUSD",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.post)

        XCTAssertTrue(transferFundMenu.exists)
        transferFundMenu.tap()
        waitForNonExistence(spinner)

        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertTrue(transferFunds.transferAmount.exists)

        let pasteAmountWithCharacters = "1000CAN"
        transferFunds.pasteAmountToTransferAmount(amount: pasteAmountWithCharacters)
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "")
    }

    func testTransferFunds_createTransferCopyAndPasteTransferAmountWithDigits() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListOneBankAccountTransferUSD",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.post)

        XCTAssertTrue(transferFundMenu.exists)
        transferFundMenu.tap()
        waitForNonExistence(spinner)

        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertTrue(transferFunds.transferAmount.exists)

        let pastAmountWithNumberNoDigit = "10000"
        transferFunds.pasteAmountToTransferAmount(amount: pastAmountWithNumberNoDigit)
        transferFunds.transferAmount.tap()
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "10,000.00")
    }

    /* When user enters amount below the transaction limit in transfer amount Field
     And when user tab Next
     Then shows error dialog
     */
    func testTransferFunds_createTransferBelowTransactionLimit() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListOneBankAccountTransferUSD",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.post)

        XCTAssertTrue(transferFundMenu.exists)
        transferFundMenu.tap()
        waitForNonExistence(spinner)

        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertTrue(transferFunds.transferAmount.exists)

        // Enter amount lower than the transaction limit
        transferFunds.enterTransferAmount(amount: "0.01")

        mockServer.setupStubError(url: "/rest/v3/transfers",
                                  filename: "TransferBelowTransactionLimitError",
                                  method: HTTPMethod.post)

        XCTAssertTrue(transferFunds.nextLabel.exists)
        transferFunds.nextLabel.tap()

        waitForExistence(app.alerts["Error"])
        // XCTAssert(app.alerts["Error"].exists)
        let predicate = NSPredicate(format:
            "label CONTAINS[c] 'Requested transfer amount $0.01, is below the transaction limit of $1.00.'")
        XCTAssert(app.alerts["Error"].staticTexts.element(matching: predicate).exists)
    }

    /* When user enter notes description over the length limit (255) and tab Next
     Then shows error dialog.
     */
    func testTransferFunds_createTransferDescriptionLength() {
        let over255String = """
                            1234567890abcdefghij1234567890abcdefghij1234567890abcdefghij
                            1234567890abcdefghij1234567890abcdefghij1234567890abcdefghij
                            1234567890abcdefghij1234567890abcdefghij1234567890abcdefghij
                            1234567890abcdefghij1234567890abcdefghij1234567890abcdefghij
                            1234567890abcdefghij1234567890abcdefghij1234567890abcdefghij
                            1234567890abcdefghij1234567890abcdefghij1234567890abcdefghij
                            1234567890abcdefghij1234567890abcdefghij1234567890abcdefghij
                            1234567890abcdefgEND
                            """

        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListOneBankAccountTransferUSD",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.post)

        XCTAssertTrue(transferFundMenu.exists)
        transferFundMenu.tap()
        waitForNonExistence(spinner)

        transferFunds.enterTransferAmount(amount: "1000")
        if #available(iOS 11.0, *) {
            transferFunds.enterNotes(description: over255String)
        }

        XCTAssertTrue(transferFunds.nextLabel.exists)
        transferFunds.nextLabel.tap()

//        let predicate = NSPredicate(format:
//            "label CONTAINS[c] 'Notes should be between 1 and 255 characters'")
//        XCTAssert(app.tables["createTransferTableView"].staticTexts.element(matching: predicate).exists)
    }

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

        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertTrue(transferFunds.transferAmount.exists)
        transferFunds.enterTransferAmount(amount: "999999999")

        // Next Button
        mockServer.setupStubError(url: "/rest/v3/transfers",
                                  filename: "TransferErrorLimitExceeded",
                                  method: HTTPMethod.post)
        XCTAssertTrue(transferFunds.nextLabel.exists)
        transferFunds.nextLabel.tap()

        waitForExistence(app.alerts["Error"])
        XCTAssert(app.alerts["Error"].exists)
        let predicate = NSPredicate(format: """
            label CONTAINS[c] 'Your attempted transaction has exceeded the approved payout limit; \
            please contact Hyperwallet for further assistance.'
            """)
        XCTAssert(app.alerts["Error"].staticTexts.element(matching: predicate).exists)
    }

    /* Given that Transfer methods exist And insufficient funds to transfer
     When user transfers the fund
     Then Amount Less than fee error occurs and the app should display the error
     */
    func testTransferFunds_createTransferInsufficientFundsError() {
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
        XCTAssertTrue(transferFunds.transferAmount.exists)
        transferFunds.enterTransferAmount(amount: "1000000")

        // Next Button
        mockServer.setupStubError(url: "/rest/v3/transfers",
                                  filename: "TransferErrorOverAvailableFund",
                                  method: HTTPMethod.post)

        XCTAssertTrue(transferFunds.nextLabel.exists)
        transferFunds.nextLabel.tap()

        waitForExistence(app.alerts["Error"])
        XCTAssert(app.alerts["Error"].exists)
        let predicate = NSPredicate(format:
            "label CONTAINS[c] 'You do not have enough funds in any single currency to complete this transfer'")
        XCTAssert(app.alerts["Error"].staticTexts.element(matching: predicate).exists)
    }

    func testTransferFunds_createTransferInvalidSourceError() {
        mockServer.setupStubError(url: "/rest/v3/users/usr-token/transfer-methods",
                                  filename: "InvalidSourceError",
                                  method: HTTPMethod.get)

        XCTAssertTrue(transferFundMenu.exists)
        transferFundMenu.tap()
        waitForNonExistence(spinner)

        waitForExistence(app.alerts["Error"])
        XCTAssert(app.alerts["Error"].exists)
        let predicate = NSPredicate(format:
            "label CONTAINS[c] 'The source token you provided doesn’t exist or is not a valid source.'")
        XCTAssert(app.alerts["Error"].staticTexts.element(matching: predicate).exists)
    }

    /* Given that Transfer methods exist And there is NO available fund
     When user tabs on the Transfer Fund menu
     Then will see the error
     */
    func testTransferFunds_createTransferMinimumAmountError() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListOneBankAccountTransferUSD",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundZero",
                             method: HTTPMethod.post)

        XCTAssertTrue(transferFundMenu.exists)
        transferFundMenu.tap()
        mockServer.setupStubError(url: "/rest/v3/transfers",
                                  filename: "TransferErrorAmountLessThanFee",
                                  method: HTTPMethod.post)

        waitForNonExistence(spinner)

        waitForExistence(app.alerts["Error"])
        XCTAssert(app.alerts["Error"].exists)
        let predicate = NSPredicate(format:
            "label CONTAINS[c] 'Amount is less than the fee amount'")
        XCTAssert(app.alerts["Error"].staticTexts.element(matching: predicate).exists)
    }

    /*
     func testTransferFunds_createTransferConnectionError() {
         mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListMoreThanOneTransferMethod",
                             method: HTTPMethod.get)

          mockServer.setUpConnectionResponse(url: "/rest/v3/transfer", filename: "AvailableFundUSD", method: HTTPMethod.post)

         XCTAssertTrue(transferFundMenu.exists)
         transferFundMenu.tap()

         waitForNonExistence(spinner)

         let predicate = NSPredicate(format:
         "label CONTAINS[c] 'We are encountering a problem processing the request. Please check your connectivity'")

         XCTAssertTrue(app.alerts["Connectivity Issue"].staticTexts.element(matching: predicate).exists)
     }
   */
}
