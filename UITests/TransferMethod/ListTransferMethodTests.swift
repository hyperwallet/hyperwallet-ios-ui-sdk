import XCTest

class ListTransferMethodTests: BaseTests {
    var listTransferMethod: ListTransferMethod!
    var selectTransferMethodType: SelectTransferMethodType!
    var addTransferMethod: AddTransferMethod!
    var loadingSpinner: XCUIElement!
    let bankAccountTitle = TransferMethods.bankAccount
    let debitCardTitle = TransferMethods.debitCard
    let payPalAccountTitle = TransferMethods.paypal
    let venmoAccountTitle = TransferMethods.venmo
    let paperCheckTitle = TransferMethods.paperCheck
    var debitCard: NSPredicate!
    var bankAccount: NSPredicate!

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

    var removeVenmoAccountURL: String {
        let venmoAccountEndpoint = "rest/v3/users/usr-token/venmo-accounts/"
        let removeVenmoAccountEndpoint = "trm-11111111-0000-0000-0000-000000000000/status-transitions"
        return venmoAccountEndpoint + removeVenmoAccountEndpoint
    }

    var removePaperCheckURL: String {
           let paperCheckEndpoint = "rest/v3/users/usr-token/paper-checks/"
           let removePaperCheckEndpoint = "trm-00000000-1111-0000-0000-000000000001/status-transitions"
           return paperCheckEndpoint + removePaperCheckEndpoint
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
        debitCard = NSPredicate(format: "label CONTAINS[c] '\(debitCardTitle)'")
        bankAccount = NSPredicate(format: "label CONTAINS[c] '\(bankAccountTitle)'")
    }

    func testListTransferMethod_emptyTransferMethodsList() {
        mockServer.setUpEmptyResponse(url: "/rest/v3/users/usr-token/transfer-methods")

        openTransferMethodsList()

        let expectedTitle = "Add a transfer method to get started."

        XCTAssertTrue(app.staticTexts[expectedTitle].exists)
        XCTAssertTrue(listTransferMethod.addTransferMethodButton.exists)
    }

