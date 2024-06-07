//
//  ProfilePageTopNavBar.swift
//  Roam
//
//  Created by Jeremy Teng  on 07/05/2024.
//

import SwiftUI

enum ProfileTabItem : String, CaseIterable{
    case post
    case guide
}

struct ProfilePageTopNavBar: View {
    
    @Binding var tabSelection: ProfileTabItem
    @Binding var addNewPost: Bool
    @Namespace private var tabAnimation

    var body: some View {
        
        ZStack {
            Capsule()
                .frame(height: 0.5)
                .offset(y: 20)
                .opacity(0.8)
                .padding(.horizontal)
            
            HStack {
                ForEach(ProfileTabItem.allCases, id:\.self){ item in
                    
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                tabSelection = item
                            }
                        } label: {
                            ZStack{
                                Text(item.rawValue.capitalized)
                                    .font(.headline)
                                    .foregroundStyle(tabSelection == item ? .accent:.gray)
                                
                                if tabSelection == item {
                                    Capsule()
                                        .frame(height: 5)
                                        .offset(y: 20)
                                        .foregroundStyle(Color.accentColor)
                                        .matchedGeometryEffect(id: "selectedID", in: tabAnimation)
                                }
                            }
                            
                        }
                        Spacer()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .overlay {
                Button{
                    addNewPost.toggle()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 48, height: 48)
                        .foregroundStyle(.accent)
                }
            }
        }
        .padding()
    }
}


#Preview {
    ProfilePageTopNavBar(tabSelection: .constant(.guide), addNewPost: .constant(false))
}
