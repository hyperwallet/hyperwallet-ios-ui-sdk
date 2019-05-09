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
import HyperwalletSDK
import UIKit

/// Represents the selection input widget. 
final class SelectionWidget: AbstractWidget {
    weak var viewController: UIViewController?

    private let labelField: UILabel = {
        let label = UILabel()
        label.textColor = Theme.Text.color
        label.font = Theme.Label.bodyFont
        return label
    }()

    private var selectedValue: String?

    required init(field: HyperwalletField) {
        super.init(field: field)
        setupLayout(field: field)
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func value() -> String {
        return selectedValue ?? ""
    }

    override func focus() {}

    override func setupLayout(field: HyperwalletField) {
        super.setupLayout(field: field)
        self.addArrangedSubview(labelField)
        setupUITapGestureRecognizer(view: labelField, action: #selector(handleTap))
    }

    private func setupUITapGestureRecognizer(view: UIView, action: Selector ) {
        let tap = UITapGestureRecognizer(target: self, action: action)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
    }

    override func handleTap(sender: UITapGestureRecognizer? = nil) {
        viewController?.view.endEditing(true)
        showGenericTableView()
    }

    private func showGenericTableView() {
        guard let viewController = viewController else {
            return
        }

        let tableView = GenericTableViewController<SelectionWidgetCell, HyperwalletFieldSelectionOption>()
        tableView.title = field.label ?? ""

        tableView.items = field.fieldSelectionOptions ?? [HyperwalletFieldSelectionOption]()
        tableView.selectedHandler = { option in
            self.labelField.text = option.label.localized()
            self.selectedValue = option.value
            if self.isValid() {
                self.hideError()
            } else {
                self.showError()
            }
        }

        tableView.initialSelectedItemIndex = tableView.items.firstIndex { $0.value == value() }

        tableView.shouldMarkCellAction = { option in
            self.labelField.text == option.label.localized()
        }

        /// setup search bar
        tableView.filterContentForSearchTextAction = {(items, searchText) in
            items.filter {
                $0.label.lowercased().contains(searchText.lowercased())
            }
        }

        viewController.show(tableView, sender: viewController)
    }
}
