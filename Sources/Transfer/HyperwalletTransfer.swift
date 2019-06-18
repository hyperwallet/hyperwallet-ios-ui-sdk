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

// TODO remvoe this mocked model
struct HyperwalletTransfer {
    var sourceToken: String?
    var destinationToken: String?
    var clientTransferId: String?
    var sourceAmount: String?
    var destinationAmount: String?
    var destinationFeeAmount: String?
    var notes: String?
    var destinationCurrency: String?
    var foreignExchanges: [HyperwalletForeignExchange]?
    var token: String?

    init(sourceToken: String?,
         destinationToken: String?,
         clientTransferId: String?,
         sourceAmount: String?,
         destinationAmount: String?,
         destinationFeeAmount: String?,
         notes: String?,
         destinationCurrency: String?,
         foreignExchanges: [HyperwalletForeignExchange]?,
         token: String? = nil) {
        self.sourceToken = sourceToken
        self.destinationToken = destinationToken
        self.clientTransferId = clientTransferId
        self.sourceAmount = sourceAmount
        self.destinationAmount = destinationAmount
        self.destinationFeeAmount = destinationFeeAmount
        self.notes = notes
        self.destinationCurrency = destinationCurrency
        self.foreignExchanges = foreignExchanges
        self.token = token
    }
}

struct HyperwalletForeignExchange {
    var sourceAmount: String?
    var sourceCurrency: String?
    var destinationAmount: String?
    var destinationCurrency: String?
    var rate: String?
}
