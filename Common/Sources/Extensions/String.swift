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

/// The String extension
public extension String {
    /// Returns a localized string
    ///
    /// - Parameter withComment: Comment for localization.
    /// - Returns: Returns a substring
    func localized(withComment: String? = nil) -> String {
        return NSLocalizedString(self,
                                 tableName: nil,
                                 bundle: HyperwalletBundle.bundle,
                                 value: "",
                                 comment: withComment ?? "")
    }

    /// Returns a string, up to the given maximum length, containing the
    /// final elements of the collection.
    ///
    /// - Parameter startAt: The start character of elements to get the suffix string.
    /// - Returns: Returns a substring
    func suffix(startAt: Int) -> String {
        return String(self.suffix(startAt))
    }

    /// Calculates the string height based on UIFont
    ///
    /// - Parameters:
    ///   - width: the UIView width
    ///   - font: the UIFont
    /// - Returns: the String height
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width,
                                    height: .greatestFiniteMagnitude)

        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [NSAttributedString.Key.font: font],
                                            context: nil)

        return ceil(boundingBox.height)
    }

    /// Format an amount to a currency format with currency code
    ///
    /// - Parameter currencyCode: the currency code
    /// - Returns: a formatted String amount with currency code
    func format(with currencyCode: String?) -> String {
        if !self.isEmpty {
            let currencyFormatter = NumberFormatter()
            currencyFormatter.maximumFractionDigits = 2
            currencyFormatter.minimumFractionDigits = 2
            currencyFormatter.minimumIntegerDigits = 1
            currencyFormatter.numberStyle = .currency
            currencyFormatter.currencyCode = currencyCode
            currencyFormatter.currencySymbol = ""
            let formattedAmountInNumber = currencyFormatter.number(from: self)
            return currencyFormatter.string(for: formattedAmountInNumber) ?? ""
        } else {
            return ""
        }
    }

    /// Format an amount to a currency format with currency code
    ///
    /// - Parameter currencyCode: the currency code
    /// - Returns: a formatted NSNumber amount  with currency code
    func formatToNumber(with currencyCode: String? = nil) -> NSNumber {
        if !self.isEmpty {
            let currencyFormatter = NumberFormatter()
            currencyFormatter.maximumFractionDigits = 2
            currencyFormatter.minimumFractionDigits = 2
            currencyFormatter.minimumIntegerDigits = 1
            currencyFormatter.numberStyle = .currency
            currencyFormatter.currencyCode = currencyCode
            currencyFormatter.currencySymbol = ""
            return currencyFormatter.number(from: self) ?? 0
        } else {
            return 0
        }
    }
}

/// The NSMutableAttributedString extension
public extension NSMutableAttributedString {
    /// Creates and appends a NSAttributedString
    ///
    /// - Parameters:
    ///   - value: the string value
    ///   - font: the UIFont
    ///   - color: the UIColor
    func append(value: String, font: UIFont, color: UIColor) {
        append(value: value, attributes: [
            .font: font,
            .foregroundColor: color
        ])
    }

    private func append(value: String, color: UIColor) {
        append(value: value, attributes: [.foregroundColor: color] )
    }

    private func append(value: String, attributes: [NSAttributedString.Key: Any]?) {
        append(
            NSAttributedString(string: value,
                               attributes: attributes))
    }
}
