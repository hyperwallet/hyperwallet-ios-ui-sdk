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

import Foundation
import HyperwalletSDK
import Insights

// Protocol for HyperwalletInsights
public protocol HyperwalletInsightsProtocol: class {
    /// Track Clicks
    ///
    /// - Parameters:
    ///   - pageName: Name of the page
    ///   - pageGroup: Page group name
    ///   - link: The link clicked - example : select-transfer-method
    ///   - params: A list of other information to be tracked - example : country,currency
    func trackClick(pageName: String, pageGroup: String, link: String, params: [String: String])

    /// Track Impressions
    ///
    /// - Parameters:
    ///   - pageName: Name of the page - example : transfer-method:add:select-transfer-method
    ///   - pageGroup: Page group name - example : transfer-method
    ///   - params: A list of other information to be tracked - example : country,currency
    func trackImpression(pageName: String, pageGroup: String, params: [String: String])

    /// Track Error
    ///
    /// - Parameters:
    ///   - pageName: Name of the page - example : transfer-method:add:select-transfer-method
    ///   - pageGroup: Page group name - example : transfer-method
    ///   - errorInfo: The ErrorInfo structure is used to describe an occurred error
    func trackError(pageName: String, pageGroup: String, errorInfo: ErrorInfo)
}
/// Class responsible for initializing the Insights module.
/// It contains methods to call Insights for various actions performed by the user
public class HyperwalletInsights: HyperwalletInsightsProtocol {
    private static var instance: HyperwalletInsights?
    var insights: InsightsProtocol?

    /// Returns the previously initialized instance of the HyperwalletInsights interface object
    public static var shared: HyperwalletInsights {
        return instance ?? HyperwalletInsights()
    }

    private init() {
        loadConfigurationAndInitializeInsights()
    }

    /// Set up HyperwalletInsights
    public static func setup() {
        instance = HyperwalletInsights()
    }

    public func trackClick(pageName: String, pageGroup: String, link: String, params: [String: String]) {
        if let insights = insights {
            insights.trackClick(pageName: pageName, pageGroup: pageGroup, link: link, params: params)
        } else {
            loadConfigurationAndInitializeInsights()
            if let insights = insights {
                insights.trackClick(pageName: pageName, pageGroup: pageGroup, link: link, params: params)
            }
        }
    }

    public func trackError(pageName: String, pageGroup: String, errorInfo: ErrorInfo) {
        if let insights = insights {
            insights.trackError(pageName: pageName, pageGroup: pageGroup, errorInfo: errorInfo)
        } else {
            loadConfigurationAndInitializeInsights()
            if let insights = insights {
                insights.trackError(pageName: pageName, pageGroup: pageGroup, errorInfo: errorInfo)
            }
        }
    }

    public func trackImpression(pageName: String, pageGroup: String, params: [String: String]) {
        if let insights = insights {
            insights.trackImpression(pageName: pageName, pageGroup: pageGroup, params: params)
        } else {
            loadConfigurationAndInitializeInsights()
            if let insights = insights {
                insights.trackImpression(pageName: pageName, pageGroup: pageGroup, params: params)
            }
        }
    }

    private func loadConfigurationAndInitializeInsights() {
        loadConfiguration { configuration in
            if let configuration = configuration {
                self.initializeInsights(configuration: configuration)
            }
        }
    }

    /// Fetch configuration
    ///
    /// - Parameter completion: boolean completion handler
    private func loadConfiguration(completion: @escaping(Configuration?) -> Void) {
        // Fetch configuration again
        Hyperwallet.shared.getConfiguration { configuration, _ in
            if let configuration = configuration {
                completion(configuration)
            } else {
                completion(nil)
            }
        }
    }

    /// Initialize the Insights module if the url and environment variables are available
    private func initializeInsights(configuration: Configuration) {
         if let environment = configuration.environment,
            let insightsUrl = configuration.insightsUrl,
            let sdkVersion = HyperwalletBundle.currentSDKAppVersion {
            Insights.setup(environment: environment,
                           programToken: configuration.issuer,
                           sdkVersion: sdkVersion,
                           apiUrl: insightsUrl,
                           userToken: configuration.userToken)
            insights = Insights.shared
        }
    }
}

/// A helper class to build the `ErrorInfo` instance.
public class ErrorInfoBuilder {
    private let type: String
    private let message: String
    private var fieldName = ""
    private var description = Thread.callStackSymbols.joined(separator: "\n")
    private var code = ""

    /// Initializes ErrorInfoBuilder
    ///
    /// - Parameters:
    ///   - type: The Type of error that occurred.
    ///   - message: The Field Name is especially interesting when there is a validation error/issue in combination
    ///     with error_type = FORM
    public init(type: String, message: String) {
        self.type = type
        self.message = message
    }

    /// Sets FieldName
    ///
    /// - Parameter fieldName: The Field Name is especially interesting when there is a validation
    ///     error/issue in combination with error_type = FORM or when an API error occurs in relation
    ///     to a field, error_type = API
    /// - Returns: ErrorInfoBuilder
    public func fieldName(_ fieldName: String) -> ErrorInfoBuilder {
        self.fieldName = fieldName
        return self
    }

    /// Sets Code
    ///
    /// - Parameter code: The Error Code is the type of error that occurred
    /// - Returns: ErrorInfoBuilder
    public func code(_ code: String) -> ErrorInfoBuilder {
        self.code = code
        return self
    }

    /// Sets description
    ///
    /// - Parameter description: The Source of error that occurred. This allows to understand what caused the error.
    /// - Returns: ErrorInfoBuilder
    public func description(_ description: String) -> ErrorInfoBuilder {
        self.description = description
        return self
    }

    /// Builds a new instance of the `ErrorInfo`.
    ///
    /// - Returns: a new instance of the `ErrorInfo`.
    public func build() -> ErrorInfo {
        return ErrorInfo(type: type,
                         message: message,
                         fieldName: fieldName,
                         description: description,
                         code: code)
    }
}
