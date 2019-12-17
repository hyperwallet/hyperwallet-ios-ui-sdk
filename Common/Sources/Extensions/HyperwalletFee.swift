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

/// The HyperwalletFee extenstion
public extension HyperwalletFee {
    private static let percent = "PERCENT"
    private static let flat = "FLAT"

    /// Formats the Fees to be displayed
    static func format(fees: [HyperwalletFee]) -> String {
        var description = ""
        let percentFee = fees.first(where: { (fee) in fee.feeRateType == percent })
        let flatFee = fees.first(where: { (fee) in fee.feeRateType == flat })

        if let percentFee = percentFee, let flatFee = flatFee {
            description = FeeTypes.mixed(percentFee, flatFee).feeDescription()
        } else if let flatFee = flatFee {
            description = FeeTypes.flat(flatFee).feeDescription()
        } else if let percentFee = percentFee {
            description = FeeTypes.percent(percentFee).feeDescription()
        }
        return description
    }

    /// Represents the fee types
    ///
    /// - flat: the flat format
    /// - percent: the percent format
    /// - mixed: the flat and percent format
    // swiftlint:disable missing_docs
    /// Different fee types
    enum FeeTypes {
        /// Flat fee
        case flat(_ flatFee: HyperwalletFee)
        /// Percent fee
        case percent(_ percentFee: HyperwalletFee)
        /// Mixed fee
        case mixed(_ percentFee: HyperwalletFee, _ flatFee: HyperwalletFee)

        func feeDescription() -> String {
            switch self {
            case .flat(let flatFee):
                return flatFeeDescription(flatFee)

            case .percent(let percentFee):
                return percentFeeDescription(percentFee)

            case let .mixed(percentFee, flatFee):
                return mixedFeeDescription(percentFee, flatFee)
            }
        }

        private func flatFeeDescription(_ flatFee: HyperwalletFee) -> String {
            var description = ""
            let feeFormat = "fee_flat_formatter".localized()

            if let currency = flatFee.currency, let flatValue = flatFee.value {
                description = String(format: feeFormat.localized(), currency, flatValue)
            }
            return description
        }

        private func percentFeeDescription(_ percentFee: HyperwalletFee) -> String {
            var description = ""
            var feeFormat = ""
            let value = percentFee.value
            let min = percentFee.minimum
            let max = percentFee.maximum
            let currency = percentFee.currency

            if let min = min, let max = max, let value = value, let currency = currency {
                feeFormat = "fee_percent_formatter".localized()
                description = String(format: feeFormat, value, currency, min, max)
            } else if let min = min, max == nil, let value = value, let currency = currency {
                feeFormat = "fee_percent_only_min_formatter".localized()
                description = String(format: feeFormat, value, currency, min)
            } else if min == nil, let max = max, let value = value, let currency = currency {
                feeFormat = "fee_percent_only_max_formatter".localized()
                description = String(format: feeFormat, value, currency, max)
            } else {
                if let value = value {
                    feeFormat = "fee_percent_no_min_and_max_formatter".localized()
                    description = String(format: feeFormat, value)
                }
            }
            return description
        }

        private func mixedFeeDescription(_ percentFee: HyperwalletFee, _ flatFee: HyperwalletFee) -> String {
            var description = ""
            var feeFormat = ""
            let flatValue = flatFee.value
            let percentValue = percentFee.value
            let min = percentFee.minimum
            let max = percentFee.maximum
            let currency = flatFee.currency

            if let min = min, let max = max, let flatValue = flatValue,
                let percentValue = percentValue, let currency = currency {
                feeFormat = "fee_mix_formatter".localized()
                description = String(
                    format: feeFormat, currency, flatValue, percentValue, min, max)
            } else if let min = min, max == nil, let flatValue = flatValue,
                let percentValue = percentValue, let currency = currency {
                feeFormat = "fee_mix_only_min_formatter".localized()
                description = String(
                    format: feeFormat, currency, flatValue, percentValue, min)
            } else if min == nil, let max = max, let flatValue = flatValue,
                let percentValue = percentValue, let currency = currency {
                feeFormat = "fee_mix_only_max_formatter".localized()
                description = String(
                    format: feeFormat, currency, flatValue, percentValue, max)
            } else {
                if let flatValue = flatValue, let percentValue = percentValue, let currency = currency {
                    feeFormat = "fee_mix_no_min_and_max_formatter".localized()
                    description = String(
                        format: feeFormat, currency, flatValue, percentValue)
                }
            }
            return description
        }
    }
}
