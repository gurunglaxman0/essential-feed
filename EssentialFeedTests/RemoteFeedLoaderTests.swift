//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Lakshman Gurung on 12/12/23.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTestes: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestsDataFromURL() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0)}
        
        let clientError = NSError(domain: "an error", code: 0)
        client.complete(with: clientError)

        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
       
        samples.enumerated().forEach { index, code in
            var capturedErrors = [RemoteFeedLoader.Error]()
            sut.load { capturedErrors.append($0)}
            
            client.complete(withStatusCode: code, at: index)
            XCTAssertEqual(capturedErrors, [.invalidData])
            capturedErrors = []
        }
    }

    // MARK: Helpers

    private func makeSUT(
        url: URL = URL(string: "http://a-given-url.com")!
    ) -> (sut: RemoteFeedLoader, client: HTTPCLientSpy) {
        let client = HTTPCLientSpy()
        return  (RemoteFeedLoader(url: url, client: client), client)
    }

    private class HTTPCLientSpy: HTTPClient {
        var requestedURLs: [URL] {
            messages.map {$0.url}
        }
        var messages = [(url: URL, completion: (HTTPURLResponse?, Error?) -> Void)]()

        func get(from url: URL, completion: @escaping (HTTPURLResponse?, Error?) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(nil, error)
        }
        
        func complete(withStatusCode code: Int, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )
            
            messages[index].completion(response, nil)
        }
    }

}
