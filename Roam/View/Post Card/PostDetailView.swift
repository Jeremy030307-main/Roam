//
//  PostDetailView.swift
//  Roam
//
//  Created by Jeremy Teng  on 26/04/2024.
//

import SwiftUI

struct PostDetailView: View {
    
    @ObservedObject var postManager = PostManager(post: post1)
    
    var body: some View {
        ScrollView {
            VStack(alignment:.leading, spacing: 9) {
                
                PostProfileView(user: postManager.post.author)
                Text(postManager.post.title).padding(.top, 8)
                
                Text(postManager.post.content)
                    .font(.caption)
                
                HStack(spacing: 20) {
                    PostVoteView(voteItem: postManager.post)
                    PostCommentView(postManager: postManager)
                }
                Divider()
                
                Text("Comment").font(.headline)
                
                ForEach(postManager.post.comments){ comment in
                    CommentCardView(comment: comment)
                }
                
                Spacer()
            }
            .padding()
        }
        .background(Color(.secondarySystemFill))
    }
}

#Preview {
    PostDetailView()
}
