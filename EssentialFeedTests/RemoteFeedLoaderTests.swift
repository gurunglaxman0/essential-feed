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

        XCTAssertNil(client.requestedURL)
    }

    func test_load_requestDataFromURL() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load()

        XCTAssertEqual(client.requestedURL, url)
    }

    // MARK: Helpers

    private func makeSUT(
        url: URL = URL(string: "http://a-given-url.com")!
    ) -> (sut: RemoteFeedLoader, client: HTTPCLientSpy) {
        let client = HTTPCLientSpy()
        return  (RemoteFeedLoader(url: url, client: client), client)
    }

    private class HTTPCLientSpy: HTTPClient {
        var requestedURL: URL?

        func get(from url: URL) {
            requestedURL = url
        }
    }

}
