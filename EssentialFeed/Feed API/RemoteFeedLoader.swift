//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Lakshman Gurung on 12/12/23.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPURLResponse?, Error?) -> Void)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load(completion: @escaping (Error) -> Void) {
        client.get(from: url) { response, error in
            if response != nil {
                completion(.invalidData)
            } else {
                completion(.connectivity)
            }
           
        }
    }
}
