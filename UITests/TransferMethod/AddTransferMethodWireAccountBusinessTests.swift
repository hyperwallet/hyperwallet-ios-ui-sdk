import XCTest

class AddTransferMethodWireAccountBusinessTests: BaseTests {
    var selectTransferMethodType: SelectTransferMethodType!
    var addTransferMethod: AddTransferMethod!

    let bankAccount = NSPredicate(format: "label CONTAINS[c] 'Bank Account'")

    override func setUp() {
        profileType = .business
        super.setUp()

        setUpWireAccountScreen()
    }

    func testAddTransferMethodBankAccountBusiness_displaysElementsOnBusinessProfileTmcResponse() {
        waitForNonExistence(spinner)

        XCTAssert(app.navigationBars.staticTexts["Bank Account"].exists)

        verifyAccountInformationSection()
        verifyIntermediaryAccountSection()
        verifyBusinessAccountHolderSection()
        verifyContactInformationSection()
        verifyAddressSection()

        addTransferMethod.addTransferMethodTableView
            .scroll(to: addTransferMethod.addTransferMethodTableView.otherElements["TRANSFER METHOD INFORMATION"])

        XCTAssert(addTransferMethod.addTransferMethodTableView.otherElements["TRANSFER METHOD INFORMATION"].exists)

        addTransferMethod.addTransferMethodTableView.scroll(to: addTransferMethod.createTransferMethodButton)
        XCTAssert(addTransferMethod.createTransferMethodButton.exists)
    }

    func testAddTransferMethodBankAccountBusiness_createBankAccountBusiness() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/bank-accounts",
                             filename: "BankAccountBusinessResponse",
                             method: HTTPMethod.post)

        waitForNonExistence(spinner)

        addTransferMethod.setBranchId("021000021")
        addTransferMethod.setAccountNumber("7861012347")
        addTransferMethod.selectAccountType("CHECKING")
        addTransferMethod.selectRelationship("Own company")
        addTransferMethod.setNameBusiness("Smith & Co")
        addTransferMethod.setPhoneNumber("+16045555555")
        addTransferMethod.setMobileNumber("+16046666666")
        addTransferMethod.selectCountry("United States")
        addTransferMethod.setStateProvince("Maine")
        addTransferMethod.setStreet("632 Broadway")
        addTransferMethod.setCity("Bangor")
        addTransferMethod.setPostalCode("04401")

        addTransferMethod.clickCreateTransferMethodButton()

        waitForNonExistence(spinner)

        XCTAssert(app.navigationBars.staticTexts["Account Settings"].exists)
    }
}

private extension AddTransferMethodWireAccountBusinessTests {
    func setUpWireAccountScreen() {
        mockServer.setupGraphQLStubs(for: profileType)

        selectTransferMethodType = SelectTransferMethodType(app: app)
        addTransferMethod = AddTransferMethod(app: app, for: .bankAccount)

        app.tables.cells.containing(.staticText, identifier: "Add Transfer Method").element(boundBy: 0).tap()
        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)

        selectTransferMethodType.selectCountry(country: "UNITED STATES")
        selectTransferMethodType.selectCurrency(currency: "USD")

        app.tables["selectTransferMethodTypeTable"].staticTexts.element(matching: bankAccount).tap()
    }

    func verifyAccountInformationSection() {
        let sectionHeader = "ACCOUNT INFORMATION - UNITED STATES (USD)"

        XCTAssert(addTransferMethod.addTransferMethodTableView.otherElements[sectionHeader].exists)
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

        table.scroll(to: table.staticTexts["CHECKING"])

        XCTAssert(app.tables.firstMatch.staticTexts["CHECKING"].exists)
        XCTAssert(app.tables.firstMatch.staticTexts["SAVINGS"].exists)

        addTransferMethod.clickGenericBackButton()
    }
    func verifyIntermediaryAccountSection() {
        XCTAssert(addTransferMethod.addTransferMethodTableView.otherElements["INTERMEDIARY ACCOUNT"].exists)
        XCTAssert(addTransferMethod.selectRelationshipType.exists)
    }

    func verifyBusinessAccountHolderSection() {
        addTransferMethod.addTransferMethodTableView
            .scroll(to: addTransferMethod.addTransferMethodTableView.otherElements["ACCOUNT HOLDER"])

        XCTAssert(addTransferMethod.addTransferMethodTableView.otherElements["ACCOUNT HOLDER"].exists )

        XCTAssert(addTransferMethod.addTransferMethodTableView.staticTexts["Business Name"].exists)
        XCTAssert(addTransferMethod.businessNameInput.exists)
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
}
