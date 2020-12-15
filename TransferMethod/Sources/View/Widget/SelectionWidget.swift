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
#if !COCOAPODS
import Common
#endif
import HyperwalletSDK
import UIKit

/// Represents the selection input widget.
final class SelectionWidget: AbstractWidget {
    weak var viewController: UIViewController?

    private let labelField: UILabel = {
        let label = UILabel()
        label.font = Theme.Label.titleFont
        return label
    }()
    private var selectedValue: String?

    override func focus() {}

    override func handleTap(sender: UITapGestureRecognizer? = nil) {
        viewController?.view.endEditing(true)
        showGenericTableView()
    }

    override func setupLayout(field: HyperwalletField) {
        super.setupLayout(field: field)
        if let fieldName = field.name {
            labelField.accessibilityIdentifier = "\(fieldName)Value"
        }

        addArrangedSubview(labelField)
        labelField.font = Theme.Label.titleFont
        labelField.adjustsFontForContentSizeCategory = true
        if field.isEditable ?? true {
            labelField.textColor = Theme.Text.color
            labelField.isUserInteractionEnabled = true
            labelField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        } else {
            labelField.textColor = Theme.Text.disabledColor
        }

        if let defaultValue = field.value,
            let option = field.fieldSelectionOptions?.first(where: { $0.value == defaultValue }) {
            updateLabelFieldValue(option)
        }
    }

    override func value() -> String {
        return selectedValue ?? ""
    }

    private func setupUITapGestureRecognizer(view: UIView, action: Selector ) {
        let tap = UITapGestureRecognizer(target: self, action: action)
        view.addGestureRecognizer(tap)
    }

    private func showGenericTableView() {
        guard let viewController = viewController else {
            return
        }

        let tableView = GenericController<SelectionWidgetCell, HyperwalletFieldSelectionOption>()
        tableView.title = field.label ?? ""

        tableView.items = field.fieldSelectionOptions ?? [HyperwalletFieldSelectionOption]()
        tableView.selectedHandler = { option in
            self.updateLabelFieldValue(option)
            if self.isValid() {
                self.hideError()
            } else {
                self.showError()
            }
        }

        tableView.shouldMarkCellAction = { self.selectedValue == $0.value }
        tableView.filterContentForSearchTextAction = {(items, searchText) in
            items.filter {
                $0.label?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }

        viewController.show(tableView, sender: viewController)
    }

    private func updateLabelFieldValue(_ option: HyperwalletFieldSelectionOption) {
        isValueUpdated = true
        labelField.text = option.label
        selectedValue = option.value
    }

    @objc dynamic var textLabelColor: UIColor! {
        get { return self.label.textColor }
        set {
            if !(self.label.accessibilityIdentifier?.hasSuffix("_error") ?? false) {
                self.label.textColor = newValue
            }
        }
    }

    @objc dynamic var textLabelFont: UIFont! {
        get { return self.label.font }
        set { self.label.font = newValue }
    }

    @objc dynamic var labelFieldColor: UIColor! {
        get { return self.labelField.textColor }
        set { self.labelField.textColor = newValue }
    }

    @objc dynamic var labelFieldFont: UIFont! {
        get { return self.labelField.font }
        set { self.labelField.font = newValue }
    }
}
