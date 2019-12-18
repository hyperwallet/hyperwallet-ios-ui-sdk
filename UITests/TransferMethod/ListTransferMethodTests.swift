import XCTest

class ListTransferMethodTests: BaseTests {
    var listTransferMethod: ListTransferMethod!
    var selectTransferMethodType: SelectTransferMethodType!
    var addTransferMethod: AddTransferMethod!
    var loadingSpinner: XCUIElement!

    let debitCard = NSPredicate(format: "label CONTAINS[c] 'Debit Card'")
    let bankAccount = NSPredicate(format: "label CONTAINS[c] 'Bank Account'")
    let bankAccountTitle = "Bank Account"
    let debitCardTitle = "Debit Card"
    let payPalAccountTitle = "PayPal"

    var expectedFirstBankAccountLabel: String = {
        if #available(iOS 11.2, *) {
            return "United States\nEnding on 0001"
        } else {
            return "United States Ending on 0001"
        }
    }()

    var expectedSecondBankAccountLabel: String = {
        if #available(iOS 11.2, *) {
            return "United States\nEnding on 0002"
        } else {
            return "United States Ending on 0002"
        }
    }()

    var expectedThirdBankAccountLabel: String = {
        if #available(iOS 11.2, *) {
            return "United States\nEnding on 0003"
        } else {
            return "United States Ending on 0003"
        }
    }()

    var expectedDebitCardCellLabel: String = {
        if #available(iOS 11.2, *) {
            return "United States\nEnding on 0006"
        } else {
            return "United States Ending on 0006"
        }
    }()

    var expectedPayPalAccountCellLabel: String = {
        if #available(iOS 11.2, *) {
            return "United States\ncarroll.lynn@byteme.com"
        } else {
            return "United States carroll.lynn@byteme.com"
        }
    }()

    var removeBankCardURL: String {
        let bankCardEndpoint = "rest/v3/users/usr-token/bank-cards/"
        let removeDebitCardEndpoint = "trm-00000000-0000-0000-0000-111111111111/status-transitions"
        return bankCardEndpoint + removeDebitCardEndpoint
    }

    var removeBankAccountURL: String {
        let bankAccountEndpoint = "rest/v3/users/usr-token/bank-accounts/"
        let removeBankAccountEndpoint = "trm-11111111-1111-1111-1111-000000000000/status-transitions"
        return bankAccountEndpoint + removeBankAccountEndpoint
    }

    var removePayPalAccountURL: String {
        let payPalAccountEndpoint = "rest/v3/users/usr-token/paypal-accounts/"
        let removePayPalAccountEndpoint = "trm-11111111-1111-1111-1111-000000000000/status-transitions"
        return payPalAccountEndpoint + removePayPalAccountEndpoint
    }

    override func setUp() {
        super.setUp()

        app = XCUIApplication()
        app.launch()

        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodConfigurationKeysResponse",
                             method: HTTPMethod.post)
        mockServer.setupStub(url: "/rest/v3/users/usr-token",
                             filename: "UserIndividualResponse",
                             method: HTTPMethod.get)

        listTransferMethod = ListTransferMethod(app: app)
        selectTransferMethodType = SelectTransferMethodType(app: app)
        addTransferMethod = AddTransferMethod(app: app)
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
        XCTAssertTrue(app.cells.element(boundBy: 4).staticTexts[expectedPayPalAccountCellLabel].exists)
    }

    func testListTransferMethod_addTransferMethodFromEmptyScreen() {
        mockServer.setUpEmptyResponse(url: "/rest/v3/users/usr-token/transfer-methods")

        openTransferMethodsList()
        listTransferMethod.tapAddTransferMethodEmptyScreenButton()

        XCTAssertTrue(app.navigationBars["Add Account"].exists)
    }

    func testListTransferMethod_addTransferMethod() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodResponse",
                             method: HTTPMethod.get)

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
        let cellsCountBeforeRemove = 5
        let expectedCellsCountAfterRemove = 4

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
        XCTAssertTrue(app.cells.element(boundBy: 3).staticTexts[expectedPayPalAccountCellLabel].exists)
        XCTAssertFalse(app.cells.element(boundBy: 4).exists)
    }

    func testListTransferMethod_deleteDebitCard() {
        let cellsCountBeforeRemove = 5
        let expectedCellsCountAfterRemove = 4

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
        XCTAssertTrue(app.cells.element(boundBy: 3).staticTexts[expectedPayPalAccountCellLabel].exists)
        XCTAssertFalse(app.cells.element(boundBy: 4).exists)
    }

    func testListTransferMethod_deletePayPalAccount() {
        let cellsCountBeforeRemove = 5
        let expectedCellsCountAfterRemove = 4

        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodResponse",
                             method: HTTPMethod.get)

        openTransferMethodsList()
        app.tables.cells.containing(.staticText, identifier: "PayPal").element(boundBy: 0).tap()

        XCTAssertEqual(app.tables.element(boundBy: 0).cells.count, cellsCountBeforeRemove)

        listTransferMethod.tapRemoveAccountButton()

        mockServer.setupStub(url: removePayPalAccountURL,
                             filename: "RemovedTransferMethodResponse",
                             method: HTTPMethod.post)
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodResponseWithoutPayPalAccount",
                             method: HTTPMethod.get)

        XCTAssertTrue(listTransferMethod.confirmAccountRemoveButton.exists)

        listTransferMethod.tapConfirmAccountRemoveButton()
        waitForNonExistence(spinner)
        waitForNonExistence(loadingSpinner)

        XCTAssertEqual(app.tables.element(boundBy: 0).cells.count, expectedCellsCountAfterRemove)
        XCTAssertTrue(app.cells.element(boundBy: 0).staticTexts[expectedFirstBankAccountLabel].exists)
        XCTAssertTrue(app.cells.element(boundBy: 1).staticTexts[expectedSecondBankAccountLabel].exists)
        XCTAssertTrue(app.cells.element(boundBy: 2).staticTexts[expectedThirdBankAccountLabel].exists)
        XCTAssertTrue(app.cells.element(boundBy: 3).staticTexts[expectedDebitCardCellLabel].exists)
        XCTAssertFalse(app.cells.element(boundBy: 4).exists)
    }

    func testListTransferMethod_cancelDeleteTransferMethod() {
        let expectedCellsCount = 5

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
        XCTAssertTrue(app.cells.element(boundBy: 4).staticTexts[expectedPayPalAccountCellLabel].exists)
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

    private func validateTestListTransferMethodScreen() {
        let expectedCellsCount = 5
        XCTAssertTrue(listTransferMethod.navigationBar.exists)
        XCTAssertTrue(app.tables.element(boundBy: 0).cells.count == expectedCellsCount)
        XCTAssertTrue(app.cells.element(boundBy: 0).staticTexts[expectedFirstBankAccountLabel].exists)
        XCTAssertTrue(app.cells.element(boundBy: 1).staticTexts[expectedSecondBankAccountLabel].exists)
        XCTAssertTrue(app.cells.element(boundBy: 2).staticTexts[expectedThirdBankAccountLabel].exists)
        XCTAssertTrue(app.cells.element(boundBy: 3).staticTexts[expectedDebitCardCellLabel].exists)
        XCTAssertTrue(app.cells.element(boundBy: 4).staticTexts[expectedPayPalAccountCellLabel].exists)
        XCTAssertTrue(app.cells.element(boundBy: 0).staticTexts[bankAccountTitle].exists)
        XCTAssertTrue(app.cells.element(boundBy: 1).staticTexts[bankAccountTitle].exists)
        XCTAssertTrue(app.cells.element(boundBy: 2).staticTexts[bankAccountTitle].exists)
        XCTAssertTrue(app.cells.element(boundBy: 3).staticTexts[debitCardTitle].exists)
        XCTAssertTrue(app.cells.element(boundBy: 4).staticTexts[payPalAccountTitle].exists)

        if #available(iOS 11.0, *) {
            XCTAssertTrue(app.cells.element(boundBy: 0).images.element.exists)
            XCTAssertTrue(app.cells.element(boundBy: 1).images.element.exists)
            XCTAssertTrue(app.cells.element(boundBy: 2).images.element.exists)
            XCTAssertTrue(app.cells.element(boundBy: 3).images.element.exists)
            XCTAssertTrue(app.cells.element(boundBy: 4).images.element.exists)
        }
    }
}
