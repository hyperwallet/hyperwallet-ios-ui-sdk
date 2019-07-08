import XCTest

class AddTransferMethodBankAccountIndividualTests: BaseTests {
    var selectTransferMethodType: SelectTransferMethodType!
    var addTransferMethod: AddTransferMethod!

    let bankAccount = NSPredicate(format: "label CONTAINS[c] 'Bank Account'")

    override func setUp() {
        super.setUp()

        app = XCUIApplication()
        app.launchEnvironment = [
            "COUNTRY": "US",
            "CURRENCY": "USD",
            "ACCOUNT_TYPE": "BANK_ACCOUNT",
            "PROFILE_TYPE": "INDIVIDUAL"
        ]
        app.launch()

        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodConfigurationBankAccountResponse",
                             method: HTTPMethod.post)

        app.tables.cells.staticTexts["Add Transfer Method"].tap()
        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)
        addTransferMethod = AddTransferMethod(app: app)
    }

    func testAddTransferMethod_displaysElementsOnTmcResponse() {
        XCTAssert(app.navigationBars["Bank Account"].exists)

        verifyAccountInformationSection()
        verifyIndividualAccountHolderSection()
        verifyAddressSection()

        XCTAssert(addTransferMethod.transferMethodInformationHeader.exists)
        XCTAssert(addTransferMethod.addTransferMethodTableView
            .staticTexts["Transaction Fees: USD 2.00 Processing Time: 1-2 Business days"].exists)

        app.scroll(to: addTransferMethod.createTransferMethodButton)
        XCTAssert(addTransferMethod.createTransferMethodButton.exists)
    }

    func testAddTransferMethod_verifyPresetValues() {
        verifyPresetValue(for: addTransferMethod.firstNameInput, with: "Neil")
        verifyPresetValue(for: addTransferMethod.lastNameInput, with: "Louis")
        verifyPresetValue(for: addTransferMethod.dateOfBirthInput, with: "January 1, 1980")
        verifyPresetValue(for: addTransferMethod.phoneNumberInput, with: "+1 604 6666666")
        verifyPresetValue(for: addTransferMethod.mobileNumberInput, with: "604 666 6666")
        verifyPresetValue(for: addTransferMethod.stateProvinceInput, with: "BC")
        verifyPresetValue(for: addTransferMethod.addressLineInput, with: "950 Granville Street")
        verifyPresetValue(for: addTransferMethod.cityInput, with: "Vancouver")
        verifyPresetValue(for: addTransferMethod.postalCodeInput, with: "V6Z1L2")
    }

    func testAddTransferMethod_verifyNotEditableFields() {
        addTransferMethod.firstNameInput.tap()
        XCTAssertFalse(app.keyboards.element.exists)
        addTransferMethod.lastNameInput.tap()
        XCTAssertFalse(app.keyboards.element.exists)
    }

    func testAddTransferMethod_returnsErrorOnInvalidPattern() {
        addTransferMethod.setBranchId("abc123abc")
        addTransferMethod.setBankAccountId("1a31a")

        addTransferMethod.clickCreateTransferMethodButton()

        XCTAssert(app.tables["addTransferMethodTable"].staticTexts["branchId_error"].exists)
        XCTAssert(app.tables["addTransferMethodTable"].staticTexts["bankAccountId_error"].exists)
    }

    func testAddTransferMethod_returnsErrorOnInvalidLength() {
        addTransferMethod.setBranchId("91")
        addTransferMethod.setBankAccountId("19")

        addTransferMethod.clickCreateTransferMethodButton()

        XCTAssert(app.tables["addTransferMethodTable"].staticTexts["branchId_error"].exists)
        XCTAssert(app.tables["addTransferMethodTable"].staticTexts["bankAccountId_error"].exists)
    }

    func testAddTransferMethod_returnsErrorOnInvalidPresence() {
        addTransferMethod.setBranchId("")
        addTransferMethod.setBankAccountId("")

        addTransferMethod.clickCreateTransferMethodButton()

        XCTAssert(app.tables["addTransferMethodTable"].staticTexts["branchId_error"].exists)
        XCTAssert(app.tables["addTransferMethodTable"].staticTexts["bankAccountId_error"].exists)
        XCTAssert(app.tables["addTransferMethodTable"].staticTexts["bankAccountPurpose_error"].exists)
    }

    func testAddTransferMethod_createBankAccountInvalidRouting() {
        mockServer.setupStubError(url: "/rest/v3/users/usr-token/bank-accounts",
                                  filename: "BankAccountInvalidRoutingResponse",
                                  method: HTTPMethod.post)

        addTransferMethod.setBranchId("021000022")
        addTransferMethod.setBankAccountId("12345")
        addTransferMethod.selectAccountType("CHECKING")

        addTransferMethod.clickCreateTransferMethodButton()
        waitForNonExistence(spinner)

        XCTAssertNotNil(app.tables.otherElements
            .containing(NSPredicate(format: "label CONTAINS %@", "Routing Number [021000022] is not valid. " +
                "Please modify Routing Number to a valid ACH Routing Number of the branch of your bank.")))
    }

    func testAddTransferMethod_createBankAccountValidResponse() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/bank-accounts",
                             filename: "BankAccountIndividualResponse",
                             method: HTTPMethod.post)

        addTransferMethod.setBranchId("021000021")
        addTransferMethod.setBankAccountId("12345")
        addTransferMethod.selectAccountType("CHECKING")
        addTransferMethod.setMiddleName("Adam")
        addTransferMethod.clickCreateTransferMethodButton()
        waitForNonExistence(spinner)

        XCTAssert(app.navigationBars["Account Settings"].exists)
    }

    func testAddTransferMethod_createBankAccountUnexpectedError() {
        mockServer.setupStubError(url: "/rest/v3/users/usr-token/bank-accounts",
                                  filename: "UnexpectedErrorResponse",
                                  method: HTTPMethod.post)

        addTransferMethod.setBranchId("021000022")
        addTransferMethod.setBankAccountId("12345")
        addTransferMethod.selectAccountType("CHECKING")

        addTransferMethod.clickCreateTransferMethodButton()
        waitForNonExistence(spinner)

        XCTAssert(app.alerts["Unexpected Error"].exists)
        XCTAssert(app.alerts["Unexpected Error"].staticTexts["Oops... Something went wrong, please try again"].exists)
        app.alerts["Unexpected Error"].buttons["OK"].tap()
        XCTAssertFalse(app.alerts["Unexpected Error"].exists)

        waitForExistence(app.navigationBars["Account Settings"])
        XCTAssertTrue(app.navigationBars["Account Settings"].exists)
    }
}

