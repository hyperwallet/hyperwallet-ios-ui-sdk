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
        public static var color = UIColor(rgb: 0x2C2E2F)
        /// The color to highlight errors
        public static var errorColor = UIColor(rgb: 0xFF3B30)
        /// The subtitle color
        public static var subtitleColor = UIColor(rgb: 0x757575, alpha: 0.6)
        /// The text color
        public static var textColor = UIColor(rgb: 0x8e8e93)
        /// The title font style
        public static var titleFont = UIFont.preferredFont(forTextStyle: .body)
        /// The subtitle font style
        public static var subtitleFont = UIFont.preferredFont(forTextStyle: .subheadline)
        /// The footnote font style
        public static var footnoteFont = UIFont.preferredFont(forTextStyle: .footnote)
    }

    /// Representation of all customizable visual style property for `UINavigationBar`.
    public struct NavigationBar {
        /// The `UINavigationBar` bar style
        public static var barStyle = UIBarStyle.default
        /// Sets the opaque background color for The `UINavigationBar`
        public static var isTranslucent = false
        /// The `UINavigationBar` shadow color
        public static var shadowColor = UIColor.clear
        /// The `UINavigationBar` large title color
        public static var largeTitleColor = Theme.tintColor
        /// The `UINavigationBar` title color
        public static var titleColor = Theme.tintColor
        /// The `UINavigationBar` Back Button color
        public static var backButtonColor = Theme.tintColor
        @available(iOS 11.0, *)
        /// The `UINavigationBar` large title font
        public static var largeTitleFont = UIFont.boldSystemFont(ofSize: 20.0)
        /// The `UINavigationBar` title font
        public static var titleFont = UIFont.boldSystemFont(ofSize: 16.0)
    }

    /// Representation of all customizable visual style property for `UIButton`.
    public struct Button {
        /// The `UIButton` primary color
        public static var color = UIColor(rgb: 0xFFFFFF)
        /// The `UIButton` link color
        public static var linkColor = Theme.themeColor
        /// The `UIButton` background color
        public static var backgroundColor = Theme.themeColor
        /// The `UIButton` link font
        public static var linkFont = Theme.Label.titleFont
        /// The button font
        public static var font = Theme.Label.titleFont
    }

    /// Representation of all customizable visual style property for `UIText`.
    public struct Text {
        /// The text primary color
        public static var color = Theme.Label.color
        /// The text disabled color
        public static var disabledColor = Theme.Label.textColor
        /// The text font style
        public static var font = UIFont.preferredFont(forTextStyle: .body)
        /// Create Transfer Amount Font
        public static var createTransferAmountFont = UIFont.systemFont(ofSize: 60)
        /// The text label font
        public static var labelFont = Theme.Label.titleFont
        /// The text label color
        public static var labelColor = Theme.Label.color
    }

   /// Representation of all customizable visual style property for `UITableViewCell`
    public struct Cell {
        /// The common `UITableViewCell` height.
        public static let smallHeight = CGFloat(61)
        /// The common `UITableViewCell` height.
        public static let mediumHeight = CGFloat(70)
        /// The common `UITableViewCell` height.
        public static let height = CGFloat(80)
        /// The `UITableViewCell` height for the List transfer method items and
        /// the Select transfer method type items.
        public static let largeHeight = CGFloat(88)
        /// The Select transfer method type items header height.
        public static let headerHeight = CGFloat(37)
        /// The divider `UITableViewCell` height.
        public static let dividerHeight = CGFloat(8)
        /// The `UITableViewCell` tint color
        public static var tintColor = Theme.tintColor
        /// The `UITableViewCell` separator color
        public static var separatorColor = UIColor(rgb: 0x757575, alpha: 0.29)
        /// The `UITableViewCell` disabled background color
        public static var disabledBackgroundColor = UIColor(rgb: 0xf8f8f8)
    }

    /// Representation of all customizable visual style property for the `Hyperwallet`'s icon.
    public struct Icon {
        /// The icon font size
        public static let size = 30
        /// The add tranfer method icon size
        public static let addTransferMethodIconSize = 20
        /// The icon frame
        public static let frame = CGSize(width: 30, height: 30)
        /// The icon primary color
        public static var primaryColor = Theme.themeColor
        /// The icon credit color
        public static var creditColor = Amount.creditColor
        /// The icon debit color
        public static var debitColor = Amount.debitColor
    }

    /// Representation of all customized visual style property for numbers
    public struct Amount {
        /// The credit color
        public static var creditColor = UIColor(rgb: 0x299976)
        /// The debit color
        public static var debitColor = Theme.Label.color
    }

    /// Representation of all customizable visual style property for `UITableViewController`.
    public struct UITableViewController {
        /// The `UITableViewController` background color
        public static var backgroundColor = UIColor(rgb: 0xFFFFFF)
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
