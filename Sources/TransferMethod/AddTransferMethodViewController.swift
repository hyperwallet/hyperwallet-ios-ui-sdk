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

/// Controller to create a new transfer method.
///
/// The form fields are based on the country, currency, user's profile type and transfer method type should be passed
/// to this Controller to create new Transfer Method for those values.
public final class AddTransferMethodViewController: UITableViewController {
    typealias ButtonHandler = () -> Void
    private let footerViewCellId = "footerViewCellId"
    private let footerTag = 654312

    private let emptyFooterHeight = CGFloat(2.0)
    private let defaultFooterHeight = CGFloat(38.0)
    private let lineSpacing = CGFloat(8.0)
    private var defaultHeaderHeight = CGFloat(38.0)

    private let emptyHeaderHeight: CGFloat = {
        if #available(iOS 11.0, *) {
            return CGFloat(1.0)
        } else {
            return CGFloat(16.0)
        }
    }()

    // MARK: - Properties -
    /// The completion handler will be performed after a new transfer method has been created.
    public var createTransferMethodHandler: ((HyperwalletTransferMethod) -> Void)?
    private var country: String
    private var currency: String
    private var profileType: String
    private var transferMethodType: String
    private var processingView: ProcessingView?
    private var spinnerView: SpinnerView?
    private var presenter: AddTransferMethodPresenter!
    private var widgets = [AbstractWidget]()
    // MARK: - Button -
    private lazy var button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(
            greaterThanOrEqualToConstant: Theme.Cell.rowHeight).isActive = true

        button.accessibilityLabel = "create_account_label".localized()
        button.accessibilityIdentifier = "createAccount"
        button.setTitle("create_account_label".localized(), for: .normal)
        button.setTitleColor(Theme.Button.color, for: UIControl.State.normal)
        button.addTarget(self, action: #selector(onTapped), for: .touchUpInside)
        button.accessibilityIdentifier = "createAccountBtn"
        return button
    }()

    @objc
    private func onTapped() {
        presenter.createTransferMethod()
    }

    private lazy var infoView: UIStackView = {
        let label = UILabel()
        label.numberOfLines = 0

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

    // MARK: - View Lifecycle -
    /// Creates a new instance of the `AddTransferMethodViewController`
    ///
    /// - Parameters:
    ///   - country: The 2 letter ISO 3166-1 country code.
    ///   - currency: The 3 letter ISO 4217-1 currency code.
    ///   - profileType: The profile type. Possible values - INDIVIDUAL, BUSINESS.
    ///   - transferMethodType: The transfer method type. Possible values - BANK_ACCOUNT, BANK_CARD.
    public init(_ country: String,
                _ currency: String,
                _ profileType: String,
                _ transferMethodType: String) {
        self.country = country
        self.currency = currency
        self.profileType = profileType
        self.transferMethodType = transferMethodType
        super.init(nibName: nil, bundle: nil)
    }

    // swiftlint:disable unavailable_function
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = transferMethodType.lowercased().localized()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        view.addGestureRecognizer(tap)
        initializePresenter()
        setupLayout()
        hideKeyboardWhenTappedAround()
        navigationItem.backBarButtonItem = UIBarButtonItem.back
    }

    // MARK: - Setup Layout -
    private func setupLayout() {
        setViewBackgroundColor()
        setupTableView()
    }

    private func setupTableView() {
        tableView = UITableView(frame: view.frame, style: .grouped)
        tableView.allowsSelection = false

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Theme.Cell.rowHeight
        tableView.accessibilityIdentifier = "addTransferMethodTable"
        // ?????
        //tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)

        tableView.register(
            AddTransferMethodTableViewCell.self,
            forCellReuseIdentifier: AddTransferMethodTableViewCell.reuseId
        )

        let nib = UINib(nibName: String(describing: AddTransferMethodFooter.self), bundle: HyperwalletBundle.bundle)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: AddTransferMethodFooter.reuseIdentifier)
    }

    @objc
    func handleTap(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    private func initializePresenter() {
        presenter = AddTransferMethodPresenter(self,
                                               country,
                                               currency,
                                               profileType,
                                               transferMethodType)
        presenter.loadTransferMethodConfigurationFields()
    }
}

