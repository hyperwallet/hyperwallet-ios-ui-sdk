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

#if !COCOAPODS
import Common
#endif

/// The ThemeManager extension
public extension ThemeManager {
    /// Applies default visual styles to the Hyperwallet user interface components.
    static func applyTransferMethodTheme() {
        applyToCountryCurrencyCell()
        applyToCountryCurrencySelectionCell()
        applyToSelectionWidgetCell()
        applyToListTransferMethodTableViewCell()
        applyToSelectTransferMethodTypeCell()
        applyToTextWidget()
    }

    private static func applyToCountryCurrencyCell() {
        let proxy = CountryCurrencyCell.appearance()
        proxy.textLabelFont = Theme.Text.labelFont
        proxy.textLabelColor = Theme.Text.labelColor
        proxy.detailTextLabelFont = Theme.Text.font
        proxy.detailTextLabelColor = Theme.Text.color
    }

    private static func applyToCountryCurrencySelectionCell() {
        let proxy = CountryCurrencySelectionCell.appearance()
        proxy.textLabelFont = Theme.Label.titleFont
        proxy.textLabelColor = Theme.Label.color
    }

    private static func applyToSelectionWidgetCell() {
        let proxy = SelectionWidgetCell.appearance()
        proxy.textLabelColor = Theme.Label.color
        proxy.textLabelFont = Theme.Label.titleFont
    }

    private static func applyToListTransferMethodTableViewCell() {
        let proxy = ListTransferMethodCell.appearance()
        proxy.titleLabelFont = Theme.Label.titleFont
        proxy.titleLabelColor = Theme.Label.color
        proxy.subTitleLabelFont = Theme.Label.subtitleFont
    }

    private static func applyToSelectTransferMethodTypeCell() {
        let proxy = SelectTransferMethodTypeCell.appearance()
        proxy.titleLabelFont = Theme.Label.titleFont
        proxy.titleLabelColor = Theme.Label.color
        proxy.subTitleLabelFont = Theme.Label.subtitleFont
    }

    private static func applyToTextWidget() {
        let proxy = TextWidget.appearance()
        proxy.textLabelFont = Theme.Text.labelFont
        proxy.textLabelColor = Theme.Text.labelColor
        proxy.textFieldFont = Theme.Text.font
        proxy.textFieldColor = Theme.Text.color
    }
}
