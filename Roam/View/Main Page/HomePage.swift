//
//  HomePage.swift
//  Roam
//
//  Created by Jeremy Teng  on 07/05/2024.
//

import SwiftUI

struct HomePage: View {
    
    @EnvironmentObject var firebaseController: FirebaseController
    @EnvironmentObject var userManager: UserManager
    @StateObject var yelpFetcher = YelpFetcher()
    @Namespace var searchBarAnimation
    @State private var searching = false
    
    var body: some View {
        let targetSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height / 4.5)
        
        NavigationStack{
            switch yelpFetcher.searchingState{
                
            case .noSearch:
                ScrollView{
                    ZStack{
                        VStack {
                            
                            Color.accentColor
                                .frame(width: targetSize.width, height: targetSize.height)
                                .cornerRadius(50)
                            Spacer()
                        }
                        .ignoresSafeArea()
                        
                        VStack{
                            Image("Logo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: targetSize.height/2)
                                .padding(.horizontal, 60)
                            
                            ZStack{
                                Button("Cancel"){
                                }
                                .matchedGeometryEffect(id: "cancelButton", in: searchBarAnimation, isSource: true)
                                
                                Button{
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        yelpFetcher.searchingState = .enterSearch(fromMainPage: true)
                                    }
                                    
                                } label: {
                                    SearchBar(searchText: .constant(""), height: 50)
                                        .matchedGeometryEffect(id: "selectedID", in: searchBarAnimation, isSource: true)
                                        .padding(.horizontal, 30)
                                        .disabled(true)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading){
                        Text("Itineraru Guide").font(.headline)
                        ScrollView(.horizontal) {
                            ForEach(firebaseController.guide){ guide in
                                PostCard(post: guide)
                                    .frame(width: targetSize.width/1.1)
                            }
                        }
                        .scrollIndicators(.visible, axes: .horizontal)
                    }
                    .padding()
                        
                    VStack(alignment: .leading){
                        HStack{
                            Text("Post").font(.headline)
                            Spacer()
                        }
                        ForEach(firebaseController.post){ post in
                            PostCard(post: post)
                        }
                    }.padding()
    
                    Spacer()
                }
                .ignoresSafeArea()
                
            case .enterSearch(fromMainPage: let fromMainPage):
                SearchingView(yelpFetcher: yelpFetcher, searchBarAnimation: searchBarAnimation, fromMainPage: fromMainPage)
                
            case .completesSearching:
                SearchResultView(yelpFetcher: yelpFetcher, searchText: $yelpFetcher.searchText, searchBarAnimation: searchBarAnimation)
                    .animation(.easeInOut, value: 20)
            }
        }
    }

}


#Preview {
    HomePage()
        .environmentObject(UserManager(user: FirebaseController.shared.user))
        .environmentObject(FirebaseController.shared)
}
