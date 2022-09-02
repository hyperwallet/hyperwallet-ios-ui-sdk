import XCTest

class AddTransferMethodBankAccountIndividualTests: BaseTests {
    var selectTransferMethodType: SelectTransferMethodType!
    var addTransferMethod: AddTransferMethod!

    let bankAccount = NSPredicate(format: "label CONTAINS[c] 'Bank Account'")
    var otherElements: XCUIElementQuery!

    var branchIdPatternError: String!
    var bankAccountIdPatternError: String!

    var branchIdEmptyError: String!
    var bankAccountIdEmptyError: String!

    var branchIdLengthError: String!
    var bankAccountIdLengthError: String!

    let invalidRoutingNumberError = "Routing Number [021000022] is not valid. " +
    "Please modify Routing Number to a valid ACH Routing Number of the branch of your bank."
    let invalidAccountError = "Note: we are not able to support adding an account for someone else."

    override func setUp() {
        super.setUp()

        app = XCUIApplication()
        app.launchArguments.append("enable-testing")
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

        addTransferMethod = AddTransferMethod(app: app)

        spinner = app.activityIndicators["activityIndicator"]
        addTransferMethod.addTransferMethodtable.tap()
        waitForNonExistence(spinner)
        waitForExistence(addTransferMethod.navBarBankAccount)

        branchIdPatternError = addTransferMethod.getPatternError(label: addTransferMethod.routingNumber)
        bankAccountIdPatternError = addTransferMethod.getPatternError(label: addTransferMethod.accountNumber)

        branchIdEmptyError = addTransferMethod.getEmptyError(label: addTransferMethod.routingNumber)
        bankAccountIdEmptyError = addTransferMethod.getEmptyError(label: addTransferMethod.accountNumber)

        branchIdLengthError = addTransferMethod.getRoutingNumberError(length: 9)
        bankAccountIdLengthError = addTransferMethod
            .getLengthConstraintError(label: addTransferMethod.accountNumber, min: 4, max: 17)

        otherElements = addTransferMethod.addTransferMethodTableView.otherElements
    }

    func testAddTransferMethod_displaysElementsOnTmcResponse() {
        XCTAssert(addTransferMethod.navBarBankAccount.exists)

        verifyAccountInformationSection()
        verifyIndividualAccountHolderSection()
        verifyAddressSection()

        XCTAssert(addTransferMethod.transferMethodInformationHeader.exists)
        XCTAssert(addTransferMethod.addTransferMethodTableView
            .staticTexts["$2.00 fee \u{2022} 1-2 Business days"].exists)

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
        waitForExistence(addTransferMethod.branchIdInput)

        addTransferMethod.firstNameInput.tap()
        XCTAssertFalse(app.keyboards.element.exists)
        addTransferMethod.lastNameInput.tap()
        XCTAssertFalse(app.keyboards.element.exists)
    }

    func testAddTransferMethod_returnsErrorOnInvalidPattern() {
        waitForExistence(addTransferMethod.branchIdInput)
        addTransferMethod.setBranchId("abc123abc")
        addTransferMethod.setBankAccountId("1a31a")

        addTransferMethod.clickCreateTransferMethodButton()

        XCTAssert(addTransferMethod.elementQuery["branchId_error"].exists)
        XCTAssert(addTransferMethod.elementQuery["bankAccountId_error"].exists)

        // Comment to address UI Test after migrate to Xcode 13 
//        XCTAssert(otherElements
//                              .containing(NSPredicate(format: "label CONTAINS %@", branchIdPatternError)).count == 1)
        
        XCTAssert(app.staticTexts
            .containing(NSPredicate(format: "label CONTAINS %@", branchIdPatternError)).firstMatch.waitForExistence(timeout: 1))
        
        XCTAssert(app.staticTexts
            .containing(NSPredicate(format: "label CONTAINS %@", bankAccountIdPatternError)).count == 1)
    }

