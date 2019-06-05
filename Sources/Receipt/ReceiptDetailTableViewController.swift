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

public final class ReceiptDetailTableViewController: UITableViewController {
    private let registeredCells: [(type: AnyClass, id: String)] = [
        (ReceiptTransactionTableViewCell.self, ReceiptTransactionTableViewCell.reuseIdentifier),
        (ReceiptFeeTableViewCell.self, ReceiptFeeTableViewCell.reuseIdentifier),
        (ReceiptDetailTableViewCell.self, ReceiptDetailTableViewCell.reuseIdentifier),
        (ReceiptNotesTableViewCell.self, ReceiptNotesTableViewCell.reuseIdentifier)
    ]

    private var presenter: ReceiptDetailViewPresenter!

    public init(with hyperwalletReceipt: HyperwalletReceipt) {
        super.init(nibName: nil, bundle: nil)
        presenter = ReceiptDetailViewPresenter(with: hyperwalletReceipt)
    }

    // swiftlint:disable unavailable_function
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = "title_transaction_details".localized()
        titleDisplayMode(UINavigationItem.LargeTitleDisplayMode.never)
        setViewBackgroundColor()
        setupReceiptDetailTableView()
    }

    private func setupReceiptDetailTableView() {
        tableView = UITableView(frame: view.frame, style: .grouped)
        tableView.allowsSelection = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.accessibilityIdentifier = "ReceiptDetailTableView"
        registeredCells.forEach {
            tableView.register($0.type, forCellReuseIdentifier: $0.id)
        }
    }
}

extension ReceiptDetailTableViewController {
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.numberOfSections()
    }

    override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return presenter.titleForHeaderInSection(section)
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRowsInSection(section)
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = presenter.cellIdentifierForRowInSection(indexPath.section)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        presenter.configureCell(cell, for: indexPath)
        return cell
    }

    override public func tableView(_ tableView: UITableView,
                                   estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(Theme.Cell.headerHeight)
    }
}
