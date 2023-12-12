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
        
        expect(sut, toCompleteWith: .connectivity) {
            let clientError = NSError(domain: "an error", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
       
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .invalidData) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWihtInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .invalidData) {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
        
    }

    // MARK: Helpers

    private func makeSUT(
        url: URL = URL(string: "http://a-given-url.com")!
    ) -> (sut: RemoteFeedLoader, client: HTTPCLientSpy) {
        let client = HTTPCLientSpy()
        return  (RemoteFeedLoader(url: url, client: client), client)
    }

    private func expect(_ sut: RemoteFeedLoader, toCompleteWith error: RemoteFeedLoader.Error, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0)}
        
        action()
        
        XCTAssertEqual(capturedErrors, [error], file: file, line: line)
    }

    private class HTTPCLientSpy: HTTPClient {
        var requestedURLs: [URL] {
            messages.map {$0.url}
        }
        var messages = [(url: URL, completion: (HTTPCLientResult) -> Void)]()

        func get(from url: URL, completion: @escaping (HTTPCLientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(),  at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            
            messages[index].completion(.success(data, response))
        }
    }

}
