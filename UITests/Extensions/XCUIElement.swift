import XCTest

extension XCUIElement {
    func scrollToElement(element: XCUIElement) {
        while !element.visible() {
            swipeUp()
        }
    }

    func visible() -> Bool {
        guard self.exists && !self.frame.isEmpty else {
            return false }
        return XCUIApplication().windows.element(boundBy: 0).frame.contains(self.frame)
    }
}
