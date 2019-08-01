import Hippolyte
import HyperwalletSDK
import XCTest

class UserRepositoryRequestHelper {
    private static let userIndividualResponseFileName = "UserIndividualResponse"
    private static let failureResponseFile = "UnexpectedErrorResponse"
    private static let requestUrl = HyperwalletTestHelper.userRestURL

    static func setupSucessRequest() {
        let dataResponse = HyperwalletTestHelper.okHTTPResponse(for: userIndividualResponseFileName)
        UserRepositoryRequestHelper.setUpMockServer(dataResponse, requestUrl)
    }

    static func setupFailureRequest() {
        let errorResponse = HyperwalletTestHelper.badRequestHTTPResponse(for: failureResponseFile)
        UserRepositoryRequestHelper.setUpMockServer(errorResponse, requestUrl)
    }

    static func getResponseError(_ error: HyperwalletErrorType) -> HyperwalletError {
        return (error.getHyperwalletErrors()?.errorList?.first)!
    }

    private static func setUpMockServer(_ dataResponse: StubResponse, _ requestUrl: String) {
        let dataRequest = HyperwalletTestHelper.buildGetRequest(baseUrl: requestUrl, dataResponse)
        HyperwalletTestHelper.setUpMockServer(request: dataRequest)
    }
}
