import XCTest

class AddTransferMethodBankAccountBusinessTests: BaseBusinessTests {
    var selectTransferMethodType: SelectTransferMethodType!
    var addTransferMethod: AddTransferMethod!

    let bankAccount = NSPredicate(format: "label CONTAINS[c] 'Bank Account'")

    override func setUp() {
        super.setUp()

        setUpBankAccountScreen()
    }

    func testAddTransferMethodBankAccountBusiness_displaysElementsOnBusinessProfileTmcResponse() {
        waitForNonExistence(spinner)

        XCTAssert(app.navigationBars.staticTexts["Bank Account"].exists)

        verifyAccountInformationSection()
        verifyBusinessAccountHolderSection()
        verifyAddressSection()

        addTransferMethod.addTMTableView.scrollToElement(element: addTransferMethod.addTMTableView.otherElements["TRANSFER METHOD INFORMATION"])

        XCTAssert(addTransferMethod.addTMTableView.otherElements["TRANSFER METHOD INFORMATION"].exists)

        addTransferMethod.addTMTableView.scrollToElement(element: addTransferMethod.createTransferMethodButton)
        XCTAssert(addTransferMethod.createTransferMethodButton.exists)
    }

    func testAddTransferMethodBankAccountBusiness_createBankAccountBusiness() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/bank-accounts",
                             filename: "BankAccountBusinessResponse",
                             method: HTTPMethod.post)

        waitForNonExistence(spinner)

        addTransferMethod.setBranchId("021000021")
        addTransferMethod.setAccountNumber("7861012347")
        addTransferMethod.selectAccountType("Checking")
        addTransferMethod.selectRelationship("Own company")
        addTransferMethod.setNameBusiness("Smith & Co")
        addTransferMethod.setPhoneNumber("+16045555555")
        addTransferMethod.setMobileNumber("+16046666666")
        addTransferMethod.selectCountry("United States")
        addTransferMethod.setStateProvince("Maine")
        addTransferMethod.setStreet("632 Broadway")
        addTransferMethod.setCity("Bangor")
        addTransferMethod.setPostalCode("04401")

        app.scrollToElement(element: addTransferMethod.createTransferMethodButton)

        addTransferMethod.clickCreateTransferMethodButton()

        waitForNonExistence(spinner)

        XCTAssert(app.navigationBars.staticTexts["Account Settings"].exists)
    }
}

private extension AddTransferMethodBankAccountBusinessTests {
    func setUpBankAccountScreen() {
        selectTransferMethodType = SelectTransferMethodType(app: app)
        addTransferMethod = AddTransferMethod(app: app, for: .bankAccount)

        app.tables.cells.containing(.staticText, identifier: "Add Transfer Method").element(boundBy: 0).tap()
        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)

        selectTransferMethodType.selectCountry(country: "United States")
        selectTransferMethodType.selectCurrency(currency: "US Dollar")

        app.tables["transferMethodTableView"].staticTexts.element(matching: bankAccount).tap()
    }

    func verifyAccountInformationSection() {
        XCTAssert(addTransferMethod.addTMTableView.otherElements["ACCOUNT INFORMATION - UNITED STATES (USD)"].exists)
        XCTAssert(addTransferMethod.addTMTableView.cells.staticTexts["Routing Number"].exists)
        XCTAssert(addTransferMethod.branchIdInput.exists)

        XCTAssert(addTransferMethod.addTMTableView.staticTexts["Account Number"].exists)
        XCTAssert(addTransferMethod.accountNumberInput.exists)

        verifyAccountTypeSelection()
    }

    func verifyAccountTypeSelection() {
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

    func verifyBusinessAccountHolderSection() {
        addTransferMethod.addTMTableView.scrollToElement(element: addTransferMethod.addTMTableView.otherElements["ACCOUNT HOLDER"])

        XCTAssert(addTransferMethod.addTMTableView.otherElements["ACCOUNT HOLDER"].exists )

        XCTAssert(addTransferMethod.addTMTableView.staticTexts["Business Name"].exists)
        XCTAssert(addTransferMethod.inputNameBusiness.exists)

        XCTAssert(addTransferMethod.addTMTableView.staticTexts["Phone Number"].exists)
        XCTAssert(addTransferMethod.inputPhoneNumber.exists)

        XCTAssert(addTransferMethod.addTMTableView.staticTexts["Mobile Number"].exists)
        XCTAssert(addTransferMethod.inputMobileNumber.exists)

        XCTAssertNotNil(app.tables.otherElements
            .containing(NSPredicate(format: "label CONTAINS %@", "Note: we are not able to support adding an account for someone else.")))
    }

    func verifyAddressSection() {
        addTransferMethod.addTMTableView.scrollToElement(element: addTransferMethod.addTMTableView.staticTexts["Address"])

        XCTAssert(addTransferMethod.addTMTableView.staticTexts["Address"].exists)

        XCTAssert(addTransferMethod.selectCountry.exists)

        XCTAssert(addTransferMethod.addTMTableView.staticTexts["State/Province"].exists)
        XCTAssert(addTransferMethod.inputStateProvince.exists)

        XCTAssert(addTransferMethod.addTMTableView.staticTexts["Street"].exists)
        XCTAssert(addTransferMethod.inputStreet.exists)

        XCTAssert(addTransferMethod.addTMTableView.staticTexts["City"].exists)
        XCTAssert(addTransferMethod.inputCity.exists)

        XCTAssert(addTransferMethod.addTMTableView.staticTexts["Zip/Postal Code"].exists)
        XCTAssert(addTransferMethod.inputZip.exists)
    }
}
