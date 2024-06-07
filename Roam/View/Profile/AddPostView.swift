//
//  AddPostView.swift
//  Roam
//
//  Created by Jeremy Teng  on 02/06/2024.
//

import SwiftUI

enum PostType {
    case post, guide
}

struct AddPostView: View {
    
    @EnvironmentObject var userManager: UserManager
    @State var postType:PostType?
    
    var body: some View {
        if postType == nil {
            ChoosePostType(postType: $postType)
                .presentationDetents([.fraction(0.3)])
        } else {
            switch postType {
            case .post:
                WritePostView()
                    .presentationDetents([.medium])
            case .guide:
                WriteGuideView()
                    .presentationDetents([.medium])
            case nil:
                Text("")
            }
        }
    }
}

struct ChoosePostType: View {
    
    @Binding var postType: PostType?
    
    var body: some View {
        
        VStack(alignment: .leading){
            Text("Choose a type").font(.title2).bold().padding(.bottom)
            HStack{
                Button{
                    postType = .guide
                } label: {
                    VStack{
                        TripCirceleIcon(image: Image(systemName: "safari.fill"), color: .accent, dimension: 25).padding(10)
                        Text("Guide").font(.headline)
                    }
                    .padding()
                    .background(
                        Capsule()
                            .foregroundStyle(.quinary)
                    )
                }
                
                Button{
                    postType = .post
                } label: {
                    VStack{
                        TripCirceleIcon(image: Image(systemName: "person.fill.questionmark"), color: .accent, dimension: 25).padding(10)
                        Text("Post").font(.headline)
                    }
                    .padding()
                    .background(
                        Capsule()
                            .foregroundStyle(.quinary)
                    )
                }
                
            }
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)

        }
        .padding()
    }
}

struct WritePostView : View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userManager: UserManager
    @State var title: String = ""
    @State var content: String = ""
    
    var body: some View {
        VStack(alignment: .leading){
            ProfileHeader(image: Image(userManager.user.image ?? "profilePiicture"), username: userManager.user.username ?? "Jeremy")
            
            VStack{
                TextField("Write a title for your question?", text: $title).font(.title2).bold()
                Divider()
                TextField("What's on your mind? ", text: $content, axis: .vertical)
            }.padding()
            
            Spacer()
            
            Button{
                userManager.addNewPost(title: title, content: content)
                dismiss()
            } label: {
                Text("Publish").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

        }
        .padding()
    }
}

struct WriteGuideView : View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userManager: UserManager
    @State var trip: Trip?
    
    var body: some View {
        VStack{
            if trip == nil{
                Text("Choose a Trip").font(.title2).bold().padding(.bottom)
                
                ForEach(Array(userManager.user.trips.enumerated()), id: \.1.id) {index, itinerary in
                    Button{
                        trip = itinerary
                    } label: {
                        SideImageCard(image: itinerary.image ?? "", backgroundColor: Color(.secondarySystemBackground), textHeight: 100) {
                            VStack(alignment: .leading) {
                                Text(itinerary.title ?? "").font(.headline)
                                Text(itinerary.destination ?? "").font(.subheadline)
                                
                                HStack {
                                    Spacer()
                                    if itinerary.startDate == nil {
                                        Text("\(itinerary.totalDays ?? 0)d").font(.footnote)
                                    }
                                    else{
                                        Text(itinerary.startDate!.formatted(.dateTime.day().month()) + " - " + itinerary.endDate!.formatted(.dateTime.day().month())).font(.footnote)
                                    }
                                }
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        .cornerRadius(20)
                        .shadow(radius: 2, y:3)
                    }
                    .foregroundStyle(.primary)
                }
            } else {
                let trip = trip!
                SideImageCard(image: trip.image ?? "", backgroundColor: Color(.secondarySystemBackground), textHeight: 80) {
                    
                    VStack(alignment: .leading) {
                        Text(trip.title ?? "").font(.headline).lineLimit(1)
                        Text(trip.destination ?? "").font(.subheadline)
                        
                        HStack(spacing: 15){
                            if trip.pax != nil {
                                HStack{
                                    Image(systemName: "person.fill").foregroundStyle(.accent)
                                    Text("\(trip.pax ?? 0 )").font(.footnote)
                                }
                            }

                            HStack{
                                Image(systemName: "calendar").foregroundStyle(.accent)
                                Text("\(trip.totalDays ?? 0)d").font(.footnote)
                            }
                            
                            if trip.totalSpent != nil {
                                HStack{
                                    Image(systemName: "dollarsign").foregroundStyle(.accent)
                                    Text("\(trip.totalSpent ?? 0)").font(.footnote)
                                }
                            }
                            
                        }.padding(.top,5)
                    }
                    .padding(10)
                    
                    Spacer()
                }
                
                Button{
                    userManager.addNewGuide(trip: trip)
                    dismiss()
                } label: {
                    Text("Publish").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)
            }
            Spacer()
        }.padding()
    }
}

#Preview("Write Guide") {
    WriteGuideView()
        .environmentObject(UserManager(user: FirebaseController.shared.user))
}

#Preview("Write Post") {
    WritePostView()
        .environmentObject(UserManager(user: FirebaseController.shared.user))
}

#Preview {
    ChoosePostType(postType: .constant(.post))
}

#Preview("Post Type") {
    AddPostView()
}
