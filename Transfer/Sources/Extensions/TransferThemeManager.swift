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
    static func applyTransferTheme() {
        applyToTransferSourceCell()
        applyToTransferDestinationCell()
        applyToTransferButtonCell()
        applyToTransferNotesCell()
        applyToTransferAllFundsCell()
        applyToTransferAmountCell()
        applyToScheduleTransferSummaryCell()
        applyToScheduleForeignExchangeCell()
    }

    private static func applyToTransferDestinationCell() {
        let proxy = TransferDestinationCell.appearance()
        proxy.titleLabelFont = Theme.Label.titleFont
        proxy.titleLabelColor = Theme.Label.color
        proxy.subTitleLabelFont = Theme.Label.subtitleFont
        proxy.subTitleLabelColor = Theme.Label.subtitleColor
    }

    private static func applyToTransferSourceCell() {
        let proxy = TransferSourceCell.appearance()
        proxy.titleLabelFont = Theme.Label.titleFont
        proxy.titleLabelColor = Theme.Label.color
        proxy.subTitleLabelFont = Theme.Label.subtitleFont
        proxy.subTitleLabelColor = Theme.Label.subtitleColor
    }

    private static func applyToListTransferDestinationCell() {
        let proxy = ListTransferDestinationCell.appearance()
        proxy.titleLabelFont = Theme.Label.titleFont
        proxy.titleLabelColor = Theme.Label.color
        proxy.subTitleLabelFont = Theme.Label.subtitleFont
        proxy.subTitleLabelColor = Theme.Label.subtitleColor
        proxy.tintColor = Theme.Cell.tintColor
    }

    private static func applyToTransferButtonCell() {
        let proxy = TransferButtonCell.appearance()
        proxy.buttonTitleLabelColor = Theme.Button.color
        proxy.buttonTitleLabelFont = Theme.Button.font
        proxy.buttonBackgroundColor = Theme.Button.backgroundColor
    }

    private static func applyToTransferNotesCell() {
        let proxy = TransferNotesCell.appearance()
        proxy.notesTextFieldColor = Theme.Label.color
        proxy.notesTextFieldFont = Theme.Label.titleFont
    }

    private static func applyToTransferAllFundsCell() {
        let proxy = TransferAllFundsCell.appearance()
        proxy.availableFundsLabelFont = Theme.Label.titleFont
        proxy.availableFundsLabelColor = Theme.Label.subtitleColor
        proxy.transferMaxAmountButtonFont = Theme.Button.linkFont
        proxy.transferMaxAmountButtonColor = Theme.Button.linkColor
    }

    private static func applyToTransferAmountCell() {
        let proxy = TransferAmountCell.appearance()
        proxy.currencySymbolLabelFont = Theme.Label.titleFont
        proxy.currencySymbolLabelColor = Theme.Label.color
        proxy.amountTextFieldFont = Theme.Text.font.withSize(60)
        proxy.currencyLabelFont = Theme.Label.titleFont
        proxy.currencyLabelColor = Theme.Label.color
    }

    private static func applyToScheduleTransferSummaryCell() {
        let proxy = TransferSummaryCell.appearance()
        proxy.titleLabelFont = Theme.Label.titleFont
        proxy.titleLabelColor = Theme.Label.color
        proxy.subTitleLabelFont = Theme.Label.subtitleFont
        proxy.subTitleLabelColor = Theme.Label.subtitleColor
    }

    private static func applyToScheduleForeignExchangeCell() {
        let proxy = TransferForeignExchangeCell.appearance()
        proxy.titleLabelFont = Theme.Label.titleFont
        proxy.titleLabelColor = Theme.Label.color
        proxy.subTitleLabelFont = Theme.Label.subtitleFont
        proxy.subTitleLabelColor = Theme.Label.subtitleColor
    }
}
