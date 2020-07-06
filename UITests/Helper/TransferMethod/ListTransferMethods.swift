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
    let removeAccountTitle = "remove_transfer_method_confirmation_title".localized()
    let removeAccountMessage = "remove_transfer_method_confirmation_message".localized()
    let addAccountTitle = "add_account_title".localized()
    let title = "title_accounts".localized()
    let removeButtonLabel = "remove_button_label".localized()
    let cancelButtonLabel = "cancel_button_label".localized()
    var alert: XCUIElement

    init(app: XCUIApplication) {
        self.app = app

        addTransferMethodButton = app.navigationBars.buttons["Add"]
        addTransferMethodEmptyScreenButton = app.buttons[addAccountTitle]
        removeAccountButton = app.buttons[removeAccountTitle]
        alert = app.alerts[removeAccountTitle]
        confirmAccountRemoveButton = alert.buttons[removeButtonLabel]
        cancelAccountRemoveButton = alert.buttons[cancelButtonLabel]
        navigationBar = app.navigationBars[title]
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

    func getTransferMethodLabel(endingDigits: String) -> String {
          let endingIn = "endingIn".localized()
          let expectedLabel: String = {
                if #available(iOS 11.2, *) {
                    return "United States\n\(endingIn) \(endingDigits)"
                } else {
                    return "United States \(endingIn) \(endingDigits)"
                }
          }()

          return expectedLabel
      }

    func getTransferMethodPayalLabel(email: String) -> String {
          let endingIn = "endingIn".localized()
          let expectedLabel: String = {
                if #available(iOS 11.2, *) {
                    return "United States\nto\(endingIn) \(email)"
                } else {
                    return "United States to \(endingIn) \(email)"
                }
          }()

          return expectedLabel
      }
}
