import XCTest

class SelectTransferMethodCountryType {
    var app: XCUIApplication
    var countryTable: XCUIElement
    var navigationBar: XCUIElement

    init(app: XCUIApplication) {
        self.app = app

        countryTable = app.otherElements.containing(.navigationBar, identifier: "Select Country").element
        navigationBar = app.navigationBars["Select Country"]
    }

    func clickBackButton() {
        navigationBar.children(matching: .button).matching(identifier: "Back").element(boundBy: 0).tap()
    }
}
