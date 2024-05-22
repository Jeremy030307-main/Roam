//
//  HomePage.swift
//  Roam
//
//  Created by Jeremy Teng  on 07/05/2024.
//

import SwiftUI

struct HomePage: View {
    
    @ObservedObject var yelpFetcher = YelpFetcher()
    @Namespace var searchBarAnimation
    @State private var searching = false
    
    var body: some View {
        let targetSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height / 4.5)
        NavigationStack{
            switch yelpFetcher.searchingState{
            case .noSearch:
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
                        
                        Spacer()
                    }
                    
                }
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
}
