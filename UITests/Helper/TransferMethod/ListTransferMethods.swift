import XCTest

class ListTransferMethod {
    let defaultTimeout = 5.0

    var app: XCUIApplication

    var addTransferMethodButton: XCUIElement
    var addTransferMethodEmptyScreenButton: XCUIElement
    var removeAccountButton: XCUIElement
    var confirmAccountRemoveButton: XCUIElement
    var cancelAccountRemoveButton: XCUIElement
    var navigationBar: XCUIElement

    init(app: XCUIApplication) {
        self.app = app

        addTransferMethodButton = app.navigationBars.buttons["Add"]
        addTransferMethodEmptyScreenButton = app.buttons["mobileAddTransferMethodHeader".localized()]
        removeAccountButton = app.buttons["Remove Account"]
        confirmAccountRemoveButton = app.alerts["Remove Account"].buttons["Remove"]
        cancelAccountRemoveButton = app.alerts["Remove Account"].buttons["Cancel"]
        navigationBar = app.navigationBars["Accounts"]
    }

    func tapAddTransferMethodButton() {
        addTransferMethodButton.tap()
    }

    func tapAddTransferMethodEmptyScreenButton() {
        addTransferMethodEmptyScreenButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    }

    func tapRemoveAccountButton() {
        removeAccountButton.tap()
    }

    func tapConfirmAccountRemoveButton() {
        confirmAccountRemoveButton.tap()
    }

    func tapCancelAccountRemoveButton() {
        cancelAccountRemoveButton.tap()
    }

    func clickBackButton() {
        navigationBar.children(matching: .button).matching(identifier: "Back").element(boundBy: 0).tap()
    }
}
