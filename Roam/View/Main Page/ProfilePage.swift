//
//  ProfilePage.swift
//  Roam
//
//  Created by Jeremy Teng  on 27/04/2024.
//

import SwiftUI

struct ProfilePage: View {
    
    @EnvironmentObject var authViewModel: AuthenticationVM
    @EnvironmentObject var userManager: UserManager

    @State var tabSelection: ProfileTabItem = .post
    @State var addNewPost = false
    
    let presentationDetents: [PresentationDetent] = [.large, .medium, .fraction(0.3)]
    @State var currentPresentationDetent: PresentationDetent = .fraction(0.3)
    
    var body: some View {
        VStack{
            HStack{
                Text("Profile").font(.title).bold()
                Spacer()
                Button{
                    authViewModel.signOut()
                } label: {
                    Text("Log Out")
                }
            }
            .padding(.horizontal)
            
            VStack {
                ProfileCard(user: userManager.user)
                ProfilePageTopNavBar(tabSelection: $tabSelection, addNewPost: $addNewPost)
                
                ScrollView{
                    switch tabSelection {
                    case .post:
                        ForEach(userManager.user.posts){ post in
                            PostCard(post: post)
                        }
                    case .guide:
                        ForEach(userManager.user.guides) { guide in
                            PostCard(post: guide)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $addNewPost){
            AddPostView()
        }
    }
}

#Preview {
    ProfilePage()
        .environmentObject(AuthenticationVM())
        .environmentObject(UserManager(user: FirebaseController.shared.user))
}
