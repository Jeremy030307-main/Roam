//
//  ImageEnlargeView.swift
//  Roam
//
//  Created by Jeremy Teng  on 10/05/2024.
//

import SwiftUI

struct ImageEnlargeView: View {
    
    var id: String
    var image: Image?
    var imageURL: String?
    var namespace : Namespace.ID
    
    var body: some View {
        let targetSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height/2)

        VStack{
            Spacer()
            if imageURL != nil {
                AsyncImage(url: URL(string: convertHTTP(url: imageURL ?? "") ?? "")){ phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
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
            } else if image != nil {
                image
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: targetSize.height)
        .matchedGeometryEffect(id: "showDetail[\(id)]", in: namespace)
    }
    
    func convertHTTP(url: String) -> String? {
        var comps = URLComponents(string: url)
        comps?.scheme = "https"
        let https = comps?.string
        return https
    }
}

struct ImageEnlargeView_Previews: PreviewProvider {
    @Namespace static var namespace // <- This

    static var previews: some View {
        ImageEnlargeView(id: "012", image: Image("Sydney"), namespace: namespace)
    }
}
