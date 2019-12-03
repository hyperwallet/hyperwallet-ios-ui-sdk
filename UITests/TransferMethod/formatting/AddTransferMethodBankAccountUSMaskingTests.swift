import XCTest

class AddTransferMethodMaskingTest: BaseTests {
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

    // conditionalPattern = "####-###-########"
    // defaultPattern = "####"
    func testAddTransferMethod_accountNumberDefaultPattern() {
           XCTAssert(app.navigationBars["Bank Account"].exists)
           XCTAssert(addTransferMethod.transferMethodInformationHeader.exists)
           addTransferMethod.setBankAccountId("12345")
           print(addTransferMethod.bankAccountIdInput.value ?? "")

        // Assert field is 1234-5
        checkSelectFieldValueIsEqualTo("1234-5", addTransferMethod.bankAccountIdInput)
    }

    func testAddTransferMethod_accountNumberDefaultPatternByPaste() {
                 XCTAssert(app.navigationBars["Bank Account"].exists)
                 XCTAssert(addTransferMethod.transferMethodInformationHeader.exists)
        addTransferMethod.bankAccountIdInput.enterByPaste(
            text: "123456780000", field: addTransferMethod.bankAccountIdInput, app: app)
        checkSelectFieldValueIsEqualTo("1234-5678-0000", addTransferMethod.bankAccountIdInput)

        addTransferMethod.bankAccountIdInput.enterByPaste(
            text: "1234-5678-0000", field: addTransferMethod.bankAccountIdInput, app: app)
        checkSelectFieldValueIsEqualTo("1234-5678-0000", addTransferMethod.bankAccountIdInput)
    }

    // Assert invalid input is not allowed
    func testAddTransferMethod_accountNumberMaskingInvalidInput() {
           XCTAssert(app.navigationBars["Bank Account"].exists)
           XCTAssert(addTransferMethod.transferMethodInformationHeader.exists)

           addTransferMethod.bankAccountIdInput.enterByPaste(
            text: "123abc", field: addTransferMethod.bankAccountIdInput, app: app)

        // Assert the field only shows "123"
         checkSelectFieldValueIsEqualTo("123", addTransferMethod.bankAccountIdInput)

        //addTransferMethod.setBankAccountId("123abc")

        //checkSelectFieldValueIsEqualTo("123", addTransferMethod.bankAccountIdInput)
    }

    // Assert extra char is not entered
    func testAddTransferMethod_accountNumberMaskingInvalidLength() {
           XCTAssert(app.navigationBars["Bank Account"].exists)
           XCTAssert(addTransferMethod.transferMethodInformationHeader.exists)
           addTransferMethod.bankAccountIdInput.enterByPaste(
            text: "1234-5678-00001111", field: addTransferMethod.bankAccountIdInput, app: app)
           checkSelectFieldValueIsEqualTo("1234-5678-0000", addTransferMethod.bankAccountIdInput)
    }
}
