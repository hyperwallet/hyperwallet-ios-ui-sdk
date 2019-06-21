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

extension String {
    func localized(withComment: String? = nil) -> String {
        return NSLocalizedString(self,
                                 tableName: nil,
                                 bundle: HyperwalletBundle.bundle,
                                 value: "",
                                 comment: withComment ?? "")
    }

    func suffix(startAt: Int) -> String {
        return String(self.suffix(startAt))
    }

    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width,
                                    height: .greatestFiniteMagnitude)

        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [NSAttributedString.Key.font: font],
                                            context: nil)

        return ceil(boundingBox.height)
    }

    func currencyFormatter(by currencyCode: String) -> String {
        if let amountInDouble = Double(self) {
            let currencyFormatter = NumberFormatter()
            currencyFormatter.numberStyle = .currency
            currencyFormatter.currencyCode = currencyCode
            return currencyFormatter.string(for: amountInDouble) ?? ""
        } else {
            return ""
        }
    }
}

extension NSMutableAttributedString {
    func append(value: String, font: UIFont, color: UIColor) {
        append(value: value, attributes: [
            .font: font,
            .foregroundColor: color
        ])
    }

    func append(value: String, color: UIColor) {
        append(value: value, attributes: [.foregroundColor: color] )
    }

    func append(value: String, attributes: [NSAttributedString.Key: Any]?) {
        append(
            NSAttributedString(string: value,
                               attributes: attributes))
    }
}

extension Array {
    func isNotEmpty() -> Bool {
        return !self.isEmpty
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
