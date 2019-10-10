import Hippolyte
import HyperwalletSDK
import XCTest

class CreateTransferRequestHelper {
    private static let fileName = "CreateTransferResponse"
    private static let unexpectedFailureResponseFile = "UnexpectedErrorResponse"
    private static let failureResponseWithFieldNameFile = "MultipleCurrenciesErrorResponse"
    private static let failureResponseWithoutFieldNameFile = "MultipleFXErrorResponse"

    private static let requestUrl = "\(HyperwalletTestHelper.restURL)transfers"

    static func setupSuccessRequest() {
        let dataResponse = HyperwalletTestHelper.okHTTPResponse(for: fileName)
        CreateTransferRequestHelper.setUpMockServer(dataResponse, requestUrl)
    }

    static func setupNoContentRequest() {
        let dataResponse = HyperwalletTestHelper.noContentHTTPResponse()
        CreateTransferRequestHelper.setUpMockServer(dataResponse, requestUrl)
    }

    static func setupFailureRequestWithFieldName() {
        let errorResponse = HyperwalletTestHelper.badRequestHTTPResponse(for: failureResponseWithFieldNameFile)
        CreateTransferRequestHelper.setUpMockServer(errorResponse, requestUrl)
    }

    static func setupFailureRequestWithoutFieldName() {
        let errorResponse = HyperwalletTestHelper.badRequestHTTPResponse(for: failureResponseWithoutFieldNameFile)
        CreateTransferRequestHelper.setUpMockServer(errorResponse, requestUrl)
    }

    static func setupUnexpectedFailureRequest() {
        let errorResponse = HyperwalletTestHelper.unexpectedErrorHTTPResponse(for: unexpectedFailureResponseFile)
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
