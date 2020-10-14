import Hippolyte
import HyperwalletSDK
import XCTest

class PrepaidCardRepositoryRequestHelper {
    static let clientSourceToken = "trm-123456789"
    private static let successResponseFile = "GetPrepaidCardSuccessResponse"
    private static let failureResponseFile = "UnexpectedErrorResponse"
    private static let requestUrl = "\(HyperwalletTestHelper.userRestURL)/prepaid-cards"

    static func setupSuccessRequest(responseFile: String, prepaidCardToken: String?) {
        let dataResponse = HyperwalletTestHelper.okHTTPResponse(for: responseFile)
        if let prepaidCardToken = prepaidCardToken {
            PrepaidCardRepositoryRequestHelper.setUpMockServer(dataResponse,
                                                               String(format: "%@/%@", requestUrl, prepaidCardToken))
        } else {
            PrepaidCardRepositoryRequestHelper.setUpMockServer(dataResponse, requestUrl)
        }
    }

    static func setupNoContentRequest(prepaidCardToken: String?) {
        let dataResponse = HyperwalletTestHelper.noContentHTTPResponse()
        if let prepaidCardToken = prepaidCardToken {
            PrepaidCardRepositoryRequestHelper.setUpMockServer(dataResponse,
                                                               String(format: "%@/%@", requestUrl, prepaidCardToken))
        } else {
            PrepaidCardRepositoryRequestHelper.setUpMockServer(dataResponse, requestUrl)
        }
    }

    static func setupFailureRequest(prepaidCardToken: String?) {
        let errorResponse = HyperwalletTestHelper.badRequestHTTPResponse(for: failureResponseFile)
        if let prepaidCardToken = prepaidCardToken {
            PrepaidCardRepositoryRequestHelper.setUpMockServer(errorResponse,
                                                               String(format: "%@/%@", requestUrl, prepaidCardToken))
        } else {
            PrepaidCardRepositoryRequestHelper.setUpMockServer(errorResponse, requestUrl)
        }
    }

    static func getResponseError(_ error: HyperwalletErrorType) -> HyperwalletError {
        return (error.getHyperwalletErrors()?.errorList?.first)!
    }

    private static func setUpMockServer(_ dataResponse: StubResponse, _ requestUrl: String) {
        let dataRequest = HyperwalletTestHelper.buildGetRequestRegexMatcher(pattern: requestUrl, dataResponse)
        HyperwalletTestHelper.setUpMockServer(request: dataRequest)
    }
}
