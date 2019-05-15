import XCTest

class AddTransferMethodTests: BaseTests {
    var selectTransferMethodType: SelectTransferMethodType!
    var addTransferMethod: AddTransferMethod!

    let bankAccount = NSPredicate(format: "label CONTAINS[c] 'Bank Account'")

    override func setUp() {
        super.setUp()

        // Initialize stubs
        setUpBankAccountScreen()
    }

    func testAddTransferMethod_createBankAccount() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/bank-accounts",
                             filename: "BankAccountResponse",
                             method: HTTPMethod.post)

        waitForNonExistence(spinner)

        addTransferMethod.setBranchId(branchId: "021000021")
        addTransferMethod.setAccountNumber(accountNumber: "12345")
        addTransferMethod.selectAccountType(accountType: "Checking")
        addTransferMethod.clickCreateTransferMethodButton()

        //Todo - check processing indicator
    }

    func testAddTransferMethod_returnsErrorOnInvalidPattern() {
        waitForNonExistence(spinner)

        addTransferMethod.setBranchId(branchId: "abc123abc")
        XCTAssert(app.tables["addTransferMethodTable"].staticTexts["label_branchId_error"].exists)

        addTransferMethod.setAccountNumber(accountNumber: "1a31a")
        XCTAssert(app.tables["addTransferMethodTable"].staticTexts["label_bankAccountId_error"].exists)
    }

    func testAddTransferMethod_createBankAccountInvalidRouting() {
        mockServer.setupStubError(url: "/rest/v3/users/usr-token/bank-accounts",
                                  filename: "BankAccountInvalidRoutingResponse",
                                  method: HTTPMethod.post)

        waitForNonExistence(spinner)

        addTransferMethod.setBranchId(branchId: "021000022")
        addTransferMethod.setAccountNumber(accountNumber: "12345")
        addTransferMethod.selectAccountType(accountType: "Checking")
        addTransferMethod.clickCreateTransferMethodButton()
        waitForNonExistence(spinner)

        XCTAssertNotNil(app.tables.otherElements
            .containing(NSPredicate(format: "label CONTAINS %@", "Routing Number [021000022] is not valid. " +
                "Please modify Routing Number to a valid ACH Routing Number of the branch of your bank.")))
    }

    func testAddTransferMethod_createBankAccountUnexpectedError() {
        mockServer.setupStubError(url: "/rest/v3/users/usr-token/bank-accounts",
                                  filename: "UnexpectedErrorResponse",
                                  method: HTTPMethod.post)

        waitForNonExistence(spinner)

        addTransferMethod.setBranchId(branchId: "021000022")
        addTransferMethod.setAccountNumber(accountNumber: "12345")
        addTransferMethod.selectAccountType(accountType: "Checking")
        addTransferMethod.clickCreateTransferMethodButton()
        waitForNonExistence(spinner)

        XCTAssert(app.alerts["Unexpected Error"].exists)
        XCTAssert(app.alerts["Unexpected Error"].staticTexts["Oops... Something went wrong, please try again"].exists)
        app.alerts["Unexpected Error"].buttons["OK"].tap()
        XCTAssertFalse(app.alerts["Unexpected Error"].exists)
        XCTAssertTrue(app.navigationBars["Add Account"].exists)
        XCTAssertTrue(app.tables["transferMethodTableView"].staticTexts.element(matching: bankAccount).exists)
    }

    func testAddTransferMethod_displaysElementsOnIndividualProfileTmcResponse() {
        waitForNonExistence(spinner)

        XCTAssert(app.navigationBars.staticTexts["Bank Account"].exists)

        verifyAccountInformationSection()
        verifyAccountHolderSection()
        verifyAddressSection()

        addTransferMethod.addTMTableView.scrollToElement(element: addTransferMethod.addTMTableView.otherElements["TRANSFER METHOD INFORMATION"])

        XCTAssert(addTransferMethod.addTMTableView.otherElements["TRANSFER METHOD INFORMATION"].exists)

        addTransferMethod.addTMTableView.scrollToElement(element: addTransferMethod.createTransferMethodButton)
        XCTAssert(addTransferMethod.createTransferMethodButton.exists)
    }

    func testAddTransferMethod_varifyPresetValues() {
        mockServer.setUpGraphQLBankAccountWithPreSetValues()
        addTransferMethod.clickBackButton()
        app.tables["transferMethodTableView"].staticTexts.element(matching: bankAccount).tap()

        guard let routingNumberPreSetValue = addTransferMethod.branchIdInput.value as? String else {
            XCTFail("preset value is nill")
            return
        }
        guard let accountNumberPreSetValue = addTransferMethod.accountNumberInput.value as? String else {
            XCTFail("preset value is nill")
            return
        }

        XCTAssertEqual(routingNumberPreSetValue, "012345678")
        XCTAssertEqual(accountNumberPreSetValue, "012345")
    }

    func testAddTransferMethod_verifyAfterRelaunch() {
        setUpScreenWithInvalidRoutingError()
        validateAddTransferMethodBankAccountScreen()
        XCUIDevice.shared.clickHomeAndRelaunch(app: app)
        setUpBankAccountScreen()
        setUpScreenWithInvalidRoutingError()
        validateAddTransferMethodBankAccountScreen()
    }

    func testAddTransferMethod_verifyRotateScreen() {
        setUpScreenWithInvalidRoutingError()
        XCUIDevice.shared.rotateScreen(times: 3)
        validateAddTransferMethodBankAccountScreen()
    }

    func testAddTransferMethod_verifyWakeFromSleep() {
        setUpScreenWithInvalidRoutingError()
        XCUIDevice.shared.wakeFromSleep(app: app)
        validateAddTransferMethodBankAccountScreen()
    }

    func testAddTransferMethod_verifyResumeFromRecents() {
        setUpScreenWithInvalidRoutingError()
        XCUIDevice.shared.resumeFromRecents(app: app)
        waitForNonExistence(addTransferMethod.navigationBar)
        validateAddTransferMethodBankAccountScreen()
    }

    func testAddTransferMethod_verifyAppToBackground() {
        setUpScreenWithInvalidRoutingError()
        XCUIDevice.shared.sendToBackground(app: app)
        validateAddTransferMethodBankAccountScreen()
    }

    func testAddTransferMethod_verifyPressBackButton() {
        addTransferMethod.clickBackButton()
        XCTAssertTrue(selectTransferMethodType.navigationBar.exists)
    }

    func validateAddTransferMethodBankAccountScreen() {
        XCTAssertTrue(addTransferMethod.navigationBar.exists)
        XCTAssertTrue(addTransferMethod.branchIdInput.exists)
        XCTAssertTrue(addTransferMethod.accountNumberInput.exists)
        XCTAssertTrue(addTransferMethod.accountTypeSelect.exists)
        XCTAssertNotNil(app.tables.otherElements
            .containing(NSPredicate(format: "label CONTAINS %@", "Routing Number [021000022] is not valid. " +
                "Please modify Routing Number to a valid ACH Routing Number of the branch of your bank.")))
    }

    private func setUpBankAccountScreen() {
        mockServer.setupGraphQLStubs()

        app = XCUIApplication()
        app.launch()

        selectTransferMethodType = SelectTransferMethodType(app: app)
        addTransferMethod = AddTransferMethod(app: app, for: .bankAccount)

        app.tables.cells.containing(.staticText, identifier: "Add Transfer Method").element(boundBy: 0).tap()
        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)

        selectTransferMethodType.selectCountry(country: "United States")
        selectTransferMethodType.selectCurrency(currency: "US Dollar")

        app.tables["transferMethodTableView"].staticTexts.element(matching: bankAccount).tap()
    }

    private func setUpScreenWithInvalidRoutingError() {
        mockServer.setupStubError(url: "/rest/v3/users/usr-token/bank-accounts",
                                  filename: "BankAccountInvalidRoutingResponse",
                                  method: HTTPMethod.post)

        waitForNonExistence(spinner)

        addTransferMethod.setBranchId(branchId: "021000022")
        addTransferMethod.setAccountNumber(accountNumber: "12345")
        addTransferMethod.selectAccountType(accountType: "Checking")
        app.scrollToElement(element: addTransferMethod.createTransferMethodButton)
        addTransferMethod.clickCreateTransferMethodButton()
        waitForNonExistence(spinner)
    }

    func testAddTransferMethod_verifyRoutingNumberIsNotEditable() {
        mockServer.setUpGraphQLBankAccountWithNotEditableField()
        addTransferMethod.clickBackButton()
        app.tables["transferMethodTableView"].staticTexts.element(matching: bankAccount).tap()
        addTransferMethod.branchIdInput.tap()

        XCTAssertFalse(app.keyboards.element.exists)
    }

    func testAddTransferMethod_verifyAccountTypeIsNotEditable() {
        mockServer.setUpGraphQLBankAccountWithNotEditableField()
        addTransferMethod.clickBackButton()
        app.tables["transferMethodTableView"].staticTexts.element(matching: bankAccount).tap()
        addTransferMethod.accountTypeSelect.tap()

        XCTAssertTrue(addTransferMethod.navigationBar.exists)
        XCTAssertFalse(app.tables["transferMethodTableView"].buttons["More Info"].exists)
    }

    private func verifyAccountInformationSection() {
        XCTAssert(addTransferMethod.addTMTableView.otherElements["ACCOUNT INFORMATION - UNITED STATES (USD)"].exists)
        XCTAssert(addTransferMethod.addTMTableView.cells.staticTexts["Routing Number"].exists)
        XCTAssert(addTransferMethod.branchIdInput.exists)

        XCTAssert(addTransferMethod.addTMTableView.staticTexts["Account Number"].exists)
        XCTAssert(addTransferMethod.accountNumberInput.exists)

        verifyAccountTypeSelection()
        verifyRelationshipTypeSelection()
    }

    private func verifyAccountTypeSelection() {
        XCTAssert(addTransferMethod.accountTypeSelect.exists)

        addTransferMethod.accountTypeSelect.tap()

        XCTAssert(app.navigationBars["Account Type"].exists)

        let table = app.tables.firstMatch

        XCTAssert(table.exists)

        table.scrollToElement(element: table.staticTexts["Checking"])

        XCTAssert(app.tables.firstMatch.staticTexts["Checking"].exists)
        XCTAssert(app.tables.firstMatch.staticTexts["Savings"].exists)

        addTransferMethod.clickGenericBackButton()
    }

    private func verifyRelationshipTypeSelection() {
        let relationshipTypeSelect = addTransferMethod.addTMTableView.staticTexts["Relationship"]

        XCTAssert(relationshipTypeSelect.exists)

        relationshipTypeSelect.tap()

        XCTAssert(app.navigationBars["Relationship"].exists)

        let table = app.tables.firstMatch

        XCTAssert(table.exists)
        XCTAssert(table.staticTexts["Self"].exists)

        addTransferMethod.clickGenericBackButton()
    }

    private func verifyAccountHolderSection() {
        addTransferMethod.addTMTableView.scrollToElement(element: addTransferMethod.addTMTableView.otherElements["ACCOUNT HOLDER"])

        XCTAssert(addTransferMethod.addTMTableView.otherElements["ACCOUNT HOLDER"].exists )

        XCTAssert(addTransferMethod.addTMTableView.staticTexts["First Name"].exists)
        XCTAssert(addTransferMethod.addTMTableView.textFields["firstName"].exists)

        XCTAssert(addTransferMethod.addTMTableView.staticTexts["Middle Name"].exists)
        XCTAssert(addTransferMethod.addTMTableView.textFields["middleName"].exists)

        XCTAssert(addTransferMethod.addTMTableView.staticTexts["Last Name"].exists)
        XCTAssert(addTransferMethod.addTMTableView.textFields["lastName"].exists)

        XCTAssert(addTransferMethod.addTMTableView.staticTexts["Phone Number"].exists)
        XCTAssert(addTransferMethod.addTMTableView.textFields["phoneNumber"].exists)

        XCTAssert(addTransferMethod.addTMTableView.staticTexts["Mobile Number"].exists)
        XCTAssert(addTransferMethod.addTMTableView.textFields["mobileNumber"].exists)

        XCTAssert(addTransferMethod.addTMTableView.staticTexts["Date of Birth"].exists)
        XCTAssert(addTransferMethod.addTMTableView.textFields["dateOfBirth"].exists)

        XCTAssertNotNil(app.tables.otherElements
            .containing(NSPredicate(format: "label CONTAINS %@", "Note: we are not able to support adding an account for someone else.")))
    }

    private func verifyAddressSection() {
        addTransferMethod.addTMTableView.scrollToElement(element: addTransferMethod.addTMTableView.staticTexts["Address"])

        XCTAssert(addTransferMethod.addTMTableView.staticTexts["Address"].exists)

        XCTAssert(addTransferMethod.addTMTableView.staticTexts["Country"].exists)

        XCTAssert(addTransferMethod.addTMTableView.staticTexts["State/Province"].exists)
        XCTAssert(addTransferMethod.addTMTableView.textFields["stateProvince"].exists)

        XCTAssert(addTransferMethod.addTMTableView.staticTexts["Street"].exists)
        XCTAssert(addTransferMethod.addTMTableView.textFields["addressLine1"].exists)

        XCTAssert(addTransferMethod.addTMTableView.staticTexts["City"].exists)
        XCTAssert(addTransferMethod.addTMTableView.textFields["city"].exists)

        XCTAssert(addTransferMethod.addTMTableView.staticTexts["Zip/Postal Code"].exists)
        XCTAssert(addTransferMethod.addTMTableView.textFields["postalCode"].exists)
    }
}
