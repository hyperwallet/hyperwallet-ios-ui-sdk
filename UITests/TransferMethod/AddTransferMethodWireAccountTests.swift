import XCTest

class AddTransferMethodWireAccountIndividualTests: BaseTests {
    var selectTransferMethodType: SelectTransferMethodType!
    var addTransferMethod: AddTransferMethod!
    var otherElements: XCUIElementQuery!

    var bankIdPatternError: String!
    var branchIdPatternError: String!
    var bankAccountIdPatternError: String!

    var bankIdEmptyError: String!
    var branchIdEmptyError: String!
    var bankAccountIdEmptyError: String!

    var bankIdLengthError: String!
    var branchIdLengthError: String!
    var bankAccountIdLengthError: String!

    let wireAccount = NSPredicate(format: "label CONTAINS[c] 'Wire Transfer'")
    override func setUp() {
        super.setUp()

        app = XCUIApplication()
        app.launchEnvironment = [
            "COUNTRY": "US",
            "CURRENCY": "USD",
            "ACCOUNT_TYPE": "WIRE_ACCOUNT",
            "PROFILE_TYPE": "INDIVIDUAL"
        ]
        app.launch()

        addTransferMethod = AddTransferMethod(app: app)
        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodConfigurationWireAccountResponse",
                             method: HTTPMethod.post)

        bankIdPatternError = addTransferMethod.getPatternError(label: addTransferMethod.swiftNumber)
        branchIdPatternError = addTransferMethod.getPatternError(label: addTransferMethod.routingNumber)
        bankAccountIdPatternError = addTransferMethod.getPatternError(label: addTransferMethod.accountNumberORIBan)

        bankIdEmptyError = addTransferMethod.getEmptyError(label: addTransferMethod.swiftNumber)
        branchIdEmptyError = addTransferMethod.getEmptyError(label: addTransferMethod.swiftNumber)
        bankAccountIdEmptyError = addTransferMethod.getEmptyError(label: addTransferMethod.accountNumberORIBan)

        bankIdLengthError = addTransferMethod
            .getLengthConstraintError(label: addTransferMethod.swiftNumber, min: 8, max: 11)
        branchIdLengthError = addTransferMethod.getRoutingNumberError(length: 9)
        bankAccountIdLengthError = addTransferMethod
            .getLengthConstraintError(label: addTransferMethod.accountNumberORIBan, min: 4, max: 17)