    func testAddTransferMethod_returnsErrorOnInvalidLength() {
        waitForExistence(addTransferMethod.branchIdInput)
        addTransferMethod.setBranchId("91")
        addTransferMethod.setBankAccountId("19")

        addTransferMethod.clickCreateTransferMethodButton()
        waitForExistence(addTransferMethod.branchIdError)
        XCTAssert(addTransferMethod.branchIdError.exists)
        XCTAssert(addTransferMethod.bankAccountIdError.exists)

        XCTAssert(otherElements.containing(NSPredicate(format: "label CONTAINS %@", branchIdLengthError)).count == 1)
        XCTAssert(otherElements
            .containing(NSPredicate(format: "label CONTAINS %@", bankAccountIdLengthError)).count == 1)
    }

    func testAddTransferMethod_returnsErrorOnInvalidPresence() {
        waitForExistence(addTransferMethod.branchIdInput)

        addTransferMethod.setBranchId("")
        addTransferMethod.setBankAccountId("")

        addTransferMethod.clickCreateTransferMethodButton()

        XCTAssert(addTransferMethod.elementQuery["branchId_error"].exists)
        XCTAssert(addTransferMethod.elementQuery["bankAccountId_error"].exists)
        XCTAssert(addTransferMethod.elementQuery["bankAccountPurpose_error"].exists)
    }

    func testAddTransferMethod_createBankAccountInvalidRouting() {
        mockServer.setupStubError(url: "/rest/v3/users/usr-token/bank-accounts",
                                  filename: "BankAccountInvalidRoutingResponse",
                                  method: HTTPMethod.post)
        
        waitForExistence(addTransferMethod.branchIdInput)
        
        addTransferMethod.setBranchId("021000022")
        addTransferMethod.setBankAccountId("12345")
        addTransferMethod.selectAccountType("CHECKING")

        addTransferMethod.clickCreateTransferMethodButton()
        waitForNonExistence(spinner)

        XCTAssert(otherElements
            .containing(NSPredicate(format: "label CONTAINS %@", invalidRoutingNumberError)).count == 1)
    }
    
    func testAddTransferMethod_rest_unauthenticatedError() {
        mockServer.setupStubError(url: "/rest/v3/users/usr-token/bank-accounts",
                                  filename: "JWTTokenRevolked",
                                  method: HTTPMethod.post,
                                  statusCode: 401)
        
        waitForExistence(addTransferMethod.branchIdInput)
        
        addTransferMethod.setBranchId("021000022")
        addTransferMethod.setBankAccountId("12345")
        addTransferMethod.selectAccountType("CHECKING")

        addTransferMethod.clickCreateTransferMethodButton()
        waitForNonExistence(spinner)
        
        
        XCTAssertEqual(app.alerts.element.label, "Authentication Error")
    }

    func testAddTransferMethod_createBankAccountValidResponse() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/bank-accounts",
                             filename: "BankAccountIndividualResponse",
                             method: HTTPMethod.post)
        
        XCTAssert(addTransferMethod.navBarBankAccount.exists)
        XCTAssertTrue(app.tables["addTransferMethodTable"].textFields["branchId"].waitForExistence(timeout: 20))
        app.tables["addTransferMethodTable"].textFields["branchId"].enterText(text: "021000021")
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

        waitForExistence(addTransferMethod.accountTypeLabel)

        addTransferMethod.selectAccountType("CHECKING")
        addTransferMethod.setBranchId("021000022")
        addTransferMethod.setBankAccountId("12345")

        addTransferMethod.clickCreateTransferMethodButton()
        waitForNonExistence(spinner)

        verifyUnexpectedError()

        waitForExistence(addTransferMethod.navBar)
        XCTAssertTrue(addTransferMethod.navBar.exists)
    }
}

private extension AddTransferMethodBankAccountIndividualTests {
    func verifyAccountInformationSection() {
        let accountInformation = String(format: "account_information".localized(), "UNITED STATES", "USD")
        XCTAssert(addTransferMethod.addTransferMethodTableView.staticTexts[accountInformation].exists)
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
            XCTFail("preset value is nil")
            return
        }

        XCTAssertEqual(element, text)
    }
}
