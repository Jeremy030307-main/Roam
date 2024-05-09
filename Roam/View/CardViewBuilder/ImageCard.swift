//
//  ImageCard.swift
//  Roam
//
//  Created by Jeremy Teng  on 27/04/2024.
//

import SwiftUI

struct SideImageCard<Content: View>: View {
    
    var image: Image
    let content: Content
    @State var textHeight: CGFloat = CGFloat()
    @State var width: CGFloat = CGFloat()
    var backgroundColor: Color
    
    init(image: Image, backgroundColor: Color, @ViewBuilder content: () -> Content) {
        self.image = image
        self.backgroundColor = backgroundColor
        self.content = content()
    }
    
    var body: some View{
    
        HStack(alignment: .top){
            
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: width, height: textHeight)
                .clipped()
            content
                .background(
                    GeometryReader { geometry in
                        Path { path in
                            let height = geometry.size.height
                            DispatchQueue.main.async {
                                if self.textHeight != height {
                                    self.textHeight = height
                                }
                            }
                        }
                    })
        }
        .frame(height: textHeight)
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        .cornerRadius(10)
        .background(
            GeometryReader { geometry in
                Path { path in
                    let width = geometry.size.width
                    DispatchQueue.main.async {
                        if self.width != width * 0.3 {
                            self.width = 0.3 * width
                        }
                    }
                }
            })

        }
}

struct TopImagaeCard<Content: View>: View {
    
    var image: Image
    let content: Content
    var backgroundColor: Color
    
    @State var height: CGFloat = CGFloat()
    
    init(image: Image, backgroundColor: Color, @ViewBuilder content: () -> Content) {
        self.image = image
        self.backgroundColor = backgroundColor
        self.content = content()
    }
    
    var body: some View{
    
        VStack(alignment: .leading){
            
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: height)
                .frame(maxWidth: .infinity)
                .clipped()
            content
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
        }
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        .cornerRadius(10)

        }
}
