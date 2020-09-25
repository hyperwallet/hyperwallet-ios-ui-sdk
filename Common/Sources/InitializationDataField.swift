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
/// Representation of Initialization DataField
public enum InitializationDataField: String {
    /// The 2 letter ISO 3166-1 country code.
    case country
    /// The 3 letter ISO 4217-1 currency code.
    case currency
    /// The profile type. Possible values - INDIVIDUAL, BUSINESS.
    case profileType
    /// The transfer method type. Possible values - BANK_ACCOUNT, BANK_CARD.
    case transferMethodTypeCode
    /// Forces to refresh the cached data.
    case forceUpdateData
    /// The receipt
    case receipt
    /// The client TransferId
    case clientTransferId
    /// The prepaid token
    case prepaidCardToken
    /// The source token
    case sourceToken
    /// The transfer
    case transfer
    /// The transfer method like bank account, bank card, PayPal account, prepaid card, paper check
    case transferMethod
    /// Boolean value to check whether foreign exchange rate changed
    case didFxQuoteChange
    /// Boolean value to check whether to show all the available sources for receipts/ transfers
    case showAllAvailableSources
    /// Prepaid Card Tokens
    case prepaidCardTokens
}
