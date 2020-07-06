import XCTest

class ReceiptsList {
    let defaultTimeout = 5.0

    var app: XCUIApplication

    var navigationBar: XCUIElement

    init(app: XCUIApplication) {
        self.app = app

        navigationBar = app.navigationBars["Transactions"]
    }

    func clickBackButton() {
        navigationBar.children(matching: .button).matching(identifier: "Back".localized()).element(boundBy: 0).tap()
    }
}
