import XCTest

class UpdateTransferMethodBankCardTests: BaseTests {
    var updateTransferMethod: UpdateTransferMethod!
    let debitCard = NSPredicate(format: "label CONTAINS[c] 'Debit Card'")
    var otherElements: XCUIElementQuery!

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

        //updateTransferMethod.selectShipMethod("Expedited Delivery")
        updateTransferMethod.clickUpdateTransferMethodButton()
        waitForNonExistence(spinner)

        XCTAssert(app.navigationBars["Transfer methods"].exists)
    }
}
