import Hippolyte
import HyperwalletSDK
import XCTest

class PrepaidCardRepositoryRequestHelper {
    static let clientSourceToken = "trm-123456789"
    private static let successResponseFile = "GetPrepaidCardSuccessResponse"
    private static let failureResponseFile = "UnexpectedErrorResponse"
    private static let requestUrl = "\(HyperwalletTestHelper.userRestURL)/prepaid-cards/\(clientSourceToken)"

    static func setupSuccessRequest() {
        let dataResponse = HyperwalletTestHelper.okHTTPResponse(for: successResponseFile)
        PrepaidCardRepositoryRequestHelper.setUpMockServer(dataResponse, requestUrl)
    }

    static func setupNoContentRequest() {
        let dataResponse = HyperwalletTestHelper.noContentHTTPResponse()
        PrepaidCardRepositoryRequestHelper.setUpMockServer(dataResponse, requestUrl)
    }

    static func setupFailureRequest() {
        let errorResponse = HyperwalletTestHelper.badRequestHTTPResponse(for: failureResponseFile)
        PrepaidCardRepositoryRequestHelper.setUpMockServer(errorResponse, requestUrl)
    }

    static func getResponseError(_ error: HyperwalletErrorType) -> HyperwalletError {
        return (error.getHyperwalletErrors()?.errorList?.first)!
    }

    private static func setUpMockServer(_ dataResponse: StubResponse, _ requestUrl: String) {
        let dataRequest = HyperwalletTestHelper.buildGetRequestRegexMatcher(pattern: requestUrl, dataResponse)
        HyperwalletTestHelper.setUpMockServer(request: dataRequest)
    }
}
