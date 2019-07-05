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

/// The transfer method configuration data maganager protocol
public protocol TransferMethodConfigurationDataManagerProtocol {
    /// Gets the list of countries
    ///
    /// - Returns: a list of HyperwalletCountry object
    func countries() -> [HyperwalletCountry]?

    /// Gets the list of currencies
    ///
    /// - Parameter countryCode: the 2 letter ISO 3166-1 country code
    /// - Returns: a list of HyperwalletCurrency object
    func currencies(_ countryCode: String) -> [HyperwalletCurrency]?

    /// Gets the list of transfer method types
    ///
    /// - Parameters:
    ///   - countryCode: the 2 letter ISO 3166-1 country code
    ///   - currencyCode: the 3 letter ISO 4217-1 currency code
    /// - Returns: a list of HyperwalletTransferMethodTypes
    func transferMethodTypes(_ countryCode: String, _ currencyCode: String) -> [HyperwalletTransferMethodType]?

    /// Gets the transfer method configuration keys
    ///
    /// - Parameter completion: the callback handler of responses from the Hyperwallet platform
    func getKeys(completion: @escaping (HyperwalletTransferMethodConfigurationKey?, HyperwalletErrorType?) -> Void)

    ///  Gets the transfer method fields based on the parameters
    ///
    /// - Parameters:
    ///   - country: the 2 letter ISO 3166-1 country code
    ///   - currency: the 3 letter ISO 4217-1 currency code
    ///   - transferMethodType: the `TransferMethodType`
    ///   - transferMethodProfileType:`INDIVIDUAL` or `BUSINESS`
    ///   - completion:
    func getFields(_ country: String,
                   _ currency: String,
                   _ transferMethodType: String,
                   _ transferMethodProfileType: String,
                   completion: @escaping (HyperwalletTransferMethodConfigurationField?, HyperwalletErrorType?) -> Void)

    /// Refreshes the transfer method keys
    func refreshKeys()

    /// Refreshes the transfer method fields
    func refreshFields()
}

/// The RepositoryFactory is singleton object to access the common repositories
public final class TransferMethodConfigurationDataManager: TransferMethodConfigurationDataManagerProtocol {
    private static var instance: TransferMethodConfigurationDataManager?
    private(set) var transferMethodConfigurationRepository: TransferMethodConfigurationRepository

    private var transferMethodConfigurationFieldsCache = [FieldMapKey: HyperwalletTransferMethodConfigurationField]()
    private var transferMethodConfigurationKeys: HyperwalletTransferMethodConfigurationKey?

    /// Returns the previously initialized instance of the RepositoryFactory object
    public static var shared: TransferMethodConfigurationDataManager {
        guard let instance = instance else {
            self.instance = TransferMethodConfigurationDataManager()
            return self.instance!
        }
        return instance
    }

    /// Clears the RepositoryFactory singleton instance.
    public static func clearInstance() {
        instance = nil
    }

    private init() {
        transferMethodConfigurationRepository = RemoteTransferMethodConfigurationRepository()
    }

    public func countries() -> [HyperwalletCountry]? {
        return transferMethodConfigurationKeys?.countries()
    }

    public func currencies(_ countryCode: String) -> [HyperwalletCurrency]? {
         return transferMethodConfigurationKeys?.currencies(from: countryCode)
    }

    public func transferMethodTypes(_ countryCode: String, _ currencyCode: String) -> [HyperwalletTransferMethodType]? {
        return transferMethodConfigurationKeys?.transferMethodTypes(countryCode: countryCode,
                                                                    currencyCode: currencyCode)
    }

    public func getKeys(completion: @escaping (HyperwalletTransferMethodConfigurationKey?,
                                               HyperwalletErrorType?) -> Void) {
        guard let transferMethodConfigurationKeys = transferMethodConfigurationKeys else {
            print("getKeys from Endpoint")
            transferMethodConfigurationRepository.getKeys(completion: getKeysHandler(completion))
            return
        }
        print("getKeys from cache")
        completion(transferMethodConfigurationKeys, nil)
    }

    public func getFields(_ country: String,
                          _ currency: String,
                          _ transferMethodType: String,
                          _ transferMethodProfileType: String,
                          completion: @escaping (HyperwalletTransferMethodConfigurationField?,
                                                 HyperwalletErrorType?) -> Void) {
        let fielMapKey = FieldMapKey(country: country,
                                     currency: currency,
                                     transferMethodType: transferMethodType,
                                     transferMethodProfileType: transferMethodProfileType)

        guard let transferMethodConfigurationFields = transferMethodConfigurationFieldsCache[fielMapKey] else {
            let fieldsQuery = HyperwalletTransferMethodConfigurationFieldQuery(
                country: country,
                currency: currency,
                transferMethodType: transferMethodType,
                profile: transferMethodProfileType
            )
            print("getFields from Endpoint")
            transferMethodConfigurationRepository.getFields(request: fieldsQuery,
                                                            completion: getFieldsHandler(fielMapKey, completion))
            return
        }

        print("getFields from cache")
        completion(transferMethodConfigurationFields, nil)
    }

    public func refreshKeys() {
        transferMethodConfigurationKeys = nil
    }

    public func refreshFields() {
        transferMethodConfigurationFieldsCache = [FieldMapKey: HyperwalletTransferMethodConfigurationField]()
    }

    private func getKeysHandler(_ completion: @escaping (HyperwalletTransferMethodConfigurationKey?,
        HyperwalletErrorType?) -> Void) -> (HyperwalletTransferMethodConfigurationKey?, HyperwalletErrorType?) -> Void {
            return { [weak self] (result, error) in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.transferMethodConfigurationKeys = strongSelf
                    .performCompletion(error, result, completion, strongSelf.transferMethodConfigurationKeys)
            }
    }

    private func getFieldsHandler(_ fieldMapKey: FieldMapKey,
                                  _ completion: @escaping (HyperwalletTransferMethodConfigurationField?,
                                                           HyperwalletErrorType?) -> Void)
        -> (HyperwalletTransferMethodConfigurationField?, HyperwalletErrorType?) -> Void {
            return { [weak self] (result, error) in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.transferMethodConfigurationFieldsCache[fieldMapKey] = strongSelf
                    .performCompletion(error,
                                       result,
                                       completion,
                                       strongSelf.transferMethodConfigurationFieldsCache[fieldMapKey])
            }
    }

    private func performCompletion<T>(_ error: HyperwalletErrorType?,
                                      _ result: T?,
                                      _ completionHandler: @escaping (T?, HyperwalletErrorType?) -> Void,
                                      _ repositoryOriginalValue: T?) -> T? {
        if let error = error {
            DispatchQueue.main.async {
                completionHandler(nil, error)
            }
        } else if let result = result {
            DispatchQueue.main.async {
                completionHandler(result, nil)
            }
            return result
        }

        return repositoryOriginalValue
    }
}
