import XCTest

class AddTransferMethodVemoAccountTests: BaseTests {
    var selectTransferMethodType: SelectTransferMethodType!
    var addTransferMethod: AddTransferMethod!
    let venmoAccount = NSPredicate(format: "label CONTAINS[c] 'Venmo Account'")

    override func setUp() {
        super.setUp()

        app = XCUIApplication()
        app.launchEnvironment = [
            "COUNTRY": "US",
            "CURRENCY": "USD",
            "ACCOUNT_TYPE": "VENMO_ACCOUNT",
            "PROFILE_TYPE": "BUSINESS"
        ]
        app.launch()

        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodVenmoResponse",
                             method: HTTPMethod.post)

        addTransferMethod = AddTransferMethod(app: app)
        addTransferMethod.addTransferMethodtable.tap()
        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)
        addTransferMethod = AddTransferMethod(app: app)
}

    func testAddTransferMethod_Venmo() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/venmo-accounts",
                             filename: "TransferMethodCreateVenmoAccount",
                             method: HTTPMethod.post)

        waitForNonExistence(spinner)
        addTransferMethod.setAccountId("9876549991")
        addTransferMethod.clickCreateTransferMethodButton()
        waitForNonExistence(spinner)
        XCTAssert(app.navigationBars[addTransferMethod.title].exists)
    }
}
