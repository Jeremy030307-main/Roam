//
//  BuisinessDetailView.swift
//  Roam
//
//  Created by Jeremy Teng  on 09/05/2024.
//

import SwiftUI

struct BuisinessDetailView: View {
    
    @State var showImageDetail = false
    @State var imageChoosen: String? = "http://s3-media4.fl.yelpcdn.com/bphoto/howYvOKNPXU9A5KUahEXLA/o.jpg"
    @State var imageID: String?
    @Namespace var imageEnalarge
    var locationData: LocationData
    var detail: LocationDetail
    var reviews: [LocationReview]
    
    let columns = [
            GridItem(.fixed(120)),
            GridItem(.flexible())
        ]
        
    var body: some View{
        let targetSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height / 5)
    
        ZStack{
            ScrollView{
                VStack(alignment: .leading){
                    
                    // Image section
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack{
                            ForEach(detail.photos ?? [], id:\.self){ link in
                                ZStack{
                                    AsyncImage(url: URL(string: convertHTTP(url: link) ?? "")){ phase in
                                        if let image = phase.image {
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .clipped()
                                                .onTapGesture {
                                                    Task{
                                                        imageChoosen = link
                                                        imageID = link
                                                        withAnimation {
                                                            showImageDetail.toggle()
                                                        }
                                                    }
                                                }
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
                                
                                .matchedGeometryEffect(id: "showDetail[\(link)]", in: imageEnalarge)
                                .padding(.trailing, -5)
                                .cornerRadius(5)    
                            }
                            
                        }
                        .frame(height: targetSize.height)

                    }
                    .shadow(color: .gray, radius: 30, x: 0, y: 10)
                    
                    VStack(alignment: .leading, spacing: 20){
                        
                        // title
                        Text(locationData.name ?? "").font(.title).bold()
                        
                        // Rating and Review
                        HStack{
                            RatingStarView(rating: locationData.rating ?? 0)
                                .foregroundStyle(.accent)
                            Text("\(locationData.rating ?? 0, specifier: "%.1f") (\(locationData.reviewCount ?? 0)) ·")
                                .padding(.leading, 5)
                            Text(locationData.price ?? "")
                                .foregroundStyle(.accent)
                        }
                        .frame(height: targetSize.height/10)
                        
                        // Category
                        HStack{
                            ForEach(locationData.categories ?? [], id: \.self){ category in
                                Text(category).font(.headline).padding(7).opacity(0.7).lineLimit(1)
                                    .background(
                                        Rectangle()
                                            .foregroundStyle(Color(.tertiarySystemFill))
                                            .cornerRadius(5)
                                    )
                            }
                        }
                        
                        // Address
                        HStack(alignment: .top){
                            Text("Address: ").font(.headline)
                            Text(detail.address ?? "").font(.subheadline)
                                .multilineTextAlignment(.leading)
                        }
                        
                        // Phone
                        HStack(alignment: .top){
                            Text("Phone: ").font(.headline)
                            Text(locationData.phone ?? "").font(.subheadline)
                        }
                        
                        // Hours
                        Text("Hours: ").font(.headline)
                        LazyVGrid(columns: columns, alignment: .leading, spacing: 5) {
                            ForEach(Weekday.allCases, id: \.self){day in
                                let start = detail.open?[day.day]?[0] ?? ""
                                let end = detail.open?[day.day]?[1] ?? ""
                                Text(day.day)
                                Text("\(start ) - \(end )")
                            }
                        }
                        .padding(.leading, 30)
                        
                        Divider()
                        
                        Text("Review (\(locationData.reviewCount ?? 0))").font(.headline)
                        ForEach(reviews, id: \.self){review in
                            BuisinessReviewView(review: review)
                        }
                        
                        
                    }
                    .padding()
                    
                    
                    Spacer()
                }
            }
            
            if showImageDetail == true && imageID != nil{
                ImageEnlargeView(id: imageID!, imageURL: imageChoosen!, namespace: imageEnalarge)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.black.opacity(0.8))
                    .onTapGesture {
                        withAnimation {
                            showImageDetail.toggle()
                        }
                    }
            }
        }
    }
    
