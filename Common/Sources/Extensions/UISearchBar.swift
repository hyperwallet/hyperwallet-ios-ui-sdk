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

extension UISearchBar {
    func setLeftAligment() {
        guard #available(iOS 11.0, *) else {
            if let textField = self.value(forKey: "searchField") as? UITextField {
                textField.accessibilityIdentifier = "Search"
                let spaceChar = " "
                let placeholderText = "search_placeholder_label".localized()
                let attributes = textField.attributedPlaceholder?.attributes(at: 0, effectiveRange: nil)
                let leftViewWidth = textField.leftView?.bounds.width ?? 0
                let leftInnerRightMargins = CGFloat(40)
                let maxSize = CGSize(width: self.bounds.size.width - leftViewWidth - leftInnerRightMargins,
                                     height: 40)
                let widthText = placeholderText.boundingRect(with: maxSize,
                                                             options: .usesLineFragmentOrigin,
                                                             attributes: attributes,
                                                             context: nil).size.width

                let widthSpace = spaceChar.boundingRect(with: maxSize,
                                                        options: .usesLineFragmentOrigin,
                                                        attributes: attributes,
                                                        context: nil).size.width

                let spacesCount = Int((maxSize.width - widthText) / widthSpace) - 1
                guard spacesCount > 0  else {
                    return
                }
                let newText = placeholderText + String(repeating: spaceChar, count: spacesCount)
                textField.attributedPlaceholder = NSAttributedString(string: newText, attributes: attributes)
            }
            return
        }
    }
}
