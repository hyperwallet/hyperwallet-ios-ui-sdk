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

/// Transfer method configuration repository protocol
public protocol TransferMethodConfigurationRepository {
    ///  Gets the transfer method fields based on the parameters
    ///
    /// - Parameters:
    ///   - country: the 2 letter ISO 3166-1 country code
    ///   - currency: the 3 letter ISO 4217-1 currency code
    ///   - transferMethodType: the `TransferMethodType`
    ///   - transferMethodProfileType:`INDIVIDUAL` or `BUSINESS`
    ///   - completion: the callback handler of responses from the Hyperwallet platform
    func getFields(
        _ country: String,
        _ currency: String,
        _ transferMethodType: String,
        _ transferMethodProfileType: String,
        completion: @escaping (Result<HyperwalletTransferMethodConfigurationField?, HyperwalletErrorType>) -> Void)

    /// Gets the transfer method configuration keys
    ///
    /// - Parameter completion: the callback handler of responses from the Hyperwallet platform
    func getKeys(
        completion: @escaping (Result<HyperwalletTransferMethodConfigurationKey?, HyperwalletErrorType>) -> Void)

    /// Refreshes the transfer method fields
    func refreshFields()

    /// Refreshes the transfer method keys
    func refreshKeys()
}

// MARK: - RemoteTransferMethodConfigurationRepository
public final class RemoteTransferMethodConfigurationRepository: TransferMethodConfigurationRepository {
    private var transferMethodConfigurationFieldsCache =
        [HyperwalletTransferMethodConfigurationFieldQuery: HyperwalletTransferMethodConfigurationField]()
    private var transferMethodConfigurationKeys: HyperwalletTransferMethodConfigurationKey?

    public func getFields(
        _ country: String,
        _ currency: String,
        _ transferMethodType: String,
        _ transferMethodProfileType: String,
        completion: @escaping (Result<HyperwalletTransferMethodConfigurationField?, HyperwalletErrorType>) -> Void) {
        let fieldsQuery = HyperwalletTransferMethodConfigurationFieldQuery(
            country: country,
            currency: currency,
            transferMethodType: transferMethodType,
            profile: transferMethodProfileType
        )
        guard let transferMethodConfigurationFields = transferMethodConfigurationFieldsCache[fieldsQuery] else {
            Hyperwallet.shared
                .retrieveTransferMethodConfigurationFields(request: fieldsQuery,
                                                           completion: getFieldsHandler(fieldsQuery, completion))
            return
        }
        completion(.success(transferMethodConfigurationFields))
    }

    public func getKeys(
        completion: @escaping (Result<HyperwalletTransferMethodConfigurationKey?, HyperwalletErrorType>) -> Void) {
        guard let transferMethodConfigurationKeys = transferMethodConfigurationKeys else {
            Hyperwallet.shared
                .retrieveTransferMethodConfigurationKeys(request: HyperwalletTransferMethodConfigurationKeysQuery(),
                                                         completion: getKeysHandler(completion))
            return
        }
        completion(.success(transferMethodConfigurationKeys))
    }

    public func refreshFields() {
        transferMethodConfigurationFieldsCache =
            [HyperwalletTransferMethodConfigurationFieldQuery: HyperwalletTransferMethodConfigurationField]()
    }

    public func refreshKeys() {
        transferMethodConfigurationKeys = nil
    }

    private func getKeysHandler(
        _ completion: @escaping (Result<HyperwalletTransferMethodConfigurationKey?, HyperwalletErrorType>) -> Void)
        -> (HyperwalletTransferMethodConfigurationKey?, HyperwalletErrorType?) -> Void {
        return { [weak self] (result, error) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.transferMethodConfigurationKeys = RemoteTransferMethodConfigurationRepository
                .performCompletion(error, result, completion, strongSelf.transferMethodConfigurationKeys)
        }
    }

    private func getFieldsHandler(
        _ fieldQuery: HyperwalletTransferMethodConfigurationFieldQuery,
        _ completion: @escaping (Result<HyperwalletTransferMethodConfigurationField?, HyperwalletErrorType>) -> Void)
        -> (HyperwalletTransferMethodConfigurationField?, HyperwalletErrorType?) -> Void {
        return { [weak self] (result, error) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.transferMethodConfigurationFieldsCache[fieldQuery] = RemoteTransferMethodConfigurationRepository
                .performCompletion(error,
                                   result,
                                   completion,
                                   strongSelf.transferMethodConfigurationFieldsCache[fieldQuery])
        }
    }

    @discardableResult
    static func performCompletion<T>(_ error: HyperwalletErrorType?,
                                     _ result: T?,
                                     _ completionHandler: @escaping (Result<T?, HyperwalletErrorType>) -> Void,
                                     _ repositoryOriginalValue: T? = nil) -> T? {
        if let error = error {
            DispatchQueue.main.async {
                completionHandler(.failure(error))
            }
        } else {
            DispatchQueue.main.async {
                completionHandler(.success(result))
            }
            return result
        }

        return repositoryOriginalValue
    }
}
