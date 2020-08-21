import XCTest

class AddTransferMethodWireAccountUSMoreMaskingTests: BaseTests {
    var selectTransferMethodType: SelectTransferMethodType!
    var addTransferMethod: AddTransferMethod!
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

        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodConfigurationResponseWithStarMasks",
                             method: HTTPMethod.post)

        app.tables.cells.staticTexts["Add Transfer Method"].tap()
        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)
        addTransferMethod = AddTransferMethod(app: app)
    }

    /**
     default pattern "**@#**"
     */
    func testAddTransferMethod_starForAllCharTest() {
        XCTAssert(addTransferMethod.navBarWireAccount.exists)
        addTransferMethod.setFirstName("AAa2BB")
        checkSelectFieldValueIsEqualTo("AAa2BB", addTransferMethod.firstNameInput)

        addTransferMethod.setFirstName("aaa2bb")
        checkSelectFieldValueIsEqualTo("aaa2bb", addTransferMethod.firstNameInput)

        addTransferMethod.setFirstName("11a2AB")
        checkSelectFieldValueIsEqualTo("11a2AB", addTransferMethod.firstNameInput)
        addTransferMethod.setFirstName("11a2ab汉字$%%123abc")
        checkSelectFieldValueIsEqualTo("11a2ab", addTransferMethod.firstNameInput)
    }

    /**
     "defaultPattern": "##\\###\\@##-###"
     */
    func testAddTransferMethod_specialCharsTest() {
        XCTAssert(addTransferMethod.navBarWireAccount.exists)
        addTransferMethod.setBankId("11223344")
        checkSelectFieldValueIsEqualTo("11#22@33-44", addTransferMethod.bankIdInput)

        addTransferMethod.setBankId("aa11aa22aa33aa$$")
        checkSelectFieldValueIsEqualTo("11#22@33", addTransferMethod.bankIdInput)

        addTransferMethod.setBankId("11223344xxyyxx")
        checkSelectFieldValueIsEqualTo("11#22@33-44", addTransferMethod.bankIdInput)

        addTransferMethod.setBankId("汉字$%%")
        checkSelectFieldValueIsEqualTo("", addTransferMethod.bankIdInput)
    }
    /**
     "defaultPattern": "999999 ####"
     */
    func testAddTransferMethod_prefixCharsTest() {
        XCTAssert(addTransferMethod.navBarWireAccount.exists)
        addTransferMethod.setStateProvince("1234")
        checkSelectFieldValueIsEqualTo("999999 1234", addTransferMethod.stateProvinceInput)
    }

    /**
     "defaultPattern": "999999 ####"
     */
    func testAddTransferMethod_prefixCharsTestByPaste() {
        XCTAssert(addTransferMethod.navBarWireAccount.exists)

        addTransferMethod.stateProvinceInput.enterByPaste(
            text: "99991", field: addTransferMethod.stateProvinceInput, app: app)
        checkSelectFieldValueIsEqualTo("999999 1", addTransferMethod.stateProvinceInput)
    }

    /**
     default pattern "@@@\\\\@@@"
     */
    func testAddTransferMethod_fourEscapeCharsTest() {
        XCTAssert(addTransferMethod.navBarWireAccount.exists)
        addTransferMethod.setLastName("ABCDEF")

        // Assert it shows "ABC\DEF" - swift requires to enter double \\
        checkSelectFieldValueIsEqualTo("ABC\\DEF", addTransferMethod.lastNameInput)

        addTransferMethod.setLastName("ABCDEFG")
        // Assert it shows "ABC\DEF" - swift requires to enter double \\
        checkSelectFieldValueIsEqualTo("ABC\\DEF", addTransferMethod.lastNameInput)
    }

    /**
     default pattern "\\@@#*\\#@#*\\*@#*"
     */
    func testAddTransferMethod_combinedWithEscapeTest() {
        XCTAssert(addTransferMethod.navBarWireAccount.exists)
        addTransferMethod.setMiddleName("aaaaaa")
        checkSelectFieldValueIsEqualTo("@a", addTransferMethod.middleNameInput)

        addTransferMethod.setMiddleName("111111")
        checkSelectFieldValueIsEqualTo("@", addTransferMethod.middleNameInput)

        // spreadsheet-case-100 only takes a-zA-Z0-9 and therefor * is not an input
        addTransferMethod.setMiddleName("a1aa1a")
        checkSelectFieldValueIsEqualTo("@a1a#a1a", addTransferMethod.middleNameInput)

        addTransferMethod.setMiddleName("@a1a#a1a*a1a")
        checkSelectFieldValueIsEqualTo("@a1a#a1a*a1a", addTransferMethod.middleNameInput)
    }

    /**
     default pattern "#@*#@*"
     */
    func testAddTransferMethod_combinedDoubleTest() {
        XCTAssert(addTransferMethod.navBarWireAccount.exists)
        addTransferMethod.setPhoneNumber("aaaaaa")
        checkSelectFieldValueIsEqualTo("", addTransferMethod.phoneNumberInput)

        addTransferMethod.setPhoneNumber("111111")
        checkSelectFieldValueIsEqualTo("1", addTransferMethod.phoneNumberInput)

        addTransferMethod.setPhoneNumber("1a12a2")
        checkSelectFieldValueIsEqualTo("1a12a2", addTransferMethod.phoneNumberInput)

        addTransferMethod.setPhoneNumber("a1aa1a")
        checkSelectFieldValueIsEqualTo("1aa1a", addTransferMethod.phoneNumberInput)

        addTransferMethod.setPhoneNumber("1ab12b")
        checkSelectFieldValueIsEqualTo("1ab1b", addTransferMethod.phoneNumberInput)
    }

    /**
     default pattern "**\\***"
     */
    func testAddTransferMethod_charsWithEscapeTest() {
        XCTAssert(addTransferMethod.navBarWireAccount.exists)
        // spreadsheet-case-73 (same as spreadsheet case-22)
        addTransferMethod.setMobileNumber("11")
        checkSelectFieldValueIsEqualTo("11", addTransferMethod.mobileNumberInput)

        addTransferMethod.setMobileNumber("1111")
        checkSelectFieldValueIsEqualTo("11*1", addTransferMethod.mobileNumberInput)

        addTransferMethod.setMobileNumber("aa11aa11")
        checkSelectFieldValueIsEqualTo("aa*1", addTransferMethod.mobileNumberInput)

        // spreadsheet-case-76 (only takes a-zA-Z0-9 and therefore "-" is not an input)
        addTransferMethod.setMobileNumber("11-NOV")
        checkSelectFieldValueIsEqualTo("11*N", addTransferMethod.mobileNumberInput)

        // spreadsheet-case-77 (only takes a-zA-Z0-9 and therefore "-" is not an input)
        addTransferMethod.setMobileNumber("aa-aa-1111")
        checkSelectFieldValueIsEqualTo("aa*a", addTransferMethod.mobileNumberInput)
    }

    /**
     default pattern "@@\\@@@@*"
     */
    func testAddTransferMethod_letterWithEscapeTest() {
        // spreadsheet-case-47 (this will not work)
        XCTAssert(addTransferMethod.navBarWireAccount.exists)
        addTransferMethod.setIntermediaryBankId("aa")
        checkSelectFieldValueIsEqualTo("aa", addTransferMethod.intermediaryBankIdInput)

        // This will work with your implementation
        addTransferMethod.setIntermediaryBankId("aaa")
        checkSelectFieldValueIsEqualTo("aa@a", addTransferMethod.intermediaryBankIdInput)

        addTransferMethod.setIntermediaryBankId("aaaa")
        checkSelectFieldValueIsEqualTo("aa@aa", addTransferMethod.intermediaryBankIdInput)

        addTransferMethod.setIntermediaryBankId("11aa11aa")
        checkSelectFieldValueIsEqualTo("aa@aa", addTransferMethod.intermediaryBankIdInput)

        addTransferMethod.setIntermediaryBankId("aa-aa")
        checkSelectFieldValueIsEqualTo("aa@aa", addTransferMethod.intermediaryBankIdInput)

        addTransferMethod.setIntermediaryBankId("11-11-aaaa")
        checkSelectFieldValueIsEqualTo("aa@aa", addTransferMethod.intermediaryBankIdInput)
    }

    /**
     defaultPattern": "**-**"
     */
    func testAddTransferMethod_charWithDelimiterTest() {
        XCTAssert(addTransferMethod.navBarWireAccount.exists)
        addTransferMethod.setIntermediaryBankAccountId("11-")
        checkSelectFieldValueIsEqualTo("11", addTransferMethod.intermediaryBankAccountIdInput)
        addTransferMethod.setIntermediaryBankAccountId("汉汉-")
        checkSelectFieldValueIsEqualTo("", addTransferMethod.intermediaryBankAccountIdInput)
        addTransferMethod.setIntermediaryBankAccountId("汉%-")
        checkSelectFieldValueIsEqualTo("", addTransferMethod.intermediaryBankAccountIdInput)
    }

    /**
     defaultPattern": "###-##\\"  (will not test ###-##\  as '\' is invalid input)
     */
    func testAddTransferMethod_escapeCharAppearAtEndTest() {
        XCTAssert(addTransferMethod.navBarWireAccount.exists)
        addTransferMethod.setPostalCode("123-45")
        checkSelectFieldValueIsEqualTo("123-45", addTransferMethod.postalCodeInput)
    }
}
