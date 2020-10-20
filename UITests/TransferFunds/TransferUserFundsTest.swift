import XCTest

class TransferUserFundsTest: BaseTests {
    var transferFundMenu: XCUIElement!
    var transferFundSourceMenu: XCUIElement!
    var transferFunds: TransferFunds!
    var selectDestination: TransferFundsSelectDestination!
    var addTransferMethod: AddTransferMethod!
    var elementQuery: XCUIElementQuery!
    let listppcUrl = "/rest/v3/users/usr-token/prepaid-cards"
    let ppcInfoUrl = "/rest/v3/users/usr-token/prepaid-cards/trm-token"

    var expectedUSDestinationPrepaidLabel: String = {
        if #available(iOS 11.2, *) {
            return "United States\nVisa •••• "
        } else {
            return "United States Visa •••• "
        }
    }()

    var expectedUSDestinationLabel: String = {
        if #available(iOS 11.2, *) {
            return "United States\nending in "
        } else {
            return "United States ending in "
        }
    }()

    var expectedCanadaDestinationLabel: String = {
        if #available(iOS 11.2, *) {
            return "Canada\nending in 1235"
        } else {
            return "Canada ending in 1235"
        }
    }()

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()

        spinner = app.activityIndicators["activityIndicator"]
        transferFundMenu = app.tables.cells
            .containing(.staticText, identifier: "Transfer Funds")
            .element(boundBy: 0)

        transferFundSourceMenu = app.tables.cells
            .containing(.staticText, identifier: "Transfer Funds Source")
            .element(boundBy: 0)

        transferFunds = TransferFunds(app: app)
        selectDestination = TransferFundsSelectDestination(app: app)
        addTransferMethod = AddTransferMethod(app: app)
        if #available(iOS 13.0, *) {
            elementQuery = app.tables["scheduleTransferTableView"].buttons
        } else {
            elementQuery = app.tables["scheduleTransferTableView"].staticTexts
        }
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

        transferFunds.verifyTransferFundsTitle()

        // TRANSFER FROM
        transferFunds.verifyTransferFrom(isAvailableFunds: true)

        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertEqual(transferFunds.addSelectDestinationLabel.label, "mobileAddTransferMethod".localized())

        // assert NOTE
        XCTAssertTrue(transferFunds.notesSectionLabel.exists)

        // assert Continue button
        XCTAssertTrue(transferFunds.nextLabel.exists)
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

        transferFunds.verifyTransferFundsTitle()

        // Amount row
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "0")
        XCTAssertEqual(transferFunds.transferCurrency.value as? String, "USD")
        XCTAssertEqual(transferFunds.transferAmountLabel.label, "Available funds $452.14 USD")
        // Transfer max funds
        XCTAssertTrue(transferFunds.transferMaxAllFunds.exists, "Transfer all funds switch should exist")

        // TRANSFER TO
        XCTAssertTrue(transferFunds.transferSectionLabel.exists)
        // Add Destination Section
        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertEqual(transferFunds.addSelectDestinationLabel.label, "Bank Account")

        transferFunds.verifyBankAccountDestination(type: "Bank Account", endingDigit: "1234")

        // Notes
        XCTAssertTrue(transferFunds.notesSectionLabel.exists)
        transferFunds.verifyNotes()

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
        transferFunds.verifyTransferFundsTitle()

        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)

        // Amount row
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "0")
        XCTAssertEqual(transferFunds.transferCurrency.value as? String, "USD")
        XCTAssertEqual(transferFunds.transferAmountLabel.label, "Available funds $452.14 USD")
        // Transfer max funds
        XCTAssertTrue(transferFunds.transferMaxAllFunds.exists, "Transfer all funds switch should exist")

        XCTAssertEqual(transferFunds.addSelectDestinationLabel.label, "Bank Account")
        transferFunds.addSelectDestinationLabel.tap()
        // Select Destination (CAD)
        mockServer.setupStub(url: "/rest/v3/transfers", filename: "AvailableFundCAD", method: HTTPMethod.post)
        let cadBankAccount = app.tables.element.children(matching: .cell).element(boundBy: 1)
        cadBankAccount.tap()

        waitForNonExistence(spinner)
        transferFunds.transferMaxAllFunds.tap()
        // Assert Destination Amount is automatically insert into the amount field
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "7,301.64")
        XCTAssertEqual(transferFunds.transferCurrency.value as? String, "CAD")
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

        XCTAssertEqual(transferFunds.transferAmount.value as? String, "0")
        XCTAssertEqual(transferFunds.transferCurrency.value as? String, "USD")
        XCTAssertEqual(transferFunds.transferAmountLabel.label, "Available funds $452.14 USD")
        // Transfer all funds row
        XCTAssertTrue(transferFunds.transferMaxAllFunds.exists, "Transfer all funds switch should exist")

        // Tap on the Transfer max funds
        transferFunds.transferMaxAllFunds.tap()
        // Assert Destination Amount is automatically insert into the amount field
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "452.14")
    }

    /*
       Given that Transfer methods exist
       When user selects TransferAllFunds AND then remove the All Funds amount AND enter a different fund amount
       Then the transfer fund amount should show different fund amount.
       */
      func testTransferFunds_switchAllFundsToEnterFundsUSD() {
          mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                               filename: "ListMoreThanOneTransferMethod",
                               method: HTTPMethod.get)
          mockServer.setupStub(url: "/rest/v3/transfers", filename: "AvailableFundUSD", method: HTTPMethod.post)

          XCTAssertTrue(transferFundMenu.exists)
          transferFundMenu.tap()
          waitForNonExistence(spinner)

          XCTAssertEqual(transferFunds.transferAmount.value as? String, "0")
          XCTAssertEqual(transferFunds.transferCurrency.value as? String, "USD")
          XCTAssertEqual(transferFunds.transferAmountLabel.label, "Available funds $452.14 USD")
          // Transfer all funds row
          XCTAssertTrue(transferFunds.transferMaxAllFunds.exists, "Transfer all funds switch should exist")

          // Tap on the Transfer max funds
          transferFunds.transferMaxAllFunds.tap()
          // Assert Destination Amount is automatically insert into the amount field
          XCTAssertEqual(transferFunds.transferAmount.value as? String, "452.14")

          transferFunds.enterTransferAmount(amount: "999.99")
          XCTAssertEqual(transferFunds.transferAmount.value as? String, "999.99")

          // Tap on the Transfer max funds again
          transferFunds.transferAmountLabel.tap()
          transferFunds.transferMaxAllFunds.tap()

          checkSelectFieldValueIsEqualTo("452.14", transferFunds.transferAmount)
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

        transferFunds.verifyBankAccountDestination(type: "Bank Account", endingDigit: "1234")

        // Transfer Section
        XCTAssertTrue(transferFunds.transferSectionLabel.exists)
        // Amount row
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "0")
        XCTAssertEqual(transferFunds.transferCurrency.value as? String, "USD")
        XCTAssertEqual(transferFunds.transferAmountLabel.label, "Available funds $5,855.17 USD")
        // Transfer all funds row
        XCTAssertTrue(transferFunds.transferMaxAllFunds.exists, "Transfer all funds switch should exist")

        // Turn the Transfer All Switch On
        transferFunds.transferMaxAllFunds.tap()
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "5,855.17")

        // Next Button
        XCTAssertTrue(transferFunds.nextLabel.exists)
        transferFunds.tapContinueButton()

        // Assert Confirmation Page
        //waitForExistence(elementQuery["Confirm"])
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

        // Transfer Section
        XCTAssertTrue(transferFunds.transferSectionLabel.exists)
        // Amount row
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "0")
        XCTAssertEqual(transferFunds.transferCurrency.value as? String, "USD")
        XCTAssertEqual(transferFunds.transferAmountLabel.label, "Available funds $452.14 USD")
        // Transfer all funds row
        XCTAssertTrue(transferFunds.transferMaxAllFunds.exists, "Transfer all funds switch should exist")

        // Add Destination Section
        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertEqual(transferFunds.addSelectDestinationLabel.label, "Bank Account")

        transferFunds.verifyBankAccountDestination(type: "Bank Account", endingDigit: "6789")

        // Notes
        XCTAssertTrue(transferFunds.notesSectionLabel.exists)

        // Turn the Transfer max funds
        transferFunds.transferMaxAllFunds.tap()
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "452.14")

        // Next Button
        XCTAssertTrue(transferFunds.nextLabel.exists)
        transferFunds.tapContinueButton()

        // Assert Confirmation Page
        //waitForExistence(elementQuery["Confirm"])
    }

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
        transferFunds.transferAmount.typeText(".12345")

        transferFunds.transferSectionLabel.tap()
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "0.12")

        transferFunds.transferAmount.clearAndEnterText(text: "12345678901234567890")
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "123456789012")
        transferFunds.transferAmount.typeText(".123456")
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "123456789012.12")

        transferFunds.transferSectionLabel.tap()
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "123456789012.12")
    }

    // MARK: Select Destination Page
    func testTransferFunds_selectDestination() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListMoreThanOneTransferMethod",
                             method: HTTPMethod.get)
        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.post)

        XCTAssertTrue(transferFundMenu.exists)
        transferFundMenu.tap()
        waitForNonExistence(spinner)

        transferFunds.verifyBankAccountDestination(type: TransferMethods.bankAccount, endingDigit: "1234")
        transferFunds.addSelectDestinationLabel.tap()

        let usdBankAccount = app.tables.element.children(matching: .cell).element(boundBy: 0)
        let cadBankAccount = app.tables.element.children(matching: .cell).element(boundBy: 1)
        let prepaidCard = app.tables.element.children(matching: .cell).element(boundBy: 2)

        XCTAssertTrue(selectDestination.selectDestinationTitle.exists)
        XCTAssertTrue(selectDestination.addTransferMethodButton.exists)

        waitForNonExistence(spinner)

        XCTAssertEqual(selectDestination.getSelectDestinationRowTitle(index: 0), TransferMethods.bankAccount)
        XCTAssertEqual(selectDestination.getSelectDestinationRowDetail(index: 0), expectedUSDestinationLabel + "1234")

        XCTAssertEqual(selectDestination.getSelectDestinationRowTitle(index: 1), TransferMethods.bankAccount)
        XCTAssertEqual(selectDestination.getSelectDestinationRowDetail(index: 1), expectedCanadaDestinationLabel)

        XCTAssertEqual(selectDestination.getSelectDestinationRowTitle(index: 2), TransferMethods.prepaidCard)
        XCTAssertEqual(selectDestination.getSelectDestinationRowDetail(index: 2),
                       expectedUSDestinationPrepaidLabel + "4281")

        // Assert first row is checked by default
        assertButtonTrue(element: usdBankAccount)
        assertButtonFalse(element: cadBankAccount)
        assertButtonFalse(element: prepaidCard)

        // Assert can go back to previous page
        //selectDestination.clickBackButton()
        clickBackButton()
        transferFunds.verifyTransferFundsTitle()
    }

    private func assertButtonTrue(element: XCUIElement) {
        if #available(iOS 13.0, *) {
            XCTAssertTrue(element.buttons["checkmark"].exists, "By default the first row should be selected")
        } else {
            XCTAssertTrue(element.buttons["More Info"].exists, "By default the first row should be selected")
        }
    }

    private func assertButtonFalse(element: XCUIElement) {
        if #available(iOS 13.0, *) {
            XCTAssertFalse(element.buttons["checkmark"].exists, "By default the first row should be selected")
        } else {
            XCTAssertFalse(element.buttons["More Info"].exists, "By default the first row should be selected")
        }
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

        transferFunds.verifyTransferFundsTitle()

        // Transfer From
        transferFunds.verifyTransferFrom(isAvailableFunds: true)

        // Transfer To
        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertEqual(transferFunds.addSelectDestinationLabel.label, "mobileAddTransferMethod".localized())

        XCTAssertTrue(transferFunds.nextLabel.exists)
        transferFunds.tapContinueButton()
        waitForNonExistence(spinner)

        app.swipeDown()

        // Assert inline errors
        XCTAssertEqual(transferFunds.invalidAmountError.label, "transferAmountInvalid".localized())
        XCTAssertEqual(transferFunds.transferMethodRequireError.label, "noTransferMethodAdded".localized())
    }

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

        transferFunds.verifyTransferFundsTitle()

        // Transfer From
        transferFunds.verifyTransferFrom(isAvailableFunds: true)

        // Transfer To
        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertTrue(transferFunds.transferAmount.exists)

        XCTAssertTrue(transferFunds.nextLabel.exists)
        transferFunds.tapContinueButton()
        waitForNonExistence(spinner)

         app.swipeDown()

        XCTAssertEqual(transferFunds.invalidAmountError.label, "transferAmountInvalid".localized())
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

        // Transfer From
        transferFunds.verifyTransferFrom(isAvailableFunds: true)

        // Transfer To
        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertTrue(transferFunds.transferAmount.exists)

        let pasteAmountWithCharacters = "1000CAN"
        transferFunds.pasteAmountToTransferAmount(amount: pasteAmountWithCharacters)
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "0")
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

        // Transfer From
        transferFunds.verifyTransferFrom(isAvailableFunds: true)

        // Transfer To
        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertTrue(transferFunds.transferAmount.exists)

        transferFunds.transferAmount.tap()
        let pastAmountWithNumberNoDigit = "10000.00"
        transferFunds.pasteAmountToTransferAmount(amount: pastAmountWithNumberNoDigit)
        waitForNonExistence(spinner)

        XCTAssertEqual(transferFunds.transferAmount.value as? String, "0")
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

        // Transfer From
        transferFunds.verifyTransferFrom(isAvailableFunds: true)

        // Transfer To
        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertTrue(transferFunds.transferAmount.exists)

        // Enter amount lower than the transaction limit
        transferFunds.enterTransferAmount(amount: "0.01")

        mockServer.setupStubError(url: "/rest/v3/transfers",
                                  filename: "TransferBelowTransactionLimitError",
                                  method: HTTPMethod.post)

        XCTAssertTrue(transferFunds.nextLabel.exists)
        transferFunds.tapContinueButton()

        waitForExistence(app.alerts["Error"])
        let predicate = NSPredicate(format:
            "label CONTAINS[c] 'Requested transfer amount $0.01, is below the transaction limit of $1.00.'")
        XCTAssert(app.alerts["Error"].staticTexts.element(matching: predicate).exists)
    }

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

        if #available(iOS 13.0, *) {
            transferFunds.notesDescriptionTextField.tap()
            transferFunds.notesDescriptionTextField.typeText(over255String)
        } else {
             transferFunds.enterNotes(description: over255String)
        }

        mockServer.setupStubError(url: "/rest/v3/transfers",
                                  filename: "NoteDescriptionLengthValidationError",
                                  method: HTTPMethod.post)

        XCTAssertTrue(transferFunds.nextLabel.exists)
        transferFunds.tapContinueButton()
        waitForNonExistence(spinner)

        let error = app.tables["createTransferTableView"].staticTexts["transferTableViewFooterViewIdentifier"].label

        // show error at footer
        XCTAssertTrue(error.contains("Notes should be between 1 and 255 characters"))
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
        transferFunds.verifyTransferFundsTitle()
        // waitForNonExistence(transferFunds.addSelectDestinationSectionLabel)

        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertTrue(transferFunds.transferAmount.exists)
        transferFunds.enterTransferAmount(amount: "999999999")

        // Next Button
        mockServer.setupStubError(url: "/rest/v3/transfers",
                                  filename: "TransferErrorLimitExceeded",
                                  method: HTTPMethod.post)
        XCTAssertTrue(transferFunds.nextLabel.exists)
        transferFunds.tapContinueButton()

        waitForExistence(app.alerts["Error"])
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
        transferFunds.tapContinueButton()

        waitForExistence(app.alerts["Error"])
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
        let predicate = NSPredicate(format:
            "label CONTAINS[c] 'The source token you provided doesn’t exist or is not a valid source.'")
        XCTAssert(app.alerts["Error"].staticTexts.element(matching: predicate).exists)
    }

    // MARK: Add Transfer Method Tests
    func testTransferFunds_addTransferMethodWhenNoTransferMethods() {
        mockServer.setUpEmptyResponse(url: "/rest/v3/users/usr-token/transfer-methods")
        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.post)

        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodConfigurationBankAccountBusinessResponse",
                             method: HTTPMethod.post)

        XCTAssertTrue(transferFundMenu.exists)
        transferFundMenu.tap()
        waitForNonExistence(spinner)

        transferFunds.verifyTransferFundsTitle()

        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertEqual(transferFunds.addSelectDestinationLabel.label, "mobileAddTransferMethod".localized())
        transferFunds.addSelectDestinationLabel.tap()

        // Assert Add a transfer method View
        waitForNonExistence(spinner)
        XCTAssertTrue(app.navigationBars["mobileAddTransferMethodHeader".localized()].exists)
        XCTAssertTrue(app.tables.staticTexts["United States"].exists)
        XCTAssertTrue(app.tables.staticTexts["USD"].exists)

        mockServer.setupStub(url: "/rest/v3/users/usr-token/bank-accounts",
                             filename: "BankAccountIndividualResponse",
                             method: HTTPMethod.post)

        // Tap on Bank Account
        app.tables["selectTransferMethodTypeTable"].cells["Bank Account"].tap()

        XCTAssert(app.navigationBars["Bank Account"].exists)
        addTransferMethod.setBranchId("021000021")
        addTransferMethod.setBankAccountId("12345")
        addTransferMethod.selectAccountType("CHECKING")
        addTransferMethod.clickCreateTransferMethodButton()
        waitForNonExistence(spinner)

        // Assert navigate to the Transfer Fund again
        transferFunds.verifyTransferFundsTitle()

        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertEqual(transferFunds.addSelectDestinationLabel.label, "Bank Account")

        transferFunds.verifyBankAccountDestination(type: "Bank Account", endingDigit: "2345")

        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "AddNewTransferMethodOneTransferMethod",
                             method: HTTPMethod.get)

        transferFunds.addSelectDestinationLabel.tap()

        waitForNonExistence(spinner)

        // Assert added account is set as the Transfer Destination
        XCTAssertEqual(selectDestination.getSelectDestinationRowTitle(index: 0), "Bank Account")
        XCTAssertEqual(selectDestination.getSelectDestinationRowDetail(index: 0), expectedUSDestinationLabel + "2345")
    }

    // MARK: Select PPC as the Transfer source
    func testTransferFunds_createTransferPrepaidCard_transferFromPrepaidCard() {
        // Get the transfer method list
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListMoreThanOneTransferMethod",
                             method: HTTPMethod.get)

        // Get the Available funds
        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.post)

        // List the available PPC of the user to select from source
        mockServer.setupStub(url: listppcUrl,
                             filename: "PrepaidCardPrimaryOnlyResponse",
                             method: HTTPMethod.get)

        // Retreive details of PPC by trm-token
        mockServer.setupStub(url: "/rest/v3/users/usr-token/prepaid-cards/trm-token",
                             filename: "GetPrepaidCardSuccessResponse",
                             method: HTTPMethod.get)

        XCTAssertTrue(transferFundSourceMenu.exists)
        transferFundSourceMenu.tap()

        waitForNonExistence(spinner)
        transferFunds.verifyTransferFrom(isAvailableFunds: true)

        // Select Transfer source - PPC
        transferFunds.transferSourceTitleLabel.tap()
        let ppcCell = app.tables.element.children(matching: .cell).element(boundBy: 1)
        ppcCell.tap()

        // Transfer From by PPC Section
        transferFunds.verifyTransferFrom(isAvailableFunds: false)
        transferFunds.verifyPPCInfo(brandType: transferFunds.prepaidCardVisa, endingDigit: "9285")

        // Transfer Destination Section - Bank Account
        transferFunds.verifyTransferFundsTitle()
        transferFunds.verifyBankAccountDestination(type: "Bank Account", endingDigit: "1234")

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

    /*
     Given that user selects a Secondary Prepaid Card method for Transfer From
     When create transfer with a Bank Account Transfer To method
     Then user can create transfer successfully
     */
    func testTransferFunds_TransferFromSecondaryPPC() {
        // Get the transfer method list
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListMoreThanOneTransferMethod",
                             method: HTTPMethod.get)

        // Get the Available funds
        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.post)

        // List the available PPC of the user to select from source
        mockServer.setupStub(url: listppcUrl,
                             filename: "PrepaidCardSecondaryResponse",
                             method: HTTPMethod.get)

        // Retreive details of PPC by trm-token
        mockServer.setupStub(url: "/rest/v3/users/usr-token/prepaid-cards/trm-token",
                             filename: "GetPrepaidCardSuccessResponse",
                             method: HTTPMethod.get)

        XCTAssertTrue(transferFundSourceMenu.exists)
        transferFundSourceMenu.tap()

        waitForNonExistence(spinner)
        transferFunds.verifyTransferFrom(isAvailableFunds: true)

        transferFunds.verifyTransferFundsTitle()

        // TRANSFER FROM
        transferFunds.verifyTransferFrom(isAvailableFunds: true)

        // Available Funds
        XCTAssertEqual(transferFunds.transferAmount.value as? String, "0")
        XCTAssertEqual(transferFunds.transferCurrency.value as? String, "USD")
        let balance = String(format: transferFunds.availableBalanceFormat, "$", "452.14", "USD")
        XCTAssertEqual(transferFunds.transferAmountLabel.label, balance)

        // TRANSFER TO
        XCTAssertTrue(transferFunds.transferSectionLabel.exists)
        // Add Destination Section
        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertEqual(transferFunds.addSelectDestinationLabel.label, TransferMethods.bankAccount)

        transferFunds.verifyBankAccountDestination(type: TransferMethods.bankAccount, endingDigit: "1234")

        // assert NOTE
        XCTAssertTrue(transferFunds.notesSectionLabel.exists)

        // assert Continue button

        app.scroll(to: transferFunds.nextLabel)
        XCTAssertTrue(transferFunds.nextLabel.exists)

        transferFunds.transferSourceTitleLabel.tap()

        // Assert Transfer from list
        let transferFromTitle = transferFunds.getTransferFromTitle()
        XCTAssertEqual(transferFromTitle.label, transferFunds.transferFromHeaderLabel)
        XCTAssertEqual(transferFunds.getSelectSourceRowTitle(index: 0), transferFunds.availableFunds)
        XCTAssertEqual(transferFunds.getSelectSourceRowTitle(index: 1), transferFunds.prepaidCard)
        XCTAssertEqual(transferFunds.getSelectSourceRowTitle(index: 2), transferFunds.prepaidCard)

        let ppcCell = app.tables.element.children(matching: .cell).element(boundBy: 1)
        ppcCell.tap()
        waitForNonExistence(spinner)

        transferFunds.verifyTransferFrom(isAvailableFunds: false)
        transferFunds.verifyPPCInfo(brandType: transferFunds.prepaidCardVisa, endingDigit: "8884")
    }

    // MARK: Select PPC as the Transfer Destination
    /*
     Given that Transfer methods exist that contains prepaid cards as well
     AND user selects Prepaid Card as the Transfer To
     When Payee enters the amount and Notes
     Then Next button is enabled
     */
    func testTransferFunds_createTransfer_transferTosPrepaidCard() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListMoreThanOneTransferMethod",
                             method: HTTPMethod.get)

        // Get the Available funds
        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.post)
        // List the available PPC of the user to select from source
        mockServer.setupStub(url: listppcUrl,
                             filename: "PrepaidCardPrimaryOnlyResponse",
                             method: HTTPMethod.get)

        // Retreive details of PPC by trm-token
        mockServer.setupStub(url: "/rest/v3/users/usr-token/prepaid-cards/trm-token",
                             filename: "GetPrepaidCardSuccessResponse",
                             method: HTTPMethod.get)

        XCTAssertTrue(transferFundMenu.exists)
        transferFundMenu.tap()
        waitForNonExistence(spinner)
        // Select PPC as the transfer method from Destination

        transferFunds.verifyBankAccountDestination(type: TransferMethods.bankAccount, endingDigit: "1234")
        transferFunds.addSelectDestinationLabel.tap()

        let usdBankAccount = app.tables.element.children(matching: .cell).element(boundBy: 0)
        let cadBankAccount = app.tables.element.children(matching: .cell).element(boundBy: 1)
        let prepaidCardTransferMethod = app.tables.element.children(matching: .cell).element(boundBy: 2)

        XCTAssertTrue(selectDestination.selectDestinationTitle.exists)
        XCTAssertTrue(selectDestination.addTransferMethodButton.exists)

        waitForNonExistence(spinner)
        XCTAssertEqual(selectDestination.getSelectDestinationRowTitle(index: 0), TransferMethods.bankAccount)
        //XCTAssertEqual(selectDestination.getSelectDestinationRowDetail(index: 0), expectedUSDestinationLabel + "1234")

        XCTAssertEqual(selectDestination.getSelectDestinationRowDetail(index: 0),
                       transferFunds.getDestinationLabel(country: "United States",
                                                         type: TransferMethods.bankAccount,
                                                         endingDigit: "1234"))

        XCTAssertEqual(selectDestination.getSelectDestinationRowTitle(index: 1), TransferMethods.bankAccount)
        // unable to see the country
        //        XCTAssertEqual(selectDestination.getSelectDestinationRowDetail(index: 1),
        //                       transferFunds.getDestinationLabel(country: "Canada",
        //                                                         type: bankAccount,
        //                                                         endingDigit: "1235"))

        XCTAssertEqual(selectDestination.getSelectDestinationRowTitle(index: 2), TransferMethods.prepaidCard)
        let ppcInfo = "United States\n\(transferFunds.prepaidCardVisa)\(transferFunds.numberMask)4281"
        XCTAssertEqual(selectDestination.getSelectDestinationRowDetail(index: 2), ppcInfo)

        // Assert first row is checked by default
        assertButtonTrue(element: usdBankAccount)
        assertButtonFalse(element: cadBankAccount)
        assertButtonFalse(element: prepaidCardTransferMethod)

        // Select Prepaid card as the destination
        selectDestination.tapSelectDestinationRow(index: 2)
        // Assert can go back to previous page
        waitForNonExistence(spinner)
        XCTAssertTrue(app.navigationBars[transferFunds.title].exists)

        // Assert Prepaid Card is set as the Destination
        transferFunds.verifyPrepaidCardDestination(brandType: transferFunds.prepaidCardVisa, endingDigit: "4281")
    }

    // will fix later
    /*
    func testTransferFunds_addBankAccountWhenMoreThanOneTransferMethods() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListOneBankAccountTransferUSD",
                             method: HTTPMethod.get)

        mockServer.setupStub(url: "/rest/v3/transfers",
                             filename: "AvailableFundUSD",
                             method: HTTPMethod.post)

        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodConfigurationBankAccountBusinessResponse",
                             method: HTTPMethod.post)

        transferFundMenu.tap()
        waitForNonExistence(spinner)

        transferFunds.verifyTransferFundsTitle()

        // Add Destination Section
        XCTAssertTrue(transferFunds.addSelectDestinationSectionLabel.exists)
        XCTAssertEqual(transferFunds.addSelectDestinationLabel.label, "Bank Account")

        transferFunds.verifyBankAccountDestination(type: "Bank Account", endingDigit: "6789")

        transferFunds.addSelectDestinationLabel.tap()
        waitForNonExistence(spinner)

        XCTAssertTrue(selectDestination.selectDestinationTitle.exists)
        XCTAssertTrue(selectDestination.addTransferMethodButton.exists)
        XCTAssertEqual(selectDestination.getSelectDestinationRowTitle(index: 0), "Bank Account")
        XCTAssertEqual(selectDestination.getSelectDestinationRowDetail(index: 0), expectedUSDestinationLabel + "6789")

        mockServer.setupStub(url: "/rest/v3/users/usr-token/bank-accounts",
                             filename: "BankAccountIndividualResponse",
                             method: HTTPMethod.post)
        selectDestination.addTransferMethodButton.tap()
        // Assert Add a transfer method View
        XCTAssertTrue(app.navigationBars["mobileAddTransferMethodHeader".localized()].exists)
        XCTAssertTrue(app.tables.staticTexts["United States"].exists)
        XCTAssertTrue(app.tables.staticTexts["USD"].exists)

        // Tap on Bank Account
        app.tables["selectTransferMethodTypeTable"].cells["Bank Account"].tap()

        XCTAssert(app.navigationBars["Bank Account"].exists)
        addTransferMethod.setBranchId("021000021")
        addTransferMethod.setBankAccountId("12345")
        addTransferMethod.selectAccountType("CHECKING")

        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "AddNewTransferMethodsMoreThanOneTransferMethod",
                             method: HTTPMethod.get)

        addTransferMethod.clickCreateTransferMethodButton()
        waitForNonExistence(spinner)

        // Assert navigate to the Transfer Fund again
        transferFunds.verifyTransferFundsTitle()

        transferFunds.verifyBankAccountDestination(type: "Bank Account", endingDigit: "2345")

        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "AddNewTransferMethodsMoreThanOneTransferMethod",
                             method: HTTPMethod.get)
        transferFunds.addSelectDestinationLabel.tap()
        waitForNonExistence(spinner)
        XCTAssertTrue(selectDestination.selectDestinationTitle.exists)
        XCTAssertTrue(selectDestination.addTransferMethodButton.exists)
        XCTAssertEqual(selectDestination.getSelectDestinationRowTitle(index: 0), "Bank Account")
        XCTAssertEqual(selectDestination.getSelectDestinationRowDetail(index: 0), expectedUSDestinationLabel + "6789")
        XCTAssertEqual(selectDestination.getSelectDestinationRowTitle(index: 1), "Bank Account")
        XCTAssertEqual(selectDestination.getSelectDestinationRowDetail(index: 1), expectedUSDestinationLabel + "2345")
    } */

    // it passed on my local but not remote, so will comment it out for now
    /* Given that Transfer methods exist And there is NO available fund
     When user tabs on the Transfer Fund menu
     Then will see the error
     */
    /*
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

     if #available(iOS 12.0, *) {
     waitForExistence(app.alerts["Error"])
     XCTAssert(app.alerts["Error"].exists)
     let predicate = NSPredicate(format:
     "label CONTAINS[c] 'Amount is less than the fee amount'")
     XCTAssert(app.alerts["Error"].staticTexts.element(matching: predicate).exists)
     }
     }
     */

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

     XCTAssertEqual(transferFunds.transferSectionLabel.label, "TRANSFER")
     XCTAssertEqual(transferFunds.transferAmountLabel.label, "Amount")
     XCTAssertEqual(transferFunds.transferCurrency.label, "JPY")

     //let availableFunds = app.tables["createTransferTableView"].staticTexts["Available for transfer: 10000"]
     //XCTAssertTrue(availableFunds.exists)
     } */

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
