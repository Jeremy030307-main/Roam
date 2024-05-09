//
//  PostComponentView.swift
//  Roam
//
//  Created by Jeremy Teng  on 26/04/2024.
//

import SwiftUI

struct PostProfileView: View {
        
    var user: User

    var body: some View {
        
        HStack {
            Image(.profilePiicture)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(Circle())
                .frame(width: 25)
            Text(user.username)
                .font(.subheadline)
            Spacer()
        }
    }
}

struct PostVoteView: View {
     
    @ObservedObject var voteManager: VoteManager

    init(voteItem: Votable) {
        self.voteManager = VoteManager(voteItem: voteItem)
    }
    
    var body: some View {
        
        HStack {
            Button(action: self.voteManager.upvote) {
                Image(systemName: voteManager.isUpvote() ? "arrowshape.up.fill":"arrowshape.up")
                    .foregroundStyle(.black)
            }
            Text("\(voteManager.voteCount())")
            Button(action: self.voteManager.downvote) {
                Image(systemName: voteManager.isDownvote() ? "arrowshape.down.fill":"arrowshape.down")
                    .foregroundStyle(.black)
            }
        }
    }
}

struct PostCommentView: View {
        
    @ObservedObject var postManager: PostManager

    var body: some View {
        
        HStack{
            Image(systemName: "message")
            Text("\(postManager.post.comment_count)")
        }
    }
}

