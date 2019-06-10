import XCTest

class AddTransferMethodBankAccountIndividualTests: BaseTests {
    var selectTransferMethodType: SelectTransferMethodType!
    var addTransferMethod: AddTransferMethod!

    let bankAccount = NSPredicate(format: "label CONTAINS[c] 'Bank Account'")

    override func setUp() {
        profileType = .individual
        super.setUp()

        // Initialize stubs
        setUpBankAccountScreen()
    }

    func testAddTransferMethod_createBankAccount() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/bank-accounts",
                             filename: "BankAccountIndividualResponse",
                             method: HTTPMethod.post)

        waitForNonExistence(spinner)

        addTransferMethod.setBranchId("021000021")
        addTransferMethod.setAccountNumber("12345")
        addTransferMethod.selectAccountType("CHECKING")
        addTransferMethod.selectRelationship("Self")
        addTransferMethod.setNameMiddle("Adam")
        addTransferMethod.clickCreateTransferMethodButton()

        waitForNonExistence(spinner)

        XCTAssert(app.navigationBars.staticTexts["Account Settings"].exists)
    }

    func testAddTransferMethod_returnsErrorOnInvalidPattern() {
        waitForNonExistence(spinner)

        addTransferMethod.setBranchId("abc123abc")
        XCTAssert(app.tables["addTransferMethodTable"].staticTexts["branchId_error"].exists)

        addTransferMethod.setAccountNumber("1a31a")
        XCTAssert(app.tables["addTransferMethodTable"].staticTexts["bankAccountId_error"].exists)
    }

    func testAddTransferMethod_createBankAccountInvalidRouting() {
        mockServer.setupStubError(url: "/rest/v3/users/usr-token/bank-accounts",
                                  filename: "BankAccountInvalidRoutingResponse",
                                  method: HTTPMethod.post)

        waitForNonExistence(spinner)

        addTransferMethod.setBranchId("021000022")
        addTransferMethod.setAccountNumber("12345")
        addTransferMethod.selectAccountType("CHECKING")

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

        addTransferMethod.setBranchId("021000022")
        addTransferMethod.setAccountNumber("12345")
        addTransferMethod.selectAccountType("CHECKING")
        addTransferMethod.selectRelationship("Self")

        addTransferMethod.clickCreateTransferMethodButton()
        waitForNonExistence(spinner)

        XCTAssert(app.alerts["Unexpected Error"].exists)
        XCTAssert(app.alerts["Unexpected Error"].staticTexts["Oops... Something went wrong, please try again"].exists)
        app.alerts["Unexpected Error"].buttons["OK"].tap()
        XCTAssertFalse(app.alerts["Unexpected Error"].exists)
        XCTAssertTrue(app.navigationBars["Add Account"].exists)
        XCTAssertTrue(app.tables["selectTransferMethodTypeTable"].staticTexts.element(matching: bankAccount).exists)
    }

    func testAddTransferMethod_displaysElementsOnIndividualProfileTmcResponse() {
        waitForNonExistence(spinner)

        XCTAssert(app.navigationBars.staticTexts["Bank Account"].exists)

        verifyAccountInformationSection()
        verifyIndividualAccountHolderSection()
        verifyAddressSection()

        addTransferMethod
            .addTransferMethodTableView
            .scroll(to: addTransferMethod.addTransferMethodTableView.otherElements["TRANSFER METHOD INFORMATION"])

        XCTAssert(addTransferMethod.addTransferMethodTableView.otherElements["TRANSFER METHOD INFORMATION"].exists)

        addTransferMethod.addTransferMethodTableView.scroll(to: addTransferMethod.createTransferMethodButton)
        XCTAssert(addTransferMethod.createTransferMethodButton.exists)
    }

    func testAddTransferMethod_verifyPresetValues() {
        waitForNonExistence(spinner)

        verifyPresetValue(for: addTransferMethod.firstNameInput, with: "Neil")
        verifyPresetValue(for: addTransferMethod.lastNameInput, with: "Louis")
        verifyPresetValue(for: addTransferMethod.dateOfBirthInput, with: "1980-01-01")
        verifyPresetValue(for: addTransferMethod.phoneNumberInput, with: "+1 604 6666666")
        verifyPresetValue(for: addTransferMethod.mobileNumberInput, with: "604 666 6666")
        verifyPresetValue(for: addTransferMethod.stateProvinceInput, with: "BC")
        verifyPresetValue(for: addTransferMethod.streetInput, with: "950 Granville Street")
        verifyPresetValue(for: addTransferMethod.cityInput, with: "Vancouver")
        verifyPresetValue(for: addTransferMethod.zipInput, with: "V6Z1L2")
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
}

private extension AddTransferMethodBankAccountIndividualTests {
    func validateAddTransferMethodBankAccountScreen() {
        XCTAssertTrue(addTransferMethod.navigationBar.exists)
        XCTAssertTrue(addTransferMethod.branchIdInput.exists)
        XCTAssertTrue(addTransferMethod.accountNumberInput.exists)
        XCTAssertTrue(addTransferMethod.accountTypeSelect.exists)
        XCTAssertNotNil(app.tables.otherElements
            .containing(NSPredicate(format: "label CONTAINS %@", "Routing Number [021000022] is not valid. " +
                "Please modify Routing Number to a valid ACH Routing Number of the branch of your bank.")))
    }

    func setUpBankAccountScreen() {
        mockServer.setupGraphQLStubs(for: profileType)

        selectTransferMethodType = SelectTransferMethodType(app: app)
        addTransferMethod = AddTransferMethod(app: app, for: .bankAccount)

        app.tables.cells.containing(.staticText, identifier: "Add Transfer Method").element(boundBy: 0).tap()
        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)

