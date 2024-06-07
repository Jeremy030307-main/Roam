//
//  SearchResultView.swift
//  Roam
//
//  Created by Jeremy Teng  on 15/05/2024.
//

import SwiftUI

struct SearchResultView: View {
    
    @EnvironmentObject var userManager: UserManager
    @ObservedObject var yelpFetcher: YelpFetcher
    @Binding var searchText: String
    var searchBarAnimation: Namespace.ID
    
    @State private var requestIndex = 1
    @State var scrollPosition: Int?
    
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
        .padding(.horizontal)
        
        if yelpFetcher.isLoading{
            VStack{
                Spacer()
                ProgressView()
                    .padding()
                Spacer()
            }
        }
        ScrollView{
            LazyVStack{
                ForEach(Array(yelpFetcher.locations.enumerated()), id: \.1.id) { index, location in
                    SearchResultCard(locationData: location)
                        .id(index)
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $scrollPosition)
        .padding()
        .padding(.top,0)
        .ignoresSafeArea()
        
        .onAppear {
            Task{
                await yelpFetcher.fetchBeuisinessByLocation(categories:"")
            }
        }
        .onChange(of: scrollPosition, { oldValue, newValue in
            Task{
                if newValue ?? 0 >= yelpFetcher.locations.count - 10{
                    if yelpFetcher.locations.count == requestIndex * yelpFetcher.QUERY_LIMIT &&
                        requestIndex * yelpFetcher.QUERY_LIMIT <= 1000{
                        await yelpFetcher.fetchBeuisinessByLocation(categories: "", requestIndex: requestIndex)
                        requestIndex += 1
                    }
                }
            }
        })
    }
}

struct SearchResultView_Previews: PreviewProvider {
    @Namespace static var namespace // <- This

    static var previews: some View {
        SearchResultView(yelpFetcher: YelpFetcher(), searchText: .constant(""), searchBarAnimation: namespace)
            .environmentObject(UserManager(user: FirebaseController.shared.user))

    }
}
