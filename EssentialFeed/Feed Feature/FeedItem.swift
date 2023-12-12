//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Lakshman Gurung on 12/12/23.
//

import Foundation
public struct FeedItem: Equatable {
    let id: UUID
    let descripion: String?
    let locastion: String?
    let imageURL: URL
}