        selectTransferMethodType.selectCountry(country: "United States")
        selectTransferMethodType.selectCurrency(currency: "United States Dollar")

        app.tables["selectTransferMethodTypeTable"].staticTexts.element(matching: bankAccount).tap()
    }

    func setUpScreenWithInvalidRoutingError() {
        mockServer.setupStubError(url: "/rest/v3/users/usr-token/bank-accounts",
                                  filename: "BankAccountInvalidRoutingResponse",
                                  method: HTTPMethod.post)

        waitForNonExistence(spinner)

        addTransferMethod.setBranchId("021000022")
        addTransferMethod.setAccountNumber("12345")
        addTransferMethod.selectAccountType("CHECKING")
        addTransferMethod.clickCreateTransferMethodButton()
        waitForNonExistence(spinner)
    }

    func verifyAccountInformationSection() {
        let title = "ACCOUNT INFORMATION - UNITED STATES (USD)"
        XCTAssert(addTransferMethod.addTransferMethodTableView.otherElements[title].exists)
        XCTAssert(addTransferMethod.addTransferMethodTableView.cells.staticTexts["Routing Number"].exists)
        XCTAssert(addTransferMethod.branchIdInput.exists)

        XCTAssert(addTransferMethod.addTransferMethodTableView.staticTexts["Account Number"].exists)
        XCTAssert(addTransferMethod.accountNumberInput.exists)

        verifyAccountTypeSelection()
    }

    func verifyAccountTypeSelection() {
        XCTAssert(addTransferMethod.accountTypeSelect.exists)

        addTransferMethod.accountTypeSelect.tap()

        XCTAssert(app.navigationBars["Account Type"].exists)

        let table = app.tables.firstMatch

        XCTAssert(table.exists)
        waitForNonExistence(spinner)

        XCTAssert(app.tables.firstMatch.staticTexts["CHECKING"].exists)
        XCTAssert(app.tables.firstMatch.staticTexts["SAVINGS"].exists)

        addTransferMethod.clickGenericBackButton()
    }

    func verifyIndividualAccountHolderSection() {
        let accountHolderTitle = addTransferMethod.addTransferMethodTableView.otherElements["ACCOUNT HOLDER"]
        addTransferMethod.addTransferMethodTableView.scroll(to: accountHolderTitle)

        XCTAssert(addTransferMethod.addTransferMethodTableView.otherElements["ACCOUNT HOLDER"].exists )

        XCTAssert(addTransferMethod.addTransferMethodTableView.staticTexts["First Name"].exists)
        XCTAssert(addTransferMethod.firstNameInput.exists)

        XCTAssert(addTransferMethod.addTransferMethodTableView.staticTexts["Middle Name"].exists)
        XCTAssert(addTransferMethod.lastNameInput.exists)

        XCTAssert(addTransferMethod.addTransferMethodTableView.staticTexts["Last Name"].exists)
        XCTAssert(addTransferMethod.middleNameInput.exists)

        XCTAssert(addTransferMethod.addTransferMethodTableView.staticTexts["Phone Number"].exists)
        XCTAssert(addTransferMethod.phoneNumberInput.exists)

        XCTAssert(addTransferMethod.addTransferMethodTableView.staticTexts["Mobile Number"].exists)
        XCTAssert(addTransferMethod.mobileNumberInput.exists)

        XCTAssert(addTransferMethod.addTransferMethodTableView.staticTexts["Date of Birth"].exists)
        XCTAssert(addTransferMethod.dateOfBirthInput.exists)

        XCTAssertNotNil(app.tables.otherElements
            .containing(NSPredicate(format: "label CONTAINS %@",
                                    "Note: we are not able to support adding an account for someone else.")))
    }

    func verifyAddressSection() {
        let title = addTransferMethod.addTransferMethodTableView.staticTexts["Transfer method information"]
        addTransferMethod.addTransferMethodTableView.scroll(to: title)

        XCTAssert(addTransferMethod.addTransferMethodTableView.staticTexts["Address"].exists)

        XCTAssert(addTransferMethod.selectCountry.exists)

        XCTAssert(addTransferMethod.addTransferMethodTableView.staticTexts["State/Province"].exists)
        XCTAssert(addTransferMethod.stateProvinceInput.exists)

        XCTAssert(addTransferMethod.addTransferMethodTableView.staticTexts["Street"].exists)
        XCTAssert(addTransferMethod.streetInput.exists)

        XCTAssert(addTransferMethod.addTransferMethodTableView.staticTexts["City"].exists)
        XCTAssert(addTransferMethod.cityInput.exists)

        XCTAssert(addTransferMethod.addTransferMethodTableView.staticTexts["Zip/Postal Code"].exists)
        XCTAssert(addTransferMethod.zipInput.exists)

        func testAddTransferMethod_verifyNotEditableFields() {
            addTransferMethod.clickBackButton()
            app.tables["selectTransferMethodTypeTable"].staticTexts.element(matching: bankAccount).tap()
            addTransferMethod.firstNameInput.tap()

            XCTAssertFalse(app.keyboards.element.exists)

            addTransferMethod.lastNameInput.tap()

            XCTAssertFalse(app.keyboards.element.exists)
        }
    }

    func verifyPresetValue(for uiElement: XCUIElement, with text: String) {
        guard let element = uiElement.value as? String else {
            XCTFail("preset value is nill")
            return
        }

        XCTAssertEqual(element, text)
    }
}
