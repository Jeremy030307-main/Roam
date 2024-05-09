//
//  TripCirceleIcon.swift
//  Roam
//
//  Created by Jeremy Teng  on 28/04/2024.
//

import SwiftUI

struct TripCirceleIcon: View {
    
    var image: Image
    var color: Color
    @State private var height: CGFloat?
    
    var body: some View {
        
        ZStack{
            Circle()
                .foregroundStyle(color)
                .background(
                    GeometryReader { geometry in
                        Path { path in
                            let height = geometry.size.height
                            DispatchQueue.main.async {
                                if self.height != height {
                                    self.height = height
                                }
                            }
                        }
                    })
            
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: (height ?? 10) / 2)
                .foregroundColor(.white)
                
        }
    }
}

#Preview {
    TripCirceleIcon(image: Image(systemName: "lightbulb.fill"), color: Color(.purple))
        .previewLayout(.sizeThatFits)
}
