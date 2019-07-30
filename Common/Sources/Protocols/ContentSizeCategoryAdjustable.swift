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

public protocol ContentSizeCategoryAdjustable: class {
    var subscriptionToken: Any? { get set }
    var isLargeSizeCategory: Bool { get }

    func setupWith(tableView: UITableView) -> Any?
    func rowHeightConsideringSizeCategory(for indexPath: IndexPath) -> CGFloat
}

/// Default implementation for ContentSizeCategoryAdjustable protocol
public extension ContentSizeCategoryAdjustable {
    /// Setups environment to listen for UIContentSizeCategory.didChangeNotification and configure
    /// given UITableView accordingly
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

    /// Indicates if current preferred content size category belongs to large or not
    var isLargeSizeCategory: Bool {
        return Self.largeSizes.contains(UIApplication.shared.preferredContentSizeCategory)
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
