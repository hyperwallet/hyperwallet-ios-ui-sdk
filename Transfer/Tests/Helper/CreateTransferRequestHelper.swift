import Hippolyte
import HyperwalletSDK
import XCTest

class CreateTransferRequestHelper {
    private static let fileName = "CreateTransferResponse"
    private static let failureResponseFile = "UnexpectedErrorResponse"
    private static let requestUrl = "\(HyperwalletTestHelper.restURL)transfers"

    static func setupSucessRequest() {
        let dataResponse = HyperwalletTestHelper.okHTTPResponse(for: fileName)
        CreateTransferRequestHelper.setUpMockServer(dataResponse, requestUrl)
    }

    static func setupNoContentRequest() {
        let dataResponse = HyperwalletTestHelper.noContentHTTPResponse()
        CreateTransferRequestHelper.setUpMockServer(dataResponse, requestUrl)
    }

    static func setupFailureRequest() {
        let errorResponse = HyperwalletTestHelper.badRequestHTTPResponse(for: failureResponseFile)
        CreateTransferRequestHelper.setUpMockServer(errorResponse, requestUrl)
    }

    static func getResponseError(_ error: HyperwalletErrorType) -> HyperwalletError {
        return (error.getHyperwalletErrors()?.errorList?.first)!
    }

    private static func setUpMockServer(_ dataResponse: StubResponse, _ requestUrl: String) {
        let dataRequest = HyperwalletTestHelper.buildPostRequest(baseUrl: requestUrl, dataResponse)
        HyperwalletTestHelper.setUpMockServer(request: dataRequest)
    }
}
