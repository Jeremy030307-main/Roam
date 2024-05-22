//
//  PostView.swift
//  Roam
//
//  Created by Jeremy Teng  on 27/04/2024.
//

import SwiftUI

struct PostVoteView: View {
     
    @ObservedObject var voteManager: VoteManager

    init(voteItem: any Votable) {
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

struct TextPostView: View {
    
    @ObservedObject var postManager: PostManager
    
    init(postManager: PostManager) {
        self.postManager = postManager
    }
    
    var body: some View {
    
        ProfileHeader(image: Image(postManager.textPost!.author.image), username: postManager.textPost!.author.username)
        
        Text(postManager.textPost!.title).padding(.top, 8)
        
        Text(postManager.textPost!.content)
            .font(.caption)
            .lineLimit(3)
        
        HStack(spacing: 20){
            PostVoteView(voteItem: postManager.post)
            PostCommentView(postManager: postManager)
        }
        .padding(.top, 2)
    }
}

struct ItineraryPostView: View {
    
    @ObservedObject var postManager: PostManager
    
    init(postManager: PostManager) {
        self.postManager = postManager
    }
    
    var body: some View {
    
        SideImageCard(image: Image(postManager.itineraryPost!.itinerary.image), backgroundColor: Color(.white)) {
            
            VStack(alignment: .leading) {
                Text(postManager.itineraryPost!.itinerary.title).font(.headline).lineLimit(1)
                Text(postManager.itineraryPost!.itinerary.destination).font(.subheadline)
                
                HStack(spacing: 15){
                    if postManager.itineraryPost!.itinerary.pax != nil {
                        HStack{
                            Image(systemName: "person.fill").foregroundStyle(.accent)
                            Text("\(postManager.itineraryPost!.itinerary.pax ?? 0 )").font(.footnote)
                        }
                    }

                    HStack{
                        Image(systemName: "calendar").foregroundStyle(.accent)
                        Text("\(postManager.itineraryPost!.itinerary.totalDays)d").font(.footnote)
                    }
                    
                    if postManager.itineraryPost!.itinerary.totalSpent != nil {
                        HStack{
                            Image(systemName: "dollarsign").foregroundStyle(.accent)
                            Text("\(postManager.itineraryPost!.itinerary.totalSpent ?? 0)").font(.footnote)
                        }
                    }
                    
                }.padding(.top,5)
            }
            .padding(10)
            
            Spacer()
        }
        
        HStack(spacing: 20){
            ProfileHeader(image: Image(postManager.itineraryPost!.author.image), username: postManager.itineraryPost!.author.username)
            
            Spacer()
            PostVoteView(voteItem: postManager.post)
            PostCommentView(postManager: postManager).padding(.trailing, 10)
        }
        .padding(.top, 2)
    }
}

struct PostCard: View {
    
    @ObservedObject var postManager: PostManager
    @State var showDetail = false
    
    init(post: any Postable) {
        self.postManager = PostManager(post: post)
    }
    
    var body: some View {
    
        BlankCard(cardColor: Color(.secondarySystemFill)){
            
            if postManager.textPost != nil {
                TextPostView(postManager: postManager)
            }
            else if postManager.itineraryPost != nil {
                ItineraryPostView(postManager: postManager)
            }
        }
        .onTapGesture {
            showDetail.toggle()
        }
        
        .sheet(isPresented: $showDetail) {
            if postManager.textPost != nil {
                PostDetailView(postManager: postManager){
                    TextPostView(postManager: postManager)
                }
            }
            else if postManager.itineraryPost != nil {
                PostDetailView(postManager: postManager){
                    ItineraryPostView(postManager: postManager)
                }
            }
        }
    }
}

#Preview("Guide") {
    PostCard(post: guide1)
}

#Preview("Post") {
    PostCard(post: post1)
}
