import Foundation
import Swifter

enum HTTPMethod {
    case get
    case post
}

class HyperwalletMockWebServer {
    var server = HttpServer()
    let testBundle = Bundle(for: HyperwalletMockWebServer.self)

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
