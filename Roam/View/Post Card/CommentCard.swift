//
//  CommentCardView.swift
//  Roam
//
//  Created by Jeremy Teng  on 26/04/2024.
//

import SwiftUI

struct CommentCard: View {
    
    @State var comment: Comment

    
    var body: some View {
        
        BlankCard(cardColor: Color(.white)) {
            PostProfileView(user: comment.user)
                        
            Text(comment.content)
                .font(.caption)
            
            HStack(spacing: 20){
                PostVoteView(voteItem: comment)
            }
            .padding(.top, 2)
        }
    }
}

struct CommentCardView_Preview: PreviewProvider {

    static var previews: some View {
        CommentCard(comment: PostManager(post: post1).post.comments[0])
            .previewLayout(.sizeThatFits)
    }
}
