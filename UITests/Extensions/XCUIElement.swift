import XCTest

extension XCUIElement {
    func scroll(to element: XCUIElement) {
        var count = 0

        while !elementIsWithinWindow(element: element) && (count < 10) {
            swipeUpSlow()
            count += 1
        }

        if count == 10 {
            XCTFail("Could not find Element")
        }
    }

    func elementIsWithinWindow(element: XCUIElement) -> Bool {
        if !element.exists || !element.isHittable || element.frame.isEmpty {
            return false
        }

        return true
    }

    func swipeUpSlow() {
        let half: CGFloat = 0.5
        let pressDuration: TimeInterval = 0.01

        let centre = self.coordinate(withNormalizedOffset: CGVector(dx: half, dy: half))
        let top = centre.withOffset(CGVector(dx: 0.0, dy: -262))

        centre.press(forDuration: pressDuration, thenDragTo: top)
    }

    /**
     Removes any current text in the field before typing in the new value
     - Parameter text: the text to enter into the field
     */
    func clearAndEnterText(text: String) {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }

        self.tap()

        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)

        self.typeText(deleteString)
        self.typeText(text)
    }

    /**
     Removes any current text in the field before typing in the new value
     - Parameter text: the text to enter into the field
     - Parameter feld: the test field
     - Parameter app: the XCUIApplication instance
     */
    func enterByPaste(text: String, field: XCUIElement, app: XCUIApplication) {
        guard case !text.isEmpty = true else {
            XCTFail("Tried to paste empty string!")
            return
        }
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = text
        field.doubleTap()
        app.menuItems["Paste"].tap()
    }
}
