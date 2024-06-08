//
//  AddLocationToTripVie.swift
//  Roam
//
//  Created by Jeremy Teng  on 22/05/2024.
//

import SwiftUI

struct AddLocationToTripView: View {
    
    @EnvironmentObject var userManager: UserManager
    @Binding var addingEvent: Bool
    @State var tripSelected: TripManager?
    @State var selectedTrip = false
    @State var selectItinerary = false
    @Namespace var addLocationAnimation
    
    var locationData: LocationData
    
    var body: some View {
        if !selectItinerary{
            NavigationStack{
                Form{
                    // this section is let user to select which trip to add into
                    if !selectedTrip{
                        Section("Add To Trip"){
                            ForEach(userManager.user.trips){trip in
                                Button{
                                    withAnimation(.easeInOut) {
                                        tripSelected = TripManager(trip: trip)
                                        selectedTrip.toggle()
                                    }
                                } label: {
                                    HStack{
                                        Image(systemName: "airplane.departure").foregroundStyle(.accent)
                                            .imageScale(.large).padding(.trailing, 10)
                                        VStack(alignment: .leading){
                                            Text(trip.title ?? "").font(.headline)
                                            Text(trip.destination ?? "").font(.subheadline)
                                        }
                                    }
                                    .matchedGeometryEffect(id: "\(trip.title ?? "")", in: addLocationAnimation)
                                }
                                .foregroundStyle(.primary)
                            }
                        }
                        .headerProminence(.increased)
                        
                    // this sectioni is let user to select which location in the trip the selected
                    } else if selectedTrip && !selectItinerary{
                        if let trip = tripSelected?.trip {
                            Section("Select A Section"){
                                HStack{
                                    Image(systemName: "airplane.departure").foregroundStyle(.accent)
                                        .imageScale(.large).padding(.trailing, 10)
                                    VStack(alignment: .leading){
                                        Text(trip.title ?? "").font(.headline)
                                        Text(trip.destination ?? "").font(.subheadline)
                                    }
                                }
                                .matchedGeometryEffect(id: "\(trip.title ?? "")", in: addLocationAnimation)
                            }
                            .headerProminence(.increased)
                            .listRowBackground(Color.secondary.opacity(0.1))
                            
                            Section("Itinerary"){
                                Button{
                                    tripSelected?.newEventLocation = locationData
                                    selectItinerary.toggle()
                                } label: {
                                    HStack{
                                        TripCirceleIcon(image: Image(systemName: "calendar.circle.fill"), color: Color.orange, dimension: 30).padding(.trailing).padding(.vertical,3)
                                        Text("Itinerary").font(.callout)
                                    }
                                }
                                .foregroundStyle(.primary)
                            }
                            
                            Section("Saved Place"){
                                ForEach(Array(trip.savedPlaces.enumerated()), id: \.1.id) { index, savedPlace in
                                    Button{
                                        tripSelected!.addItemToList(categoryIndex: index, locationData: locationData)
                                        addingEvent.toggle()
                                    } label: {
                                        HStack{
                                            TripCirceleIcon(image: Image(systemName: savedPlace.icon), color: SavedPlaceColor(rawValue: savedPlace.color)?.copy ?? .red, dimension: 30)
                                            
                                            Text(savedPlace.title).font(.callout).padding(.horizontal)
                                        }
                                    }
                                    .foregroundStyle(.primary)
                                }
                            }
                        }
                    }
                }
                .toolbar{
                    ToolbarItem(placement: .topBarLeading) {
                        if selectedTrip{
                            Button("Back"){
                                withAnimation(.easeInOut) {
                                    selectedTrip.toggle()
                                }
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Cancel"){
                            addingEvent.toggle()
                        }
                    }
                }
            }
        } else {
            if let trip = tripSelected{
                AddEventView(tripManager: trip, addingEvent: $addingEvent, previousView: $selectItinerary, location: Location(locationData: locationData))
                
            }
        }
    }
}

#Preview {
    AddLocationToTripView(addingEvent: .constant(true), locationData:
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
                                         address: "373 Columbus Ave, San Francisco, 94133 CA, US"))
    .environmentObject(UserManager(user: FirebaseController.shared.user))

}

