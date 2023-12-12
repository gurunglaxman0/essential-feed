//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Lakshman Gurung on 12/12/23.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.get(from: URL(string: "http://a-url.com")!)
    }
}

class HTTPClient {
    static var shared = HTTPClient()

    func get(from url: URL) {

    }

}

class HTTPCLientSpy: HTTPClient {
    var requestedURL: URL?

    override init() {

    }
    override func get(from url: URL) {
        requestedURL = url
    }
}

class RemoteFeedLoaderTestes: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPCLientSpy()

        HTTPClient.shared = client
        _ = RemoteFeedLoader()

        XCTAssertNil(client.requestedURL)
    }

    func test_load_requestDataFromURL() {
        let client = HTTPCLientSpy()
        HTTPClient.shared = client
        let sut = RemoteFeedLoader()

        sut.load()

        XCTAssertNotNil(client.requestedURL)
    }
}

//
