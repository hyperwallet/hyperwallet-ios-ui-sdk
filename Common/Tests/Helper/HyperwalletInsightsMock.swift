import Common
import Insights

final class HyperwalletInsightsMock: HyperwalletInsightsProtocol {
    var didTrackClick = false
    var didTrackImpression = false
    var didTrackError = false

    init() { }

    func trackClick(pageName: String, pageGroup: String, link: String, params: [String: String]) {
        didTrackClick = true
    }

    func trackImpression(pageName: String, pageGroup: String, params: [String: String]) {
        didTrackImpression = true
    }

    func trackError(pageName: String, pageGroup: String, errorInfo: ErrorInfo) {
        didTrackError = true
    }

    func resetStates() {
        didTrackClick = false
        didTrackImpression = false
        didTrackError = false
    }
}
