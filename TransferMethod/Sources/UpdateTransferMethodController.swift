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

/// Controller to update transfer method.
///
/// The form fields are based on transfer method token passed to this controller to update transfer method
final class UpdateTransferMethodController: UITableViewController {
    typealias ButtonHandler = () -> Void
    private var defaultHeaderHeight = CGFloat(38.0)

    private let emptyHeaderHeight: CGFloat = {
        if #available(iOS 11.0, *) {
            return CGFloat(1.0)
        } else {
            return CGFloat(16.0)
        }
    }()

    private let registeredCells: [(type: AnyClass, id: String)] = [
        (UpdateTransferMethodCell.self, UpdateTransferMethodCell.reuseIdentifier),
        (UpdateTransferMethodButtonCell.self, UpdateTransferMethodButtonCell.reuseIdentifier)
    ]

    // MARK: - Properties -
    private var forceUpdate: Bool?
    private var processingView: ProcessingView?
    private var spinnerView: SpinnerView?
    private var presenter: UpdateTransferMethodPresenter!
    private var widgets = [AbstractWidget]()
    private var isCalledByScrollToRow = false
    // MARK: - Button -
    private lazy var updateTransferMethodButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityLabel = "update_account_label".localized()
        button.accessibilityIdentifier = "updateAccountButton"
        button.setTitle("doneButtonLabel".localized(), for: .normal)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.titleLabel?.font = Theme.Button.font
        button.setTitleColor(Theme.Button.color, for: UIControl.State.normal)
        button.addTarget(self, action: #selector(didTap), for: .touchUpInside)
        button.backgroundColor = Theme.Button.backgroundColor

        let heightConstraint = NSLayoutConstraint(item: button,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 1,
                                                  constant: 52)
        button.addConstraint(heightConstraint)

        return button
    }()

    @objc
    private func didTap() {
        presenter.updateTransferMethod()
    }

    private lazy var infoView: UIStackView = {
        let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        let stackView = UIStackView(arrangedSubviews: [label])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(
            top: CGFloat(8.0),
            left: CGFloat(0.0),
            bottom: CGFloat(8.0),
            right: CGFloat(16.0)
        )
        return stackView
    }()

    override public func viewDidLoad() {
        super.viewDidLoad()
        initializePresenter()
        setupTableView()
        presenter.loadTransferMethodUpdateConfigurationFields()
        hideKeyboardWhenTappedAround()
        self.navigationController?.presentationController?.delegate = self
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        let currentNavigationItem: UINavigationItem = tabBarController?.navigationItem ?? navigationItem
        currentNavigationItem.backBarButtonItem = UIBarButtonItem.back
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            removeCoordinator()
        }
    }

    private func setupTableView() {
        tableView = UITableView(frame: view.frame, style: .grouped)
        tableView.allowsSelection = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Theme.Cell.smallHeight
        tableView.backgroundColor = Theme.UITableViewController.backgroundColor
        tableView.accessibilityIdentifier = "updateTransferMethodTable"
        registeredCells.forEach {
            tableView.register($0.type, forCellReuseIdentifier: $0.id)
        }
    }

    private func initializePresenter() {
        if let transferMethodToken = initializationData?[InitializationDataField.transferMethodToken] as?
            String {
            presenter = UpdateTransferMethodPresenter(self, transferMethodToken)
        } else {
            fatalError("Required data not provided in initializePresenter")
        }
    }
}

