import XCTest

class ListTransferMethodTests: BaseTests {
    var listTransferMethod: ListTransferMethod!
    var selectTransferMethodType: SelectTransferMethodType!
    var addTransferMethod: AddTransferMethod!
    var loadingSpinner: XCUIElement!

    let debitCard = NSPredicate(format: "label CONTAINS[c] 'Debit Card'")
    let bankAccount = NSPredicate(format: "label CONTAINS[c] 'Bank Account'")
    let expectedFirstBankAccountLabel = "Ending on 0001"
    let expectedSecondBankAccountLabel = "Ending on 0002"
    let expectedThirdBankAccountLabel = "Ending on 0003"
    let expectedDebitCardCellLabel = "Ending on 0006"
    let bankAccountTitle = "Bank Account"
    let debitCardTitle = "Debit Card"

    var removeBankCardURL: String {
        let bankCardEndpoint = "rest/v3/users/usr-token/bank-cards/"
        let removeDebitCardEndpoint = "trm-5c380689-4074-46c4-8827-0574d88b509b/status-transitions"
        return bankCardEndpoint + removeDebitCardEndpoint
    }

    var removeBankAccountURL: String {
        let bankAccountEndpoint = "rest/v3/users/usr-token/bank-accounts/"
        let removeBankAccountCardEndpoint = "trm-6dab5471-65d1-4d48-aacb-fdd590f943d6/status-transitions"
        return bankAccountEndpoint + removeBankAccountCardEndpoint
    }

    override func setUp() {
        super.setUp()

        listTransferMethod = ListTransferMethod(app: app)
        selectTransferMethodType = SelectTransferMethodType(app: app)
        addTransferMethod = AddTransferMethod(app: app, for: .bankAccount)
    }

    override func tearDown() {
        mockServer.tearDown()
    }

    func testListTransferMethod_emptyTransferMethodsList() {
        mockServer.setUpEmptyResponse(url: "/rest/v3/users/usr-token/transfer-methods")

        openTransferMethodsList()

        let expectedTitle = "You didn’t add an account yet. Once created, it will show up here!"

        XCTAssertTrue(app.staticTexts[expectedTitle].exists)
        XCTAssertTrue(listTransferMethod.addTransferMethodButton.exists)
    }

