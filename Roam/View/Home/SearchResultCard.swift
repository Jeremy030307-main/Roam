//
//  SearchResultCard.swift
//  Roam
//
//  Created by Jeremy Teng  on 08/05/2024.
//

import SwiftUI

struct SearchResultCard: View {
    
    @ObservedObject var yelpFetcher = YelpFetcher()
    var locationData: LocationData
    @State var locationDetail: LocationDetail?
    @State var locationReviews: [LocationReview]?
    @State var showDetail = false
    
    var body: some View {
        
        let targetSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height / 10)
        VStack{
            Button{
                Task{
                    await yelpFetcher.fetchLocationDetail(id:locationData.id ?? "")
                    await yelpFetcher.fetchLocationReview(id: locationData.id ?? "")
                    locationDetail = yelpFetcher.locationDetail
                    locationReviews = yelpFetcher.reviews
                }
                
                showDetail.toggle()
            }label: {
                BlankCard(cardColor: Color(.secondarySystemBackground)) {
                    HStack{
                        VStack{
                            AsyncImage(url: URL(string: convertHTTP() ?? "")){ phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFit()
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
                        .frame(width: targetSize.height, height: targetSize.height)
                        .clipped()
                        .cornerRadius(10)
                        
                        VStack(alignment: .leading){
                            Text(locationData.name ?? "").font(.headline)
                            HStack{
                                RatingStarView(rating: locationData.rating ?? 0)
                                    .frame(width: targetSize.width/4.5)
                                    .foregroundStyle(.accent)
                                Text("\(locationData.rating ?? 0, specifier: "%.1f") (\(locationData.reviewCount ?? 0)) ·").font(.footnote)
                                Text("\(locationData.price ?? "")").font(.footnote).foregroundStyle(.accent)
                            }.offset(y:-8)
                            
                            HStack{
                                ForEach(locationData.categories ?? [], id: \.self){ category in
                                    Text(category).font(.subheadline).padding(.horizontal, 5).opacity(0.7)
                                        .background(
                                            Rectangle()
                                                .foregroundStyle(Color(.tertiarySystemFill))
                                                .cornerRadius(5)
                                        )
                                }
                            }
                            .offset(y:-8)
                            
                            Text(locationData.address ?? "").font(.subheadline).lineLimit(1)
                        }
                        .padding(5)
                        
                    }
                    .frame(height: targetSize.height)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .foregroundStyle(.primary)
        .sheet(isPresented: $showDetail, content: {
            if locationDetail != nil && locationReviews != nil{
                BuisinessDetailView(locationData: locationData, detail: locationDetail!, reviews: locationReviews!)
            }
        })
    }
    
    func convertHTTP() -> String? {
        var comps = URLComponents(string: locationData.imageURL ?? "")
        comps?.scheme = "https"
        let https = comps?.string
        return https
    }
}

#Preview {
    SearchResultCard(locationData: LocationData(id: "molinari-delicatessen-san-francisco",
                                                name: "Molinari Delicatessen",
                                                rating: 4.5,
                                                price: "$$",
                                                phone: "+14154212337",
                                                categories: ["Delis"],
                                                reviewCount: 910,
                                                imageURL: "http://s3-media4.fl.yelpcdn.com/bphoto/6He-NlZrAv2mDV-yg6jW3g/o.jpg",
                                                latitude: 37.7983818054199,
                                                longitude: -122.407821655273,
                                                address: "373 Columbus Ave, San Francisco, 94133 CA, US"))
}
