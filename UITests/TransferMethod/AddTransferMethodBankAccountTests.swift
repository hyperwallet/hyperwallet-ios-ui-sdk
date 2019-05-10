import XCTest

class AddTransferMethodTests: XCTestCase {
    var app: XCUIApplication!
    var selectTransferMethodType: SelectTransferMethodType!
    var addTransferMethod: AddTransferMethod!
    var mockServer: HyperwalletMockWebServer!
    var spinner: XCUIElement!

    let bankAccount = NSPredicate(format: "label CONTAINS[c] 'Bank Account'")

    override func setUp() {
        continueAfterFailure = false

        mockServer = HyperwalletMockWebServer()
        mockServer.setUp()

        // Initialize stubs
        mockServer.setupStub(url: "/rest/v3/users/usr-token/authentication-token",
                             filename: "AuthenticationTokenResponse",
                             method: HTTPMethod.post)

        mockServer.setupStub(url: "/rest/v3/users/usr-token",
                             filename: "UserIndividualResponse",
                             method: HTTPMethod.get)

        mockServer.setupGraphQLStubs()

        app = XCUIApplication()
        app.launch()

        selectTransferMethodType = SelectTransferMethodType(app: app)
        addTransferMethod = AddTransferMethod(app: app, for: .bankAccount)

        app.tables.cells.containing(.staticText, identifier: "Add Transfer Method").element(boundBy: 0).tap()
        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)

        selectTransferMethodType.selectCountry(country: "United States")
        selectTransferMethodType.selectCurrency(currency: "US Dollar")

        app.tables["transferMethodTableView"].staticTexts.element(matching: bankAccount).tap()
    }

    override func tearDown() {
        mockServer.tearDown()
    }

    func testAddTransferMethod_createBankAccount() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/bank-accounts",
                             filename: "BankAccountResponse",
                             method: HTTPMethod.post)

        waitForNonExistence(spinner)

        addTransferMethod.setBranchId(branchId: "021000021")
        addTransferMethod.setAccountNumber(accountNumber: "12345")
        addTransferMethod.selectAccountType(accountType: "Checking")
        addTransferMethod.clickCreateTransferMethodButton()

        //Todo - check processing indicator
    }

    func testAddTransferMethod_returnsErrorOnInvalidPattern() {
        waitForNonExistence(spinner)

        addTransferMethod.setBranchId(branchId: "abc123abc")
        XCTAssert(app.tables["addTransferMethodTable"].staticTexts["label_branchId_error"].exists)

        addTransferMethod.setAccountNumber(accountNumber: "1a31a")
        XCTAssert(app.tables["addTransferMethodTable"].staticTexts["label_bankAccountId_error"].exists)
    }

    func testAddTransferMethod_createBankAccountInvalidRouting() {
        mockServer.setupStubError(url: "/rest/v3/users/usr-token/bank-accounts",
                                  filename: "BankAccountInvalidRoutingResponse",
                                  method: HTTPMethod.post)

        waitForNonExistence(spinner)

        addTransferMethod.setBranchId(branchId: "021000022")
        addTransferMethod.setAccountNumber(accountNumber: "12345")
        addTransferMethod.selectAccountType(accountType: "Checking")
        addTransferMethod.clickCreateTransferMethodButton()
        waitForNonExistence(spinner)

        XCTAssertNotNil(app.tables.otherElements
            .containing(NSPredicate(format: "label CONTAINS %@", "Routing Number [021000022] is not valid. " +
                "Please modify Routing Number to a valid ACH Routing Number of the branch of your bank.")))
    }

    func testAddTransferMethod_createBankAccountUnexpectedError() {
        mockServer.setupStubError(url: "/rest/v3/users/usr-token/bank-accounts",
                                  filename: "UnexpectedErrorResponse",
                                  method: HTTPMethod.post)

        waitForNonExistence(spinner)

        addTransferMethod.setBranchId(branchId: "021000022")
        addTransferMethod.setAccountNumber(accountNumber: "12345")
        addTransferMethod.selectAccountType(accountType: "Checking")
        addTransferMethod.clickCreateTransferMethodButton()
        waitForNonExistence(spinner)

        XCTAssert(app.alerts["Unexpected Error"].exists)
        XCTAssert(app.alerts["Unexpected Error"].staticTexts["Oops... Something went wrong, please try again"].exists)
        app.alerts["Unexpected Error"].buttons["OK"].tap()
        XCTAssertFalse(app.alerts["Unexpected Error"].exists)
        XCTAssertTrue(app.navigationBars["Add Account"].exists)
        XCTAssertTrue(app.tables["transferMethodTableView"].staticTexts.element(matching: bankAccount).exists)
    }

    func testAddTransferMethod_verifyRoutingNumberIsNotEditable() {
        mockServer.setUpGraphQLBankAccountWithNotEditableField()
        addTransferMethod.clickBackButton()
        app.tables["transferMethodTableView"].staticTexts.element(matching: bankAccount).tap()
        addTransferMethod.branchIdInput.tap()
        
        XCTAssertFalse(app.keyboards.element.exists)
    }
    
    func testAddTransferMethod_verifyAccountTypeIsNotEditable() {
        mockServer.setUpGraphQLBankAccountWithNotEditableField()
        addTransferMethod.clickBackButton()
        app.tables["transferMethodTableView"].staticTexts.element(matching: bankAccount).tap()
        addTransferMethod.accountTypeSelect.tap()
        
        XCTAssertTrue(addTransferMethod.navigationBar.exists)
        XCTAssertFalse(app.tables["transferMethodTableView"].buttons["More Info"].exists)
    }
    
}
