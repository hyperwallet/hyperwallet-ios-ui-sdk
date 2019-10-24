// import Insights

public class HyperwalletInsights {
    private static var instance: HyperwalletInsights?

    /// Returns the previously initialized instance of the HyperwalletInsights interface object
    public static var shared: HyperwalletInsights {
        return instance ?? HyperwalletInsights()
    }

    /// Track Clicks
    ///
    /// - Parameters:
    ///   - pageName: Name of the page
    ///   - pageGroup: Page group name
    ///   - link: The link clicked - example : select-transfer-method
    ///   - params: A list of other information to be tracked - example : country,currency
    public func trackClick(pageName: String, pageGroup: String, link: String, params: [String: String]) {
    }

    /// Track Error
    ///
    /// - Parameters:
    ///   - pageName: Name of the page - example : transfer-method:add:select-transfer-method
    ///   - pageGroup: Page group name - example : transfer-method
    public func trackError(pageName: String, pageGroup: String) {
    }

    /// Track Impressions
    ///
    /// - Parameters:
    ///   - pageName: Name of the page - example : transfer-method:add:select-transfer-method
    ///   - pageGroup: Page group name - example : transfer-method
    ///   - link: The link clicked - example : select-transfer-method
    ///   - params: A list of other information to be tracked - example : country,currency
    public func trackImpression(pageName: String, pageGroup: String, params: [String: String]) {
    }

    private func initializeInsights(completion: @escaping(Bool) -> Void) {
    }
}
