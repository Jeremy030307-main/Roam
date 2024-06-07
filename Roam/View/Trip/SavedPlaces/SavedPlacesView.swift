//
//  SavedPlacesView.swift
//  Roam
//
//  Created by Jeremy Teng  on 01/06/2024.
//

import SwiftUI

struct SavedPlacesView: View {
    
    @ObservedObject var tripManager: TripManager
    var savedplaceCaegoryIndex: Int
    var editable: Bool
    
    var body: some View {
        NavigationStack{
            ScrollView{
                Text("").frame(maxWidth: .infinity)
                ForEach(Array(tripManager.trip.savedPlaces[savedplaceCaegoryIndex].places.enumerated()), id: \.1.id) { index, location in
                    SavedPlacesCard(tripManager: tripManager, location: location, categoryIndex: savedplaceCaegoryIndex, index: index, editable: editable)
                }
                .background(Color(.secondarySystemBackground))

            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(tripManager.trip.savedPlaces[savedplaceCaegoryIndex].title).font(.headline)
                        Text(tripManager.trip.title ?? "").font(.subheadline)
                    }
                }
            }
            .background(Color(.secondarySystemBackground))
        }
    }
}

struct SavedPlacesCard: View {
    
    @ObservedObject var tripManager: TripManager
    @State var addingEvent: Bool = false
    @State var showDetail = false
    @Namespace var animation
    @State var deleting = false
    
    let location: Location
    let categoryIndex: Int
    let index: Int
    let columns = [
            GridItem(.fixed(40)),
            GridItem(.flexible())
        ]
    let editable: Bool
    
    var body: some View {
        let targetSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height / 11)
        VStack{
            BlankCard(cardColor: Color(.systemBackground)) {
                HStack{
                    
                    // pciture
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
                        HStack{
                            Text(location.name ?? "").font(.headline)
                            Spacer()
                        }
                        
                        HStack{
                            RatingStarView(rating: location.rating ?? 0)
                                .frame(width: targetSize.width/4.5)
                                .foregroundStyle(.accent)
                            Text("\(location.rating ?? 0, specifier: "%.1f")").font(.footnote)
                            Text("\(location.price ?? "")").font(.footnote).foregroundStyle(.accent)
                        }.offset(y:-8)
                        
                        if !showDetail{
                            Text(location.address ?? "").font(.subheadline).lineLimit(1)
                        }
                    }
                    .padding(5)
                    
                }
                .frame(height: targetSize.height)
                .frame(maxWidth: .infinity)
                
                VStack{
                    if showDetail{
                        
                        LazyVGrid(columns: columns, alignment: .leading, spacing: 15) {
                            Image(systemName: "map.fill").foregroundStyle(.accent)
                            Text(location.address ?? "")
                            Image(systemName: "phone.fill").foregroundStyle(.accent)
                            Text(location.phone ?? "")
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 20)
                        
                        if editable{
                            HStack{
                                Button(role: .destructive) {
                                    deleting.toggle()
                                } label: {
                                    Text("Delete")
                                }
                                .buttonStyle(.bordered)
                                .foregroundStyle(.red)
                                
                                Spacer()
                                Button("Add"){
                                    addingEvent.toggle()
                                }.buttonStyle(.bordered)
                                    .foregroundStyle(.accent)
                                
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .foregroundStyle(.primary)
        .onTapGesture {
            withAnimation {
                showDetail.toggle()
            }
        }
        .sheet(isPresented: $addingEvent){
            AddEventView(tripManager: tripManager, addingEvent: $addingEvent, previousView: .constant(false), location: location)
        }
        .alert("Comfirm remove \(location.name ?? "")", isPresented: $deleting) {
            Button("Cancel", role: .cancel) {
                deleting.toggle()
            }
            Button("Delete", role: .destructive) {
                tripManager.deleteSavedPlace(categoryIndex: categoryIndex, itemIndex: index)
            }
        }
    }
    
    func convertHTTP() -> String? {
        var comps = URLComponents(string: location.image ?? "")
        comps?.scheme = "https"
        let https = comps?.string
        return https
    }
}

#Preview {
    SavedPlacesCard(tripManager: TripManager(trip: itinerary1), location: Location(name: "Supernormal", address: "180 Flinders Lane, 3000, Melbourne, AU", rating: 4.2, phone: "+61396508688", operatingHour: "", image: "https://s3-media4.fl.yelpcdn.com/bphoto/cRwAPaSCq-h1GutpNxgJpw/o.jpg", price: "$$$"), categoryIndex: 0, index: 0, editable: false)
}

#Preview {
    SavedPlacesView(tripManager: TripManager(trip: itinerary1), savedplaceCaegoryIndex: 0, editable: false)
}