    func testListTransferMethod_verifyTransferMethodsOrder() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodResponse",
                             method: HTTPMethod.get)

        openTransferMethodsList()
        let expectedFirstBankAccountLabel = listTransferMethod.getTransferMethodLabel(endingDigits: "0001")
        let expectedSecondBankAccountLabel = listTransferMethod.getTransferMethodLabel(endingDigits: "0002")
        let expectedThirdBankAccountLabel = listTransferMethod.getTransferMethodLabel(endingDigits: "0003")
        let expectedDebitCardCellLabel = listTransferMethod.getTransferMethodLabel(endingDigits: "0006")

        let expectedPayPalAccountCellLabel = listTransferMethod
            .getTransferMethodPayalLabel(email: "carroll.lynn@byteme.com")

        XCTAssertTrue(listTransferMethod.getTransferMethodIcon(index: 0).exists, "Expect icon")
        XCTAssertTrue(listTransferMethod.getTransferMethodIcon(index: 1).exists, "Expect icon")
        XCTAssertTrue(listTransferMethod.getTransferMethodIcon(index: 2).exists, "Expect icon")
        XCTAssertTrue(listTransferMethod.getTransferMethodIcon(index: 3).exists, "Expect icon")
        XCTAssertTrue(listTransferMethod.getTransferMethodIcon(index: 4).exists, "Expect icon")

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

        XCTAssertTrue(app.navigationBars["mobileAddTransferMethodHeader".localized()].exists)
    }

    func testListTransferMethod_addTransferMethod() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodResponse",
                             method: HTTPMethod.get)

        openTransferMethodsList()
        listTransferMethod.tapAddTransferMethodButton()

        XCTAssertTrue(app.navigationBars["mobileAddTransferMethodHeader".localized()].exists)
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

        mockServer.setupStub(url: removeBankAccountURL,
                             filename: "RemovedTransferMethodResponse",
                             method: HTTPMethod.post)
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodResponseWithoutFirstElement",
                             method: HTTPMethod.get)

        app.sheets.buttons["Remove"].tap()
        XCTAssertTrue(listTransferMethod.alert.waitForExistence(timeout: 1))
        verifyRemoveConfirmation(transferMethod: "Bank Account")

        listTransferMethod.tapConfirmAccountRemoveButton()
        waitForNonExistence(spinner)
        waitForNonExistence(loadingSpinner)

        XCTAssertEqual(app.tables.element(boundBy: 0).cells.count, expectedCellsCountAfterRemove)

        let expectedSecondBankAccountLabel = listTransferMethod.getTransferMethodLabel(endingDigits: "0002")
        let expectedThirdBankAccountLabel = listTransferMethod.getTransferMethodLabel(endingDigits: "0003")
        let expectedDebitCardCellLabel = listTransferMethod.getTransferMethodLabel(endingDigits: "0006")
        let expectedPayPalAccountCellLabel = listTransferMethod
            .getTransferMethodPayalLabel(email: "carroll.lynn@byteme.com")

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

        mockServer.setupStub(url: removeBankCardURL,
                             filename: "RemovedTransferMethodResponse",
                             method: HTTPMethod.post)
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodResponseWithoutDebitCard",
                             method: HTTPMethod.get)

        app.sheets.buttons["Remove"].tap()
        XCTAssertTrue(listTransferMethod.alert.waitForExistence(timeout: 1))
        verifyRemoveConfirmation(transferMethod: "Debit Card")

        listTransferMethod.tapConfirmAccountRemoveButton()
        waitForNonExistence(spinner)
        waitForNonExistence(loadingSpinner)

        XCTAssertEqual(app.tables.element(boundBy: 0).cells.count, expectedCellsCountAfterRemove)
        let expectedFirstBankAccountLabel = listTransferMethod.getTransferMethodLabel(endingDigits: "0001")
        let expectedSecondBankAccountLabel = listTransferMethod.getTransferMethodLabel(endingDigits: "0002")
        let expectedThirdBankAccountLabel = listTransferMethod.getTransferMethodLabel(endingDigits: "0003")
        let expectedPayPalAccountCellLabel = listTransferMethod
            .getTransferMethodPayalLabel(email: "carroll.lynn@byteme.com")
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
        app.tables.cells.containing(.staticText, identifier: "paypal_account".localized()).element(boundBy: 0).tap()

        XCTAssertEqual(app.tables.element(boundBy: 0).cells.count, cellsCountBeforeRemove)

        mockServer.setupStub(url: removePayPalAccountURL,
                             filename: "RemovedTransferMethodResponse",
                             method: HTTPMethod.post)
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodResponseWithoutPayPalAccount",
                             method: HTTPMethod.get)

        app.sheets.buttons["Remove"].tap()
        XCTAssertTrue(listTransferMethod.alert.waitForExistence(timeout: 1))
        verifyRemoveConfirmation(transferMethod: "paypal_account".localized())

        listTransferMethod.tapConfirmAccountRemoveButton()
        waitForNonExistence(spinner)
        waitForNonExistence(loadingSpinner)

        XCTAssertEqual(app.tables.element(boundBy: 0).cells.count, expectedCellsCountAfterRemove)
        let expectedFirstBankAccountLabel = listTransferMethod.getTransferMethodLabel(endingDigits: "0001")
        let expectedSecondBankAccountLabel = listTransferMethod.getTransferMethodLabel(endingDigits: "0002")
        let expectedThirdBankAccountLabel = listTransferMethod.getTransferMethodLabel(endingDigits: "0003")
        let expectedDebitCardCellLabel = listTransferMethod.getTransferMethodLabel(endingDigits: "0006")

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

        waitForNonExistence(spinner)

        app.sheets.buttons["Remove"].tap()
        XCTAssertTrue(listTransferMethod.alert.waitForExistence(timeout: 1))
        verifyRemoveConfirmation(transferMethod: "Bank Account")

        listTransferMethod.tapCancelAccountRemoveButton()

        XCTAssertEqual(app.tables.element(boundBy: 0).cells.count, expectedCellsCount)

        let expectedSecondBankAccountLabel = listTransferMethod.getTransferMethodLabel(endingDigits: "0002")
        let expectedThirdBankAccountLabel = listTransferMethod.getTransferMethodLabel(endingDigits: "0003")
        let expectedDebitCardCellLabel = listTransferMethod.getTransferMethodLabel(endingDigits: "0006")
        let expectedPayPalAccountCellLabel = listTransferMethod
            .getTransferMethodPayalLabel(email: "carroll.lynn@byteme.com")
        XCTAssertTrue(app.cells.element(boundBy: 1).staticTexts[expectedSecondBankAccountLabel].exists)
        XCTAssertTrue(app.cells.element(boundBy: 2).staticTexts[expectedThirdBankAccountLabel].exists)
        XCTAssertTrue(app.cells.element(boundBy: 3).staticTexts[expectedDebitCardCellLabel].exists)
        XCTAssertTrue(app.cells.element(boundBy: 4).staticTexts[expectedPayPalAccountCellLabel].exists)
    }

    func testListTransferMethod_cancelActionDeleteTransferMethod() {
        let expectedCellsCount = 5

        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodResponse",
                             method: HTTPMethod.get)

        openTransferMethodsList()
        app.tables.cells.containing(.staticText, identifier: "Bank Account").element(boundBy: 0).tap()

        XCTAssertEqual(app.tables.element(boundBy: 0).cells.count, expectedCellsCount)

        waitForNonExistence(spinner)

        app.sheets.buttons["Cancel"].tap()

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

        waitForNonExistence(spinner)

        app.sheets.buttons["Remove"].tap()
        XCTAssertTrue(listTransferMethod.alert.waitForExistence(timeout: 1))

        XCTAssertTrue(listTransferMethod.confirmAccountRemoveButton.exists)

        listTransferMethod.tapConfirmAccountRemoveButton()
        waitForNonExistence(spinner)

        verifyUnexpectedError()

        waitForNonExistence(spinner)

        XCTAssertTrue(addTransferMethod.navBar.exists)

        XCTAssertTrue(addTransferMethod.navBar.exists)
    }

    private func openTransferMethodsList() {
        app.tables.cells.containing(.staticText, identifier: "List Transfer Methods").element(boundBy: 0).tap()
        spinner = app.activityIndicators["activityIndicator"]
        loadingSpinner = app.activityIndicators["In progress"]
        waitForNonExistence(spinner)
    }

    private func validateTestListTransferMethodScreen() {
        let expectedCellsCount = 6
        XCTAssertTrue(listTransferMethod.navigationBar.exists)
        XCTAssertTrue(app.tables.element(boundBy: 0).cells.count == expectedCellsCount)
        let expectedFirstBankAccountLabel = listTransferMethod.getTransferMethodLabel(endingDigits: "0001")
        let expectedSecondBankAccountLabel = listTransferMethod.getTransferMethodLabel(endingDigits: "0002")
        let expectedThirdBankAccountLabel = listTransferMethod.getTransferMethodLabel(endingDigits: "0003")
        let expectedDebitCardCellLabel = listTransferMethod.getTransferMethodLabel(endingDigits: "0006")
        let expectedPayPalAccountCellLabel = listTransferMethod
            .getTransferMethodPayalLabel(email: "carroll.lynn@byteme.com")

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

    func verifyRemoveConfirmation(transferMethod: String) {
          XCTAssertTrue(listTransferMethod.confirmAccountRemoveButton.exists)
          XCTAssertTrue(listTransferMethod.cancelAccountRemoveButton.exists)

        let alert = app.alerts[listTransferMethod.removeAccountTitle]
          XCTAssert(alert.exists)
          XCTAssertTrue(listTransferMethod.confirmAccountRemoveButton.exists)
          XCTAssertTrue(listTransferMethod.cancelAccountRemoveButton.exists)
      }

    func testListTransferMethod_managePrepaidcard() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodManagePrepaidCard",
                             method: HTTPMethod.get)

        openTransferMethodsList()

        XCTAssertTrue( app.tables.cells.containing(.staticText, identifier: "Prepaid Card").element(boundBy: 0).exists)
        XCTAssertTrue( app.tables.cells.containing(.staticText, identifier: "Prepaid Card").element(boundBy: 1).exists)

        //prepaid card 1 & 2 info
        let expectedPPCCellLabel1 = listTransferMethod
            .getTransferMethodPrepaidCardLabel(visacard: "Visa •••• 8766")
        let expectedPPCCellLabel2 = listTransferMethod
            .getTransferMethodPrepaidCardLabel(visacard: "Mastercard •••• 8767")

        XCTAssertTrue(app.cells.element(boundBy: 0).staticTexts[expectedPPCCellLabel1].exists)
        XCTAssertTrue(app.cells.element(boundBy: 1).staticTexts[expectedPPCCellLabel2].exists)

        //icon
        XCTAssertTrue(listTransferMethod.getTransferMethodIcon(index: 0).exists, "Expect icon")
        XCTAssertTrue(listTransferMethod.getTransferMethodIcon(index: 1).exists, "Expect icon")

        //tap n confirm no delete feature
        app.tables.cells.containing(.staticText, identifier: "Prepaid Card").element(boundBy: 0).tap()
        waitForNonExistence(spinner)
        XCTAssertFalse(listTransferMethod.confirmAccountRemoveButton.exists)

        app.tables.cells.containing(.staticText, identifier: "Prepaid Card").element(boundBy: 1).tap()
        waitForNonExistence(spinner)
        XCTAssertFalse(listTransferMethod.confirmAccountRemoveButton.exists)
    }

    func testListTransferMethod_VenmoManage() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "TransferMethodVenmoList",
                             method: HTTPMethod.get)

        openTransferMethodsList()

        XCTAssertTrue( app.tables.cells.containing(.staticText, identifier: "venmo_account".localized())
            .element(boundBy: 0).exists)
        XCTAssertTrue( app.tables.cells.containing(.staticText, identifier: "venmo_account".localized())
            .element(boundBy: 1).exists)

        let expectedFirstBankAccountLabel = listTransferMethod.getTransferMethodLabel(endingDigits: "5555")
        let expectedSecondBankAccountLabel = listTransferMethod.getTransferMethodLabel(endingDigits: "5556")

        XCTAssertTrue(app.cells.element(boundBy: 0).staticTexts[expectedFirstBankAccountLabel].exists)
        XCTAssertTrue(app.cells.element(boundBy: 1).staticTexts[expectedSecondBankAccountLabel].exists)

        XCTAssertTrue(listTransferMethod.getTransferMethodIcon(index: 0).exists, "Expect icon")
        XCTAssertTrue(listTransferMethod.getTransferMethodIcon(index: 1).exists, "Expect icon")
    }

    func testListTransferMethod_deleteVenmoAccount() {
        let cellsCountBeforeRemove = 5
        let expectedCellsCountAfterRemove = 4
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodResponseVenmo",
                             method: HTTPMethod.get)
        openTransferMethodsList()
        app.tables.cells.containing(.staticText, identifier: "venmo_account".localized()).element(boundBy: 0).tap()

        XCTAssertEqual(app.tables.element(boundBy: 0).cells.count, cellsCountBeforeRemove)

        mockServer.setupStub(url: removeVenmoAccountURL,
                             filename: "RemovedTransferMethodResponse",
                             method: HTTPMethod.post)
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodResponseWithoutFirstElement",
                             method: HTTPMethod.get)

        app.sheets.buttons["Remove"].tap()
        XCTAssertTrue(listTransferMethod.alert.waitForExistence(timeout: 1))
       verifyRemoveConfirmation(transferMethod: "venmo_account".localized())

        listTransferMethod.tapConfirmAccountRemoveButton()
        waitForNonExistence(spinner)
        waitForNonExistence(loadingSpinner)

        XCTAssertEqual(app.tables.element(boundBy: 0).cells.count, expectedCellsCountAfterRemove)
        let expectedSecondBankAccountLabel = listTransferMethod.getTransferMethodLabel(endingDigits: "0002")
        let expectedThirdBankAccountLabel = listTransferMethod.getTransferMethodLabel(endingDigits: "0003")
        let expectedDebitCardCellLabel = listTransferMethod.getTransferMethodLabel(endingDigits: "0006")
        let expectedPayPalAccountCellLabel = listTransferMethod
            .getTransferMethodPayalLabel(email: "carroll.lynn@byteme.com")

        XCTAssertTrue(app.cells.element(boundBy: 0).staticTexts[expectedSecondBankAccountLabel].exists)
        XCTAssertTrue(app.cells.element(boundBy: 1).staticTexts[expectedThirdBankAccountLabel].exists)
        XCTAssertTrue(app.cells.element(boundBy: 2).staticTexts[expectedDebitCardCellLabel].exists)
        XCTAssertTrue(app.cells.element(boundBy: 3).staticTexts[expectedPayPalAccountCellLabel].exists)
        XCTAssertFalse(app.cells.element(boundBy: 4).exists)
    }

    func testListTransferMethod_PaperCheckManage() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "TransferMethodPaperCheckList",
                             method: HTTPMethod.get)

        openTransferMethodsList()

        XCTAssertTrue( app.tables.cells.containing(.staticText, identifier: "paper_check".localized())
            .element(boundBy: 0).exists)
        XCTAssertTrue( app.tables.cells.containing(.staticText, identifier: "paper_check".localized())
            .element(boundBy: 1).exists)

        let expectedFirstBankAccountLabel = listTransferMethod.getTransferMethodPaperCheckLabel(postalCode: "12345")
        let expectedSecondBankAccountLabel = listTransferMethod.getTransferMethodPaperCheckLabel(postalCode: "12345")

        XCTAssertTrue(app.cells.element(boundBy: 0).staticTexts[expectedFirstBankAccountLabel].exists)
        XCTAssertTrue(app.cells.element(boundBy: 1).staticTexts[expectedSecondBankAccountLabel].exists)

        XCTAssertTrue(listTransferMethod.getTransferMethodIcon(index: 0).exists, "Expect icon")
        XCTAssertTrue(listTransferMethod.getTransferMethodIcon(index: 1).exists, "Expect icon")
    }

    func testListTransferMethod_deletePaperCheckAccount() {
        let cellsCountBeforeRemove = 6
        let expectedCellsCountAfterRemove = 5
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodResponsePaperCheck",
                             method: HTTPMethod.get)
        openTransferMethodsList()
        app.tables.cells.containing(.staticText, identifier: "paper_check".localized()).element(boundBy: 0).tap()

        XCTAssertEqual(app.tables.element(boundBy: 0).cells.count, cellsCountBeforeRemove)

        mockServer.setupStub(url: removePaperCheckURL,
                             filename: "RemovedTransferMethodResponse",
                             method: HTTPMethod.post)
        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodResponseWithoutPaperCheck",
                             method: HTTPMethod.get)

        app.sheets.buttons["Remove"].tap()
        XCTAssertTrue(listTransferMethod.alert.waitForExistence(timeout: 1))
       verifyRemoveConfirmation(transferMethod: "paper_check".localized())

        listTransferMethod.tapConfirmAccountRemoveButton()
        waitForNonExistence(spinner)
        waitForNonExistence(loadingSpinner)

        XCTAssertEqual(app.tables.element(boundBy: 0).cells.count, expectedCellsCountAfterRemove)
        let expectedSecondBankAccountLabel = listTransferMethod.getTransferMethodLabel(endingDigits: "0001")
        let expectedThirdBankAccountLabel = listTransferMethod.getTransferMethodLabel(endingDigits: "0003")
        let expectedDebitCardCellLabel = listTransferMethod.getTransferMethodLabel(endingDigits: "0006")
        let expectedPayPalAccountCellLabel = listTransferMethod
            .getTransferMethodPayalLabel(email: "carroll.lynn@byteme.com")

        XCTAssertTrue(app.cells.element(boundBy: 0).staticTexts[expectedSecondBankAccountLabel].exists)
        XCTAssertTrue(app.cells.element(boundBy: 2).staticTexts[expectedThirdBankAccountLabel].exists)
        XCTAssertTrue(app.cells.element(boundBy: 3).staticTexts[expectedDebitCardCellLabel].exists)
        XCTAssertTrue(app.cells.element(boundBy: 4).staticTexts[expectedPayPalAccountCellLabel].exists)
        XCTAssertFalse(app.cells.element(boundBy: 5).exists)
    }
}
