import Foundation
import Swifter

enum HTTPMethod {
    case get
    case post
    case put
}

final class HyperwalletMockWebServer {
    private var server: HttpServer!
    let testBundle = Bundle(for: HyperwalletMockWebServer.self)

    func setUp() {
        server = HttpServer()
        do {
            try server.start()
        } catch {
            print("Error info: \(error)")
        }
    }

    func tearDown() {
        if server.operating {
            server.stop()
        }
        server = nil
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

            if method == .get {
                server.GET[url] = response
            } else if method == .put {
                server.PUT[url] = response
            } else {
                server.POST[url] = response
            }
        } catch {
            print("Error info: \(error)")
        }
    }

    func setupStubError(url: String,
                        filename: String,
                        method: HTTPMethod,
                        statusCode: Int = 400) {
        let filePath = testBundle.path(forResource: filename, ofType: "json")
        let fileUrl = URL(fileURLWithPath: filePath!)
        do {
            let data = try Data(contentsOf: fileUrl, options: .uncached)
            let reasonPhrase = "Bad Request"
            let headers = ["Content-Type": "application/json"]

            let response: ((HttpRequest) -> HttpResponse) = { _ in
                HttpResponse.raw(statusCode, reasonPhrase, headers, { writer in
                    try writer.write(data)
                })
            }

            if method == .get {
                server.GET[url] = response
            } else if method == .put {
                server.PUT[url] = response
            } else {
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
    func setupStubEmpty(url: String, statusCode: Int, method: HTTPMethod) {
        let headers = ["Content-Type": "application/json"]

        let response: ((HttpRequest) -> HttpResponse) = { _ in
            HttpResponse.raw(statusCode, "Empty", headers, nil)
        }

        if method == .get {
            server.GET[url] = response
        } else if method == .put {
            server.PUT[url] = response
        } else {
            server.POST[url] = response
        }
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
