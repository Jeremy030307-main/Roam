//
//  PostCardView.swift
//  Roam
//
//  Created by Jeremy Teng  on 25/04/2024.
//

import SwiftUI

struct BlankCard<Content:View>: View {
    
    let content: Content
    let color: Color
    
    init(cardColor: Color, @ViewBuilder content: () -> Content) {
        self.color = cardColor
        self.content = content()
    }
    
    var body: some View {
    
        
        VStack(alignment: .leading, spacing: 8){
            
            content
        }
        .padding()
        .background(color)
        .cornerRadius(20)
    }
}
