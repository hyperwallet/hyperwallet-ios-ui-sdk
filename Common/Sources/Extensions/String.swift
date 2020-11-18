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

    /// Format amount for currency code using users locale
    /// - Parameter currencyCode: currency code
    /// - Returns: a formatted amount string
    func formatToCurrency(with currencyCode: String?) -> String {
        guard let currencyCode = currencyCode, !self.isEmpty
        else { return "0" }
        let number = Double(self)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.currencyCode = currencyCode
        return formatter.string(for: number) ?? self
    }

    /// Return decimal symbol for the given currency code
    /// - Parameter currencyCode: currency code
    /// - Returns: decimal symbol
    func decimalSymbol(for currencyCode: String?) -> String {
        guard let currencyCode = currencyCode, !self.isEmpty
        else { return "" }
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.decimalSeparator
    }

    /// Format amount to double
    /// - Returns: double value
    func formatAmountToDouble() -> Double {
        let decimals = Set("0123456789.")
        let result = String(self.filter { decimals.contains($0) })
        return Double(result) ?? 0
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

    /// Creates and appends a paragraph of NSAttributedString
    ///
    /// - Parameters:
    ///   - value: the string value
    ///   - font: the UIFont
    ///   - color: the UIColor
    func appendParagraph(value: String, font: UIFont, color: UIColor) {
        let paragraphText = self.string.isEmpty
            ? value
            : "\n\(value)"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .natural
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.paragraphSpacing = font.lineHeight
        append(value: paragraphText, attributes: [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle
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
