//
//  Post.swift
//  Roam
//
//  Created by Jeremy Teng  on 25/04/2024.
//

import Foundation

protocol Votable:Hashable {
    
    var upvote: [User] {get set}
    var downvote: [User] {get set}
    var vote_count: Int {get set}
}

protocol Postable: Votable {
    
    var id: UUID {get set}
    var author: User {get set}
    var comments: [Comment] {get set}
    var comment_count: Int {get set}
}

struct Post: Postable, Identifiable{
    
    var id = UUID()
    var author: User
    var title: String
    var content: String
    
    var upvote: [User] = []
    var downvote: [User] = []
    var vote_count: Int = 0
    
    var comments: [Comment] = []
    var comment_count: Int = 0
}

struct Guide: Postable, Identifiable{
    
    var id = UUID()
    var author: User
    var itinerary : Trip
    
    var upvote: [User] = []
    var downvote: [User] = []
    var vote_count: Int = 0
    
    var comments: [Comment] = []
    var comment_count: Int = 0
}

struct Comment: Identifiable, Votable {

    var id = UUID()
    var user: User
    var post: any Postable
    var content: String
    
    var upvote: [User] = []
    var downvote: [User] = []
    var vote_count: Int = 0
    
    func hash(into myhasher: inout Hasher) {
            // Using id to uniquely identify each person.
            myhasher.combine(id)
        }
    
    static func == (lhs: Comment, rhs: Comment) -> Bool {
        return (lhs.id == rhs.id)
    }
}