    func testListTransferMethod_verifyTransferMethodsOrder() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodResponse",
                             method: HTTPMethod.get)

        openTransferMethodsList()

        XCTAssertTrue(app.cells.element(boundBy: 0).staticTexts[expectedFirstBankAccountLabel].exists)
        XCTAssertTrue(app.cells.element(boundBy: 1).staticTexts[expectedSecondBankAccountLabel].exists)
        XCTAssertTrue(app.cells.element(boundBy: 2).staticTexts[expectedThirdBankAccountLabel].exists)
        XCTAssertTrue(app.cells.element(boundBy: 3).staticTexts[expectedDebitCardCellLabel].exists)
    }

    func testListTransferMethod_addTransferMethodFromEmptyScreen() {
        mockServer.setUpEmptyResponse(url: "/rest/v3/users/usr-token/transfer-methods")
        mockServer.setupGraphQLStubs()

        openTransferMethodsList()
        listTransferMethod.tapAddTransferMethodEmptyScreenButton()

        XCTAssertTrue(app.navigationBars["Add Account"].exists)
    }

    func testListTransferMethod_addTransferMethod() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodResponse",
                             method: HTTPMethod.get)
        mockServer.setupGraphQLStubs()

        openTransferMethodsList()
        listTransferMethod.tapAddTransferMethodButton()

        XCTAssertTrue(app.navigationBars["Add Account"].exists)
    }

    func testListTransferMethod_openDeleteTransferMethodActionSheet() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodResponse",
                             method: HTTPMethod.get)

        openTransferMethodsList()

        app.tables.cells.containing(.staticText, identifier: "Bank Account").element(boundBy: 0).tap()
        XCTAssertTrue(listTransferMethod.removeAccountButton.exists)
    }

    func testListTransferMethod_verifyDeleteTransferMethodConfirmationAlertIsShown() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodResponse",
                             method: HTTPMethod.get)

        openTransferMethodsList()

        app.tables.cells.containing(.staticText, identifier: "Bank Account").element(boundBy: 0).tap()
        listTransferMethod.tapRemoveAccountButton()
        waitForNonExistence(app.alerts["Remove Account"])
        XCTAssertTrue(app.alerts["Remove Account"].exists)
        XCTAssertTrue(listTransferMethod.confirmAccountRemoveButton.exists)
    }

    func testListTransferMethod_deleteBankAccount() {
        let cellsCountBeforeRemove = 4
        let expectedCellsCountAfterRemove = 3

        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodResponse",
                             method: HTTPMethod.get)

        openTransferMethodsList()

        app.tables.cells.containing(.staticText, identifier: "Bank Account").element(boundBy: 0).tap()

        XCTAssertEqual(app.tables.element(boundBy: 0).cells.count, cellsCountBeforeRemove)

        listTransferMethod.tapRemoveAccountButton()

        mockServer.setupStub(url: removeBankAccountURL,
                             filename: "RemovedTransferMethodResponse",
                             method: HTTPMethod.post)
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodResponseWithoutFirstElement",
                             method: HTTPMethod.get)

        XCTAssertTrue(listTransferMethod.confirmAccountRemoveButton.exists)

        listTransferMethod.tapConfirmAccountRemoveButton()
        waitForNonExistence(spinner)
        waitForNonExistence(loadingSpinner)

        XCTAssertEqual(app.tables.element(boundBy: 0).cells.count, expectedCellsCountAfterRemove)
        XCTAssertTrue(app.cells.element(boundBy: 0).staticTexts[expectedSecondBankAccountLabel].exists)
        XCTAssertTrue(app.cells.element(boundBy: 1).staticTexts[expectedThirdBankAccountLabel].exists)
        XCTAssertTrue(app.cells.element(boundBy: 2).staticTexts[expectedDebitCardCellLabel].exists)
        XCTAssertFalse(app.cells.element(boundBy: 3).exists)
    }

    func testListTransferMethod_deleteDebitCard() {
        let cellsCountBeforeRemove = 4
        let expectedCellsCountAfterRemove = 3

        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodResponse",
                             method: HTTPMethod.get)

        openTransferMethodsList()
        app.tables.cells.containing(.staticText, identifier: "Debit Card").element(boundBy: 0).tap()

        XCTAssertEqual(app.tables.element(boundBy: 0).cells.count, cellsCountBeforeRemove)

        listTransferMethod.tapRemoveAccountButton()

        mockServer.setupStub(url: removeBankCardURL,
                             filename: "RemovedTransferMethodResponse",
                             method: HTTPMethod.post)
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodResponseWithoutDebitCard",
                             method: HTTPMethod.get)

        XCTAssertTrue(listTransferMethod.confirmAccountRemoveButton.exists)

        listTransferMethod.tapConfirmAccountRemoveButton()
        waitForNonExistence(spinner)
        waitForNonExistence(loadingSpinner)

        XCTAssertEqual(app.tables.element(boundBy: 0).cells.count, expectedCellsCountAfterRemove)
        XCTAssertTrue(app.cells.element(boundBy: 0).staticTexts[expectedFirstBankAccountLabel].exists)
        XCTAssertTrue(app.cells.element(boundBy: 1).staticTexts[expectedSecondBankAccountLabel].exists)
        XCTAssertTrue(app.cells.element(boundBy: 2).staticTexts[expectedThirdBankAccountLabel].exists)
        XCTAssertFalse(app.cells.element(boundBy: 3).exists)
    }

    func testListTransferMethod_cancelDeleteTransferMethod() {
        let expectedCellsCount = 4

        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodResponse",
                             method: HTTPMethod.get)

        openTransferMethodsList()
        app.tables.cells.containing(.staticText, identifier: "Bank Account").element(boundBy: 0).tap()

        XCTAssertEqual(app.tables.element(boundBy: 0).cells.count, expectedCellsCount)

        listTransferMethod.tapRemoveAccountButton()

        waitForNonExistence(spinner)
        XCTAssertTrue(listTransferMethod.cancelAccountRemoveButton.exists)

        listTransferMethod.tapCancelAccountRemoveButton()

        XCTAssertEqual(app.tables.element(boundBy: 0).cells.count, expectedCellsCount)
        XCTAssertTrue(app.cells.element(boundBy: 0).staticTexts[expectedFirstBankAccountLabel].exists)
        XCTAssertTrue(app.cells.element(boundBy: 1).staticTexts[expectedSecondBankAccountLabel].exists)
        XCTAssertTrue(app.cells.element(boundBy: 2).staticTexts[expectedThirdBankAccountLabel].exists)
        XCTAssertTrue(app.cells.element(boundBy: 3).staticTexts[expectedDebitCardCellLabel].exists)
    }

    func testListTransferMethod_deleteTransferMethodUnexpectedError() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodResponse",
                             method: HTTPMethod.get)
        mockServer.setupStubError(url: removeBankAccountURL,
                                  filename: "UnexpectedErrorResponse",
                                  method: HTTPMethod.post)

        openTransferMethodsList()

        app.tables.cells.containing(.staticText, identifier: "Bank Account").element(boundBy: 0).tap()
        listTransferMethod.tapRemoveAccountButton()

        waitForNonExistence(spinner)
        XCTAssertTrue(listTransferMethod.confirmAccountRemoveButton.exists)

        listTransferMethod.tapConfirmAccountRemoveButton()
        waitForNonExistence(spinner)

        XCTAssert(app.alerts["Unexpected Error"].exists)

        app.alerts["Unexpected Error"].buttons["OK"].tap()
        XCTAssertFalse(app.alerts["Unexpected Error"].exists)

        waitForNonExistence(spinner)

        XCTAssertTrue(app.navigationBars["Account Settings"].exists)
    }

    private func openTransferMethodsList() {
        app.tables.cells.containing(.staticText, identifier: "List Transfer Methods").element(boundBy: 0).tap()
        spinner = app.activityIndicators["activityIndicator"]
        loadingSpinner = app.activityIndicators["In progress"]
        waitForNonExistence(spinner)
    }

    func testListTransferMethods_verifyAfterRelaunch() {
        setUpStandardListTransferMethod()
        validatetestListTransferMethodsScreen()
        XCUIDevice.shared.clickHomeAndRelaunch(app: app)
        setUpStandardListTransferMethod()
        validatetestListTransferMethodsScreen()
    }

    func testListTransferMethods_verifyRotateScreen() {
        setUpStandardListTransferMethod()
        XCUIDevice.shared.rotateScreen(times: 3)
        validatetestListTransferMethodsScreen()
    }

    func testListTransferMethods_verifyWakeFromSleep() {
        setUpStandardListTransferMethod()
        XCUIDevice.shared.wakeFromSleep(app: app)
        waitForNonExistence(addTransferMethod.navigationBar)
        validatetestListTransferMethodsScreen()
    }

    func testListTransferMethods_verifyResumeFromRecents() {
        setUpStandardListTransferMethod()
        XCUIDevice.shared.resumeFromRecents(app: app)
        waitForNonExistence(addTransferMethod.navigationBar)
        validatetestListTransferMethodsScreen()
    }

    func testListTransferMethods_verifyAppToBackground() {
        setUpStandardListTransferMethod()
        XCUIDevice.shared.sendToBackground(app: app)
        validatetestListTransferMethodsScreen()
    }

    func testListTransferMethods_verifyPressBackButton() {
        setUpStandardListTransferMethod()
        listTransferMethod.clickBackButton()
        XCTAssertTrue(app.navigationBars["Account Settings"].exists)
    }

    func validatetestListTransferMethodsScreen() {
        let expectedCellsCount = 4
        let isValid = listTransferMethod.navigationBar.exists &&
            (app.tables.element(boundBy: 0).cells.count == expectedCellsCount) &&
            app.cells.element(boundBy: 0).staticTexts[expectedFirstBankAccountLabel].exists &&
            app.cells.element(boundBy: 1).staticTexts[expectedSecondBankAccountLabel].exists &&
            app.cells.element(boundBy: 2).staticTexts[expectedThirdBankAccountLabel].exists &&
            app.cells.element(boundBy: 3).staticTexts[expectedDebitCardCellLabel].exists &&
            app.cells.element(boundBy: 0).staticTexts[bankAccountTitle].exists &&
            app.cells.element(boundBy: 1).staticTexts[bankAccountTitle].exists &&
            app.cells.element(boundBy: 2).staticTexts[bankAccountTitle].exists &&
            app.cells.element(boundBy: 3).staticTexts[debitCardTitle].exists

        if #available(iOS 11.0, *) {
            XCTAssertTrue(isValid)
            XCTAssertTrue(app.cells.element(boundBy: 0).images.element.exists)
            XCTAssertTrue(app.cells.element(boundBy: 1).images.element.exists)
            XCTAssertTrue(app.cells.element(boundBy: 2).images.element.exists)
            XCTAssertTrue(app.cells.element(boundBy: 3).images.element.exists)
        } else {
            XCTAssertTrue(isValid)
        }
    }

    private func setUpStandardListTransferMethod() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodResponse",
                             method: HTTPMethod.get)
        openTransferMethodsList()
    }
}
