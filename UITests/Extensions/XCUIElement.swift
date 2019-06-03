import XCTest

extension XCUIElement {
    func scroll(to element: XCUIElement) {
        while !element.isVisible {
            swipeUp()
        }
    }

    var isVisible: Bool {
        guard self.exists && !self.frame.isEmpty else {
            return false
        }
        return XCUIApplication().windows.element(boundBy: 0).frame.contains(self.frame)
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
        for _ in 0..<stringValue.count {
            self.typeText(XCUIKeyboardKey.delete.rawValue)
        }

        self.typeText(text)
    }
}
