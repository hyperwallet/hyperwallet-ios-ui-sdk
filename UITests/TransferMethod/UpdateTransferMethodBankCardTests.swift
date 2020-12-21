import XCTest

class UpdateTransferMethodBankCardTests: BaseTests {
    var updateTransferMethod: UpdateTransferMethod!
    let debitCard = NSPredicate(format: "label CONTAINS[c] 'Debit Card'")
    var otherElements: XCUIElementQuery!
    var cardNumberLengthError: String!

    override func setUp() {
        super.setUp()

        app = XCUIApplication()
        app.launchEnvironment = [
            "COUNTRY": "US",
            "CURRENCY": "USD",
            "ACCOUNT_TYPE": "BANK_CARD",
            "PROFILE_TYPE": "INDIVIDUAL"
        ]
        app.launch()

        updateTransferMethod = UpdateTransferMethod(app: app)

        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodUpdateConfigurationFieldsResponse",
                             method: HTTPMethod.post)

        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodResponse",
                             method: HTTPMethod.get)

         cardNumberLengthError = updateTransferMethod.getLengthConstraintError(label: "Card Number", min: 13, max: 19)
        otherElements = updateTransferMethod.updateTransferMethodTableView.otherElements
        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)
        app.tables.cells.staticTexts["List Transfer Methods"].tap()
        app.tables.cells.containing(.staticText, identifier: "Debit Card".localized()).element(boundBy: 0).tap()

        app.sheets.buttons["Edit"].tap()
        waitForExistence(updateTransferMethod.navBarDebitCard)
    }

    func testUpdateTransferMethod_updateBankCardValidResponse() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/bank-cards/trm-00000000-0000-0000-0000-111111111111",
                             filename: "BankCardUpdateResponse",
                             method: HTTPMethod.put)

        updateTransferMethod.setCardNumber("4216701111111114")
        updateTransferMethod.setCvv("123")
        updateTransferMethod.clickUpdateTransferMethodButton()
        waitForNonExistence(spinner)

        XCTAssert(app.navigationBars["Transfer methods"].exists)
    }

    func testUpdateTransferMethod_returnBankCardNumberError() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/bank-cards/trm-00000000-0000-0000-0000-111111111111",
                             filename: "BankCardUpdateResponse",
                             method: HTTPMethod.put)

        updateTransferMethod.setCardNumber("4879abdafdfd12345678yuuyu")
        updateTransferMethod.clickUpdateTransferMethodButton()
        XCTAssert(updateTransferMethod.elementQuery["cardNumber_error"].exists)
        XCTAssert(otherElements.containing(NSPredicate(format: "label CONTAINS %@", cardNumberLengthError)).count == 1)
    }
}
