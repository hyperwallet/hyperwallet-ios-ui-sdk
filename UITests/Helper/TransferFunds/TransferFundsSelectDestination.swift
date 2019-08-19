import XCTest

class TransferFundsSelectDestination {
    var app: XCUIApplication

    var selectDestinationTitle: XCUIElement
    var addTransferMethodButton: XCUIElement
    var destination: XCUIElement
    var destinationDetail: XCUIElement

    init(app: XCUIApplication) {
        self.app = app
        selectDestinationTitle = app.navigationBars["Select Destination"]
        addTransferMethodButton = app.navigationBars["Select Destination"].buttons["Add"]
        destination = app.tables.staticTexts["transferDestinationTitleLabel"]
        destinationDetail = app.tables.staticTexts["transferDestinationTitleLabel"]
    }

    func clickBackButton() {
        app.navigationBars.buttons["Back"].tap()
    }

    func getSelectDestinationRowTitle(index: Int) -> String {
        let row = app.tables.element.children(matching: .cell).element(boundBy: index)
        return row.staticTexts["transferDestinationTitleLabel"].label
    }

    func getSelectDestinationRowDetail(index: Int) -> String {
        let row = app.tables.element.children(matching: .cell).element(boundBy: index)
        return row.staticTexts["transferDestinationSubtitleLabel"].label
    }
}
