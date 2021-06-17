import Foundation

extension String {
    /// Format amount for currency code using users locale
    /// - Parameter currencyCode: currency code
    /// - Returns: a formatted amount string
    public func formatToCurrency(with currencyCode: String?) -> String {
        guard let currencyCode = currencyCode, !self.isEmpty
        else { return "0" }
        return TransferAmountCurrencyFormatter.formatCurrencyWithSymbol(self, with: currencyCode)
    }
}
