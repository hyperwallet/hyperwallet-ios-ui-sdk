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
    }

    func testAddTransferMethod_swiftNumberInvalidPattern() {
        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodConfigurationWireAccountResponseWithMask",
                             method: HTTPMethod.post)
        openMenu()
        XCTAssert(app.navigationBars["Wire Account"].exists)

        addTransferMethod.setBankId("A1B2C3D")
        checkSelectFieldValueIsEqualTo("ABCD", addTransferMethod.bankIdInput)

        addTransferMethod.setBankId("a1b2c3d")
        checkSelectFieldValueIsEqualTo("abcd", addTransferMethod.bankIdInput)

        addTransferMethod.setBankId("A1B2C3D4EF4%^5#")
        checkSelectFieldValueIsEqualTo("ABCDEF45", addTransferMethod.bankIdInput)

        addTransferMethod.setBankId("@#!A1B2C3D4EF4%^5#^^&&&&%")
        checkSelectFieldValueIsEqualTo("ABCDEF45", addTransferMethod.bankIdInput)

        addTransferMethod.setBankId("ABNANL1%")
        checkSelectFieldValueIsEqualTo("ABNANL1", addTransferMethod.bankIdInput)

        addTransferMethod.setBankId("$#$%^&*")
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

    /*
     Implementing....in progress
    func testAddTransferMethod_escapeCharTest() {
        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodConfigurationResponseWithEscapeMasks",
                             method: HTTPMethod.post)

        openMenu()

        XCTAssert(app.navigationBars["Wire Account"].exists)
        let input: String = "12345"
        addTransferMethod.setBankId(input)
        checkSelectFieldValueIsEqualTo("123-45", addTransferMethod.bankIdInput)

        addTransferMethod.setBranchId(input)
        checkSelectFieldValueIsEqualTo("123-45", addTransferMethod.branchIdInput)

        addTransferMethod.setBankAccountId(input)
        checkSelectFieldValueIsEqualTo("123-45\\9", addTransferMethod.bankAccountIdInput)

        addTransferMethod.setPostalCode(input)
        checkSelectFieldValueIsEqualTo("123-459", addTransferMethod.postalCodeInput)
    } */

    func testAddTransferMethod_starForAllCharTest() {
        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodConfigurationResponseWithStarMasks",
                             method: HTTPMethod.post)
        openMenu()
        XCTAssert(app.navigationBars["Wire Account"].exists)
        addTransferMethod.setFirstName("汉字a2汉字")
        checkSelectFieldValueIsEqualTo("汉字a2汉字", addTransferMethod.firstNameInput)

        addTransferMethod.setFirstName("汉字a299")
        checkSelectFieldValueIsEqualTo("汉字a299", addTransferMethod.firstNameInput)
        addTransferMethod.setFirstName("汉字a2AB")
        checkSelectFieldValueIsEqualTo("汉字a2AB", addTransferMethod.firstNameInput)

        addTransferMethod.setFirstName("汉字a2ab")
        checkSelectFieldValueIsEqualTo("汉字a2ab", addTransferMethod.firstNameInput)

        // Existing issue right now it will show "汉字汉"

        addTransferMethod.setFirstName("汉字汉字")
        checkSelectFieldValueIsEqualTo("汉字", addTransferMethod.firstNameInput)
    }

    func testAddTransferMethod_specialCharsTest() {
        mockServer.setupStub(url: "/graphql",
                            filename: "TransferMethodConfigurationResponseWithStarMasks",
                            method: HTTPMethod.post)

        openMenu()

        addTransferMethod.setBankId("11223344")
        checkSelectFieldValueIsEqualTo("11#22@33-44", addTransferMethod.bankIdInput)
        addTransferMethod.setBranchId("aaa111字字字")
        checkSelectFieldValueIsEqualTo("#aaa#111#字字字", addTransferMethod.branchIdInput)
    }

    func testAddTransferMethod_prefixCharsTest() {
        mockServer.setupStub(url: "/graphql",
                                   filename: "TransferMethodConfigurationResponseWithStarMasks",
                                   method: HTTPMethod.post)
        openMenu()
        addTransferMethod.setStateProvince("1234")
        checkSelectFieldValueIsEqualTo("999999 1234", addTransferMethod.stateProvinceInput)
    }

    func testAddTransferMethod_prefixCharsTestByPaste() {
           mockServer.setupStub(url: "/graphql",
                                      filename: "TransferMethodConfigurationResponseWithStarMasks",
                                      method: HTTPMethod.post)
           openMenu()

           addTransferMethod.stateProvinceInput.enterByPaste(
                     text: "99991", field: addTransferMethod.stateProvinceInput, app: app)
           checkSelectFieldValueIsEqualTo("999999 1", addTransferMethod.stateProvinceInput)
       }

    private func openMenu() {
        app.tables.cells.staticTexts["Add Transfer Method"].tap()
        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)
        addTransferMethod = AddTransferMethod(app: app)
    }
}
