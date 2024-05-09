//
//  RatingStarView.swift
//  Roam
//
//  Created by Jeremy Teng  on 08/05/2024.
//

import SwiftUI

struct RatingStarView: View {
    
    var rating: Double
    
    var body: some View {
        
        HStack{
            ForEach(getLocationStar(), id: \.self){image in
                Image(systemName: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 10)
            }
        }
    }
    
    func getLocationStar() -> [String]{
        
        var ratingCounter = rating
        var returnList: [String] = []
        for _ in 0..<5{
            if ratingCounter >= 1{
                returnList.append("star.fill")
            }else if ratingCounter <= 0{
                returnList.append("star")
            }else {
                returnList.append("star.leadinghalf.filled")
            }
            ratingCounter-=1
        }
        return returnList
    }
}

#Preview {
    RatingStarView(rating: 3.1)
}
