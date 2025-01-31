//
// Copyright 2018 - Present Hyperwallet
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software
// and associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute,
// sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
// BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import HyperwalletSDK

public class IntegratorAuthenticationProvider: HyperwalletAuthenticationTokenProvider {
    private var url: String
    private let user: String = "userName"
    private let password: String = "password"
    private let session: URLSession

    init(_ baseUrl: String, _ userToken: String) {
        url = "\(baseUrl)/rest/v3/users/\(userToken)/authentication-token"
        self.session = IntegratorAuthenticationProvider.createUrlSession(username: user, password: password)
    }

    public func retrieveAuthenticationToken(completionHandler: @escaping 
        HyperwalletAuthenticationTokenProvider.CompletionHandler) {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"

        let task = session.dataTask(with: request) {(data, response, error) in
            guard let data = data, let response = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completionHandler(nil, HyperwalletAuthenticationErrorType.unexpected(error?.localizedDescription ??
                        "authentication token cannot be retrieved"))
                }
                return
            }

            switch response.statusCode {
            case 200 ..< 300:
                DispatchQueue.main.async {
                    completionHandler(IntegratorAuthenticationProvider.retrieveValue(from: data), nil)
                }

            default:
                DispatchQueue.main.async {
                    completionHandler(nil, HyperwalletAuthenticationErrorType
                        .unexpected("authentication token cannot be retrieved."))
                }
            }
        }

        task.resume()
    }

    private static func createUrlSession(username: String, password: String) -> URLSession {
        let applicationJson = "application/json"

        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 5.0 // 5 seconds
        configuration.timeoutIntervalForResource = 5.0 // 5 seconds
        configuration.httpAdditionalHeaders = [
            "Accept": applicationJson,
            "Content-Type": applicationJson,
            "Authorization": authorization(username, password)
        ]

        return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
    }

    private static func authorization(_ username: String, _ password: String) -> String {
        let credential = Data("\(username):\(password)".utf8).base64EncodedString()
        return "Basic \(credential)"
    }

    private static func retrieveValue(from clientToken: Data) -> String {
        do {
            guard let payload = try JSONSerialization.jsonObject(with: clientToken, options: []) as? [String: Any],
                let value = payload["value"] as? String else {
                    return ""
            }
            return value
        } catch {
            return ""
        }
    }
}
