//
//  ItineraryView.swift
//  Roam
//
//  Created by Jeremy Teng  on 29/04/2024.
//

import SwiftUI

struct ItineraryView: View {
    
    @ObservedObject var tripManager: TripManager
    @State var addEvent = false
    
    var body: some View {
        NavigationStack{
            ZStack(alignment: .bottom){
                VStack{
                    ItineraryTopNavBar(totalDays: tripManager.trip.totalDays,
                                       startDate: tripManager.trip.startDate, endDate: tripManager.trip.endDate, daySelected: $tripManager.selectedDay)
                    .padding(.top, 10)
                    
                    ItineraryDayView(tripManager: tripManager, day: tripManager.selectedDay)
                    Spacer()
                }
                
                HStack{
                    Spacer()
                    Button{
                        addEvent.toggle()
                    }label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 50)
                    }
                    .padding(35)
                }
            }
            .frame(maxHeight: .infinity)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Itinerary").font(.headline)
                        Text(tripManager.trip.title).font(.subheadline)
                    }
                }
            }
            .background(Color(.secondarySystemBackground))
        }
        .sheet(isPresented: $addEvent) {
            AddEventView(tripManager: tripManager, addingEvent: $addEvent)
        }
    }
}

#Preview {
    ItineraryView(tripManager: TripManager(trip: itinerary2))
}
