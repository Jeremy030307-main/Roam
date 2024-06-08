//
//  PostView.swift
//  Roam
//
//  Created by Jeremy Teng  on 27/04/2024.
//

import SwiftUI

struct PostVoteView: View {
     
    @ObservedObject var voteManager: VoteManager
    var parentPost: (any Postable)?

    init(voteItem: any Votable, parentPost: (any Postable)?) {
        self.voteManager = VoteManager(voteItem: voteItem, parentPost: parentPost)
    }
    
    init(voteItem: any Votable) {
        self.voteManager = VoteManager(voteItem: voteItem, parentPost: nil)
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
    
        ProfileHeader(image: Image(postManager.textPost!.authorImage ), username: postManager.textPost!.authorName )
            
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
    @State var showDetail = false
    
    init(postManager: PostManager) {
        self.postManager = postManager
    }
    
    var body: some View {
        
        Button{
            showDetail.toggle()
        } label: {
            
            SideImageCard(image: postManager.itineraryPost!.itinerary?.image ?? "", backgroundColor: Color(.white), textHeight: 80) {
                
                VStack(alignment: .leading) {
                    Text(postManager.itineraryPost!.itinerary?.title ?? "").font(.headline).lineLimit(1)
                    Text(postManager.itineraryPost!.itinerary?.destination ?? "").font(.subheadline)
                    
                    HStack(spacing: 15){
                        if postManager.itineraryPost!.itinerary?.pax != nil {
                            HStack{
                                Image(systemName: "person.fill").foregroundStyle(.accent)
                                Text("\(postManager.itineraryPost!.itinerary?.pax ?? 0 )").font(.footnote)
                            }
                        }
                        
                        HStack{
                            Image(systemName: "calendar").foregroundStyle(.accent)
                            Text("\(postManager.itineraryPost!.itinerary?.totalDays ?? 0)d").font(.footnote)
                        }
                        
                        if postManager.itineraryPost!.itinerary?.totalSpent != nil {
                            HStack{
                                Image(systemName: "dollarsign").foregroundStyle(.accent)
                                Text("\(postManager.itineraryPost!.itinerary?.totalSpent ?? 0)").font(.footnote)
                            }
                        }
                        
                    }
                }
                .padding(10)
                
                Spacer()
            }
        }.foregroundStyle(.primary)
        
        HStack(spacing: 20){
            ProfileHeader(image: Image(postManager.itineraryPost!.authorImage), username: postManager.itineraryPost!.authorName)
            
            Spacer()
            PostVoteView(voteItem: postManager.post)
            PostCommentView(postManager: postManager).padding(.trailing, 10)
        }
        .padding(.top, 2)
        .fullScreenCover(isPresented: $showDetail){
            if postManager.itineraryPost?.itinerary != nil {
                TripMainView(trip: postManager.itineraryPost!.itinerary!, editable: false)
            }
        }
    }
}

struct PostCard: View {
    
    @EnvironmentObject var userManager: UserManager
    @ObservedObject var postManager: PostManager
    @State var showDetail = false
    @State var copyTrip = false
    @State var startDate = Date()
    
    
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
                    .disabled(true)
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
                    Button{
                        userManager.addTripFromGuide(guideTrip: (postManager.itineraryPost?.itinerary)!, name: "Testign copy trip", startDate: startDate)
                    } label: {
                        Text("Copy Trip").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .sheet(isPresented: $copyTrip) {
            DatePicker(
                "Start Date",
                selection: $startDate,
                displayedComponents: [.date]
            )
        }
    }
}

#Preview("Guide") {
    PostCard(post: guide1)
}

#Preview("Post") {
    PostCard(post: post1)
}
