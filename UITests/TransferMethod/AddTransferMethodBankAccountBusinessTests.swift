import XCTest

class AddTransferMethodBankAccountBusinessTests: BaseTests {
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
            "PROFILE_TYPE": "BUSINESS"
        ]
        app.launch()

        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodConfigurationBankAccountBusinessResponse",
                             method: HTTPMethod.post)

        addTransferMethod = AddTransferMethod(app: app)
        addTransferMethod.addTransferMethodtable.tap()
        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)
        addTransferMethod = AddTransferMethod(app: app)
    }

    func testAddTransferMethodBankAccountBusiness_displaysElementsOnBusinessProfileTmcResponse() {
        XCTAssert(addTransferMethod.navBarBankAccount.exists)

        XCTAssert(addTransferMethod.addTransferMethodTableView
            .otherElements["mobileAccountInfoLabel".localized() + " - UNITED STATES (USD)"].exists)
        XCTAssertEqual(addTransferMethod.branchIdLabel.label, "Routing Number")
        XCTAssert(addTransferMethod.branchIdInput.exists)
        XCTAssertEqual(addTransferMethod.bankAccountIdLabel.label, "Account Number")
        XCTAssert(addTransferMethod.bankAccountIdInput.exists)
        XCTAssertEqual(addTransferMethod.accountTypeLabel.label, "Account Type")

        XCTAssert(addTransferMethod.addTransferMethodTableView.otherElements["mobileAccountInfoLabel".localized()].exists )
        XCTAssertEqual(addTransferMethod.businessNameLabel.label, "Business Name")
        XCTAssert(addTransferMethod.businessNameInput.exists)
        XCTAssertEqual(addTransferMethod.phoneNumberLabel.label, "Phone Number")
        XCTAssert(addTransferMethod.phoneNumberInput.exists)
        XCTAssertEqual(addTransferMethod.mobileNumberLabel.label, "Mobile Number")
        XCTAssert(addTransferMethod.mobileNumberInput.exists)

        XCTAssert(addTransferMethod.addTransferMethodTableView.otherElements["ADDRESS"].exists)
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

        XCTAssert(addTransferMethod.addTransferMethodTableView.staticTexts["mobileFeesAndProcessingTime".localized()].exists)
        XCTAssert(addTransferMethod.addTransferMethodTableView.staticTexts["$2.00 fee"].exists)

        app.scroll(to: addTransferMethod.createTransferMethodButton)
        XCTAssert(addTransferMethod.createTransferMethodButton.exists)
    }

    func testAddTransferMethodBankAccountBusiness_createBankAccountBusiness() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/bank-accounts",
                             filename: "BankAccountBusinessResponse",
                             method: HTTPMethod.post)

        waitForNonExistence(spinner)

        addTransferMethod.setBranchId("021000021")
        addTransferMethod.setBankAccountId("7861012347")
        addTransferMethod.selectAccountType("CHECKING")
        addTransferMethod.setBusinessName("Smith & Co")
        addTransferMethod.setPhoneNumber("+16045555555")
        addTransferMethod.setMobileNumber("+16046666666")
        addTransferMethod.selectCountry("United States")
        addTransferMethod.setStateProvince("Maine")
        addTransferMethod.setStreet("632 Broadway")
        addTransferMethod.setCity("Bangor")
        addTransferMethod.setPostalCode("04401")

        addTransferMethod.clickCreateTransferMethodButton()
    }
}
