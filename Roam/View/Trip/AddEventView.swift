//
//  AddEventView.swift
//  Roam
//
//  Created by Jeremy Teng  on 02/05/2024.
//

import SwiftUI

struct AddEventView: View {
    
    @ObservedObject var tripManager: TripManager
    @Binding var addingEvent: Bool
    @State var eventForm = false
    @State var haha = "dfdfdsf"
    
    var body: some View {
        NavigationStack{
            
            List{
                Text(haha)
                Section("Event Cateogry"){
                    ForEach(EventType.allCases) {type in
                        Button{
                            tripManager.newEventType = type
                            eventForm.toggle()
                        }label: {
                            HStack{
                                TripCirceleIcon(image: Image(systemName: type.icon), color: Color.accentColor)
                                    .frame(width: 30)
                                Text(type.name).padding(.horizontal, 10)
                            }
                            .padding(4)
                        }
                        .foregroundStyle(.primary)
                    }
                }.headerProminence(.increased)
            }
            .navigationDestination(isPresented: $eventForm) {
                AddEventForm(tripManager: tripManager, addingEvent: $addingEvent)
            }
        }
    }
}

struct AddEventForm: View {
    
    @ObservedObject var tripManager: TripManager
    @Binding var addingEvent: Bool

    var body: some View {
        NavigationStack{
            Form{
                
                Text("Location Will implement afterward")
                DatePicker(selection: $tripManager.newEventStartTime,
                           displayedComponents: tripManager.trip.startDate == nil ? .hourAndMinute: [.date, .hourAndMinute],
                           label: { Text("Start Time") })
                DatePicker(selection: $tripManager.newEventEndTime,
                           displayedComponents: tripManager.trip.startDate == nil ? .hourAndMinute: [.date, .hourAndMinute],
                           label: { Text("End Time") })
                
            }
            .navigationTitle(tripManager.newEventType.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem{
                    Button("Save"){
                        let _ = tripManager.savedEvent()
                        addingEvent = false
                    }
                }
            }
        }
        
    }
}

#Preview {
    AddEventView(tripManager: TripManager(trip: itinerary1), addingEvent: .constant(false))
}
