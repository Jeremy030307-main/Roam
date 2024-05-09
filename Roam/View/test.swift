//
//  test.swift
//  Roam
//
//  Created by Jeremy Teng  on 08/05/2024.
//

import SwiftUI

struct test: View {
    
    @ObservedObject var yelpFetcher = YelpFetcher()
    
    var body: some View {
        TextField("type something", text: $yelpFetcher.searchText)
            .onSubmit {
                Task{
                    await yelpFetcher.fetchAllLocation()
                }
            }
        List{
            ForEach(yelpFetcher.locations, id: \.self) { location in
                Text(location.name ?? "")
            }
        }
    }
}

#Preview {
    test()
}
