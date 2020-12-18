import XCTest

class UpdateTransferMethodBankAccountIndividualTests: BaseTests {
    var updateTransferMethod: UpdateTransferMethod!
    let bankAccount = NSPredicate(format: "label CONTAINS[c] 'Bank Account'")
    var otherElements: XCUIElementQuery!

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

        updateTransferMethod = UpdateTransferMethod(app: app)

        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodUpdateConfigurationFieldsBankAccountResponse",
                             method: HTTPMethod.post)

        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodResponse",
                             method: HTTPMethod.get)

        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)
        app.tables.cells.staticTexts["List Transfer Methods"].tap()
        app.tables.cells.containing(.staticText, identifier: "Bank Account".localized()).element(boundBy: 0).tap()

        app.sheets.buttons["Edit"].tap()
        waitForExistence(updateTransferMethod.navBarBankAccount)
    }

    func testUpdateTransferMethod_updateBankAccountIndividualValidResponse() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/bank-accounts/trm-11111111-1111-1111-1111-000000000000",
                             filename: "BankAccountIndividualUpdateResponse",
                             method: HTTPMethod.put)

        //updateTransferMethod.selectShipMethod("Expedited Delivery")
        updateTransferMethod.clickUpdateTransferMethodButton()
        waitForNonExistence(spinner)

        XCTAssert(app.navigationBars["Transfer methods"].exists)
    }
}
