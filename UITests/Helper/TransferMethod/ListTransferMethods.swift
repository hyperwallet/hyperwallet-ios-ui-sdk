import XCTest

class ListTransferMethod {
    let defaultTimeout = 5.0

    var app: XCUIApplication

    var addTransferMethodButton: XCUIElement
    var addTransferMethodEmptyScreenButton: XCUIElement
    var confirmAccountRemoveButton: XCUIElement
    var cancelAccountRemoveButton: XCUIElement
    var navigationBar: XCUIElement
    let removeAccountTitle = "mobileRemoveEAconfirm".localized()
    let removeAccountMessage = "mobileAreYouSure".localized()
    let addAccountTitle = "mobileAddTransferMethodHeader".localized()
    let title = "mobileTransferMethodsHeader".localized()
    let removeButtonLabel = "remove".localized()
    let cancelButtonLabel = "cancelButtonLabel".localized()
    var alert: XCUIElement

    init(app: XCUIApplication) {
        self.app = app

        addTransferMethodButton = app.navigationBars.buttons["Add"]
        addTransferMethodEmptyScreenButton = app.buttons[addAccountTitle]
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
          // "ending in " already has a space!
          let endingIn = "endingIn".localized()
          let expectedLabel: String = {
                if #available(iOS 11.2, *) {
                    return "United States\n\(endingIn)\(endingDigits)"
                } else {
                    return "United States \(endingIn)\(endingDigits)"
                }
          }()

          return expectedLabel
      }

    func getTransferMethodPayalLabel(email: String) -> String {
          let toLabel = "to".localized()
          let expectedLabel: String = {
                if #available(iOS 11.2, *) {
                    return "United States\n\(toLabel)\(email)"
                } else {
                    return "United States \(toLabel)\(email)"
                }
          }()

          return expectedLabel
      }

    func getTransferMethodIcon(index: Int) -> XCUIElement {
       return app.cells.element(boundBy: index).images["ListTransferMethodTableViewCellIcon"]
    }

    func getTransferMethodPrepaidCardLabel(visacard: String) -> String {
        // let toLabel = "to".localized()
        let expectedLabel: String = {
            if #available(iOS 11.2, *) {
                return "\(visacard)\nLog in using a web browser to manage your card"
            } else {
                return "\(visacard) Log in using a web browser to manage your card"
            }
        }()

        return expectedLabel
    }
}
