//
//  Post.swift
//  Roam
//
//  Created by Jeremy Teng  on 25/04/2024.
//

import Foundation

protocol Votable:Hashable, Codable{
    
    var id: UUID {get set}
    var vote_count: Int {get set}
    var upvote: [String] {get set}
    var downvote: [String] {get set}
}

protocol Postable: Votable, Codable {
    
    var id: UUID {get set}
    var authorID: String {get set}
    var authorName: String {get set}
    var authorImage: String {get set}
    var comments: [Comment] {get set}
    var comment_count: Int {get set}
}

struct Post: Postable, Identifiable, Codable{
    
    var id = UUID()
    var authorID: String
    var authorName: String
    var authorImage: String

    var title: String
    var content: String
    
    var upvote: [String] = []
    var downvote: [String] = []
    var vote_count: Int = 0
    
    var comments: [Comment] = []
    var comment_count: Int = 0
    
    var date_created: Date? = Date()
    
    enum CodingKeys: String, CodingKey {
        case id
        case authorID
        case authorName
        case authorImage
        case title
        case content
        case upvote
        case downvote
        case vote_count
        case comment_count
        case date_created
    }
}

struct Guide: Postable, Identifiable, Codable{
    
    var id = UUID()
    var authorID: String
    var authorName: String
    var authorImage: String

    var itinerary : Trip?
    
    var upvote: [String] = []
    var downvote: [String] = []
    var vote_count: Int = 0
    
    var comments: [Comment] = []
    var comment_count: Int = 0
    var date_created: Date? = Date()
    
    enum CodingKeys: String, CodingKey {
        case id
        case authorID
        case authorName
        case authorImage
//        case itinerary
        case upvote
        case downvote
        case vote_count
        case comment_count
        case date_created
    }
}

struct Comment: Identifiable, Votable, Codable{

    var id = UUID()
    var authorID: String
    var authorName: String
    var authorImage: String

    var content: String
    
    var upvote: [String] = []
    var downvote: [String] = []
    var vote_count: Int = 0
    var date_created: Date? = Date()

}
