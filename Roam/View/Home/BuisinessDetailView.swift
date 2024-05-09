//
//  BuisinessDetailView.swift
//  Roam
//
//  Created by Jeremy Teng  on 09/05/2024.
//

import SwiftUI

struct BuisinessDetailView: View {
    
//    var locationData: LocationData
//    var detail: LocationDetail
    
    var name: String? = "North India Restaurant"
    var rating: Double? = 4
    var price: String? = "$$$"
    var phone: String? = "+14154212337"
    var categories: [String]? = ["Delis"]
    var reviewCount: Int? = 551
    var imageURL: String? = "http://s3-media4.fl.yelpcdn.com/bphoto/6He-NlZrAv2mDV-yg6jW3g/o.jpg"
    var photos: [String]? = [
        "http://s3-media4.fl.yelpcdn.com/bphoto/howYvOKNPXU9A5KUahEXLA/o.jpg",
        "http://s3-media3.fl.yelpcdn.com/bphoto/I-CX8nioj3_ybAAYmhZcYg/o.jpg",
        "http://s3-media2.fl.yelpcdn.com/bphoto/uaSNfzJUiFDzMeSCwTcs-A/o.jpg"
      ]
    var hours: [String: [Int]]? = [
        "Monday": [1000, 2300],
        "Tuesday": [1000, 2300],
        "Wednesday": [1000, 2300],
        "Thursday": [1000, 2300],
        "Friday": [1000, 0000],
        "Saturday": [1000, 0000],
        "Sunday": [1000, 2300]
    ]
    var address: String = "123 Second St, Sn Francisco, CA, US"
    
    let columns = [
            GridItem(.fixed(120)),
            GridItem(.flexible())
        ]
        
    var body: some View{
        let targetSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height / 5)

        ScrollView{
            VStack(alignment: .leading){
                
                // Image section
                ScrollView(.horizontal, showsIndicators: false){
                    HStack{
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
                        .padding(.trailing, -5)
                        .cornerRadius(5)
                        
                        ForEach(photos ?? [], id:\.self){ link in
                            HStack{
                                AsyncImage(url: URL(string: convertHTTP(url: link) ?? "")){ phase in
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
                            }
                            .padding(.trailing, -5)
                            .cornerRadius(5)
                        }
                    }
                    .frame(height: targetSize.height)
                    .opacity(0.8)
                }
                .shadow(color: .gray, radius: 30, x: 0, y: 10)
                
                VStack(alignment: .leading, spacing: 20){
                    
                    // title
                    Text(name ?? "").font(.title).bold()
                    
                    // Rating and Review
                    HStack{
                        RatingStarView(rating: rating ?? 0)
                            .foregroundStyle(.accent)
                        Text("\(rating ?? 0, specifier: "%.1f") (\(reviewCount ?? 0)) ·")
                            .padding(.leading, 5)
                        Text(price ?? "")
                            .foregroundStyle(.accent)
                    }
                    .frame(height: targetSize.height/10)
                    
                    // Category
                    HStack{
                        ForEach(categories ?? [], id: \.self){ category in
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
                        Text(address).font(.subheadline)
                            .multilineTextAlignment(.leading)
                    }
                    
                    // Phone
                    HStack(alignment: .top){
                        Text("Phone: ").font(.headline)
                        Text(phone ?? "").font(.subheadline)
                    }
                    
                    // Hours
                    Text("Hours: ").font(.headline)
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 5) {
                        ForEach(Weekday.allCases, id: \.self){day in
                            let start = hours?[day.day]?[0]
                            let end = hours?[day.day]?[1]
                            Text(day.day)
                            Text("\(start ?? 0) - \(end ?? 0)")
                        }
                    }
                    .padding(.leading, 30)
                    
                    Divider()
                    Text("Review (\(reviewCount ?? 0))").font(.headline)
                }
                .padding()
                
                
                Spacer()
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

#Preview {
    BuisinessDetailView()
}