        otherElements = addTransferMethod.addTransferMethodTableView.otherElements

        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)
        app.tables.cells.staticTexts["Add Transfer Method"].tap()
        waitForExistence(addTransferMethod.navBarWireAccount)
    }

    func testAddTransferMethod_displaysElementsOnTmcResponse() {
        XCTAssert(app.navigationBars["Wire Transfer Account"].exists)

        verifyAccountInformationSection()
        verifyIntermediaryAccountSection()
        verifyIndividualAccountHolderSection()
        verifyAddressSection()
        verifyDefaultValues()

        XCTAssert(addTransferMethod.transferMethodInformationHeader.exists)
        XCTAssert(addTransferMethod.addTransferMethodTableView.staticTexts["$20.00 fee"].exists)

        addTransferMethod.addTransferMethodTableView.scroll(to: addTransferMethod.createTransferMethodButton)
        XCTAssert(addTransferMethod.createTransferMethodButton.exists)
    }

    func testAddTransferMethod_returnsErrorOnInvalidPresence() {
        addTransferMethod.setBankId("")
        addTransferMethod.setBranchId("")
        addTransferMethod.setBankAccountId("")

        addTransferMethod.clickCreateTransferMethodButton()

        XCTAssert(addTransferMethod.bankIdError.exists)
        XCTAssert(addTransferMethod.branchIdError.exists)
        XCTAssert(addTransferMethod.bankAccountIdError.exists)

        XCTAssert(otherElements.containing(NSPredicate(format: "label CONTAINS %@", bankIdEmptyError)).count == 1)
        XCTAssert(otherElements.containing(NSPredicate(format: "label CONTAINS %@", branchIdEmptyError)).count == 1)
        XCTAssert(otherElements
            .containing(NSPredicate(format: "label CONTAINS %@", bankAccountIdEmptyError)).count == 1)
    }

    func testAddTransferMethod_returnsErrorOnInvalidPattern() {
        addTransferMethod.setBankId("1a-31a-56")
        addTransferMethod.setBranchId("abc123abc")
        addTransferMethod.setBankAccountId(".1a-31a")

        addTransferMethod.clickCreateTransferMethodButton()

        XCTAssert(addTransferMethod.bankIdError.exists)
        XCTAssert(addTransferMethod.branchIdError.exists)
        XCTAssert(addTransferMethod.bankAccountIdError.exists)

        XCTAssert(otherElements.containing(NSPredicate(format: "label CONTAINS %@", bankIdPatternError)).count == 1)
        XCTAssert(otherElements.containing(NSPredicate(format: "label CONTAINS %@", branchIdPatternError)).count == 1)
        XCTAssert(otherElements
            .containing(NSPredicate(format: "label CONTAINS %@", bankAccountIdPatternError)).count == 1)
    }

    func testAddTransferMethod_returnsErrorOnInvalidLength() {
        addTransferMethod.setBranchId("1a-31a")
        addTransferMethod.setBankId("a")
        addTransferMethod.setBankAccountId("")

        addTransferMethod.clickCreateTransferMethodButton()

        XCTAssert(addTransferMethod.bankIdError.exists)
        XCTAssert(addTransferMethod.branchIdError.exists)
        XCTAssert(addTransferMethod.bankAccountIdError.exists)

        XCTAssert(otherElements.containing(NSPredicate(format: "label CONTAINS %@", bankIdLengthError)).count == 1)
        XCTAssert(otherElements.containing(NSPredicate(format: "label CONTAINS %@", branchIdLengthError)).count == 1)
    }

    func testAddTransferMethod_createBankAccount() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/bank-accounts",
                             filename: "WireAccountIndividualResponse",
                             method: HTTPMethod.post)

        waitForNonExistence(spinner)

        addTransferMethod.setBankId("HGASUS31")
        addTransferMethod.setBranchId("026009593")
        addTransferMethod.setBankAccountId("675825208")

        addTransferMethod.setAdditionalWireInstructions("This is instruction")
        addTransferMethod.setIntermediaryBankId("ELREUS44")
        addTransferMethod.setIntermediaryBankAccountId("246810")

        addTransferMethod.setFirstName("Tommy")
        addTransferMethod.setLastName("Gray")
        addTransferMethod.setMiddleName("Adam")
        addTransferMethod.setDateOfBirth(yearOfBirth: "1980", monthOfBirth: "January", dayOfBirth: "1")

        addTransferMethod.setPhoneNumber("604-345-1777")
        addTransferMethod.setMobileNumber("604-345-1888")

        addTransferMethod.selectCountry("United States")
        addTransferMethod.setStateProvince("CA")
        addTransferMethod.setStreet("575 Market Street")
        addTransferMethod.setCity("San Francisco")
        addTransferMethod.setPostalCode("94105")

        addTransferMethod.clickCreateTransferMethodButton()

        waitForNonExistence(spinner)

        XCTAssert(app.navigationBars["Account Settings"].exists)
    }
}

private extension AddTransferMethodWireAccountIndividualTests {
    func verifyAccountInformationSection() {
        let accountInformation = String(format: "account_information".localized(), "UNITED STATES", "USD")
        XCTAssert(addTransferMethod.addTransferMethodTableView.staticTexts[accountInformation].exists)
        XCTAssert(addTransferMethod.elementQuery["BIC/SWIFT"].exists)
        XCTAssert(addTransferMethod.bankIdInput.exists)
        XCTAssert(addTransferMethod.elementQuery["Routing Number"].exists)
        XCTAssert(addTransferMethod.branchIdInput.exists)
        XCTAssert(addTransferMethod.elementQuery["Account Number OR IBAN"].exists)
        XCTAssert(addTransferMethod.bankAccountIdInput.exists)
    }