// MARK: - TableViewController Data source and delegate
extension AddTransferMethodViewController {
    override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return presenter.sections[section].header
    }

    override public func tableView(_ tableView: UITableView,
                                   willDisplayHeaderView view: UIView,
                                   forSection section: Int) {
        guard let headerView = view as?  UITableViewHeaderFooterView
            else {
                return
        }
        headerView.textLabel?.textColor = Theme.Label.textColor
    }

    override public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: AddTransferMethodFooter.reuseIdentifier) as? AddTransferMethodFooter
            else {
                fatalError("can't dequeue footer view")
        }
        footerView.error = presenter.sections[section].errorMessage
        footerView.info = presenter.sections[section].footer
        return footerView
    }

    override public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if presenter.sections[section].footer == nil && presenter.sections[section].errorMessage == nil {
            return emptyFooterHeight
        }
        return UITableView.automaticDimension
    }

    override public func tableView(_ tableView: UITableView,
                                   estimatedHeightForFooterInSection section: Int) -> CGFloat {
        if presenter.sections[section].footer == nil && presenter.sections[section].errorMessage == nil {
            return emptyFooterHeight
        }
        return defaultFooterHeight
    }

    override public func tableView(_ tableView: UITableView,
                                   willDisplayFooterView view: UIView,
                                   forSection section: Int) {
        if let footerView = view as? AddTransferMethodFooter {
            updateFooterView(footerView,
                             for: section,
                             description: presenter.sections[section].footer ?? "",
                             errorMessage: presenter.sections[section].errorMessage ?? "")
        }
    }

    override public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let header = presenter.sections[section].header {
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

    override public func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.sections.count
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.sections[section].count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AddTransferMethodTableViewCell.reuseId)
            else {
                fatalError("Can't dequeue the cell")
        }
        let widget = presenter.sections[indexPath.section][indexPath.row]
        cell.contentView.addSubview(widget)
        if let widget = widget as? SelectionWidget {
            cell.accessoryType = .disclosureIndicator
            widget.viewController = self
        }

        //childView.safeAreaLeadingAnchor.constraint(equalTo: margins.leadingAnchor),
//        let leftAnchor = widget.leftAnchor.constraint(equalTo: cell.contentView.leadingAnchor)
        let leftAnchor = widget.safeAreaLeadingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.leadingAnchor)
        leftAnchor.priority = UILayoutPriority(999)

        let topAnchor = widget.topAnchor.constraint(equalTo: cell.contentView.topAnchor)
        topAnchor.priority = UILayoutPriority(999)

        let rightAnchor = widget.rightAnchor.constraint(equalTo: cell.contentView.rightAnchor)
        rightAnchor.priority = UILayoutPriority(999)

        let bottomAnchor = widget.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
        bottomAnchor.priority = UILayoutPriority(999)

        NSLayoutConstraint.activate([leftAnchor, topAnchor, rightAnchor, bottomAnchor])

        return cell
    }
}