// MARK: - TableViewController Data source and delegate
extension UpdateTransferMethodController {
    /// Returns the title for header
    override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return presenter.sectionData[section].header
    }
    /// Returns the header view
    override public func tableView(_ tableView: UITableView,
                                   willDisplayHeaderView view: UIView,
                                   forSection section: Int) {
        guard let headerView = view as?  UITableViewHeaderFooterView
            else {
                return
        }
        headerView.textLabel?.textColor = Theme.Label.subtitleColor
    }
    /// Returns the title for footer
    override public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        var footerText = ""
        if let errorMessage = presenter.sectionData[section].errorMessage {
            footerText = String(format: "%@", errorMessage)
        }
        return footerText
    }
    /// Returns the height of header
    override public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let header = presenter.sectionData[section].header {
            if header.height(withConstrainedWidth: self.view.frame.width,
                             font: UIFont.preferredFont(forTextStyle: .body)) > defaultHeaderHeight {
                return UITableView.automaticDimension
            } else {
                return defaultHeaderHeight
            }
        } else {
            return emptyHeaderHeight
        }
    }
    /// Returns height of row
    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Theme.Cell.smallHeight
    }
    /// Returns tableview section count
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.sectionData.count
    }
    /// Returns fields count to update transfer method
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.sectionData[section].count
    }
    /// Display's the fields to update transfer method
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let fieldGroup = presenter.sectionData[indexPath.section].fieldGroup
        let reuseIdentifier = fieldGroup == "UPDATE_BUTTON" ?
                UpdateTransferMethodButtonCell.reuseIdentifier : UpdateTransferMethodCell.reuseIdentifier

        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
            else {
                fatalError("Can't dequeue the cell")
        }
        let widget = presenter.sectionData[indexPath.section][indexPath.row]
        cell.contentView.addSubview(widget)
        if let widget = widget as? AbstractWidget, widget.errorMessage != nil {
            widget.showError()
        }

        if let widget = widget as? AbstractWidget, !(widget.field.isEditable ?? true) {
            cell.backgroundColor = Theme.Cell.disabledBackgroundColor
        } else {
            cell.backgroundColor = Theme.UITableViewController.backgroundColor
        }

        if let widget = widget as? SelectionWidget, widget.field.isEditable ?? true {
            cell.accessoryType = .disclosureIndicator
            widget.viewController = self
        }

        let rightAnchorConstant = fieldGroup == "UPDATE_BUTTON" ? -14 : 0

        let leftAnchor = widget.safeAreaLeadingAnchor
            .constraint(equalTo: cell.contentView.layoutMarginsGuide.leadingAnchor)
        leftAnchor.priority = UILayoutPriority(999)

        let topAnchor = widget.topAnchor.constraint(equalTo: cell.contentView.topAnchor)
        topAnchor.priority = UILayoutPriority(999)

        let rightAnchor = widget.rightAnchor.constraint(equalTo: cell.contentView.rightAnchor,
                                                        constant: CGFloat(rightAnchorConstant))
        rightAnchor.priority = UILayoutPriority(999)

        let bottomAnchor = widget.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
        bottomAnchor.priority = UILayoutPriority(999)

        NSLayoutConstraint.activate([leftAnchor, topAnchor, rightAnchor, bottomAnchor])

        return cell
    }
}

// MARK: - Presenter - UpdateTransferMethodView -
extension UpdateTransferMethodController: UpdateTransferMethodView {
    private func getSectionContainingFocusedField() -> UpdateTransferMethodSectionData? {
        return presenter.sectionData.first(where: { $0.containsFocusedField == true })
    }

    private func getSectionIndex(by fieldGroup: String) -> Int? {
        return presenter.sectionData.firstIndex(where: { $0.fieldGroup == fieldGroup })
    }

    private func focusField(in section: UpdateTransferMethodSectionData) {
        section.fieldToBeFocused?.focus()
        section.reset()
    }

    func showFooterViewWithUpdatedSectionData(for sections: [UpdateTransferMethodSectionData]) {
        for section in sections {
            if let sectionIndex = getSectionIndex(by: section.fieldGroup) {
                if let footerView = tableView.footerView(forSection: sectionIndex) {
                    // section is visible, update footer
                    updateFooterView(footerView, for: sectionIndex)
                }
            }
        }

        // even though the footer is visible, the cell might not be visible.
        // So we need to check if the field that needs
        // to be focused is visible. We need to scroll to the field in order to focus.
        if let section = getSectionContainingFocusedField() {
            let indexPath = getIndexPath(for: section)
            if isCellVisible(indexPath) {
                focusField(in: section)
            } else {
                isCalledByScrollToRow = true
                tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
    }

    /// Scrollview delegate
    override public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // update footer once scroll ends
        if let section = getSectionContainingFocusedField() {
            if isCellVisible(getIndexPath(for: section)) && isCalledByScrollToRow {
                focusField(in: section)
                isCalledByScrollToRow = false
            }
        }
    }

    func fieldValues() -> [(name: String, value: String)] {
        return widgets.filter { $0.isValueUpdated }.map { (name: $0.name(), value: $0.value()) }
    }

    func areAllUpdatedFieldsValid() -> Bool {
        var isFormValid = true
        widgets.filter { $0.isValueUpdated }.forEach {
            if $0.isValid() == false {
                $0.showError()
                if isFormValid {
                    focusOnInvalidField($0)
                }
                isFormValid = false
            }
        }
        updateErrorMessagesInFooter()
        return isFormValid
    }

    func showLoading() {
        spinnerView = HyperwalletUtilViews.showSpinner(view: view)
    }

    func hideLoading() {
        if let spinnerView = spinnerView {
            HyperwalletUtilViews.removeSpinner(spinnerView)
        }
    }

    func showProcessing() {
        processingView = HyperwalletUtilViews.showProcessing()
    }

    func dismissProcessing(handler: @escaping () -> Void) {
        processingView?.hide()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            handler()
        }
    }

