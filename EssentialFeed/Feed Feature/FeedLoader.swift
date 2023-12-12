//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Lakshman Gurung on 12/12/23.
//

import Foundation

enum FeedLoaderResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (FeedLoaderResult) -> Void)
}
