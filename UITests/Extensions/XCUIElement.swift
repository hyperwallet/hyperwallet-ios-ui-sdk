import XCTest

extension XCUIElement {
    func scroll(to element: XCUIElement) {
        var count = 0

        while !elementIsWithinWindow(element: element) && (count < 5) {
            swipeUpSlow()
            count += 1
        }

        if count == 5 {
            XCTFail("Could not find Element")
        }
    }

    func elementIsWithinWindow(element: XCUIElement) -> Bool {
        guard element.exists && element.isHittable else {
            return false
        }

        return true
    }

    func swipeUpSlow() {
        let half: CGFloat = 0.5
        let pressDuration: TimeInterval = 0.02

        let centre = self.coordinate(withNormalizedOffset: CGVector(dx: half, dy: half))
        let top = self.coordinate(withNormalizedOffset: CGVector(dx: half, dy: 0.25))

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
}
