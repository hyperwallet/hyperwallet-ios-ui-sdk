import XCTest

class AddTransferMethodMaskingTest: BaseTests {
    var selectTransferMethodType: SelectTransferMethodType!
    var addTransferMethod: AddTransferMethod!
    let bankAccount = "bank_account".localized()
    override func setUp() {
           super.setUp()

           app = XCUIApplication()
           app.launchArguments.append("enable-testing")
           app.launchEnvironment = [
               "COUNTRY": "US",
               "CURRENCY": "USD",
               "ACCOUNT_TYPE": "BANK_ACCOUNT",
               "PROFILE_TYPE": "INDIVIDUAL"
           ]
           app.launch()

           mockServer.setupStub(url: "/graphql",
                                filename: "TransferMethodConfigrationUSBankAccountResponseMask",
                                method: HTTPMethod.post)

           app.tables.cells.staticTexts["Add Transfer Method"].tap()
           spinner = app.activityIndicators["activityIndicator"]
           waitForNonExistence(spinner)
           addTransferMethod = AddTransferMethod(app: app)
       }

    func testAddTransferMethod_accountNumberDefaultPattern() {
           XCTAssert(addTransferMethod.navBarBankAccount.exists)
           XCTAssert(addTransferMethod.transferMethodInformationHeader.exists)
           addTransferMethod.setBankAccountId("12345")
           print(addTransferMethod.bankAccountIdInput.value ?? "")

        // Assert field is 1234-5
        checkSelectFieldValueIsEqualTo("1234-5", addTransferMethod.bankAccountIdInput)
    }

    // "defaultPattern": "####-####-####-##"
    func testAddTransferMethod_accountNumberDefaultPatternByPaste() {
        XCTAssert(addTransferMethod.navBarBankAccount.exists)
        XCTAssert(addTransferMethod.transferMethodInformationHeader.exists)
        addTransferMethod.bankAccountIdInput.enterByPaste(
            text: "12345678000088", field: addTransferMethod.bankAccountIdInput, app: app)
        checkSelectFieldValueIsEqualTo("1234-5678-0000-88", addTransferMethod.bankAccountIdInput)
    }

    // "defaultPattern": "####-####-####-##"
    func testAddTransferMethod_accountNumberDefaultPatternByPasteWithHyphen() {
           XCTAssert(addTransferMethod.navBarBankAccount.exists)
           XCTAssert(addTransferMethod.transferMethodInformationHeader.exists)
           addTransferMethod.bankAccountIdInput.enterByPaste(
               text: "1234-5678-0000-99", field: addTransferMethod.bankAccountIdInput, app: app)
           checkSelectFieldValueIsEqualTo("1234-5678-0000-99", addTransferMethod.bankAccountIdInput)
       }

    func testAddTransferMethod_accountNumberMaskingInvalidInput() {
           XCTAssert(addTransferMethod.navBarBankAccount.exists)
           XCTAssert(addTransferMethod.transferMethodInformationHeader.exists)

           addTransferMethod.bankAccountIdInput.enterByPaste(
            text: "abc123abc", field: addTransferMethod.bankAccountIdInput, app: app)

         // Assert the field only shows "123"
         checkSelectFieldValueIsEqualTo("123", addTransferMethod.bankAccountIdInput)
    }

    func testAddTransferMethod_accountNumberMaskingInvalidLength() {
           XCTAssert(addTransferMethod.navBarBankAccount.exists)
           XCTAssert(addTransferMethod.transferMethodInformationHeader.exists)
           addTransferMethod.bankAccountIdInput.enterByPaste(
            text: "1234-5678-00001111", field: addTransferMethod.bankAccountIdInput, app: app)
           // Assert extra char is not entered
           checkSelectFieldValueIsEqualTo("1234-5678-0000-11", addTransferMethod.bankAccountIdInput)
    }
}
