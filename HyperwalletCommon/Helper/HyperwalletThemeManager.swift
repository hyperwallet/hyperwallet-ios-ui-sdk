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
public class HyperwalletThemeManager {
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
        Theme.Icon.color = Theme.tintColor
        Theme.SpinnerView.activityIndicatorViewColor = Theme.tintColor
        Theme.SearchBar.textFieldBackgroundColor = UIColor(rgb: 0xdcdcdc)
        Theme.SearchBar.textFieldTintColor = UIColor(rgb: 0xdcdcdc)
        Theme.NavigationBar.shadowColor = UIColor(rgb: 0xe3e3e5)
        HyperwalletThemeManager.applyTheme()
    }

    private static func applyToUINavigationBar() {
        let proxy = UINavigationBar.appearance()
        proxy.barTintColor = Theme.themeColor
        proxy.tintColor = Theme.tintColor
        proxy.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Theme.tintColor]
        if #available(iOS 11.0, *) {
            proxy.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: Theme.tintColor]
        }
        proxy.backItem?.backBarButtonItem?.tintColor = Theme.tintColor
        proxy.barStyle = Theme.NavigationBar.barStyle
        proxy.isTranslucent = Theme.NavigationBar.isTranslucent
        proxy.shadowImage = UIImage.imageWithColor(
            color: Theme.NavigationBar.shadowColor,
            size: CGSize(width: 1, height: 1)
        )
    }

    public static func applyTo(searchBar: UISearchBar) {
        searchBar.searchBarStyle = UISearchBar.Style.minimal
        searchBar.barStyle = .black
        searchBar.backgroundColor = Theme.themeColor
        searchBar.tintColor = Theme.tintColor
        let backgroundImage = UIImage.createBackgroundPattern(
            color: Theme.SearchBar.textFieldBackgroundColor,
            size: CGSize(width: 36, height: 36),
            cornerRadius: 10)
        searchBar.setSearchFieldBackgroundImage(backgroundImage, for: UIControl.State.normal)
        searchBar.searchTextPositionAdjustment = UIOffset(horizontal: 8.0, vertical: 0.0)

        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.defaultTextAttributes = [
                NSAttributedString.Key.foregroundColor: Theme.SearchBar.textFieldTintColor,
                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)
            ]
            textField.attributedPlaceholder = NSAttributedString(
                string: "search_placeholder_label".localized(),
                attributes: [
                    .foregroundColor: Theme.SearchBar.textFieldTintColor.withAlphaComponent(0.5),
                    .font: UIFont.preferredFont(forTextStyle: .body)
                ])
            if let leftImageView = textField.leftView as? UIImageView {
                leftImageView.image = leftImageView.image?.withRenderingMode(.alwaysTemplate)
                leftImageView.tintColor = Theme.SearchBar.textFieldTintColor.withAlphaComponent(0.5)
            }
            if let clearButton = textField.value(forKey: "clearButton") as? UIButton {
                clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
                clearButton.tintColor = Theme.SearchBar.textFieldTintColor.withAlphaComponent(0.5)
            }
        }
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