private extension AddTransferMethodBankAccountIndividualTests {
    func verifyAccountInformationSection() {
        XCTAssert(addTransferMethod.addTransferMethodTableView
            .staticTexts["Account Information - United States (USD)"].exists)
        XCTAssertEqual(addTransferMethod.branchIdLabel.label, "Routing Number")
        XCTAssert(addTransferMethod.branchIdInput.exists)
        XCTAssertEqual(addTransferMethod.bankAccountIdLabel.label, "Account Number")
        XCTAssert(addTransferMethod.bankAccountIdInput.exists)
        XCTAssertEqual(addTransferMethod.accountTypeLabel.label, "Account Type")

        addTransferMethod.accountTypeLabel.tap()
        XCTAssert(app.navigationBars["Account Type"].exists)

        let table = app.tables.firstMatch

        XCTAssert(table.exists)
        waitForNonExistence(spinner)

        XCTAssert(app.tables.firstMatch.staticTexts["CHECKING"].exists)
        XCTAssert(app.tables.firstMatch.staticTexts["SAVINGS"].exists)

        addTransferMethod.clickBackButton()
    }

    func verifyIndividualAccountHolderSection() {
        XCTAssert(addTransferMethod.accountHolderHeader.exists)
        XCTAssertEqual(addTransferMethod.firstNameLabel.label, "First Name")
        XCTAssert(addTransferMethod.firstNameInput.exists)
        XCTAssertEqual(addTransferMethod.middleNameLabel.label, "Middle Name")
        XCTAssert(addTransferMethod.middleNameInput.exists)
        XCTAssertEqual(addTransferMethod.lastNameLabel.label, "Last Name")
        XCTAssert(addTransferMethod.lastNameInput.exists)
        XCTAssertEqual(addTransferMethod.phoneNumberLabel.label, "Phone Number")
        XCTAssert(addTransferMethod.phoneNumberInput.exists)
        XCTAssertEqual(addTransferMethod.mobileNumberLabel.label, "Mobile Number")
        XCTAssert(addTransferMethod.mobileNumberInput.exists)
        XCTAssertEqual(addTransferMethod.dateOfBirthLabel.label, "Date of Birth")
        XCTAssert(addTransferMethod.dateOfBirthInput.exists)
        XCTAssertNotNil(app.tables.otherElements
            .containing(NSPredicate(format: "label CONTAINS %@",
                                    "Note: we are not able to support adding an account for someone else.")))
    }

    func verifyAddressSection() {
        XCTAssert(addTransferMethod.addressHeader.exists)
        XCTAssertEqual(addTransferMethod.countryLabel.label, "Country")
        XCTAssert(addTransferMethod.countrySelect.exists)
        XCTAssertEqual(addTransferMethod.stateProvinceLabel.label, "State/Province")
        XCTAssert(addTransferMethod.stateProvinceInput.exists)
        XCTAssertEqual(addTransferMethod.addressLineLabel.label, "Street")
        XCTAssert(addTransferMethod.addressLineInput.exists)
        XCTAssertEqual(addTransferMethod.cityLabel.label, "City")
        XCTAssert(addTransferMethod.cityInput.exists)
        XCTAssertEqual(addTransferMethod.postalCodeLabel.label, "Zip/Postal Code")
        XCTAssert(addTransferMethod.postalCodeInput.exists)
    }

    func verifyPresetValue(for uiElement: XCUIElement, with text: String) {
        guard let element = uiElement.value as? String else {
            XCTFail("preset value is nill")
            return
        }

        XCTAssertEqual(element, text)
    }
}
