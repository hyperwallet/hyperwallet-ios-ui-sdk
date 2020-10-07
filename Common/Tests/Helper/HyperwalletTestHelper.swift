import Hippolyte
import HyperwalletSDK
#if !COCOAPODS
import Common
#endif
import XCTest

class HyperwalletTestHelper {
    static let applicationJson = "application/json"
    static var programModel: HyperwalletProgramModel = .walletModel
    static var authenticationToken: String {
        return AuthenticationTokenGeneratorMock(hostName: "localhost",
                                                programModel: programModel).token
    }
    static var authenticationProvider: AuthenticationProviderMock {
        return AuthenticationProviderMock(authorizationData: authenticationToken)
    }

    static var authenticationProviderWithErrorResponse: AuthenticationProviderMock {
        return AuthenticationProviderMock(authorizationData: nil,
                                          error: HyperwalletAuthenticationErrorType
                                            .unexpected("authentication token cannot be retrieved."))
    }

    static let contentType = "Content-Type"
    static let graphQlURL = "https://localhost/graphql"
    static let restURL = "https://localhost/rest/v3/"
    static let userPath = "users/YourUserToken"
    static let userRestURL = "\(restURL)\(userPath)"

    // MARK: Build Requests
    static func buildPostRequest(baseUrl: String, _ response: StubResponse) -> StubRequest {
        return StubRequest.Builder()
            .stubRequest(withMethod: .POST, url: URL(string: baseUrl)!)
            .addHeader(withKey: contentType, value: applicationJson)
            .addResponse(response)
            .build()
    }

    static func buildGetRequest(baseUrl: String, _ response: StubResponse) -> StubRequest {
        return StubRequest.Builder()
            .stubRequest(withMethod: .GET, url: URL(string: baseUrl)!)
            .addHeader(withKey: contentType, value: applicationJson)
            .addResponse(response)
            .build()
    }

    static func buildGetRequestRegexMatcher(pattern: String, _ response: StubResponse) -> StubRequest {
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        return StubRequest.Builder()
            .stubRequest(withMethod: .GET, urlMatcher: RegexMatcher(regex: regex!))
            .addHeader(withKey: contentType, value: applicationJson)
            .addResponse(response)
            .build()
    }

    static func buildPutRequest(baseUrl: String, _ response: StubResponse) -> StubRequest {
        return StubRequest.Builder()
            .stubRequest(withMethod: .PUT, url: URL(string: baseUrl)!)
            .addHeader(withKey: contentType, value: applicationJson)
            .addResponse(response)
            .build()
    }

    // MARK: - StubResponses

    /// Builds the stub HTTP 200 - OK
    ///
    /// - Parameter for: The response file name will be loaded by `getDataFromJson(responseFileName)`
    /// - Returns: the StubResponse
    static func okHTTPResponse(for responseFileName: String) -> StubResponse {
        let data = HyperwalletTestHelper.getDataFromJson(responseFileName)
        return setUpMockedResponse(payload: data, httpCode: 200)
    }

    /// Builds the stub HTTP 204 - No Content
    ///
    /// - Returns: the StubResponse
    static func noContentHTTPResponse() -> StubResponse {
        return setUpMockedResponse(payload: Data(), httpCode: 204)
    }

    /// Builds the stub HTTP 400 - Bad Request
    ///
    /// - Parameter for: The response file name will be loaded by `getDataFromJson(responseFileName)`
    /// - Returns: the StubResponse
    static func badRequestHTTPResponse(for responseFileName: String) -> StubResponse {
         let data = HyperwalletTestHelper.getDataFromJson(responseFileName)
        return setUpMockedResponse(payload: data, httpCode: 400)
    }

    /// Builds the stub HTTP 500 - Unexpected Error
    ///
    /// - Parameter for: The response file name will be loaded by `getDataFromJson(responseFileName)`
    /// - Returns: the StubResponse
    static func unexpectedErrorHTTPResponse(for responseFileName: String) -> StubResponse {
        let data = HyperwalletTestHelper.getDataFromJson(responseFileName)
        return setUpMockedResponse(payload: data, httpCode: 500)
    }

    /// Receives data from JSON file
    ///
    /// - Parameter fileName: File Name
    /// - Returns: Data
    static func getDataFromJson(_ fileName: String) -> Data {
        let path = Bundle(for: self).path(forResource: fileName, ofType: "json")!
        return NSData(contentsOfFile: path)! as Data
    }

    static func setUpMockServer(request: StubRequest) {
        Hippolyte.shared.add(stubbedRequest: request)
        Hippolyte.shared.start()
    }

    static func setUpMockedResponse(payload: Data,
                                    error: NSError? = nil,
                                    httpCode: Int = 200,
                                    contentType: String = HyperwalletTestHelper.applicationJson) -> StubResponse {
        return responseBuilder(payload, httpCode, error)
            .addHeader(withKey: HyperwalletTestHelper.contentType, value: contentType)
            .build()
    }

    private static func responseBuilder(_ payload: Data,
                                        _ httpCode: Int,
                                        _ error: NSError? = nil) -> StubResponse.Builder {
        let stubResponseBuilder = StubResponse.Builder().defaultResponse()
        guard let error = error else {
            return stubResponseBuilder
                .stubResponse(withStatusCode: httpCode)
                .addBody(payload)
        }
        return stubResponseBuilder
            .stubResponse(withError: error)
    }
}
