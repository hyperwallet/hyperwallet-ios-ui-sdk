import XCTest

class AddTransferMethodWireAccountUSMaskingTests: BaseTests {
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
                             filename: "TransferMethodConfigurationWireAccountResponseWithMask",
                             method: HTTPMethod.post)

        app.tables.cells.staticTexts["Add Transfer Method"].tap()
        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)
        addTransferMethod = AddTransferMethod(app: app)
    }

    func testAddTransferMethod_brandIdDefaultPattern() {
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
        XCTAssert(app.navigationBars["Wire Account"].exists)
        addTransferMethod.branchIdInput.enterByPaste(
            text: "111222333", field: addTransferMethod.branchIdInput, app: app)

        checkSelectFieldValueIsEqualTo("111-222-333", addTransferMethod.branchIdInput)
    }

    /**
     "defaultPattern": "@@@@@@**"
     */
    func testAddTransferMethod_swiftNumberDefaultPattern() {
        XCTAssert(app.navigationBars["Wire Account"].exists)
        addTransferMethod.setBankId("ABNANL2A")
        checkSelectFieldValueIsEqualTo("ABNANL2A", addTransferMethod.bankIdInput)

        addTransferMethod.setBankId("ABNANLAA")
        checkSelectFieldValueIsEqualTo("ABNANLAA", addTransferMethod.bankIdInput)

        addTransferMethod.setBankId("ABNANL22")
        checkSelectFieldValueIsEqualTo("ABNANL22", addTransferMethod.bankIdInput)

        addTransferMethod.setBankId("abNANLH2")
        checkSelectFieldValueIsEqualTo("abNANLH2", addTransferMethod.bankIdInput)

        addTransferMethod.setBankId("abnanL2K")
        checkSelectFieldValueIsEqualTo("abnanL2K", addTransferMethod.bankIdInput)
    }

    /**
     "defaultPattern": "@@@@@@**"
     */
    func testAddTransferMethod_swiftNumberInvalidPattern() {
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
        XCTAssert(app.navigationBars["Wire Account"].exists)
        addTransferMethod.setBankId("AABNANL1233333")
        checkSelectFieldValueIsEqualTo("AABNANL1", addTransferMethod.bankIdInput)
        addTransferMethod.setBankId("AABNANLXXBBB")
        checkSelectFieldValueIsEqualTo("AABNANLX", addTransferMethod.bankIdInput)
    }
}
