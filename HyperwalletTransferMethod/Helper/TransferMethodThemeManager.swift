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

import Foundation

public class TransferMethodThemeManager {
    /// Applies default visual styles to the Hyperwallet user interface components.
    public static func applyTheme() {
        HyperwalletThemeManager.applyTheme()
        applyToCountryCurrencyCell()
        applyToListTransferMethodTableViewCell()
        applyToSelectTransferMethodTypeCell()
        applyToSelectionWidgetCell()
    }

    private static func applyToCountryCurrencyCell() {
        let proxy = CountryCurrencyCell.appearance()
        proxy.titleLabelFont = Theme.Label.bodyFont
        proxy.titleLabelColor = Theme.Label.color
        proxy.valueLabelFont = Theme.Label.bodyFont
        proxy.valueLabelColor = Theme.Label.subTitleColor
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
        proxy.subTitleLabelFont = Theme.Label.captionOne
        proxy.subTitleLabelColor = Theme.Label.subTitleColor
    }

    private static func applyToSelectionWidgetCell() {
        let proxy = SelectionWidgetCell.appearance()
        proxy.textLabelColor = Theme.Label.color
        proxy.textLabelFont = Theme.Label.bodyFont
    }
}
