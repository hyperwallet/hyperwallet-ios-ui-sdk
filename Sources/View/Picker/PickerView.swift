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

protocol ToolbarPickerViewDelegate: class {
    func didTapDone(_ handler: (_ textField: UITextField) -> Void)
}

class PickerView: UIPickerView {
    public private(set) var toolbar: UIToolbar!
    public weak var toolBarDelegate: ToolbarPickerViewDelegate?
    var tapDoneHandler: ((_ textField: UITextField) -> Void)!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpToolBar()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpToolBar()
    }

    /// Add a tool bar containing a done button on top of the picker
    private func setUpToolBar() {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = Theme.themeColor
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "done_button_label".localized(),
                                         style: .plain,
                                         target: self,
                                         action: #selector(self.doneTapped))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolBar.setItems([spaceButton, doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        toolBar.accessibilityIdentifier = "Toolbar"
        self.toolbar = toolBar
    }

    @objc
    func doneTapped() {
        toolBarDelegate?.didTapDone(tapDoneHandler)
    }
}
