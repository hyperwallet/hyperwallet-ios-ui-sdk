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

final class AddTransferMethodFooter: UITableViewHeaderFooterView {
    static let reuseIdentifier = "AddTransferMethodFooterCell"

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!

    var error: String? {
        didSet {
            errorLabel.text = error
            setIsStackViewHidden()
            errorLabel.isAccessibilityElement = true
        }
    }

    var info: String? {
        didSet {
            infoLabel.text = info
            setSpacing()
            setIsStackViewHidden()
        }
    }

    private func setSpacing() {
        stackView.spacing = error == nil
                ? CGFloat(0.0)
                : CGFloat(8.0)
    }

    private func setIsStackViewHidden() {
        stackView.isHidden = error == nil && info == nil
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        errorLabel.textColor = Theme.Label.errorColor
        errorLabel.font = Theme.Label.footnoteFont
        infoLabel.textColor = Theme.Label.textColor
        infoLabel.font = Theme.Label.footnoteFont
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        error = nil
        info = nil
        stackView.layoutSubviews()
    }
}

final class AddTransferMethodSectionData {
    var category: String
    var country: String
    var currency: String
    var transferMethodType: String

    var containsFocusedField: Bool = false
    var fieldToBeFocused: AbstractWidget?
    var rowShouldBeScrolledTo: Int?
    var isScrolling: Bool = false

    lazy var header: String? = {
        switch category {
        case "ACCOUNT":
            let format = "\(category)_header".lowercased().localized()
            return String(format: format, "account_information_title".localized(), country.localized(), currency)
        case "PROFILE", "ADDRESS", "INFORMATION":
            return "\(category)_header".lowercased().localized()

        default:
            return  nil
        }
    }()

    lazy var footer: String? = {
        switch category {
        case "ACCOUNT":
            return "\(transferMethodType.lowercased())_footer".localized()
        case "PROFILE":
            return "add_profile_footer".localized()

        default:
            return nil
        }
    }()

    var errorMessage: String?

    var cells: [UIView] = []

    var count: Int {
        return cells.count
    }

    init(category: String,
         country: String,
         currency: String,
         transferMethodType: String,
         cells: [UIView]
        ) {
        self.category = category
        self.country = country
        self.currency = currency
        self.transferMethodType = transferMethodType
        self.cells = cells
    }

    subscript(index: Int) -> UIView {
        return cells[index]
    }
}
