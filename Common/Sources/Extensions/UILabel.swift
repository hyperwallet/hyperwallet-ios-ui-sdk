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

extension UILabel {
    private var selectionOverlay: CALayer {
        let layer = CALayer()
        layer.cornerRadius = 8
        layer.backgroundColor = UIColor.black.withAlphaComponent(0.14).cgColor
        layer.isHidden = true
        return layer
    }
    
    private var longPress: UILongPressGestureRecognizer {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
        recognizer.minimumPressDuration = 0.4
        return recognizer
    }
    
    override open var canBecomeFirstResponder: Bool {
        return true
    }
    
    /// Allow text selection
    public func allowTextSelection() {
        isUserInteractionEnabled = true
        layer.addSublayer(selectionOverlay)
        
        addGestureRecognizer(longPress)
        isUserInteractionEnabled = true
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didHideMenu),
                                               name: UIMenuController.didHideMenuNotification,
                                               object: nil)
    }
    
    private func applyBackgroundColor(_ color: UIColor) {
        let attributes: [NSAttributedString.Key: Any] = [
            .backgroundColor: color
        ]
        attributedText = NSAttributedString(string: text ?? "",
                                            attributes: attributes)
    }
    
    @objc
    private func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard let text = text, !text.isEmpty
        else { return }
        
        becomeFirstResponder()
        applyBackgroundColor(Theme.themeColor.withAlphaComponent(0.14))
        
        let menu = menuForSelection()
        if !menu.isMenuVisible {
            selectionOverlay.isHidden = false
            if #available(iOS 13.0, *) {
                menu.showMenu(from: self, rect: textRect())
            } else {
                menu.setTargetRect(textRect(), in: self)
                menu.setMenuVisible(true, animated: true)
            }
        }
    }
    
    @objc
    private func didHideMenu(_ notification: Notification) {
        selectionOverlay.isHidden = true
        applyBackgroundColor(UIColor.clear)
    }
        
    private func textRect() -> CGRect {
        let inset: CGFloat = -2
        return textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines).insetBy(dx: inset, dy: inset)
    }
    
    private func menuForSelection() -> UIMenuController {
        let menu = UIMenuController.shared
        menu.menuItems = [
            UIMenuItem(title: "Copy", action: #selector(copyText))
        ]
        return menu
    }
    
    @objc
    private func copyText(_ sender: Any?) {
        cancelSelection()
        let board = UIPasteboard.general
        board.string = text
    }
    
    private func cancelSelection() {
        let menu = UIMenuController.shared
        if #available(iOS 13.0, *) {
            menu.hideMenu(from: self)
        } else {
            menu.setMenuVisible(false, animated: true)
        }
    }
}
