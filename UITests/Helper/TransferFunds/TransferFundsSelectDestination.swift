import XCTest

class TransferFundsSelectDestination {
    var app: XCUIApplication

    var selectDestinationTitle: XCUIElement
    var addTransferMethodButton: XCUIElement
    var destination: XCUIElement
    var destinationDetail: XCUIElement
    let destinationCellTitle = "transferDestinationTitleLabel"
    let destinationCellSubtitle = "transferDestinationSubtitleLabel"

    init(app: XCUIApplication) {
        self.app = app
        selectDestinationTitle = app.navigationBars["Select Destination"]
        addTransferMethodButton = selectDestinationTitle.buttons["Add"]
        destination = app.tables.staticTexts[destinationCellTitle]
        destinationDetail = app.tables.staticTexts[destinationCellSubtitle]
    }

    func clickBackButton() {
        app.navigationBars.buttons["Back"].tap()
    }

    func getSelectDestinationRowTitle(index: Int) -> String {
        let row = app.tables.element.children(matching: .cell).element(boundBy: index)
        return row.staticTexts[destinationCellTitle].label
    }

    func getSelectDestinationRowDetail(index: Int) -> String {
        let row = app.tables.element.children(matching: .cell).element(boundBy: index)
        return row.staticTexts[destinationCellSubtitle].label
    }
}
