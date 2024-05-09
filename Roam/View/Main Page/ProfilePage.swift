//
//  ProfilePage.swift
//  Roam
//
//  Created by Jeremy Teng  on 27/04/2024.
//

import SwiftUI

struct ProfilePage: View {
    
    var user = user10
    @State var tabSelection: ProfileTabItem = .post
    
    var body: some View {
        VStack{
            HStack{
                Text("Profile").font(.title).bold()
                Spacer()
            }
            .padding(.horizontal)
            
            VStack {
                ProfileCard(user: user)
                
                ProfilePageTopNavBar(tabSelection: $tabSelection)
                
                ScrollView{
                    switch tabSelection {
                    case .post:
                        ForEach(user.posts){ post in
                            PostCard(post: post)
                        }
                    case .guide:
                        ForEach(user.guides) { guide in
                            PostCard(post: guide)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ProfilePage()
}
