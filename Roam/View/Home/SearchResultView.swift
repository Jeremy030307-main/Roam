//
//  SearchResultView.swift
//  Roam
//
//  Created by Jeremy Teng  on 15/05/2024.
//

import SwiftUI

struct SearchResultView: View {
    
    @ObservedObject var yelpFetcher: YelpFetcher
    @Binding var searchText: String
    var searchBarAnimation: Namespace.ID
    
    var body: some View {
        VStack{
            HStack{
                Button{
                    yelpFetcher.searchingState = .enterSearch(fromMainPage: true)
                    yelpFetcher.searchText = ""
                }label: {
                    HStack{
                        Image(systemName: "chevron.backward")
                    }
                }.foregroundStyle(.accent)
                
                SearchBar(searchText: $searchText, height: 35)
                    .matchedGeometryEffect(id: "selectedID", in: searchBarAnimation, isSource: true)
                    .disabled(true)
                    .onTapGesture {
                        yelpFetcher.searchingState = .enterSearch(fromMainPage: false)
                    }
            }
        }
        .padding()
        
        if yelpFetcher.isLoading{
            ProgressView()
        }
        List{
            ForEach(yelpFetcher.locations, id: \.self) { location in
                SearchResultCard(locationData: location)
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        
        .onAppear {
            Task{
                await yelpFetcher.fetchAllLocation(categories:"")
            }
        }
    }
}

struct SearchResultView_Previews: PreviewProvider {
    @Namespace static var namespace // <- This

    static var previews: some View {
        SearchResultView(yelpFetcher: YelpFetcher(), searchText: .constant(""), searchBarAnimation: namespace)
    }
}
