import Ambassador
import Embassy
import Foundation

enum HTTPMethod {
    case get
    case post
    case put
}

// swiftlint:disable force_try
final class HyperwalletMockWebServer {
    private var server: HTTPServer!
    private var router: Router! = Router()
    private var loop: EventLoop!
    private var thread: Thread!
    let testBundle = Bundle(for: HyperwalletMockWebServer.self)
    static let shared = HyperwalletMockWebServer(port: 8432)

    private init(port: Int) {
        loop = try! SelectorEventLoop(selector: try! KqueueSelector())
        router = Router()
        server = DefaultHTTPServer(eventLoop: loop, port: port, app: router.app)

        try! server.start()

        thread = Thread {
            self.loop.runForever()
        }
        thread.start()
    }
    
    func setupStub(url: String, filename: String, method: HTTPMethod, statusCode: Int = 200) {
        let filePath = testBundle.path(forResource: filename, ofType: "json")
        let fileUrl = URL(fileURLWithPath: filePath!)
        
        do {
            let data = try Data(contentsOf: fileUrl, options: .uncached)
            guard let json = dataToJSON(data: data)
            else { return }
            
            router[url] = JSONResponse(statusCode: statusCode) { _ -> Any in
                return json
            }
        } catch {
            print("Error info: \(error)")
        }
    }
    
    func setupStubError(url: String, filename: String, method: HTTPMethod, statusCode: Int = 400) {
        let filePath = testBundle.path(forResource: filename, ofType: "json")
        let fileUrl = URL(fileURLWithPath: filePath!)
        do {
            let data = try Data(contentsOf: fileUrl, options: .uncached)
            guard let json = dataToJSON(data: data)
            else { return }
            
            router[url] = JSONResponse(statusCode: statusCode) { _ -> Any in
                return json
            }
        } catch {
            print("Error info: \(error)")
        }
    }
    
    func setUpEmptyResponse(url: String) {
        router[url] = DataResponse(
            statusCode: 204,
            statusMessage: "No Content",
            contentType: "application/json",
            headers: []
        ) { _, sendData in
            sendData(Data())
        }
    }
    
    func setupStubEmpty(url: String, statusCode: Int, method: HTTPMethod) {
        router[url] = JSONResponse(statusCode: statusCode)
    }
    
    func shutDown() {
        server.stop()
        loop.stop()
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
// swiftlint:enable force_try
