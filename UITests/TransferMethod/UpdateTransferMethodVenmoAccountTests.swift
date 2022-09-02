import XCTest

class UpdateTransferMethodVenmoAccountTests: BaseTests {
    var updateTransferMethod: UpdateTransferMethod!
    let venmoAccount = NSPredicate(format: "label CONTAINS[c] 'Venmo Account'")
    var lengthErrorForVenmo: String!
    var otherElements: XCUIElementQuery!

    override func setUp() {
        super.setUp()

        app = XCUIApplication()
        app.launchArguments.append("enable-testing")
        app.launchEnvironment = [
            "COUNTRY": "US",
            "CURRENCY": "USD",
            "ACCOUNT_TYPE": "VENMO_ACCOUNT",
            "PROFILE_TYPE": "INDIVIDUAL"
        ]
        app.launch()

        updateTransferMethod = UpdateTransferMethod(app: app)

        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodUpdateConfigurationFieldsVenmoResponse",
                             method: HTTPMethod.post)

        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodResponsePaperCheck",
                             method: HTTPMethod.get)

         lengthErrorForVenmo = updateTransferMethod.getLengthErrorForVenmo(length: 10)
         otherElements = updateTransferMethod.updateTransferMethodTableView.otherElements

        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)
        app.tables.cells.staticTexts["List Transfer Methods"].tap()
        app.tables.cells.containing(.staticText, identifier: "venmo_account".localized()).element(boundBy: 0).tap()

        app.sheets.buttons["Edit"].tap()
        waitForExistence(updateTransferMethod.navBarVenmo)
    }

    func testUpdateTransferMethod_updateVenmoAccountValidResponse() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/venmo-accounts/trm-11111111-0000-0000-0000-000000000000",
                             filename: "VenmoUpdateResponse",
                             method: HTTPMethod.put)

        updateTransferMethod.setAccountId("6474551127")
        updateTransferMethod.clickUpdateTransferMethodButton()
        waitForNonExistence(spinner)

        XCTAssert(app.navigationBars["Transfer methods"].exists)
    }

    func testUpdateTransferMethod_returnVenmoLengthError() {
           mockServer.setupStub(url: "/rest/v3/users/usr-token/venmo-accounts/trm-11111111-0000-0000-0000-000000000000",
                                filename: "VenmoUpdateResponse",
                                method: HTTPMethod.put)

           updateTransferMethod.setAccountId("3654643563546546474551127")
           updateTransferMethod.clickUpdateTransferMethodButton()
           XCTAssert(updateTransferMethod.elementQuery["accountId_error"].exists)
           XCTAssert(otherElements.containing(NSPredicate(format: "label CONTAINS %@", lengthErrorForVenmo)).count == 1)
       }
}
