//
// Copyright 2018 - Present Hyperwallet
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software
// and associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute,
// sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
// BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import UIKit

/// The `ThemeManager` class is responsible for applying the visual styles to the Hyperwallet user interface components.
@objcMembers
public class ThemeManager: NSObject {
    /// Applies default visual styles to the Hyperwallet user interface components.
    public static func applyTheme() {
        applyToUINavigationBar()
        applyToProcessingView()
        applyToSpinnerView()
        registerFonts
    }

    /// Applies White Theme visual styles to the Hyperwallet user interface components.
    public static func applyWhiteTheme() {
        Theme.themeColor = .white
        Theme.tintColor = UIColor(red: 0, green: 0.48, blue: 1, alpha: 1)
        Theme.Button.color = Theme.tintColor
        Theme.Icon.primaryColor = Theme.tintColor
        Theme.SpinnerView.activityIndicatorViewColor = Theme.tintColor
        Theme.NavigationBar.shadowColor = UIColor(rgb: 0xe3e3e5)
        ThemeManager.applyTheme()
    }

    private static func applyToUINavigationBar() {
        let proxy = UINavigationBar.appearance()
        if #available(iOS 11.0, *) {
            proxy.largeTitleTextAttributes =
                [
                    NSAttributedString.Key.foregroundColor: Theme.NavigationBar.largeTitleColor,
                    NSAttributedString.Key.font: Theme.NavigationBar.largeTitleFont
                ]
        }
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.titleTextAttributes =
                [
                    NSAttributedString.Key.foregroundColor: Theme.NavigationBar.titleColor,
                    NSAttributedString.Key.font: Theme.NavigationBar.titleFont
                ]
            navBarAppearance.largeTitleTextAttributes =
                [
                    NSAttributedString.Key.foregroundColor: Theme.NavigationBar.largeTitleColor,
                    NSAttributedString.Key.font: Theme.NavigationBar.largeTitleFont
                ]
            navBarAppearance.backgroundColor = Theme.themeColor
            proxy.standardAppearance = navBarAppearance
            proxy.scrollEdgeAppearance = navBarAppearance
        }
        proxy.barTintColor = Theme.themeColor
        proxy.tintColor = Theme.tintColor
        proxy.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: Theme.NavigationBar.titleColor,
            NSAttributedString.Key.font: Theme.NavigationBar.titleFont
        ]
        proxy.backItem?.backBarButtonItem?.tintColor = Theme.NavigationBar.backButtonColor
        proxy.barStyle = Theme.NavigationBar.barStyle
        proxy.isTranslucent = Theme.NavigationBar.isTranslucent
    }

    private static func applyToProcessingView() {
        let proxy = ProcessingView.appearance()
        proxy.viewBackgroundColor = Theme.ProcessingView.backgroundColor
        proxy.stateLabelColor = Theme.ProcessingView.stateLabelColor
    }

    private static func applyToSpinnerView() {
        let proxy = SpinnerView.appearance()
        proxy.activityIndicatorStyle = Theme.SpinnerView.activityIndicatorViewStyle
        proxy.activityIndicatorColor = Theme.SpinnerView.activityIndicatorViewColor
        proxy.activityIndicatorBackgroundColor = Theme.SpinnerView.backgroundColor
        proxy.viewBackgroundColor = Theme.SpinnerView.backgroundColor
    }

    private static let registerFonts: Void = {
        UIFont.register("icomoon", type: "ttf")
    }()
}
