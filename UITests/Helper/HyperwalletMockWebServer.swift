import Foundation
import Swifter

enum HTTPMethod {
    case get
    case post
}

class HyperwalletMockWebServer {
    var server = HttpServer()

    func setUp() {
        do {
            try server.start()
        } catch {
            print("Error info: \(error)")
        }
    }

    func tearDown() {
        server.stop()
    }

    func setupStub(url: String, filename: String, method: HTTPMethod) {
        let testBundle = Bundle(for: type(of: self))
        let filePath = testBundle.path(forResource: filename, ofType: "json")
        let fileUrl = URL(fileURLWithPath: filePath!)
        do {
            let data = try Data(contentsOf: fileUrl, options: .uncached)
            let json = dataToJSON(data: data)
            let response: ((HttpRequest) -> HttpResponse) = { _ in
                HttpResponse.ok(.json(json as AnyObject))
            }

            switch method {
            case HTTPMethod.get :
                server.GET[url] = response

            case HTTPMethod.post:
                server.POST[url] = response
            }
        } catch {
            print("Error info: \(error)")
        }
    }

    func setupStubError(url: String, filename: String, method: HTTPMethod) {
        let testBundle = Bundle(for: type(of: self))
        let filePath = testBundle.path(forResource: filename, ofType: "json")
        let fileUrl = URL(fileURLWithPath: filePath!)
        do {
            let data = try Data(contentsOf: fileUrl, options: .uncached)

            let statusCode = 400
            let reasonPhrase = "Bad Request"
            let headers = ["Content-Type": "application/json"]

            let response: ((HttpRequest) -> HttpResponse) = { _ in
                HttpResponse.raw(statusCode, reasonPhrase, headers, { writer in
                    try writer.write(data)
                })
            }

            switch method {
            case HTTPMethod.get :
                server.GET[url] = response

            case HTTPMethod.post:
                server.POST[url] = response
            }
        } catch {
            print("Error info: \(error)")
        }
    }

    func setupGraphQLStubs() {
        let testBundle = Bundle(for: type(of: self))

        let filePathKeys = testBundle.path(forResource: "TransferMethodConfigurationKeysResponse", ofType: "json")
        let filePathBankField = testBundle.path(forResource: "TransferMethodConfigurationBankAccountResponse",
                                                ofType: "json")
        let filePathCardField = testBundle.path(forResource: "TransferMethodConfigurationBankCardResponse",
                                                ofType: "json")

        let fileUrlKeys = URL(fileURLWithPath: filePathKeys!)
        let fileUrlBankField = URL(fileURLWithPath: filePathBankField!)
        let fileUrlCardField = URL(fileURLWithPath: filePathCardField!)

        do {
            let dataKeys = try Data(contentsOf: fileUrlKeys, options: .uncached)
            let dataBankField = try Data(contentsOf: fileUrlBankField, options: .uncached)
            let dataCardField = try Data(contentsOf: fileUrlCardField, options: .uncached)

            let jsonKeys = dataToJSON(data: dataKeys)
            let jsonBankField = dataToJSON(data: dataBankField)
            let jsonCardField = dataToJSON(data: dataCardField)

            server.POST["/graphql"] = { request in
                let requestBody = String(bytes: request.body, encoding: .utf8)!
                if requestBody.contains("fields") {
                    if requestBody.contains("BANK_CARD") {
                        // Update this when correct details are there
                        return HttpResponse.ok(.json(jsonCardField as AnyObject))
                    } else {
                        return HttpResponse.ok(.json(jsonBankField as AnyObject))
                    }
                } else {
                    return HttpResponse.ok(.json(jsonKeys as AnyObject))
                }
            }
        } catch {
            print("Error info: \(error)")
        }
    }

    func setUpEmptyResponse(url: String) {
        let statusCode = 204
        let headers = ["Content-Type": "application/json"]

        let response: ((HttpRequest) -> HttpResponse) = { _ in
            HttpResponse.raw(statusCode, "Empty", headers, nil)
        }

        server.GET[url] = response
    }

    func dataToJSON(data: Data) -> Any? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        } catch {
            print("Error info: \(error)")
        }
        return nil
    }
}