// MARK: - Presenter - AddTransferMethodView -
extension AddTransferMethodViewController: AddTransferMethodView {
    func showFooterViewWithUpdatedSectionData(for sections: [AddTransferMethodSectionData]) {
        for section in sections {
            if let sectionIndex = presenter.getSectionIndex(by: section.category) {
                if let footerView = tableView.footerView(forSection: sectionIndex) as? AddTransferMethodFooter {
                    // section is visible, update footer
                    updateFooterView(footerView,
                                     for: sectionIndex,
                                     description: presenter.sections[sectionIndex].footer ?? "",
                                     errorMessage: section.errorMessage ?? "")
                }
            }
        }

        //even though the footer is visible, the cell might not be visible. So we need to check if the field that needs
        // to be focused is visible. We need to scroll to the field in order to focus.
        if let section = presenter.getSectionContainingFocusedField() {
            let indexPath = getIndexPath(for: section)
            if isCellVisibile(indexPath: indexPath) {
                presenter.focusField(in: section)
            } else {
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }

    override public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // update footer once scroll ends
        if let section = presenter.getSectionContainingFocusedField() {
            if isCellVisibile(indexPath: getIndexPath(for: section)) {
                presenter.focusField(in: section)
            }
        }
    }

    func fieldValues() -> [(name: String, value: String)] {
        return widgets.map { (name: $0.name(), value: $0.value()) }
    }

    func areAllFieldsValid() -> Bool {
        var isFormValid = true
        widgets.forEach {
            if $0.isValid() == false {
                $0.showError()
                if isFormValid {
                    $0.focus()
                    isFormValid = false
                }
            }
        }
        return isFormValid
    }

    func showLoading() {
        if let view = self.navigationController?.view {
            spinnerView = HyperwalletUtilViews.showSpinner(view: view)
        }
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

    func showTransferMethodFields(_ fields: [HyperwalletField], _ transferMethodTypeDetail: TransferMethodTypeDetail) {
        addFieldsSection(fields)
        addInfoSection(transferMethodTypeDetail)
        addCreateButtonSection()
        self.tableView.reloadData()
    }

    func showError(_ error: HyperwalletErrorType, _ handler: (() -> Void)?) {
        let errorView = ErrorView(viewController: self, error: error)
        errorView.show(handler)
    }

    func showBusinessError(_ error: HyperwalletErrorType, _ handler: @escaping (() -> Void)) {
        let errorView = ErrorView(viewController: self, error: error)
        errorView.businessError({ (_) in handler() })
    }

    func notifyTransferMethodAdded(_ transferMethod: HyperwalletTransferMethod) {
        DispatchQueue.global(qos: .background).async {
            NotificationCenter.default.post(name: .transferMethodAdded,
                                            object: self,
                                            userInfo: [UserInfo.transferMethod: transferMethod])
        }
        navigationController?.skipPreviousViewControllerIfPresent(skip: SelectTransferMethodTypeViewController.self)
        createTransferMethodHandler?(transferMethod)
    }

    private func updateFooterView(_ footerView: AddTransferMethodFooter,
                                  for section: Int,
                                  description: String,
                                  errorMessage: String) {
        if footerView.error != presenter.sections[section].errorMessage {
            UIView.setAnimationsEnabled(false)
            self.tableView.beginUpdates()
            footerView.error = errorMessage
            footerView.info = description
            self.tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }

    private func addFieldsSection(_ fields: [HyperwalletField]) {
        for field in fields {
            let widgetView = WidgetFactory.newWidget(field: field)
            guard let category = field.category else {
                continue
            }
            if let section = presenter.sections.first(where: { $0.category == category }) {
                section.cells.append(widgetView)
            } else {
                let section = AddTransferMethodSectionData(
                    category: category,
                    country: country,
                    currency: currency,
                    transferMethodType: transferMethodType,
                    cells: [widgetView]
                )
                presenter.sections.append(section)
            }
            widgets.append(widgetView)
        }
    }

    private func addInfoSection(_ transferMethodTypeDetail: TransferMethodTypeDetail) {
        guard transferMethodTypeDetail.fees != nil || transferMethodTypeDetail.processingTime != nil else {
            return
        }

        if let infoLabel = infoView.arrangedSubviews[0] as? UILabel {
            infoLabel.attributedText = transferMethodTypeDetail.formatFeesProcessingTime()
            let infoSection = AddTransferMethodSectionData(
                category: "INFORMATION",
                country: country,
                currency: currency,
                transferMethodType: transferMethodType,
                cells: [infoView])
            presenter.sections.append(infoSection)
        }
    }

    private func addCreateButtonSection() {
        let buttonSection = AddTransferMethodSectionData(
            category: "CREATE_BUTTON",
            country: country,
            currency: currency,
            transferMethodType: transferMethodType,
            cells: [button])
        presenter.sections.append(buttonSection)
    }

    private func isCellVisibile(indexPath: IndexPath) -> Bool {
        let cellRect = tableView.rectForRow(at: indexPath)
        return tableView.bounds.contains(cellRect)
    }

    private func getIndexPath(for section: AddTransferMethodSectionData) -> IndexPath {
        let sectionIndex = presenter.getSectionIndex(by: section.category)!
        return IndexPath(row: section.rowShouldBeScrolledTo!, section: sectionIndex)
    }
}
