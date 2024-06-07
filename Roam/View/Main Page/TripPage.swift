//
//  ItineraryPage.swift
//  Roam
//
//  Created by Jeremy Teng  on 27/04/2024.
//

import SwiftUI

struct TripPage: View {
    
    @EnvironmentObject var userManager: UserManager
    @State var navigateToDetail = false
    @State var tripChosen: Trip?
    @State var addNewTrip = false
    @State var tripIndexChosen = 0
    
    @Binding var enterPerDayView: Bool
    
    var body: some View {
        
        NavigationStack {
            
            List{
                ForEach(Array(userManager.user.trips.enumerated()), id: \.1.id) {index, itinerary in
                    SideImageCard(image: itinerary.image ?? "", backgroundColor: Color(.secondarySystemBackground), textHeight: 100) {
                        VStack(alignment: .leading) {
                            Text(itinerary.title ?? "").font(.headline)
                            Text(itinerary.destination ?? "").font(.subheadline)
                            
                            HStack {
                                Spacer()
                                if itinerary.startDate == nil {
                                    Text("\(itinerary.totalDays ?? 0)d").font(.footnote)
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
                    .shadow(radius: 2, y:3)
                    .background {
                        NavigationLink("", destination: TripMainView(trip: itinerary, editable: true))
                    }
                }
                .onDelete(perform: userManager.deleteTrip)
                .listRowSeparator(.hidden)
                .onChange(of: navigateToDetail) { oldValue, newValue in
                    enterPerDayView = navigateToDetail
                }
            }
            .listStyle(.plain)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Trip").font(.title).bold()
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Spacer()
                    Button{
                        addNewTrip.toggle()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                        Text("New Trip")
                    }
                }
            }
            .sheet(isPresented: $addNewTrip) {
                AddNewTripView()
            }
        }
    }
}

#Preview {
    TripPage(enterPerDayView: .constant(false))
        .environmentObject(UserManager(user: FirebaseController.shared.user))
}
