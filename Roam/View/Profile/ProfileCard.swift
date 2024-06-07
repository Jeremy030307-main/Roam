//
//  ProfileCard.swift
//  Roam
//
//  Created by Jeremy Teng  on 27/04/2024.
//

import SwiftUI

struct ProfileCard: View {
    
    var user: User
    @State var height: CGFloat?
    
    var body: some View {
        BlankCard(cardColor: Color(.secondarySystemFill)) {
            HStack(alignment: .top){
                
                HStack(alignment: .center) {
                    Image(user.image ?? "")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80)
                    .clipShape(Circle())
                }
                .frame(height: height)
                .padding(.horizontal, 5)
                
                VStack(alignment:.leading){
                    Text(user.name ?? "").font(.title2).bold()
                    Text("@" + (user.username ?? "")).font(.subheadline).opacity(0.8)
                    
                    HStack {
                        VStack{
                            Text("\(user.posts.count)").bold()
                            Text(user.posts.count > 1 ? "posts" : "post")
                        }
                        Spacer()
                        VStack{
                            Text("\(user.followers.count)").bold()
                            Text(user.followers.count > 1 ? "followers" : "follower")
                        }
                        Spacer()
                        VStack{
                            Text("\(user.following.count)").bold()
                            Text(user.following.count > 1 ? "followings" : "following")
                        }
                    }
                    .padding(.top,10)
                }
                .padding(.horizontal,10)
                .background(
                    GeometryReader { geometry in
                        Path { path in
                            let height = geometry.size.height
                            DispatchQueue.main.async {
                                if self.height != height {
                                    self.height = height
                                }
                            }
                        }
                    })
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
}
#Preview {
    ProfileCard(user: user10)
}
