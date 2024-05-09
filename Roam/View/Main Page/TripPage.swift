//
//  ItineraryPage.swift
//  Roam
//
//  Created by Jeremy Teng  on 27/04/2024.
//

import SwiftUI

struct TripPage: View {
    
    @ObservedObject var userManager = UserManager(user: user10)
    @State var navigateToDetail = false
    @State var tripChosen: Trip?
    
    var body: some View {
        
        NavigationStack {
            
            List{
                
                ForEach(userManager.user.itinerary){ itinerary in
                    Button{
                        tripChosen = itinerary
                        navigateToDetail.toggle()
                    } label: {
                        SideImageCard(image: Image(itinerary.image), backgroundColor: Color(.secondarySystemFill)) {
                            VStack(alignment: .leading) {
                                Text(itinerary.title).font(.headline)
                                Text(itinerary.destination).font(.subheadline)
                                
                                HStack {
                                    Spacer()
                                    if itinerary.startDate == nil {
                                        Text("\(itinerary.totalDays)d").font(.footnote)
                                    }
                                    else{
                                        Text(itinerary.startDate!.formatted(.dateTime.day().month()) + " - " + itinerary.endDate!.formatted(.dateTime.day().month())).font(.footnote)
                                    }
                                }
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        .cornerRadius(20)
                    }
                    .foregroundStyle(.black)
                }
                .onDelete(perform: userManager.deleteTrip)
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .navigationDestination(isPresented: $navigateToDetail) {
                TripMainView(trip: tripChosen ?? itinerary1)
            }
            .navigationTitle("Trip").navigationBarTitleDisplayMode(.large)
                        
        }
        
        
    }
}

#Preview {
    TripPage()
}
