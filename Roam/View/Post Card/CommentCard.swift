//
//  CommentCardView.swift
//  Roam
//
//  Created by Jeremy Teng  on 26/04/2024.
//

import SwiftUI

struct CommentCard: View {
    
    var comment: Comment
    var parentPost: (any Postable)?
    
    var body: some View {
        
        BlankCard(cardColor: Color(.white)) {
            ProfileHeader(image: Image(comment.authorImage), username: comment.authorName )
                        
            Text(comment.content)
                .font(.caption)
            
            HStack(spacing: 20){
                PostVoteView(voteItem: comment, parentPost: parentPost)
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
