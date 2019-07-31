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

/// Helper protocol with default implementation to handle
/// Accessibility content size category
public protocol ContentSizeCategoryAdjustable {
    /// Keeps token of subscription to UIContentSizeCategory.didChangeNotification
    /// Conforming class should call `setupWith(_:)` in `viewWillAppear(_:)`,
    /// keep `subscriptionToken` and call
    /// `NotificationCenter.default.removeObserver(subscriptionToken!)`
    /// in `viewWillDisappear(_:)`
    var subscriptionToken: Any? { get set }

    /// Indicates if current preferred content size category belongs to large or not
    var isLargeSizeCategory: Bool { get }

    /// Returns default height of cell, that is being used in
    /// `rowHeightConsideringSizeCategory(for _:)`
    /// Should be overriden for single cell type
    /// Should not be overridden in case of multiple cells with different heights, as in this case
    /// conforming class should override implementation
    /// of `rowHeightConsideringSizeCategory(for _:)` and deal with appropriate cells heights there
    var defaultCellHeight: CGFloat { get }

    /// Subscribes to listen for UIContentSizeCategory.didChangeNotification and call
    /// `reloadData()` of given UITableView upon notification arrival
    ///
    /// - Parameters:
    ///   - tableView: UITableView to update
    /// - Returns: token of subscription observer
    func setupWith(tableView: UITableView) -> Any?

    /// Returns row height for given indexPath taking into account current
    /// content size category.
    /// For single cell type returns `UITableView.automaticDimesion` for large content size
    /// and `defaultCellHeight` for regular.
    /// For multiple cell types should handle appropriate cell type basing on `indexPath`
    func rowHeightConsideringSizeCategory(for indexPath: IndexPath) -> CGFloat
}

// MARK: - Default implementation

/// Default implementation for ContentSizeCategoryAdjustable protocol
public extension ContentSizeCategoryAdjustable {
    /// Indicates if current preferred content size category belongs to large or not
    var isLargeSizeCategory: Bool {
        return Self.largeSizes.contains(UIApplication.shared.preferredContentSizeCategory)
    }

    /// Returns default height of cell, that is being used in
    /// `rowHeightConsideringSizeCategory(for _:)`
    /// Should be overriden for single cell type
    /// Should not be overridden in case of multiple cells with different heights, as in this case
    /// conforming class should override implementation
    /// of `rowHeightConsideringSizeCategory(for _:)` and deal with appropriate cells heights there
    var defaultCellHeight: CGFloat {
        return UITableView.automaticDimension
    }

    /// Subscribes to listen for UIContentSizeCategory.didChangeNotification and call
    /// `reloadData()` of given UITableView upon notification arrival
    ///
    /// - Parameters:
    ///   - tableView: UITableView to update
    /// - Returns: token of subscription observer
    func setupWith(tableView: UITableView) -> Any? {
        tableView.reloadData()

        return NotificationCenter.default.addObserver(forName: UIContentSizeCategory.didChangeNotification,
                                                      object: nil,
                                                      queue: nil,
                                                      using: { [weak tableView] _ in
                                                        tableView?.reloadData()
        })
    }

    /// Returns row height for given indexPath taking into account current
    /// content size category.
    /// For single cell type returns `UITableView.automaticDimesion` for large content size
    /// and `defaultCellHeight` for regular.
    /// For multiple cell types should handle appropriate cell type basing on `indexPath`
    func rowHeightConsideringSizeCategory(for indexPath: IndexPath) -> CGFloat {
        if isLargeSizeCategory {
            return UITableView.automaticDimension
        } else {
            return defaultCellHeight
        }
    }

    private static var largeSizes: [UIContentSizeCategory] {
        return [
            .accessibilityExtraExtraExtraLarge,
            .accessibilityExtraExtraLarge,
            .accessibilityExtraLarge,
            .accessibilityLarge,
            .accessibilityMedium,
            .extraExtraExtraLarge,
            .extraExtraLarge,
            .extraLarge
        ]
    }
}
