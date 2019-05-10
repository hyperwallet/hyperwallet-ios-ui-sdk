import XCTest

extension XCUIDevice {
    func clickHomeAndRelaunch(app: XCUIApplication) {
        self.press(.home)
        app.launch()
        app.activate()
    }

    func rotateScreen(times: Int) {
        for _ in 0 ..< times {
            self.orientation = .landscapeLeft
            self.orientation = .portrait
        }
    }

    func resumeFromRecents(app: XCUIApplication) {
        var secondaryApp: String

        if #available(iOS 11.0, *) {
            secondaryApp = "com.apple.DocumentsApp"
        } else {
            secondaryApp = "com.apple.MobileSMS"
        }
        XCUIApplication(bundleIdentifier: secondaryApp).launch()
        app.activate()
    }

    func wakeFromSleep(app: XCUIApplication) {
        //Press button to sleep
        self.perform(NSSelectorFromString("pressLockButton"))
        //Press button to wake
        self.perform(NSSelectorFromString("pressLockButton"))

        if #available(iOS 11.2, *) {
            app.activate()
        } else {
            self.press(.home)
        }
    }

    func sendToBackground(app: XCUIApplication) {
        self.press(.home)
        app.wait(for: .unknown, timeout: 3)
        app.activate()
    }
}
