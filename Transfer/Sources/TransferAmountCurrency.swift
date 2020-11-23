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

struct TransferAmountCurrencyData: Decodable {
    let data: [TransferAmountCurrency]
}

struct TransferAmountCurrency: Decodable {
    let baseUnit: String
    let currencyCode: String
    let decimals: Int
    let denominationAmount: Int
    let displayedAs: String?
    let exchangeable: Int
    let fxTransactionVisible: Int
    let governmentIssued: Int
    let groupingUsed: Int
    let hiddenDecimals: Int
    let identifier: Int
    let isoCurrencyCode: String
    let name: String
    let symbol: String

    enum CodingKeys: String, CodingKey {
        case baseUnit = "baseunit"
        case currencyCode = "currencycode"
        case denominationAmount = "denominationamount"
        case governmentIssued = "governmentissued"
        case identifier = "id"
        case isoCurrencyCode = "isocurrencycode"
        case decimals
        case displayedAs
        case exchangeable
        case fxTransactionVisible
        case groupingUsed
        case hiddenDecimals
        case name
        case symbol
    }
}
