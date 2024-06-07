//
//  ImageCard.swift
//  Roam
//
//  Created by Jeremy Teng  on 27/04/2024.
//

import SwiftUI

struct SideImageCard<Content: View>: View {
    
    var image: String
    let content: Content
    var textHeight: CGFloat
    @State var width: CGFloat = CGFloat()
    var backgroundColor: Color
    
    init(image: String, backgroundColor: Color, textHeight: CGFloat, @ViewBuilder content: () -> Content) {
        self.image = image
        self.backgroundColor = backgroundColor
        self.textHeight = textHeight
        self.content = content()
    }
    
    var body: some View{
    
        HStack(alignment: .top){
            
            VStack{
                AsyncImage(url: URL(string: convertHTTP(url: self.image) ?? "")){ phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: width, height: textHeight)
                            .clipped()
                        
                    } else if phase.error != nil {
                        Image(systemName: "photo.on.rectangle.angled")
                            .imageScale(.large)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.secondary)
                        
                    } else {
                        ProgressView()
                    }
                }
            }
            .frame(width: width)
            
            content
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
        
        func convertHTTP(url: String) -> String? {
            var comps = URLComponents(string: url)
            comps?.scheme = "https"
            let https = comps?.string
            return https
        }
}

struct TopImagaeCard<Content: View>: View {
    
    var image: Image
    let content: Content
    var backgroundColor: Color
    var height: CGFloat
    
    init(image: Image, backgroundColor: Color, height: CGFloat, @ViewBuilder content: () -> Content) {
        self.image = image
        self.height = height
        self.backgroundColor = backgroundColor
        self.content = content()
    }
    
    var body: some View{
    
        VStack(alignment: .leading){
            
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: height/2 > 150 ? 150: height/2)
                .frame(maxWidth: .infinity)
                .clipped()
            content
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(backgroundColor)
        .cornerRadius(10)

        }
}
