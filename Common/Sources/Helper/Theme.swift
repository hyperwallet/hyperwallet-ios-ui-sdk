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

/// The `Theme` is used customize all visual style provided by Hyperwallet UI SDK.
/// In order to apply a new style changes the method `ThemeManager.applyTheme()` has to been called.
///
/// - Example:
///  `Theme.themeColor = UIColor.white`
///  `ThemeManager.applyTheme()`
@objcMembers
public class Theme: NSObject {
    /// The main color.
    public static var themeColor = UIColor(rgb: 0x00AFD0)
    /// The tint color.
    public static var tintColor = UIColor.white

    /// Representation of all customizable visual style property for `UILabel`.
    public struct Label {
        /// The label primary color
        public static var color = UIColor.black
        /// The color to highlight errors
        public static var errorColor = UIColor(rgb: 0xFF3B30)
        /// The subtitle color
        public static var subTitleColor = UIColor(rgb: 0x666666)
        /// The text color
        public static var textColor = UIColor(rgb: 0x8e8e93)
        /// The title font style
        public static var titleFont = UIFont.preferredFont(forTextStyle: .headline)
        /// The body font style
        public static var bodyFont = UIFont.preferredFont(forTextStyle: .body)
        /// The caption one font style
        public static var captionOne = UIFont.preferredFont(forTextStyle: .caption1)
        /// The footnote font style
        public static var footnoteFont = UIFont.preferredFont(forTextStyle: .footnote)
    }

    /// Representation of all customizable visual style property for `UINavigationBar`.
    public struct NavigationBar {
        /// The `UINavigationBar` bar style
        public static var barStyle = UIBarStyle.black
        /// Sets the opaque background color
        public static var isTranslucent = false
        /// The color of NavigationBar shadow
        public static var shadowColor = UIColor.clear
    }

    /// Representation of all customizable visual style property for `UIButton`.
    public struct Button {
        /// The button primary color
        public static var color = Theme.themeColor
        /// The button font
        public static var font = Theme.Label.bodyFont
    }

    /// Representation of all customizable visual style property for `UIText`.
    public struct Text {
        /// The text primary color
        public static var color = UIColor.black
        /// The text disabled color
        public static var disabledColor = Theme.Label.textColor
    }

    /// Representation of all customizable visual style property for `UISearchBar`.
    public struct SearchBar {
        /// The `UITextField` tint color
        public static var textFieldTintColor = Theme.tintColor
        /// The `UITextField` background color.
        public static var textFieldBackgroundColor = UIColor(rgb: 0x28BBD7)
    }

   /// Representation of all customizable visual style property for `UITableViewViewCell`
    public struct Cell {
        /// The common `UITableViewViewCell` height.
        public static let smallHeight = CGFloat(44)
        /// The `UITableViewViewCell` height for the receipt items
        public static let mediumHeight = CGFloat(63)
        /// The `UITableViewViewCell` height for the List transfer method items and
        /// the Select transfer method type items.
        public static let largeHeight = CGFloat(88)
        /// The Select transfer method type items header height.
        public static let headerHeight = CGFloat(16)
        /// The divider UITableViewViewCell height.
        public static let dividerHeight = CGFloat(8)
    }

    /// Representation of all customizable visual style property for the `Hyperwallet`'s icon.
    public struct Icon {
        /// The icon font size
        public static let size = 20
        /// The icon frame
        public static let frame = CGSize(width: 40, height: 40)
        /// The icon primary color
        public static var primaryColor = Theme.themeColor
        /// The icon primary background color
        public static var primaryBackgroundColor = UIColor(rgb: 0xE5F7FA)
        /// The icon credit color
        public static var creditColor = Amount.creditColor
        /// The icon credit background color
        public static var creditBackgroundColor = UIColor(rgb: 0xF1FAE8)
        /// The icon debit color
        public static var debitColor = Amount.debitColor
        /// The icon debit background color
        public static var debitBackgroundColor = UIColor(rgb: 0xFEF7F7)
    }

    /// Representation of all customized visual style property for numbers
    public struct Amount {
        /// The credit color
        public static var creditColor = UIColor(rgb: 0x5FBF00)
        /// The debit color
        public static var debitColor = UIColor(rgb: 0xDB4437)
    }

    /// Representation of all customizable visual style property for `UIViewController`.
    public struct ViewController {
        /// The `UIViewController` background color
        public static var backgroundColor = UIColor(rgb: 0xEFEFF4)
    }

    /// Representation of all customizable visual style property for `SpinnerView`.
    public struct SpinnerView {
        /// The `UIActivityIndicatorView` style
        public static var activityIndicatorViewStyle = UIActivityIndicatorView.Style.whiteLarge
        /// The `UIActivityIndicatorView` color
        public static var activityIndicatorViewColor = Theme.themeColor
        /// The background color
        public static var backgroundColor = UIColor.clear
    }

    /// Representation of all customizable visual style property for `ProcessingView`.
    public struct ProcessingView {
        /// The background color
        public static var backgroundColor = UIColor.black.withAlphaComponent(0.85)
        /// The state label color
        public static var stateLabelColor = UIColor.white
    }
}
