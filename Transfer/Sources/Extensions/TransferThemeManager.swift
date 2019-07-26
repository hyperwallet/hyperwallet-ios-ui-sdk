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
    static func applyCreateTransferTheme() {
        applyToCreateTransferAddSelectDestinationCell()
        applyToCreateTransferButtonCell()
        applyToCreateTransferNotesCell()
        applyToCreateTransferAllFundsCell()
        applyToCreateTransferAmountCell()
    }

    private static func applyToCreateTransferAddSelectDestinationCell() {
        let proxy = CreateTransferAddSelectDestinationCell.appearance()
        proxy.titleLabelFont = Theme.Label.bodyFontMedium
        proxy.titleLabelColor = Theme.Label.color
        proxy.subTitleLabelFont = Theme.Label.captionOne
        proxy.subTitleLabelColor = Theme.Label.subTitleColor
    }

    private static func applyToCreateTransferButtonCell() {
        let proxy = CreateTransferButtonCell.appearance()
        proxy.titleLabelColor = Theme.Label.color
        proxy.titleLabelFont = Theme.Label.bodyFont
    }

    private static func applyToCreateTransferNotesCell() {
        let proxy = CreateTransferNotesCell.appearance()
        proxy.titleLabelColor = Theme.Label.color
        proxy.titleLabelFont = Theme.Label.bodyFont
    }

    private static func applyToCreateTransferAllFundsCell() {
        let proxy = CreateTransferAllFundsCell.appearance()
        proxy.titleLabelFont = Theme.Label.bodyFontMedium
        proxy.titleLabelColor = Theme.Label.color
    }

    private static func applyToCreateTransferAmountCell() {
        let proxy = CreateTransferAmountCell.appearance()
        proxy.titleLabelFont = Theme.Label.bodyFontMedium
        proxy.titleLabelColor = Theme.Label.color
        proxy.currencyLabelFont = Theme.Label.bodyFontMedium
        proxy.currencyLabelColor = Theme.Label.color
    }
}
