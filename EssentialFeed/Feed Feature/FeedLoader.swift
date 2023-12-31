//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Lakshman Gurung on 12/12/23.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
