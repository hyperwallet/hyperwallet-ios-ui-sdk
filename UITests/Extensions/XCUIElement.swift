import XCTest

extension XCUIElement {
    func scrollToElement(element: XCUIElement) {
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
}
