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

/// Lists user's transfer from sources
final class ListTransferSourceController: UITableViewController {
    private var presenter: ListTransferSourcePresenter!
    private var processingView: ProcessingView?
    private var spinnerView: SpinnerView?

    override public func viewDidLoad() {
        super.viewDidLoad()
        initializePresenter()
        setupTransferMethodTableView()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.backBarButtonItem = UIBarButtonItem.back
        titleDisplayMode(.never, for: "mobileTransferFromHeader".localized())
    }

    private func initializePresenter() {
        if let data = initializationData?[InitializationDataField.transferSources]
            as? [TransferSourceCellConfiguration] {
            presenter = ListTransferSourcePresenter(transferSources: data)
        }
    }

    // MARK: set up list of transfer methods table view
    private func setupTransferMethodTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Theme.Cell.smallHeight
        tableView.register(ListTransferSourceCell.self,
                           forCellReuseIdentifier: ListTransferSourceCell.reuseIdentifier)
        tableView.backgroundColor = Theme.UITableViewController.backgroundColor
    }
}

/// Transfer method list table view dataSource and delegate
extension ListTransferSourceController {
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.sectionData.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListTransferSourceCell.reuseIdentifier,
                                                 for: indexPath)
        cell.accessoryType = .none

        if let selectedTransferSource = initializationData?[InitializationDataField.selectedTransferSource]
            as? TransferSourceCellConfiguration,
            selectedTransferSource.token == presenter.sectionData[indexPath.row].token {
            cell.accessoryType = .checkmark
        }

        if let listTransferSourceCell = cell as? ListTransferSourceCell {
            listTransferSourceCell.configure(transferSourceCellConfiguration: presenter.sectionData[indexPath.row])
        }
        return cell
    }

    /// To select the transfer method
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTransferSoource = presenter.sectionData[indexPath.row]
        flowDelegate?.didFlowComplete(with: selectedTransferSoource)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Theme.Cell.largeHeight
    }

    override public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    override public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}

extension ListTransferSourceController {
    /// The callback to refresh create transfer
    override public func didFlowComplete(with response: Any) {
        if response is HyperwalletTransferMethod {
            navigationController?.popViewController(animated: false)
            flowDelegate?.didFlowComplete(with: response)
        }
    }
}
