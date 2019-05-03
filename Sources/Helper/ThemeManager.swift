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
public class ThemeManager {
    /// Applies visual styles to the Hyperwallet user interface components.
    public static func applyTheme() {
        applyToUINavigationBar()
        applyToProcessingView()
        applyToCountryCurrencyCell()
        applyToSpinnerView()
        applyToSelectionWidgetCell()
        applyToIconView()
        applyToListTransferMethodTableViewCell()
        applyToSelectTransferMethodTypeCell()
        registerFonts
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
    }

    static func applyTo(searchBar: UISearchBar) {
        searchBar.searchBarStyle = UISearchBar.Style.minimal
        searchBar.barStyle = .black
        searchBar.backgroundColor = Theme.themeColor

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

    private static func applyToCountryCurrencyCell() {
        let proxy = CountryCurrencyCell.appearance()
        proxy.titleLabelFont = Theme.Label.bodyFont
        proxy.titleLabelColor = Theme.Label.color
        proxy.valueLabelFont = Theme.Label.bodyFont
        proxy.valueLabelColor = Theme.Label.subTitleColor
    }

    private static func applyToSpinnerView() {
        let proxy = SpinnerView.appearance()
        proxy.activityIndicatorStyle = Theme.SpinnerView.activityIndicatorViewStyle
        proxy.activityIndicatorColor = Theme.SpinnerView.activityIndicatorViewColor
        proxy.activityIndicatorBackgroundColor = Theme.SpinnerView.backgroundColor
        proxy.viewBackgroundColor = Theme.SpinnerView.backgroundColor
    }

    private static func applyToSelectionWidgetCell() {
        let proxy = SelectionWidgetCell.appearance()
        proxy.textLabelColor = Theme.Label.color
        proxy.textLabelFont = Theme.Label.bodyFont
    }

    private static func applyToIconView() {
        let proxy = IconView.appearance()
        proxy.tintColor = Theme.Icon.color
        proxy.backgroundColor = Theme.Icon.backgroundColor
    }

    private static func applyToListTransferMethodTableViewCell() {
        let proxy = ListTransferMethodTableViewCell.appearance()
        proxy.titleLabelFont = Theme.Label.bodyFontMedium
        proxy.titleLabelColor = Theme.Label.color
        proxy.subTitleLabelFont = Theme.Label.captionOne
        proxy.subTitleLabelColor = Theme.Label.subTitleColor
    }

    private static func applyToSelectTransferMethodTypeCell() {
        let proxy = SelectTransferMethodTypeCell.appearance()
        proxy.titleLabelFont = Theme.Label.bodyFontMedium
        proxy.titleLabelColor = Theme.Label.color
    }

    private static let registerFonts: Void = {
        UIFont.register("icomoon", type: "ttf")
    }()
}
