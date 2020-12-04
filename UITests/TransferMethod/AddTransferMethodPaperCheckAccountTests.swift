import XCTest

class AddTransferMethodPaperCheckAccountTests: BaseTests {
    var selectTransferMethodType: SelectTransferMethodType!
    var addTransferMethod: AddTransferMethod!
    let paperCheckAccount = NSPredicate(format: "label CONTAINS[c] 'Paper Check'")

    override func setUp() {
        super.setUp()

        app = XCUIApplication()
        app.launchEnvironment = [
            "COUNTRY": "US",
            "CURRENCY": "USD",
            "ACCOUNT_TYPE": "PAPER_CHECK",
            "PROFILE_TYPE": "BUSINESS"
        ]
        app.launch()

        mockServer.setupStub(url: "/graphql",
                             filename: "TransferMethodPaperCheckResponse",
                             method: HTTPMethod.post)

        addTransferMethod = AddTransferMethod(app: app)
        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)
        addTransferMethod.addTransferMethodtable.tap()
        waitForExistence(addTransferMethod.navBarPaperCheck)
}

    func testAddTransferMethod_PaperCheck() {
        mockServer.setupStub(url: "/rest/v3/users/usr-token/-accounts",
                             filename: "TransferMethodCreatePaperCheck",
                             method: HTTPMethod.post)

        waitForNonExistence(spinner)
//        addTransferMethod.
        addTransferMethod.setPostalCode("10030")
        addTransferMethod.clickCreateTransferMethodButton()
        waitForNonExistence(spinner)
        XCTAssert(app.navigationBars[addTransferMethod.title].exists)
    }
}
