//
//  HomePage.swift
//  Roam
//
//  Created by Jeremy Teng  on 07/05/2024.
//

import SwiftUI

struct HomePage: View {
    
    @Namespace var searchBarAnimation
    @State private var searching: CGFloat = 0
    
    var body: some View {
        let targetSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height / 4.5)
        NavigationStack{
            if searching == 0{
                ZStack{
                    VStack {
                        
                        Color.accentColor
                            .frame(width: targetSize.width, height: targetSize.height)
                            .cornerRadius(50)
                        Spacer()
                    }
                    .ignoresSafeArea()
                    
                    VStack{
                        
                        Image("Logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: targetSize.height/2)
                            .padding(.horizontal, 60)
                        
                        ZStack{
                            Button("Cancel"){
                                
                            }
                            .matchedGeometryEffect(id: "cancelButton", in: searchBarAnimation, isSource: true)
                            
                            Button{
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    self.searching = 360
                                }
                                
                            } label: {
                                SearchBar(searchText: .constant(""))
                                    .matchedGeometryEffect(id: "selectedID", in: searchBarAnimation, isSource: true)
                                    .padding(.horizontal, 30)
                                    .disabled(true)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        
                        Spacer()
                    }
                    
                }
            } else {
                SearchingView(searching: $searching, searchBarAnimation: searchBarAnimation)
            }
        }
    }

}


#Preview {
    HomePage()
}
