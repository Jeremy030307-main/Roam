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
    
    private var firebaseController = FirebaseController.shared
    var currentUser: User = FirebaseController.shared.user
    @Published var voteItem: any Votable
    var parentPost: (any Postable)?
    var collectionName: String {
        if voteItem is Post{
            return "Post"
        } else if voteItem is Guide {
            return "Guide"
        } else {
            if let parent = parentPost {
                if parent is Post {
                    return "Post"
                } else {
                    return "Guide"
                }
            } else {
                return ""
            }
        }
    }
    
    init(voteItem: any Votable, parentPost: (any Postable)?) {
        self.voteItem = voteItem
        self.parentPost = parentPost
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
            
            if let parent = parentPost {
                firebaseController.addValueToArray(valuetoAdd: currentUser.id ?? "", collectionPath: "\(collectionName)/\(parent.id.uuidString)/Comment", documentPath: voteItem.id.uuidString, attributeName: "upvote")
            } else {
                // add the user_id into the upvote array
                firebaseController.addValueToArray(valuetoAdd: currentUser.id ?? "", collectionPath: collectionName, documentPath: voteItem.id.uuidString, attributeName: "upvote")
            }
            
            // update the vote_count
            voteItem.vote_count += 1
            self.updateVoteCount()
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
            
            if let parent = parentPost {
                firebaseController.addValueToArray(valuetoAdd: currentUser.id ?? "", collectionPath: "\(collectionName)/\(parent.id.uuidString)/Comment", documentPath: voteItem.id.uuidString, attributeName: "downvote")
            } else{
                // add the user_id into the downvote array
                firebaseController.addValueToArray(valuetoAdd: currentUser.id ?? "", collectionPath: collectionName, documentPath: voteItem.id.uuidString, attributeName: "downvote")
            }
            
            // update the vote_count
            voteItem.vote_count -= 1
            self.updateVoteCount()

        }
    }
    
    func unvote(voteType: VoteType){
        
        let attributeName: String
        switch voteType {
            case .upvote:
            
            attributeName = "upvote"
            voteItem.vote_count -= 1
                
            case .downvote:
            
            attributeName = "downvote"
            voteItem.vote_count += 1
            }
        
        Task{
            // firest remove the current user from upvote array
            if let parent = parentPost {
                await firebaseController.removeValueFromArray(valueToremove:currentUser.id ?? "", collectionPath:"\(collectionName)/\(parent.id.uuidString)/Comment", documentPath:voteItem.id.uuidString, attributeName:attributeName)
            } else {
                await firebaseController.removeValueFromArray(valueToremove: currentUser.id ?? "", collectionPath: collectionName, documentPath: voteItem.id.uuidString, attributeName: attributeName)
            }
        }
        self.updateVoteCount()

    }
    
    func isUpvote() -> Bool{
        return voteItem.upvote.contains(currentUser.id ?? "")
    }
    
    func isDownvote() -> Bool{
        return voteItem.downvote.contains(currentUser.id ?? "")
    }
    
    func voteCount() -> Int {
        return voteItem.vote_count
    }
    
    private func updateVoteCount(){
        if let parent = parentPost{
            firebaseController.updateField(object:voteItem.vote_count, collectionPath:"\(collectionName)/\(parent.id.uuidString)/Comment", documentPath:voteItem.id.uuidString, attributeName:"vote_count")
        } else {
            firebaseController.updateField(object: voteItem.vote_count, collectionPath: collectionName, documentPath: voteItem.id.uuidString, attributeName: "vote_count")
        }
    }
}

class PostManager: ObservableObject {
    
    private var firebaseController = FirebaseController.shared
    private var currentUser: User = FirebaseController.shared.user
    var post: any Postable
    @Published var comment: String = ""
    @Published var textPost: Post?
    @Published var itineraryPost: Guide?
    var collectionName: String = ""
    
    init(post: any Postable) {
        self.post = post
        
        if let normalPost = post as? Post {
            textPost = normalPost
            collectionName = "Post"
        } else if let itineraryPost = post as? Guide {
            self.itineraryPost = itineraryPost
            collectionName = "Guide"
        }
    }
    
    func addComment(){
        let newComment = Comment(authorID: currentUser.id ?? "", authorName: currentUser.name ?? "", authorImage: currentUser.image ?? "", content: comment)
        
        // first create a new comment document inside the subcollection of this particular post
        if let documentPath = firebaseController.addDocument(itemToAdd: newComment, collectionPath: "\(collectionName)/\(post.id.uuidString)/Comment", documentPath: newComment.id.uuidString){
            
            // if sucessfully add, add the reference into the post
            firebaseController.addReferenceToArray(referenceToAdd: documentPath, collectionPath: collectionName, documentPath: post.id.uuidString, attributeName: "comments")
            
            // and update the comment count
            post.comment_count += 1
            firebaseController.updateField(object: post.comment_count, collectionPath: collectionName, documentPath: post.id.uuidString, attributeName: "comment_count")
            comment = ""
        }
    }
    
}

