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

/// Generic Controller
public class GenericController<T: GenericCell<ModelType>, ModelType>: UITableViewController,
UISearchResultsUpdating, UISearchControllerDelegate {
    private let reuseIdentifier = "genericCellIdentifier"
    private let reuseHeaderIdentifier = "headerCellIdentifier"
    /// Enable the search controller
    private var shouldDisplaySearchBar = false
    /// The amount of items to enable the search bar to the Generic TableView
    let amountOfItemsToEnableSearchBar = 20
    public var items = [ModelType]() {
        didSet {
            shouldDisplaySearchBar = items.count >= amountOfItemsToEnableSearchBar
        }
    }
    public var filteredItems = [ModelType]()
    /// Event handler to indicate if the item cell should be marked
    public var shouldMarkCellAction: ((_ value: ModelType) -> Bool)?

    /// Delegate to customise the filter content.
    ///
    /// - parameters: searchText - The text should be used to filter the items list and returned the filtered list.
    public var filterContentForSearchTextAction: ((_ items: [ModelType], _ searchText: String) -> [ModelType])? {
        didSet {
            if shouldDisplaySearchBar {
                setupSearchBar()
            } else {
                setupWithoutSearchBar()
            }
        }
    }
    public typealias SelectedHandler = (_ value: ModelType) -> Void
    /// Event handler to return the item selected
    public var selectedHandler: SelectedHandler?

    // MARK: - Private properties
    private let searchController: UISearchController = {
        UISearchController(searchResultsController: nil)
    }()

    override public func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        titleDisplayMode(.never)
        extendedLayoutIncludesOpaqueBars = true
        setupTable()
        setViewBackgroundColor()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        scrollToSelectedRow()
        setupUISearchController()
    }

    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        guard #available(iOS 11.0, *) else {
            DispatchQueue.main.async {
                self.setupSearchBarSize()
                self.searchController.searchBar.setLeftAlignment()
            }
            return
        }
    }

    public func didDismissSearchController(_ searchController: UISearchController) {
        setupSearchBarSize()
    }

    private func setupSearchBarSize() {
       searchController.searchBar.sizeToFit()
    }
    // MARK: - UITableViewDataSource

    override public func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return retrieveItems().count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        cell.accessoryType = .none

        if shouldMarkCellAction?(retrieveItems()[indexPath.row]) ?? false {
            cell.accessoryType = .checkmark
        }

        if let genericCell = cell as? GenericCell<ModelType> {
            genericCell.item = retrieveItems()[indexPath.row]
        }

        return cell
    }

    // MARK: - UITableViewDelegate

    override public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard #available(iOS 11.0, *) else {
            if shouldDisplaySearchBar {
                let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseHeaderIdentifier)

                headerView?.addSubview(searchController.searchBar)
                return headerView
            }

            return nil
        }

        return nil
    }

    override public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard #available(iOS 11.0, *) else {
            return shouldDisplaySearchBar ? searchController.searchBar.frame.size.height : CGFloat.leastNormalMagnitude
        }

        return CGFloat.leastNormalMagnitude
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Retrieve the item selected
        if let performItemSelected = selectedHandler {
            let item = retrieveItems()[indexPath.row]
            performItemSelected(item)
        }
        navigationController?.popViewController(animated: true)
    }

    // MARK: - UISearchResultsUpdating
    public func updateSearchResults(for searchController: UISearchController) {
        guard let performFilter = filterContentForSearchTextAction,
            let searchText = searchController.searchBar.text else {
                return
        }

        filteredItems = performFilter(items, searchText)
        tableView.reloadData()
    }
}

private extension GenericController {
    // MARK: - Setup
    /// Setup the Search Controller
    func setupUISearchController() {
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        setupSearchBarSize()
        searchController.searchBar.setLeftAlignment()
        searchController.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
    }

    // MARK: - Private instance methods
    /// Checks the search bar is empty
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    /// Checks the search bar is active
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }

    func retrieveItems() -> [ModelType] {
        if isFiltering() {
            return filteredItems
        } else {
            return items
        }
    }

    func setupSearchBar() {
        setupUISearchController()

        if #available(iOS 11.0, *) {
            navigationItem.searchController = self.searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        }
        ThemeManager.applyTo(searchBar: searchController.searchBar)
    }

    func setupWithoutSearchBar() {
        definesPresentationContext = false
        if #available(iOS 11.0, *) {
            navigationItem.searchController = nil
        }
    }

    func setupTable() {
        if #available(iOS 11.0, *) {
            tableView = UITableView(frame: .zero, style: .grouped)
            tableView.tableFooterView = UIView()
        } else {
            tableView = UITableView(frame: .zero, style: .plain)
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0.5))
            footerView.backgroundColor = tableView.separatorColor
            tableView.tableFooterView = footerView
        }
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: reuseHeaderIdentifier)
        tableView.estimatedRowHeight = Theme.Cell.smallHeight
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(T.self, forCellReuseIdentifier: reuseIdentifier)
    }

    func scrollToSelectedRow() {
        var selectedItemIndex: Int?

        for index in items.indices {
            if shouldMarkCellAction?(retrieveItems()[index]) ?? false {
                selectedItemIndex = index
                break
            }
        }

        guard let indexToScrollTo = selectedItemIndex, indexToScrollTo < items.count else {
            return
        }

        DispatchQueue.main.async {
            self.tableView.scrollToRow(at: IndexPath(row: indexToScrollTo, section: 0), at: .middle, animated: false)
        }
    }
}
