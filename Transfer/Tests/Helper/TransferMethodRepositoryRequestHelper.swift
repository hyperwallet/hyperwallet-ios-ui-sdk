import Hippolyte
import HyperwalletSDK
import XCTest

class TransferMethodRepositoryRequestHelper {
    private static let successResponseFile = "ListTransferMethodSuccessResponse"
    private static let failureResponseFile = "UnexpectedErrorResponse"
    private static let requestUrl = "\(HyperwalletTestHelper.userRestURL)/transfer-methods"

    static func setupSuccessRequest() {
        let dataResponse = HyperwalletTestHelper.okHTTPResponse(for: successResponseFile)
        TransferMethodRepositoryRequestHelper.setUpMockServer(dataResponse, requestUrl)
    }

    static func setupNoContentRequest() {
        let dataResponse = HyperwalletTestHelper.noContentHTTPResponse()
        TransferMethodRepositoryRequestHelper.setUpMockServer(dataResponse, requestUrl)
    }

    static func setupFailureRequest() {
        let errorResponse = HyperwalletTestHelper.badRequestHTTPResponse(for: failureResponseFile)
        TransferMethodRepositoryRequestHelper.setUpMockServer(errorResponse, requestUrl)
    }

    static func getResponseError(_ error: HyperwalletErrorType) -> HyperwalletError {
        return (error.getHyperwalletErrors()?.errorList?.first)!
    }

    private static func setUpMockServer(_ dataResponse: StubResponse, _ requestUrl: String) {
        let dataRequest = HyperwalletTestHelper.buildGetRequestRegexMatcher(pattern: requestUrl, dataResponse)
        HyperwalletTestHelper.setUpMockServer(request: dataRequest)
    }
}