    func showConfirmation(handler: @escaping (() -> Void)) {
        processingView?.hide(with: .complete)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            handler()
        }
    }

    func reloadData(_ fieldGroups: [HyperwalletFieldGroup]) {
        titleDisplayMode(.always, for: presenter.transferMethodConfiguration?
        .transferMethodType?.lowercased().localized())
        addFieldsSection(fieldGroups)
        addUpdateButtonSection()
        self.tableView.reloadData()
    }

    func showError( title: String, message: String) {
        HyperwalletUtilViews.showAlert(self, title: title, message: message, actions: UIAlertAction.close(self))
    }

    func showError(_ error: HyperwalletErrorType,
                   pageName: String,
                   pageGroup: String,
                   _ retry: (() -> Void)?) {
        let errorView = ErrorView(viewController: self,
                                  error: error,
                                  pageName: pageName,
                                  pageGroup: pageGroup)
        errorView.show(retry)
    }

    func notifyTransferMethodUpdated(_ transferMethod: HyperwalletTransferMethod) {
        DispatchQueue.global(qos: .background).async {
            NotificationCenter.default.post(name: .transferMethodUpdated,
                                            object: self,
                                            userInfo: [UserInfo.transferMethodUpdated: transferMethod])
        }
        removeCoordinator()
        flowDelegate?.didFlowComplete(with: transferMethod)
    }

    private func focusOnInvalidField(_ widget: AbstractWidget) {
        if let indexPath = getIndexPathFor(fieldToBeFocused: widget) {
            if isCellVisible(indexPath) {
                widget.focus()
            } else {
                let sectionContainingInvalidWidget = presenter.sectionData[indexPath.section]
                sectionContainingInvalidWidget.containsFocusedField = true
                presenter.prepareSectionForScrolling(sectionContainingInvalidWidget, indexPath.row, widget)
                tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
    }

    private func getIndexPathFor(fieldToBeFocused: AbstractWidget) -> IndexPath? {
        if let sectionContainingInvalidField = presenter
            .sectionData
            .first(where: { $0.cells.contains(fieldToBeFocused) }),
            let sectionIndex = getSectionIndex(by: sectionContainingInvalidField.fieldGroup),
            let cellIndex = sectionContainingInvalidField.cells.firstIndex(of: fieldToBeFocused) {
            return IndexPath(row: cellIndex, section: sectionIndex)
        }
        return nil
    }

    private func updateFooterView(_ footerView: UITableViewHeaderFooterView, for section: Int) {
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        footerView.textLabel?.text = presenter.sectionData[section].errorMessage
        footerView.sizeToFit()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }

    /// Tableview delegate for footer view
    override public func tableView(_ tableView: UITableView,
                                   willDisplayFooterView view: UIView,
                                   forSection section: Int) {
        if let footerView = view as? UITableViewHeaderFooterView {
            footerView.textLabel?.textColor = Theme.Label.errorColor
        }
    }

    private func addFieldsSection(_ fieldGroups: [HyperwalletFieldGroup]) {
        for fieldGroup in fieldGroups {
            guard let fields = fieldGroup.fields, let fieldGroup = fieldGroup.group
                else {
                    continue
            }
            let newWidgets =
                fields.map({WidgetFactory.newWidget(field: $0,
                                                    pageName: UpdateTransferMethodPresenter
                                                        .updateTransferMethodPageName,
                                                    pageGroup: UpdateTransferMethodPresenter
                                                        .updateTransferMethodPageGroup
                ) {[weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.updateErrorMessagesInFooter()
                }})
            let section = UpdateTransferMethodSectionData(
                fieldGroup: fieldGroup,
                country: presenter.transferMethodConfiguration?.country,
                currency: presenter.transferMethodConfiguration?.currency,
                cells: newWidgets
            )
            presenter.sectionData.append(section)
            widgets.append(contentsOf: newWidgets)
        }
    }

    /// Updates error messages if present for widgets, under corresponding section in footer
    private func updateErrorMessagesInFooter() {
        presenter.resetErrorMessagesForAllSections()
        presenter.sectionData.forEach { sectionData in
            var errorMessages = [String]()
            sectionData.cells.forEach { cell in
                if let widget = cell as? AbstractWidget, let errorMessage = widget.errorMessage {
                    errorMessages.append(errorMessage)
                }
            }
            sectionData.errorMessage = errorMessages.joined(separator: "\n")
        }
        showFooterViewWithUpdatedSectionData(for: presenter.sectionData)
    }

    private func addUpdateButtonSection() {
        let buttonSection = UpdateTransferMethodSectionData(
            fieldGroup: "UPDATE_BUTTON",
            country: presenter.transferMethodConfiguration?.country,
            currency: presenter.transferMethodConfiguration?.currency,
            cells: [updateTransferMethodButton])
        presenter.sectionData.append(buttonSection)
    }

    private func isCellVisible(_ indexPath: IndexPath) -> Bool {
        let cellRect = tableView.rectForRow(at: indexPath)
        return tableView.bounds.contains(cellRect)
    }

    private func getIndexPath(for section: UpdateTransferMethodSectionData) -> IndexPath {
        let sectionIndex = getSectionIndex(by: section.fieldGroup)!
        return IndexPath(row: section.rowShouldBeScrolledTo!, section: sectionIndex)
    }
}
