import XCTest

class AddTransferMethodWireAccountIndividualTests: BaseTests {
    var selectTransferMethodType: SelectTransferMethodType!
    var addTransferMethod: AddTransferMethod!

    let wireAccount = NSPredicate(format: "label CONTAINS[c] 'Wire Transfer'")

    override func setUp() {
        profileType = .individual
        super.setUp()

        // Initialize stubs
        setUpBankAccountScreen()
    }

    func testAddTransferMethod_displaysElementsOnIndividualProfileTmcResponse() {
        waitForNonExistence(spinner)

        XCTAssert(app.navigationBars.staticTexts["Wire Account"].exists)

        verifyAccountInformationSection()
        verifyIntermediaryAccountSection()
        verifyIndividualAccountHolderSection()
        verifyAddressSection()
        verifyDefaultValues()

        addTransferMethod.addTransferMethodTableView
            .scroll(to: addTransferMethod.addTransferMethodTableView.otherElements["TRANSFER METHOD INFORMATION"])

        XCTAssert(addTransferMethod.addTransferMethodTableView.otherElements["TRANSFER METHOD INFORMATION"].exists)

        addTransferMethod.addTransferMethodTableView.scroll(to: addTransferMethod.createTransferMethodButton)
        XCTAssert(addTransferMethod.createTransferMethodButton.exists)
    }

    func testAddTransferMethod_createBankAccount() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/bank-accounts",
                             filename: "WireAccountIndividualResponse",
                             method: HTTPMethod.post)

        waitForNonExistence(spinner)

        addTransferMethod.setBankId("HGASUS31")
        addTransferMethod.setBranchId("026009593")
        addTransferMethod.setAccountNumber("675825208")

        addTransferMethod.setAdditionalWireInstructions("This is instruction")
        addTransferMethod.selectRelationship("Self")
        addTransferMethod.setIntermediaryBankId("ELREUS44")
        addTransferMethod.setIntermediaryBankAccountId("246810")

        addTransferMethod.setNameFirst("Tommy")
        addTransferMethod.setNameLast("Gray")
        addTransferMethod.setNameMiddle("Adam")
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

        XCTAssert(app.navigationBars.staticTexts["Account Settings"].exists)
    }

    func testAddTransferMethodBankAccountBusiness_displaysFeeAndProcessingElementsOnTmcResponse() {
        var feeAndProcessing: String
        if #available(iOS 12.0, *) {
            feeAndProcessing = "Transaction Fees: USD 20.00"
        } else {
            feeAndProcessing = "Transaction Fees: USD 20.00"
        }
        XCTAssert(addTransferMethod.addTransferMethodTableView.staticTexts[feeAndProcessing].exists)
    }
}

private extension AddTransferMethodWireAccountIndividualTests {
    func setUpBankAccountScreen() {
        mockServer.setupGraphQLStubs(for: profileType)

        selectTransferMethodType = SelectTransferMethodType(app: app)
        addTransferMethod = AddTransferMethod(app: app, for: .wireAccount)

        app.tables.cells.containing(.staticText, identifier: "Add Transfer Method").element(boundBy: 0).tap()
        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)

        selectTransferMethodType.selectCountry(country: "United States")
        selectTransferMethodType.selectCurrency(currency: "United States Dollar")