    func verifyIntermediaryAccountSection() {
        XCTAssert(addTransferMethod.intermediaryAccountHeader.exists)
        XCTAssert(addTransferMethod.elementQuery["Additional Wire Instructions"].exists)
        XCTAssert(addTransferMethod.wireInstructionsInput.exists)
        XCTAssert(addTransferMethod.elementQuery["Intermediary BIC / SWIFT Code"].exists)
        XCTAssert(addTransferMethod.intermediaryBankIdInput.exists)
        XCTAssert(addTransferMethod.elementQuery["Intermediary Account Number"].exists)
        XCTAssert(addTransferMethod.intermediaryBankAccountIdInput.exists)
    }

    func verifyIndividualAccountHolderSection() {
        XCTAssert(addTransferMethod.accountHolderHeader.exists)
        XCTAssert(addTransferMethod.elementQuery[addTransferMethod.firstName].exists)
        XCTAssert(addTransferMethod.firstNameInput.exists)
        XCTAssert(addTransferMethod.elementQuery[addTransferMethod.middleName].exists)
        XCTAssert(addTransferMethod.lastNameInput.exists)
        XCTAssert(addTransferMethod.elementQuery[addTransferMethod.lastName].exists)
        XCTAssert(addTransferMethod.middleNameInput.exists)
        XCTAssert(addTransferMethod.elementQuery[addTransferMethod.dateOfBirth].exists)
        XCTAssert(addTransferMethod.dateOfBirthInput.exists)
    }

    func verifyContactInformationSection() {
        XCTAssert(addTransferMethod.contactInformationHeader.exists )
        XCTAssert(addTransferMethod.addTransferMethodTableView.staticTexts[addTransferMethod.phoneNumber].exists)
        XCTAssert(addTransferMethod.phoneNumberInput.exists)
    XCTAssert(addTransferMethod.addTransferMethodTableView.staticTexts[addTransferMethod.mobileNumber].exists)
        XCTAssert(addTransferMethod.mobileNumberInput.exists)
    }

    func verifyAddressSection() {
        XCTAssert(addTransferMethod.addressHeader.exists)
        XCTAssert(addTransferMethod.countrySelect.exists)
        XCTAssert(addTransferMethod.elementQuery["State/Province"].exists)
        XCTAssert(addTransferMethod.stateProvinceInput.exists)
        XCTAssert(addTransferMethod.elementQuery["Street"].exists)
        XCTAssert(addTransferMethod.addressLineInput.exists)
        XCTAssert(addTransferMethod.elementQuery["City"].exists)
        XCTAssert(addTransferMethod.cityInput.exists)
        XCTAssert(addTransferMethod.elementQuery["Zip/Postal Code"].exists)
        XCTAssert(addTransferMethod.postalCodeInput.exists)
    }

    func verifyDefaultValues() {
        XCTAssertEqual(addTransferMethod.bankIdInput.value as? String, "")
        XCTAssertEqual(addTransferMethod.branchIdInput.value as? String, "")
        XCTAssertEqual(addTransferMethod.bankAccountIdInput.value as? String, "")

        XCTAssertEqual(addTransferMethod.wireInstructionsInput.value as? String, "")
        XCTAssertEqual(addTransferMethod.intermediaryBankIdInput.value as? String, "")
        XCTAssertEqual(addTransferMethod.intermediaryBankAccountIdInput.value as? String, "")

        XCTAssertEqual(addTransferMethod.firstNameInput.value as? String, "Craig")
        XCTAssertEqual(addTransferMethod.middleNameInput.value as? String, "")
        XCTAssertEqual(addTransferMethod.lastNameInput.value as? String, "Brenden")
        XCTAssertEqual(addTransferMethod.dateOfBirthInput.value as? String, "January 1, 1980")

        XCTAssertEqual(addTransferMethod.phoneNumberInput.value as? String, "+1 604 6666666")
        XCTAssertEqual(addTransferMethod.mobileNumberInput.value as? String, "604 666 6666")

        XCTAssert(addTransferMethod.elementQuery["Canada"].exists)
        XCTAssertEqual(addTransferMethod.stateProvinceInput.value as? String, "BC")
        XCTAssertEqual(addTransferMethod.addressLineInput.value as? String, "950 Granville Street")
        XCTAssertEqual(addTransferMethod.cityInput.value as? String, "Vancouver")
        XCTAssertEqual(addTransferMethod.postalCodeInput.value as? String, "V6Z1L2")
    }
}
