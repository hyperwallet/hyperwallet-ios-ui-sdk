import XCTest

class AddTransferMethodWireAccountBusinessTests: BaseTests {
    var selectTransferMethodType: SelectTransferMethodType!
    var addTransferMethod: AddTransferMethod!

    let wireAccount = NSPredicate(format: "label CONTAINS[c] 'Wire Transfer'")

    override func setUp() {
        profileType = .business
        super.setUp()

        setUpWireAccountScreen()
    }

    func testAddTransferMethodBankAccountBusiness_displaysElementsOnBusinessProfileTmcResponse() {
        waitForNonExistence(spinner)

        XCTAssert(app.navigationBars.staticTexts["Wire Account"].exists)

        verifyAccountInformationSection()
        verifyIntermediaryAccountSection()
        verifyBusinessAccountHolderSection()
        verifyContactInformationSection()
        verifyAddressSection()

        addTransferMethod.addTransferMethodTableView
            .scroll(to: addTransferMethod.addTransferMethodTableView.otherElements["TRANSFER METHOD INFORMATION"])

        XCTAssert(addTransferMethod.addTransferMethodTableView.otherElements["TRANSFER METHOD INFORMATION"].exists)

        verifyDefaultValues()

        addTransferMethod.addTransferMethodTableView.scroll(to: addTransferMethod.createTransferMethodButton)
        XCTAssert(addTransferMethod.createTransferMethodButton.exists)
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

    func testAddTransferMethodBankAccountBusiness_createBankAccountBusiness() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/bank-accounts",
                             filename: "WireAccountBusinessResponse",
                             method: HTTPMethod.post)

        waitForNonExistence(spinner)

        addTransferMethod.setBankId("HGASUS31")
        addTransferMethod.setBranchId("026009593")
        addTransferMethod.setAccountNumber("675825208")

        addTransferMethod.setAdditionalWireInstructions("This is instruction")
        addTransferMethod.selectRelationship("Own company")
        addTransferMethod.setIntermediaryBankId("ELREUS44")
        addTransferMethod.setIntermediaryBankAccountId("246810")

        addTransferMethod.setNameBusiness("Some company")
        addTransferMethod.setBusinessRegistrationId("123455511")

        addTransferMethod.setPhoneNumber("604-345-1777")
        addTransferMethod.setMobileNumber("604-345-1888")

        addTransferMethod.selectCountry("United States")
        addTransferMethod.setStateProvince("WA")
        addTransferMethod.setStreet("1234, Broadway")
        addTransferMethod.setCity("Test City")
        addTransferMethod.setPostalCode("12345")

        addTransferMethod.clickCreateTransferMethodButton()

        waitForNonExistence(spinner)

        XCTAssert(app.navigationBars.staticTexts["Account Settings"].exists)
    }
}

private extension AddTransferMethodWireAccountBusinessTests {
    func setUpWireAccountScreen() {
        mockServer.setupGraphQLStubs(for: profileType)

        selectTransferMethodType = SelectTransferMethodType(app: app)
        addTransferMethod = AddTransferMethod(app: app, for: .wireAccount)

        app.tables.cells.containing(.staticText, identifier: "Add Transfer Method").element(boundBy: 0).tap()
        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)

        selectTransferMethodType.selectCountry(country: "UNITED STATES")
        selectTransferMethodType.selectCurrency(currency: "USD")

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

    func verifyBusinessAccountHolderSection() {
        addTransferMethod.addTransferMethodTableView
            .scroll(to: addTransferMethod.addTransferMethodTableView.otherElements["ACCOUNT HOLDER"])

        XCTAssert(addTransferMethod.addTransferMethodTableView.otherElements["ACCOUNT HOLDER"].exists )

        XCTAssert(addTransferMethod.addTransferMethodTableView.staticTexts["Business Name"].exists)
        XCTAssert(addTransferMethod.businessNameInput.exists)

        XCTAssert(addTransferMethod.addTransferMethodTableView.staticTexts["Business Reg Number"].exists)
        XCTAssert(addTransferMethod.businessRegistrationIdInput.exists)
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
        addTransferMethod.addTransferMethodTableView
            .scroll(to: addTransferMethod.addTransferMethodTableView.staticTexts["Address"])

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

        XCTAssertEqual(addTransferMethod.businessNameInput.value as? String, "Hyperwallet Systems")
        XCTAssertEqual(addTransferMethod.businessRegistrationIdInput.value as? String, "123455511")

        XCTAssertEqual(addTransferMethod.phoneNumberInput.value as? String, "+1 604 6666666")
        XCTAssertEqual(addTransferMethod.mobileNumberInput.value as? String, "604 666 6666")

        XCTAssert(addTransferMethod.addTransferMethodTableView.cells.staticTexts["United States"].exists)
        XCTAssertEqual(addTransferMethod.stateProvinceInput.value as? String, "WA")
        XCTAssertEqual(addTransferMethod.streetInput.value as? String, "801 Occidental Ave S")
        XCTAssertEqual(addTransferMethod.cityInput.value as? String, "Seattle")
        XCTAssertEqual(addTransferMethod.zipInput.value as? String, "98134")
    }
}
