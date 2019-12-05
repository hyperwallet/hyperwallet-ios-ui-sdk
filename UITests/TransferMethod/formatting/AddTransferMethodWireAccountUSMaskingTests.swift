import XCTest

class AddTransferMethodWireAccountUSMaskingTests: BaseTests {
    var selectTransferMethodType: SelectTransferMethodType!
    var addTransferMethod: AddTransferMethod!
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
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddTransferMethod_brandIdDefaultPattern() {
        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodConfigurationWireAccountResponseWithMask",
                             method: HTTPMethod.post)

        openMenu()
        XCTAssert(app.navigationBars["Wire Account"].exists)
        addTransferMethod.setBranchId("111222333")
        checkSelectFieldValueIsEqualTo("111-222-333", addTransferMethod.branchIdInput)

        // what if we enter the hyphen ?
        addTransferMethod.setBranchId("111-222-333")
        checkSelectFieldValueIsEqualTo("111-222-333", addTransferMethod.branchIdInput)
    }

    /**
     "defaultPattern": "###-###-###"
     */
    func testAddTransferMethod_brandIdDefaultPatternByPaste() {
        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodConfigurationWireAccountResponseWithMask",
                             method: HTTPMethod.post)

        openMenu()
        XCTAssert(app.navigationBars["Wire Account"].exists)
        addTransferMethod.branchIdInput.enterByPaste(
            text: "111222333", field: addTransferMethod.branchIdInput, app: app)

        checkSelectFieldValueIsEqualTo("111-222-333", addTransferMethod.branchIdInput)
    }

    /**
      "defaultPattern": "@@@@@@**"
     */
    func testAddTransferMethod_swiftNumberDefaultPattern() {
        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodConfigurationWireAccountResponseWithMask",
                             method: HTTPMethod.post)

        openMenu()
        XCTAssert(app.navigationBars["Wire Account"].exists)
        addTransferMethod.setBankId("ABNANL2A")
        checkSelectFieldValueIsEqualTo("ABNANL2A", addTransferMethod.bankIdInput)

        addTransferMethod.setBankId("ABNANLAA")
        checkSelectFieldValueIsEqualTo("ABNANLAA", addTransferMethod.bankIdInput)

        addTransferMethod.setBankId("ABNANL22")
        checkSelectFieldValueIsEqualTo("ABNANL22", addTransferMethod.bankIdInput)

        addTransferMethod.setBankId("abNANL22")
        checkSelectFieldValueIsEqualTo("abNANL22", addTransferMethod.bankIdInput)
        addTransferMethod.setBankId("abnanL汉字")
        checkSelectFieldValueIsEqualTo("abnanL汉字", addTransferMethod.bankIdInput)
    }

    /**
     "defaultPattern": "@@@@@@**"
    */
    func testAddTransferMethod_swiftNumberInvalidPattern() {
        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodConfigurationWireAccountResponseWithMask",
                             method: HTTPMethod.post)
        openMenu()
        XCTAssert(app.navigationBars["Wire Account"].exists)

        addTransferMethod.setBankId("A1B2C3DFG12")
        checkSelectFieldValueIsEqualTo("ABCDFG12", addTransferMethod.bankIdInput)

        addTransferMethod.setBankId("a1b2c3dfg12")
        checkSelectFieldValueIsEqualTo("abcdfg12", addTransferMethod.bankIdInput)

        addTransferMethod.setBankId("A1B2C3D4EF4%^5#")
        checkSelectFieldValueIsEqualTo("ABCDEF45", addTransferMethod.bankIdInput)

        addTransferMethod.setBankId("@#!A1B2C3D4EF4%^5#^^&&&&%")
        checkSelectFieldValueIsEqualTo("ABCDEF45", addTransferMethod.bankIdInput)

        addTransferMethod.setBankId("ABNANL1%")
        checkSelectFieldValueIsEqualTo("ABNANL1", addTransferMethod.bankIdInput)

        addTransferMethod.setBankId("$#$%^&*")
        checkSelectFieldValueIsEqualTo("", addTransferMethod.bankIdInput)

        addTransferMethod.setBankId("字字字字")
        checkSelectFieldValueIsEqualTo("", addTransferMethod.bankIdInput)
    }

    func testAddTransferMethod_swiftNumberInvalidLength() {
        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodConfigurationWireAccountResponseWithMask",
                             method: HTTPMethod.post)

        openMenu()

        XCTAssert(app.navigationBars["Wire Account"].exists)
        addTransferMethod.setBankId("AABNANL1233333")
        checkSelectFieldValueIsEqualTo("AABNANL1", addTransferMethod.bankIdInput)
        addTransferMethod.setBankId("AABNANLXXBBB")
        checkSelectFieldValueIsEqualTo("AABNANLX", addTransferMethod.bankIdInput)
    }

    /**
     default pattern "**@#**"
     */
    func testAddTransferMethod_starForAllCharTest() {
        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodConfigurationResponseWithStarMasks",
                             method: HTTPMethod.post)
        openMenu()
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
        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodConfigurationResponseWithStarMasks",
                             method: HTTPMethod.post)
        openMenu()

        addTransferMethod.setBankId("11223344")
        checkSelectFieldValueIsEqualTo("11#22@33-44", addTransferMethod.bankIdInput)
    }
    /**
     "defaultPattern": "999999 ####"
     */
    func testAddTransferMethod_prefixCharsTest() {
        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodConfigurationResponseWithStarMasks",
                             method: HTTPMethod.post)
        openMenu()
        addTransferMethod.setStateProvince("1234")
        checkSelectFieldValueIsEqualTo("999999 1234", addTransferMethod.stateProvinceInput)
    }

    /**
     "defaultPattern": "999999 ####"
     */
    func testAddTransferMethod_prefixCharsTestByPaste() {
        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodConfigurationResponseWithStarMasks",
                             method: HTTPMethod.post)
        openMenu()

        addTransferMethod.stateProvinceInput.enterByPaste(
            text: "99991", field: addTransferMethod.stateProvinceInput, app: app)
        checkSelectFieldValueIsEqualTo("999999 1", addTransferMethod.stateProvinceInput)
    }

    /**
       default pattern
       ###-##\           -> expect 123-45
       ###-##\\         -> expect 123-45   (because single has no meaning)
       ###-##\\\\     -> expect 123-45\
       ###-##\\\\9     -> expect 123-45\9
       ###-##\\9       -> expect 123-459
       */
      /*
      func testAddTransferMethod_escapeCharTest() {
          mockServer.setupStub(url: "/graphql",
                               filename: "TransferMethodConfigurationResponseWithEscapeMasks",
                               method: HTTPMethod.post)

          openMenu()
          XCTAssert(app.navigationBars["Wire Account"].exists)
          let input: String = "12345"
          // verify ###-##\
          addTransferMethod.setBankId(input)
          checkSelectFieldValueIsEqualTo("123-45", addTransferMethod.bankIdInput)

          // verify ###-##\\
          addTransferMethod.setBranchId(input)
          checkSelectFieldValueIsEqualTo("123-45", addTransferMethod.branchIdInput)

           // verify ###-##\\
          addTransferMethod.setBankAccountId(input)
          checkSelectFieldValueIsEqualTo("123-45\\9", addTransferMethod.bankAccountIdInput)

          addTransferMethod.setPostalCode(input)
          checkSelectFieldValueIsEqualTo("123-459", addTransferMethod.postalCodeInput)
      } */

    private func openMenu() {
        app.tables.cells.staticTexts["Add Transfer Method"].tap()
        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)
        addTransferMethod = AddTransferMethod(app: app)
    }
}