        app.tables["selectTransferMethodTypeTable"].staticTexts.element(matching: wireAccount).tap()
    }

    func verifyAccountInformationSection() {
        let sectionHeader = "ACCOUNT INFORMATION - UNITED STATES (USD)"
        XCTAssert(addTransferMethod.addTransferMethodTableView.otherElements[sectionHeader].exists)

        XCTAssert(addTransferMethod.addTransferMethodTableView.cells.staticTexts["BIC/SWIFT"].exists)
        XCTAssert(addTransferMethod.bankIdInput.exists)

        XCTAssert(addTransferMethod.addTransferMethodTableView.cells.staticTexts["Routing Number"].exists)
        XCTAssert(addTransferMethod.branchIdInput.exists)

        XCTAssert(addTransferMethod.addTransferMethodTableView.staticTexts["Account Number OR IBAN"].exists)
        XCTAssert(addTransferMethod.accountNumberInput.exists)
    }

    func verifyIntermediaryAccountSection() {
        XCTAssert(addTransferMethod.addTransferMethodTableView.otherElements["INTERMEDIARY ACCOUNT"].exists)

        XCTAssert(addTransferMethod.addTransferMethodTableView.cells
            .staticTexts["Additional Wire Instructions"].exists)
        XCTAssert(addTransferMethod.wireInstructionsInput.exists)

        XCTAssert(addTransferMethod.selectRelationshipType.exists)

        XCTAssert(addTransferMethod.addTransferMethodTableView.cells
            .staticTexts["Intermediary BIC / SWIFT Code"].exists)
        XCTAssert(addTransferMethod.intermediaryBankIdInput.exists)

        XCTAssert(addTransferMethod.addTransferMethodTableView.cells
            .staticTexts["Intermediary Account Number"].exists)
        XCTAssert(addTransferMethod.intermediaryBankAccountIdInput.exists)
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

        XCTAssert(addTransferMethod.addTransferMethodTableView.staticTexts["Date of Birth"].exists)
        XCTAssert(addTransferMethod.dateOfBirthInput.exists)
    }

    func verifyContactInformationSection() {
        addTransferMethod.addTransferMethodTableView
            .scroll(to: addTransferMethod.addTransferMethodTableView.otherElements["CONTACT INFORMATION"])

        XCTAssert(addTransferMethod.addTransferMethodTableView.otherElements["CONTACT INFORMATION"].exists )

        XCTAssert(addTransferMethod.addTransferMethodTableView.staticTexts["Phone Number"].exists)
        XCTAssert(addTransferMethod.phoneNumberInput.exists)

        XCTAssert(addTransferMethod.addTransferMethodTableView.staticTexts["Mobile Number"].exists)
        XCTAssert(addTransferMethod.mobileNumberInput.exists)
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
    }

    func verifyDefaultValues() {
        XCTAssertEqual(addTransferMethod.bankIdInput.value as? String, "")
        XCTAssertEqual(addTransferMethod.branchIdInput.value as? String, "")
        XCTAssertEqual(addTransferMethod.accountNumberInput.value as? String, "")

        XCTAssertEqual(addTransferMethod.wireInstructionsInput.value as? String, "")
        XCTAssertEqual(addTransferMethod.intermediaryBankIdInput.value as? String, "")
        XCTAssertEqual(addTransferMethod.intermediaryBankAccountIdInput.value as? String, "")

        XCTAssertEqual(addTransferMethod.firstNameInput.value as? String, "Craig")
        XCTAssertEqual(addTransferMethod.middleNameInput.value as? String, "")
        XCTAssertEqual(addTransferMethod.lastNameInput.value as? String, "Brenden")
        XCTAssertEqual(addTransferMethod.dateOfBirthInput.value as? String, "January 1, 1980")

        XCTAssertEqual(addTransferMethod.phoneNumberInput.value as? String, "+1 604 6666666")
        XCTAssertEqual(addTransferMethod.mobileNumberInput.value as? String, "604 666 6666")

        XCTAssert(addTransferMethod.addTransferMethodTableView.cells.staticTexts["Canada"].exists)
        XCTAssertEqual(addTransferMethod.stateProvinceInput.value as? String, "BC")
        XCTAssertEqual(addTransferMethod.streetInput.value as? String, "950 Granville Street")
        XCTAssertEqual(addTransferMethod.cityInput.value as? String, "Vancouver")
        XCTAssertEqual(addTransferMethod.zipInput.value as? String, "V6Z1L2")
    }

    func verifyPresetValue(for uiElement: XCUIElement, with text: String) {
        guard let element = uiElement.value as? String else {
            XCTFail("preset value is nill")
            return
        }

        XCTAssertEqual(element, text)
    }
}
