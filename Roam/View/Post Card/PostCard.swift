//
//  PostView.swift
//  Roam
//
//  Created by Jeremy Teng  on 27/04/2024.
//

import SwiftUI

struct PostView: View {
    
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

struct TextPostView: View {
    
    @ObservedObject var postManager: PostManager
    
    init(postManager: PostManager) {
        self.postManager = postManager
    }
    
    var body: some View {
    
        PostProfileView(user: postManager.textPost!.author)
        
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
            PostProfileView(user: postManager.itineraryPost!.author)
            
            Spacer()
            PostVoteView(voteItem: postManager.post)
            PostCommentView(postManager: postManager).padding(.trailing, 10)
        }
        .padding(.top, 2)
    }
}


#Preview {
    PostView(post: guide1)
}
