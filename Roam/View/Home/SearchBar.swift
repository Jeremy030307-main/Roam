//
//  SearchBar.swift
//  Roam
//
//  Created by Jeremy Teng  on 08/05/2024.
//

import SwiftUI

struct SearchBar: View {
    
    @Binding var searchText: String
    
    var body: some View {
        HStack{
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.accent)
            TextField("Place, Country, User", text: $searchText)
        }
        .font(.headline)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15.0)
                .foregroundStyle(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    SearchBar(searchText: .constant(""))
}