    func convertHTTP(url: String) -> String? {
        var comps = URLComponents(string: url)
        comps?.scheme = "https"
        let https = comps?.string
        return https
    }
}

struct BuisinessReviewView: View {
    
    var review: LocationReview
    
    var body: some View{
        let targetSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height / 5)

        VStack(alignment: .leading){
            
            // Profile Header
            HStack{
                VStack{
                    AsyncImage(url: URL(string: convertHTTP(url: review.userImage ?? "") ?? "")){ phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipped()
                        } else if phase.error != nil {
                            Image(systemName: "person.fill")
                                .imageScale(.large)
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.accent)
                        } else {
                            ProgressView()
                        }
                    }
                }
                .clipShape(Circle())
                .frame(width: 25)
                .background(
                    Circle()
                        .stroke(.black, lineWidth: 1)
                )
                
                Text(review.userName ?? "").font(.subheadline).bold()
                
                RatingStarView(rating: review.rating ?? 0)
                    .frame(height: targetSize.height/12)
                    .foregroundStyle(.accent)
                    .padding(.leading)
                Text(" \(review.rating ?? 0, specifier: "%.1f")").font(.caption)
                
                Spacer()
            }
            
            let display = (review.text ?? "") + "[read more](\(review.reviewLink ?? ""))"
            Text(.init(display)).font(.caption)
        }
    }
    
    func convertHTTP(url: String) -> String? {
        var comps = URLComponents(string: url)
        comps?.scheme = "https"
        let https = comps?.string
        return https
    }
}

#Preview("Review"){
    BuisinessReviewView(review: LocationReview(text: "This place is really pretty and I really love this place. My friends and me came here yesterday. The food is superb, the service is impeccable (mostly) and...",
                                               userName: "Hoang V.",
                                               userImage: "",
                                               rating: 5,
                                               reviewLink: "https://www.yelp.com/biz/north-india-restaurant-san-francisco?hrid=AeVAkQgueu6JtYtU4r3Jrg"))
}

#Preview("BuisinessDetail") {
    BuisinessDetailView(locationData:
                            LocationData(id: "molinari-delicatessen-san-francisco",
                                          name: "Molinari Delicatessen",
                                          rating: 4.5,
                                          price: "$$",
                                          phone: "+14154212337",
                                          categories: ["Delis"],
                                          reviewCount: 910,
                                          imageURL: "http://s3-media4.fl.yelpcdn.com/bphoto/6He-NlZrAv2mDV-yg6jW3g/o.jpg",
                                          latitude: 37.7983818054199,
                                          longitude: -122.407821655273,
                                          address: "373 Columbus Ave, San Francisco, 94133 CA, US"),
                        detail:
                            LocationDetail(photos: [
                                "http://s3-media4.fl.yelpcdn.com/bphoto/howYvOKNPXU9A5KUahEXLA/o.jpg",
                                "http://s3-media3.fl.yelpcdn.com/bphoto/I-CX8nioj3_ybAAYmhZcYg/o.jpg",
                                "http://s3-media2.fl.yelpcdn.com/bphoto/uaSNfzJUiFDzMeSCwTcs-A/o.jpg"
                              ],
                               open: [
                                "Monday": ["1000", "2300"],
                                "Tuesday": ["1000", "2300"],
                                "Wednesday": ["1000", "2300"],
                                "Thursday": ["1000", "2300"],
                                "Friday": ["1000", "2300"],
                                "Saturday": ["1000", "2300"],
                                "Sunday": ["1000", "2300"],
                               ],
                            address: "373 Columbus Ave, San Francisco, 94133 CA, US"),
                        reviews:
                            [LocationReview(text: "This place is really pretty and I really love this place. My friends and me came here yesterday. The food is superb, the service is impeccable (mostly) and...",
                                           userName: "Hoang V.",
                                           userImage: "",
                                           rating: 5,
                                           reviewLink: "https://www.yelp.com/biz/north-india-restaurant-san-francisco?hrid=AeVAkQgueu6JtYtU4r3Jrg")])
}
