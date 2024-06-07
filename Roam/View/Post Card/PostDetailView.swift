//
//  PostDetailView.swift
//  Roam
//
//  Created by Jeremy Teng  on 26/04/2024.
//

import SwiftUI

struct PostDetailView<Content: View> : View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var postManager: PostManager
    let content: Content
    
    init(postManager: PostManager, @ViewBuilder content: () -> Content) {
        self.postManager = postManager
        self.content = content()
    }

    var body: some View {
        VStack {
            HStack{
                Spacer()
                Text("Post").font(.headline)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "x.circle.fill")
                        .foregroundStyle(.black)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            ScrollView {
                VStack(alignment:.leading, spacing: 9) {
                    
                    content
                    
                    Divider()
                    
                    Text("Comment").font(.headline)
                    
                    ForEach(postManager.post.comments.reversed()){ comment in
                        CommentCard(comment: comment, parentPost: postManager.post)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            
            VStack {
                ZStack(alignment: .bottom) {
                    TextField("Write your comment", text: $postManager.comment, axis: .vertical)
                        .padding(.trailing, 25)
                        .padding(9)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(lineWidth: 1.0)
                                .foregroundStyle(Color(uiColor: .clear))
                                .background(Color.white.opacity(0.5)
                                    .clipShape(RoundedRectangle(cornerRadius: 25))
                                           )
                        )
                        .onSubmit {
                            postManager.addComment()
                        }
                    
                    HStack(alignment: .bottom) {
                        Spacer()
                        Button {
                            postManager.addComment()
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundColor(.accentColor)
                                .font(.title)
                                .padding(.trailing, 3)
                        }
                    }.padding(.bottom, 5)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .background(Color(.secondarySystemFill))
    }
}

