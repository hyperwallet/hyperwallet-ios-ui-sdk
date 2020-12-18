import XCTest

class UpdateTransferMethodWireAccountTests: BaseTests {
    var updateTransferMethod: UpdateTransferMethod!
    let wireAccount = NSPredicate(format: "label CONTAINS[c] 'Wire Transfer'")
    var otherElements: XCUIElementQuery!

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

        updateTransferMethod = UpdateTransferMethod(app: app)

        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodUpdateConfigurationFieldsWireAccountResponse",
                             method: HTTPMethod.post)

        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodWireAccount",
                             method: HTTPMethod.get)

        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)
        app.tables.cells.staticTexts["List Transfer Methods"].tap()
        app.tables.cells.containing(.staticText,
                                    identifier: "Wire Transfer Account".localized())
            .element(boundBy: 0)
            .tap()

        app.sheets.buttons["Edit"].tap()
        waitForExistence(updateTransferMethod.navBarWireAccount)
    }

    func testUpdateTransferMethod_updateWireAccountValidResponse() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/bank-accounts/trm-12345",
                             filename: "WireAccountUpdateResponse",
                             method: HTTPMethod.put)

        //updateTransferMethod.selectShipMethod("Expedited Delivery")
        updateTransferMethod.clickUpdateTransferMethodButton()
        waitForNonExistence(spinner)

        XCTAssert(app.navigationBars["Transfer methods"].exists)
    }
}
