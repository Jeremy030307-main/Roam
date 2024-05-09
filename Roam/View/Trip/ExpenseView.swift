//
//  ExpenseView.swift
//  Roam
//
//  Created by Jeremy Teng  on 30/04/2024.
//

import SwiftUI

struct ExpenseView: View {
    
    @ObservedObject var tripManager: TripManager
    @State var selectedDay = 1
    
    var body: some View {
        NavigationStack{
            VStack{
                ItineraryTopNavBar(totalDays: tripManager.trip.totalDays,
                                   startDate: tripManager.trip.startDate, endDate: tripManager.trip.endDate, daySelected: $selectedDay)
                .padding(.top, 5)
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Expense").font(.headline)
                        Text(tripManager.trip.title).font(.subheadline)
                    }
                }
            }
            
        }
    }
}

#Preview {
    ExpenseView(tripManager: TripManager(trip: itinerary1))
}
