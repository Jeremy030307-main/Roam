//
//  PostManager.swift
//  Roam
//
//  Created by Jeremy Teng  on 25/04/2024.
//

import Foundation

enum VoteType {
    case upvote, downvote
}

class VoteManager: ObservableObject {
    
    var currentUser: User = user1
    @Published var voteItem: any Votable
    
    init(voteItem: any Votable) {
        self.voteItem = voteItem
    }
    
    func upvote(){
        
        // unvote if the user had upvote before
        if isUpvote(){
            unvote(voteType: .upvote)
        } else {
            
            // remove downvote before upvote
            if isDownvote(){
                unvote(voteType: .downvote)
            }
            voteItem.upvote.append(currentUser)
            voteItem.vote_count += 1
        }
    }
    
    func downvote(){
        // unvote if the user had downvote before
        if isDownvote(){
            unvote(voteType: .downvote)
        } else {
            
            // remove upvote before downvote
            if isUpvote(){
                unvote(voteType: .upvote)
            }
            voteItem.downvote.append(currentUser)
            voteItem.vote_count -= 1
        }
    }
    
    internal func unvote(voteType: VoteType){
        
        switch voteType {
            case .upvote:
                guard let removeIndex = voteItem.upvote.firstIndex(of: currentUser) else {
                    print("User not found")
                    return
                }
            voteItem.upvote.remove(at: removeIndex)
            voteItem.vote_count -= 1
                
            case .downvote:
                guard let removeIndex = voteItem.downvote.firstIndex(of: currentUser) else {
                    print("User not found")
                    return
                }
            voteItem.downvote.remove(at: removeIndex)
            voteItem.vote_count += 1
            }
    }
    
    func isUpvote() -> Bool{
        return voteItem.upvote.contains(currentUser)
    }
    
    func isDownvote() -> Bool{
        return voteItem.downvote.contains(currentUser)
    }
    
    func voteCount() -> Int {
        return voteItem.vote_count
    }
}

class PostManager: ObservableObject {
    
    var currentUser: User = user1
    var post: any Postable
    @Published var comment: String = ""
    @Published var textPost: Post?
    @Published var itineraryPost: Guide?
    
    init(post: any Postable) {
        self.post = post
        for comment in post1Comment {
            self.post.comments.append(comment)
            self.post.comment_count += 1
        }
        
        if let normalPost = post as? Post {
            textPost = normalPost
        } else if let itineraryPost = post as? Guide {
            self.itineraryPost = itineraryPost
        }
    }
    
    func addComment(){
        let newComment = Comment(user: currentUser, post: post, content: comment)
        post.comments.append(newComment)
        post.comment_count += 1
        comment = ""
    }
    
}

