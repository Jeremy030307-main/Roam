//
//  SearchingView.swift
//  Roam
//
//  Created by Jeremy Teng  on 08/05/2024.
//

import SwiftUI

struct SearchingView: View {
    
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var locationService: CitySearchViewModal = CitySearchViewModal()
    @ObservedObject var yelpFetcher: YelpFetcher
    var searchBarAnimation: Namespace.ID
    var fromMainPage: Bool
    
    var body: some View {
        VStack{
            HStack{
                SearchBar(searchText: $locationService.queryFragment, height: 35)
                    .matchedGeometryEffect(id: "selectedID", in: searchBarAnimation, isSource: true)
                    .onSubmit {
                        yelpFetcher.searchText = locationService.queryFragment
                        withAnimation {
                            yelpFetcher.searchingState = .completesSearching
                        }
                    }
                if locationService.status == .isSearching {
                    Image(systemName: "clock")
                        .foregroundColor(Color.gray)
                }
                
                Button("Cancel"){
                    withAnimation(.easeInOut(duration: 0.5)) {
                        if fromMainPage{
                            yelpFetcher.searchingState = .noSearch
                            yelpFetcher.searchText = ""
                        }
                        else{
                            yelpFetcher.searchingState = .completesSearching
                        }
                                
                    }
                }
                .matchedGeometryEffect(id: "cancelButton", in: searchBarAnimation)
            }
            
            ScrollView{
                ForEach(locationService.returnText(), id:\.self) { completionResult in
                    Button{
                        yelpFetcher.searchText = completionResult
                        withAnimation {
                            yelpFetcher.searchingState = .completesSearching
                        }
                    } label: {
                        HStack{
                            Image(systemName: "location.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(.accent)
                                .frame(height: 30)
                                .padding()
                                .background(.quinary)
                                .cornerRadius(15)
                            Text(completionResult).font(.title3).bold().padding(.horizontal)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .foregroundStyle(.primary)
                }
            }
            Spacer()
        }
        .padding()
    }
}

struct SearchingView_Previews: PreviewProvider {
    @Namespace static var namespace // <- This

    static var previews: some View {
        SearchingView(yelpFetcher: YelpFetcher(), searchBarAnimation: namespace, fromMainPage: false)
    }
}

