import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct UnexpectedValuesRepresentation: Error {}
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url ) { _ , _ , error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequest()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequest()
    }
    
    func test_getFromURL_performsGETRequestWithURK() {
        
        let url = anyURL()
        let exp = expectation(description: "Wait for completion")
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
    func test_getFromURL_failsOnRequestError() {
        let error = NSError(domain: "an error", code: 0)
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        
        let exp = expectation(description: "Wait for completion")
        makeSUT().get(from: anyURL()) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.domain, error.domain)
                XCTAssertEqual(receivedError.code, error.code)
            default:
                XCTFail("Expected failure with error \(error), got \(result) instead")
            }
            exp.fulfill()
        } 
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnAllNilValues(){
        URLProtocolStub.stub(data: nil, response: nil, error: nil)
        let exp = expectation(description: "Wait for completion")
        
        makeSUT().get(from: anyURL()) { result in
            switch result {
            case .failure:
               break
            default:
                XCTFail("Expected failure, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func anyURL() -> URL{
        URL(string: "http://any-url.com")!
    }
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error? = nil) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func startInterceptingRequest(){
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest(){
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
          return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            requestObserver?(request)
            return request
        }
        
        override func startLoading() {
            guard let stub = URLProtocolStub.stub else {return}
            if let data = stub.data  {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
