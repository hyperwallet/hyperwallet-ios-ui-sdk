import Insights

public final class HyperwalletInsightsMock: HyperwalletInsightsProtocol {
    public var didTrackClick = false
    public var didTrackImpression = false
    public var didTrackError = false

    public init() { }

    public func trackClick(pageName: String, pageGroup: String, link: String, params: [String: String]) {
        didTrackClick = true
    }

    public func trackImpression(pageName: String, pageGroup: String, params: [String: String]) {
        didTrackImpression = true
    }

    public func trackError(pageName: String, pageGroup: String, errorInfo: ErrorInfo) {
        didTrackError = true
    }

    public func resetStates() {
        didTrackClick = false
        didTrackImpression = false
        didTrackError = false
    }
}
