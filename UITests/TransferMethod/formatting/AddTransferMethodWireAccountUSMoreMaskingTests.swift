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
        XCTAssert(app.navigationBars["Wire Account"].exists)
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
        XCTAssert(app.navigationBars["Wire Account"].exists)
        addTransferMethod.setBankId("11223344")
        checkSelectFieldValueIsEqualTo("11#22@33-44", addTransferMethod.bankIdInput)
    }
    /**
     "defaultPattern": "999999 ####"
     */
    func testAddTransferMethod_prefixCharsTest() {
        XCTAssert(app.navigationBars["Wire Account"].exists)
        addTransferMethod.setStateProvince("1234")
        checkSelectFieldValueIsEqualTo("999999 1234", addTransferMethod.stateProvinceInput)
    }

    /**
     "defaultPattern": "999999 ####"
     */
    func testAddTransferMethod_prefixCharsTestByPaste() {
        XCTAssert(app.navigationBars["Wire Account"].exists)

        addTransferMethod.stateProvinceInput.enterByPaste(
            text: "99991", field: addTransferMethod.stateProvinceInput, app: app)
        checkSelectFieldValueIsEqualTo("999999 1", addTransferMethod.stateProvinceInput)
    }

    /**
     default pattern "@@@\\\\@@@"
     */
    func testAddTransferMethod_fourEscapeCharsTest() {
        XCTAssert(app.navigationBars["Wire Account"].exists)
        addTransferMethod.setLastName("ABCDEF")
        // Assert it shows "ABC\DEF" - swift requires to enter double \\
        checkSelectFieldValueIsEqualTo("ABC\\DEF", addTransferMethod.lastNameInput)
        addTransferMethod.setLastName("ABCDEFG")
        // Assert it shows "ABC\DEF" - swift requires to enter double \\
        checkSelectFieldValueIsEqualTo("ABC\\DEF", addTransferMethod.lastNameInput)
    }

    /**
     default pattern "@@@\\\\@@@"
     */
    func testAddTransferMethod_fourEscapeCharsTestByPaste() {
        XCTAssert(app.navigationBars["Wire Account"].exists)
        addTransferMethod.lastNameInput.enterByPaste(
            text: "ABCDEF", field: addTransferMethod.lastNameInput, app: app)
        // Assert it shows "ABC\DEF" - swift requires to enter double \\
        checkSelectFieldValueIsEqualTo("ABC\\DEF", addTransferMethod.lastNameInput)
    }
}
