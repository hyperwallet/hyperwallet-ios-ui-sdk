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
import Insights
import UIKit

/// The class to handle UI errors
public final class ErrorView {
    private let errorTypeConnection = "CONNECTION"
    private let errorTypeException = "EXCEPTION"
    private weak var viewController: UIViewController!
    private var error: HyperwalletErrorType
    private var pageName: String
    private var pageGroup: String
    private let hyperwalletInsights: HyperwalletInsightsProtocol

    /// Initializer to initialize the class with errors to be displayed and the viewcontroller responsible
    /// to display the errors
    /// - Parameters:
    ///   - viewController: view controller that contains errors
    ///   - error: hyperwallet error
    ///   - pageName: The Page or screen that is currently visible
    ///   - pageGroup: The group of the Page or screen that is currently visible
    public init(viewController: UIViewController,
                hyperwalletInsights: HyperwalletInsightsProtocol,
                error: HyperwalletErrorType,
                pageName: String,
                pageGroup: String) {
        self.viewController = viewController
        self.error = error
        self.pageName = pageName
        self.pageGroup = pageGroup
        self.hyperwalletInsights = hyperwalletInsights
    }

    /// To show error messages
    ///
    /// - Parameter handler: handler to either remain on same UI page or go back to previous
    public func show(_ handler: (() -> Void)?) {
        switch error.group {
        case .business:
            businessError({ (_) in handler?() })

        case .connection:
            connectionError({ (_) in handler?() })

        default:
            unexpectedError()
        }
    }

    /// To handle business errors
    ///
    /// - Parameter handler: to handle business error
    private func businessError(_ handler: ((UIAlertAction) -> Void)? = nil) {
        HyperwalletUtilViews.showAlert(viewController,
                                       title: "error".localized(),
                                       message: error.getHyperwalletErrors()?.errorList?
                                                .filter { $0.fieldName == nil }
                                                .map { $0.message }
                                                .joined(separator: "\n"),
                                       actions: UIAlertAction.close(handler))
    }

    private func unexpectedError() {
      if !pageName.isEmpty, !pageGroup.isEmpty {
       let errorInfo = ErrorInfoBuilder(type: self.errorTypeException,
                                        message: error.getHyperwalletErrors()?.errorList?.first?.message ?? "")
                .fieldName(fieldName: "")
                .code(code: error.getHyperwalletErrors()?.errorList?.first?.code ?? "")
                .build()
        HyperwalletInsights.shared.trackError(pageName: pageName,
                                              pageGroup: pageGroup,
                                              errorInfo: errorInfo)

        HyperwalletUtilViews.showAlert(viewController,
                                       title: "unexpected_title".localized(),
                                       message: "unexpected_error_message".localized(),
                                       actions: UIAlertAction.close(viewController))
        }
    }

    private func connectionError(_ handler: @escaping (UIAlertAction) -> Void) {
        if !pageName.isEmpty, !pageGroup.isEmpty {
            let errorInfo = ErrorInfo(type: errorTypeConnection,
                                      message: self.error.errorDescription ?? "",
                                      fieldName: "",
                                      description: Thread.callStackSymbols.joined(separator: "\n"),
                                      code: self.error.getHyperwalletErrors()?.errorList?.first?.code ?? "")
            hyperwalletInsights.trackError(pageName: pageName,
                                           pageGroup: pageGroup,
                                           errorInfo: errorInfo)
        }
        HyperwalletUtilViews.showAlertWithRetry(viewController,
                                                title: "network_connection_error_title".localized(),
                                                message: "network_connection_error_message".localized(),
                                                handler)
    }
}
