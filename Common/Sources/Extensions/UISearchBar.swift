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

/// The UISearchBar extension
public extension UISearchBar {
    /// Setup text alignment to the left
    func setLeftAligment() {
        guard let textField = self.value(forKey: "searchField") as? UITextField else {
            return
        }
        textField.accessibilityIdentifier = "search"
        guard #available(iOS 11.0, *) else {
            let spaceCharacter = " "
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

            let widthSpace = spaceCharacter.boundingRect(with: maxSize,
                                                         options: .usesLineFragmentOrigin,
                                                         attributes: attributes,
                                                         context: nil).size.width

            let spacesCount = Int((maxSize.width - widthText) / widthSpace) - 1
            guard spacesCount > 0  else {
                return
            }
            let newText = placeholderText + String(repeating: spaceCharacter, count: spacesCount)
            textField.attributedPlaceholder = NSAttributedString(string: newText, attributes: attributes)
            return
        }
    }

    /// <#Description#>
    func getTextField() -> UITextField? {
        return value(forKey: "searchField") as? UITextField
    }
    /// <#Description#>
    /// - Parameter textColor: <#textColor description#>
    func set(textColor: UIColor) {
        if let textField = getTextField() {
            textField.textColor = textColor
        }
    }
    /// <#Description#>
    /// - Parameter textColor: <#textColor description#>
    func setPlaceholder(textColor: UIColor) {
        getTextField()?.setPlaceholder(textColor: textColor)
    }
    /// <#Description#>
    /// - Parameter color: <#color description#>
    func setClearButton(color: UIColor) {
        getTextField()?.setClearButton(color: color)
    }

    /// <#Description#>
    /// - Parameter color: <#color description#>
    func setTextField(color: UIColor) {
        guard let textField = getTextField() else {
            return
        }
        switch searchBarStyle {
        case .minimal:
            textField.layer.backgroundColor = color.cgColor
            textField.layer.cornerRadius = 6
        case .prominent, .default: textField.backgroundColor = color
        @unknown default: break
        }
    }

    /// <#Description#>
    /// - Parameter color: <#color description#>
    func setSearchImage(color: UIColor) {
        guard let imageView = getTextField()?.leftView as? UIImageView else {
            return
        }
        imageView.tintColor = color
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
    }
}

private extension UITextField {
    private class Label: UILabel {
        private var _textColor = UIColor.lightGray
        override var textColor: UIColor! {
            set { super.textColor = _textColor }
            get { return _textColor }
        }

        init(label: UILabel, textColor: UIColor = .lightGray) {
            _textColor = textColor
            super.init(frame: label.frame)
            self.text = label.text
            self.font = label.font
        }

        required init?(coder: NSCoder) { super.init(coder: coder) }
    }

    private class ClearButtonImage {
        private static var _image: UIImage?
        private static var semaphore = DispatchSemaphore(value: 1)
        static func getImage(closure: @escaping (UIImage?) -> Void) {
            DispatchQueue.global(qos: .userInteractive).async {
                semaphore.wait()
                DispatchQueue.main.async {
                    if let image = _image {
                        closure(image); semaphore.signal()
                        return
                    }
                    guard let window = UIApplication.shared.windows.first else {
                        semaphore.signal(); return
                    }
                    let searchBar = UISearchBar(
                        frame: CGRect(x: 0, y: -200, width: UIScreen.main.bounds.width, height: 44))
                    window.rootViewController?.view.addSubview(searchBar)
                    searchBar.text = "txt"
                    searchBar.layoutIfNeeded()
                    _image = searchBar.getTextField()?.getClearButton()?.image(for: .normal)
                    closure(_image)
                    searchBar.removeFromSuperview()
                    semaphore.signal()
                }
            }
        }
    }

    func setClearButton(color: UIColor) {
        ClearButtonImage.getImage { [weak self] image in
            guard   let image = image,
                let button = self?.getClearButton() else { return }
            button.imageView?.tintColor = color
            button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }

    var placeholderLabel: UILabel? { return value(forKey: "placeholderLabel") as? UILabel }

    func setPlaceholder(textColor: UIColor) {
        guard let placeholderLabel = placeholderLabel else {
            return
        }
        let label = Label(label: placeholderLabel, textColor: textColor)
        setValue(label, forKey: "placeholderLabel")
    }

    func getClearButton() -> UIButton? { return value(forKey: "clearButton") as? UIButton }
}
