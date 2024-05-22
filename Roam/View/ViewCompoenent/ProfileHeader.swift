//
//  ProfileHeader.swift
//  Roam
//
//  Created by Jeremy Teng  on 09/05/2024.
//

import SwiftUI

struct ProfileHeader: View {
        
    var image: Image
    var username: String

    var body: some View {
        
        HStack {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(Circle())
                .frame(width: 25)
            Text(username)
                .font(.subheadline)
            Spacer()
        }
    }
}

#Preview {
    ProfileHeader(image: Image("profilePiicture"), username: "Jeremy")
}
