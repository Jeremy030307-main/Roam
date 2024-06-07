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
    var dimension: Int
    @State private var height: CGFloat?
    @State private var imageHeight: CGFloat?
    @State private var imageWidth: CGFloat?
    
    var body: some View {
        
        //        ZStack{
        //            Circle()
        //                .foregroundStyle(color)
        //                .background(
        //                    GeometryReader { geometry in
        //                        Path { path in
        //                            let height = geometry.size.height
        //                            DispatchQueue.main.async {
        //                                if self.height != height {
        //                                    self.height = height
        //                                }
        //                            }
        //                        }
        //                    })
        //
        //            image
        //                .resizable()
        //                .aspectRatio(contentMode: .fit)
        //                .frame(
        //                    width:imageWidth ?? 10>imageHeight ?? 10 ? (height ?? 10)/1.5:imageWidth,
        //                    height: imageHeight ?? 10>imageWidth ?? 10 ? (height ?? 10)/1.5:imageWidth)
        //                .foregroundColor(.white)
        //                .background(
        //                    GeometryReader { geometry in
        //                        Path { path in
        //                            let height = geometry.size.height
        //                            let width = geometry.size.width
        //                            DispatchQueue.main.async {
        //                                if self.imageHeight != height {
        //                                    self.imageHeight = height
        //                                }
        //                                if self.imageWidth != width {
        //                                    self.imageWidth = width
        //                                }
        //                            }
        //                        }
        //                    })
        //
        //        }
        
        image
            .resizable()
            .scaledToFit()
            .frame(width: CGFloat(dimension))
            .foregroundStyle(color)
    }
}

#Preview {
    TripCirceleIcon(image: Image(systemName: EventType.accomodation.icon), color: Color(.purple), dimension: 30)
        .previewLayout(.sizeThatFits)
}
