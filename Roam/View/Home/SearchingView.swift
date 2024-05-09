//
//  SearchingView.swift
//  Roam
//
//  Created by Jeremy Teng  on 08/05/2024.
//

import SwiftUI

struct SearchingView: View {
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var yelpFetcher = YelpFetcher()
    @Binding var searching: CGFloat

    var searchBarAnimation: Namespace.ID
    
    var body: some View {
        HStack{
            SearchBar(searchText: $yelpFetcher.searchText)
                .matchedGeometryEffect(id: "selectedID", in: searchBarAnimation)
                .onSubmit {
                    Task{
                        await yelpFetcher.fetchAllLocation()
                    }
                }
            
            Button("Cancel"){
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.searching = 0
                }
            }
            .matchedGeometryEffect(id: "cancelButton", in: searchBarAnimation)
        }
        
        List{
            ForEach(yelpFetcher.locations, id: \.self) { location in
                SearchResultCard(locationData: location)
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }
}
