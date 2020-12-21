import XCTest

class UpdateTransferMethodPaPerCheckAccountTests: BaseTests {
    var updateTransferMethod: UpdateTransferMethod!
    let paperCheckAccount = NSPredicate(format: "label CONTAINS[c] 'Paper Check'")
    var otherElements: XCUIElementQuery!
    var postalEmptyError: String!

    override func setUp() {
        super.setUp()

        app = XCUIApplication()
        app.launchEnvironment = [
            "COUNTRY": "US",
            "CURRENCY": "USD",
            "ACCOUNT_TYPE": "PAPER_CHECK",
            "PROFILE_TYPE": "INDIVIDUAL"
        ]
        app.launch()

        updateTransferMethod = UpdateTransferMethod(app: app)

        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodUpdateConfigurationFieldsPaperCheckResponse",
                             method: HTTPMethod.post)

        mockServer.setupStub(url: "/rest/v3/users/usr-token/transfer-methods",
                             filename: "ListTransferMethodResponsePaperCheck",
                             method: HTTPMethod.get)

        postalEmptyError = updateTransferMethod.getEmptyError(label: "Zip/Postal Code")
        otherElements = updateTransferMethod.updateTransferMethodTableView.otherElements

        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)
        app.tables.cells.staticTexts["List Transfer Methods"].tap()
        app.tables.cells.containing(.staticText, identifier: "paper_check".localized()).element(boundBy: 0).tap()

        app.sheets.buttons["Edit"].tap()
        waitForExistence(updateTransferMethod.navBarPaperCheck)
    }

    func testUpdateTransferMethod_updatePaPerCheckAccountValidResponse() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/paper-checks/trm-00000000-1111-0000-0000-000000000001",
                             filename: "PaperCheckUpdateResponse",
                             method: HTTPMethod.put)

        updateTransferMethod.selectShipMethod("Expedited Delivery")
        updateTransferMethod.setStateProvince("ON")
        updateTransferMethod.setCity("Toronto")
        updateTransferMethod.setPostalCode("M4X1P1")
        updateTransferMethod.clickUpdateTransferMethodButton()
        waitForNonExistence(spinner)

        XCTAssert(app.navigationBars["Transfer methods"].exists)
    }

    func testUpdateTransferMethod_returnPaPerCheckEmptyPostalError() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/paper-checks/trm-00000000-1111-0000-0000-000000000001",
                             filename: "PaperCheckUpdateResponse",
                             method: HTTPMethod.put)

        updateTransferMethod.setPostalCode("")
        updateTransferMethod.clickUpdateTransferMethodButton()
        XCTAssert(updateTransferMethod.elementQuery["postalCode_error"].exists)
        XCTAssert(otherElements.containing(NSPredicate(format: "label CONTAINS %@", postalEmptyError)).count == 1)
    }
}
