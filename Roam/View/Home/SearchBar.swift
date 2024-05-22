//
//  SearchBar.swift
//  Roam
//
//  Created by Jeremy Teng  on 08/05/2024.
//

import SwiftUI

struct SearchBar: View {
    
    @Binding var searchText: String
    @FocusState var isFocused: Bool
    var height: Int
    
    var body: some View {
        HStack{
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.accent)
            TextField("Where to?", text: $searchText)
                .focused($isFocused)
        }
        .font(.headline)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15.0)
                .foregroundStyle(Color(.secondarySystemBackground))
                .frame(height: CGFloat(height))
        )
        .onAppear{
            isFocused = true
        }
    }
}

#Preview {
    SearchBar(searchText: .constant(""), height: 30)
}
