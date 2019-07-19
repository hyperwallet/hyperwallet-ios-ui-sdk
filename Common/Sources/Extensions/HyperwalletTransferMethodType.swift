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
import HyperwalletSDK

/// The HyperwalletTransferMethodType extension
public extension HyperwalletTransferMethodType {
    /// Formats the fee processing time
    ///
    /// - Returns: an NSAttributedString
    func formatFeesProcessingTime() -> NSAttributedString {
        let attributedText = NSMutableAttributedString()
        let color = Theme.Label.subTitleColor
        // Fees
        if let fees = self.fees?.nodes {
            let feeLabel = "add_transfer_method_fee_label".localized()

            attributedText.append(value: feeLabel, font: Theme.Label.captionOne, color: color)
            attributedText.append(value: HyperwalletFee.format(fees: fees),
                                  font: Theme.Label.captionOneMedium,
                                  color: Theme.Label.subTitleColor)
        }

        // Processing Time
        if let processingTimeValue = self.processingTimes?.nodes?.first?.value, !processingTimeValue.isEmpty {
            var processingTimeLabel = ""

            if attributedText.length > 0 {
                processingTimeLabel = "\n"
            }
            processingTimeLabel = String(format: "%@%@",
                                         processingTimeLabel,
                                         "add_transfer_method_processing_time_label".localized())

            attributedText.append(value: processingTimeLabel, font: Theme.Label.captionOne, color: color)
            attributedText.append(value: processingTimeValue, font: Theme.Label.captionOneMedium, color: color)
        }

        return attributedText
    }
}
