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
    @Binding var previousView: Bool
    @State var selectedCategory = false
    @State var didError = false
    
    @Namespace var enterCatogeoryFormAnimation
    var location: Location?
    
    var body: some View {
        NavigationStack{
            
            Form{
            switch selectedCategory {
            case true:
                AddEventForm(tripManager: tripManager, animation: enterCatogeoryFormAnimation, defaultLocation: location)
            case false:
                    Section("Add New Event"){
                        ForEach(EventType.allCases) {type in
                            if location != nil && (type == .flight || type == .transportation || type == .carRental){
                                
                            } else {
                                Button{
                                    withAnimation(.easeInOut) {
                                        tripManager.newEventType = type
                                        selectedCategory.toggle()
                                    }
                                }label: {
                                    HStack{
                                        TripCirceleIcon(image: Image(systemName: type.icon), color: Color.accentColor, dimension: 30)
                                            .frame(width: 30)
                                            .matchedGeometryEffect(id: type.icon, in: enterCatogeoryFormAnimation, isSource: true)
                                        
                                        Text(type.name).padding(.horizontal, 10)
                                            .matchedGeometryEffect(id: type.name, in: enterCatogeoryFormAnimation,isSource: true)
                                    }
                                    .padding(4)
                                }
                                .foregroundStyle(.primary)
                            }
                        }
                    }
                    .headerProminence(.increased)
                }
            }
            .toolbar{
                ToolbarItem(placement: .topBarLeading) {
                    if selectedCategory == true{
                        Button("Back"){
                            withAnimation {
                                selectedCategory.toggle()
                            }
                        }
                    } else if previousView == true {
                        Button("Back"){
                            withAnimation{
                                previousView.toggle()
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    switch selectedCategory {
                    case false:
                        Button("Cancel"){
                            addingEvent.toggle()
                        }
                    case true:
                        Button("Save"){
                            let result = tripManager.saveEvent(defaultLocation: location)
                            if result == true{
                                addingEvent.toggle()
                            } else {
                                didError.toggle()
                            }
                            
                        }
                    }
                }
            }
        }
        .alert("Failed to Save Event", isPresented: $didError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(tripManager.newEventErrorMessage)
        }
    }
}

struct AddEventForm: View {
    
    @ObservedObject var tripManager: TripManager
    
    var animation: Namespace.ID
    var defaultLocation: Location?
    
    var body: some View {
            Section{
                Text(tripManager.trip.title ?? "").foregroundStyle(.secondary)
            } header: {
                VStack(alignment:.leading){
                    HStack{
                        TripCirceleIcon(image: Image(systemName: tripManager.newEventType.icon), color: Color.accentColor, dimension: 40)
                            .frame(width: 40)
                            .matchedGeometryEffect(id: tripManager.newEventType.icon, in: animation)
                        
                        Text(tripManager.newEventType.name).padding(.horizontal, 10).font(.title3).bold().textCase(nil).foregroundStyle(.black)
                            .matchedGeometryEffect(id: tripManager.newEventType.name, in: animation)
                    }.padding(.bottom, 15)
                    Text("Trip")
                }
            }
            .headerProminence(.standard)
                        
        switch tripManager.newEventType {
        case .activity:
            AddEventDuration(tripManager: tripManager, startTimePrompt: "Start", endTimePrompt: "End")
            AddEventLocationSearch(tripManager: tripManager, locationType: .location, sectionName: "Location", prompt: "e.g., Library, Musuem", defaultLocation: defaultLocation)
        case .flight:
            AddEventDuration(tripManager: tripManager, startTimePrompt: "Depature", endTimePrompt: "Arrival")
            AddEventLocationSearch(tripManager: tripManager, locationType: .location, sectionName: "Depature Location", prompt: "e.g., Train Station, Bus Station")
            AddEventLocationSearch(tripManager: tripManager, locationType: .arrival, sectionName: "Arrival Location", prompt: "e.g., Train Station, Bus Station")
        case .accomodation:
            AddEventDuration(tripManager: tripManager, startTimePrompt: "Check In", endTimePrompt: "Check Out")
            AddEventLocationSearch(tripManager: tripManager, locationType: .location, sectionName: "Accomodation Name", prompt: "e.g., Hyatt, Shangri-La", defaultLocation: defaultLocation)
        case .restaurant:
            AddEventDuration(tripManager: tripManager, startTimePrompt: "Start", endTimePrompt: "End")
            AddEventLocationSearch(tripManager: tripManager, locationType: .location, sectionName: "Restaurant Name", prompt: "e.g., Italian, Starbucks", defaultLocation: defaultLocation)
        case .tour:
            AddEventDuration(tripManager: tripManager, startTimePrompt: "Start", endTimePrompt: "End")
            AddEventLocationSearch(tripManager: tripManager, locationType: .location, sectionName: "Location", prompt: "e.g., Mountain, Train Station", defaultLocation: defaultLocation)
        case .transportation:
            AddEventDuration(tripManager: tripManager, startTimePrompt: "Depature", endTimePrompt: "Arrival")
            AddEventLocationSearch(tripManager: tripManager, locationType: .location, sectionName: "Depature Location", prompt: "e.g., Train Station, Bus Station")
            AddEventLocationSearch(tripManager: tripManager, locationType: .arrival, sectionName: "Arrival Location", prompt: "e.g., Train Station, Bus Station")
        case .carRental:
            AddEventDuration(tripManager: tripManager, startTimePrompt: "Pick Up", endTimePrompt: "Drop Off")
            AddEventLocationSearch(tripManager: tripManager, locationType: .location, sectionName: "Pick Up Location", prompt: "e.g., Train Station, Bus Station")

            AddEventLocationSearch(tripManager: tripManager, locationType: .arrival, sectionName: "Drop Off Location", prompt: "e.g., Train Station, Bus Station")
        }
    }
}

struct AddEventLocationSearch: View {
        
    enum LocationType {
        case location, arrival
    }
    
    @ObservedObject var tripManager: TripManager

    @State var searchLocation = false
    var locationType: LocationType
    var sectionName: String
    var prompt: String
    var defaultLocation: Location?
    
    var body: some View{
        
        Section{
            if let location = defaultLocation{
                VStack{
                    Text(location.name ?? "")
                }
            } else {
                VStack{
                    if locationType == .location{
                        Text(tripManager.newEventLocation?.name==nil ? "Tap to Search":tripManager.newEventLocation?.name ?? "").foregroundStyle(tripManager.newEventLocation?.name==nil ? .tertiary: .primary)
                    } else {
                        Text(tripManager.newEventDestination?.name==nil ? "Tap to Search":tripManager.newEventDestination?.name ?? "").foregroundStyle(tripManager.newEventDestination?.name==nil ? .tertiary: .primary)
                    }
                }
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        searchLocation.toggle()
                    }
                }
            }

        } header: {
            Text(sectionName)
        } footer: {
            if let location = defaultLocation{
                Text(location.address ?? "")
            } else {
                if locationType == .location{
                    Text(tripManager.newEventLocation?.address ?? "")
                } else {
                    Text(tripManager.newEventDestination?.address ?? "")
                }
            }
        }
        
        .sheet(isPresented: $searchLocation){
            switch locationType {
            case .location:
                SearchLocationSheet(tripManager: tripManager, location: $tripManager.newEventLocation, prompt: prompt)
            case .arrival:
                SearchLocationSheet(tripManager: tripManager, location: $tripManager.newEventDestination, prompt: prompt)
            }
        }
    }
}

struct AddEventDuration: View{
    
    @ObservedObject var tripManager: TripManager
    var startTimePrompt: String
    var endTimePrompt: String
    
    var body: some View{
        
        if tripManager.trip.startDate == nil {
            Section(startTimePrompt){
                HStack{
                    Text("Start")
                    Spacer()
                    Picker("Day", selection: $tripManager.newEventStartDay){
                        ForEach(1..<(tripManager.trip.totalDays ?? 0)){ day in
                            Text("Day \(day)").tag(day)
                        }
                    }
                    .labelsHidden()
                    DatePicker("Time", selection: $tripManager.newEventStartTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
            }
            
            Section(endTimePrompt){
                HStack{
                    Text("End")
                    Spacer()
                    Picker("Day", selection: $tripManager.newEventEndDay){
                        ForEach(1..<(tripManager.trip.totalDays ?? 0)){ day in
                            Text("Day \(day)").tag(day)
                        }
                    }
                    .labelsHidden()
                    DatePicker("Time", selection: $tripManager.newEventEndTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
            }
        } else {
            Section("Period"){
                DatePicker(startTimePrompt, 
                           selection: $tripManager.newEventStartTime,
                           in: tripManager.getTripRange())
                DatePicker(endTimePrompt, 
                           selection: $tripManager.newEventEndTime,
                           in: tripManager.getTripRange())
            }
            .onAppear{
                tripManager.newEventStartTime = Calendar.current.date(byAdding: .day, value: tripManager.selectedDay-1, to: tripManager.trip.startDate ?? .now) ?? .now
                tripManager.newEventEndTime = Calendar.current.date(byAdding: .day, value: tripManager.selectedDay-1, to: tripManager.trip.startDate ?? .now) ?? .now
            }
        }
    }
}

#Preview("Main View") {
    AddEventView(tripManager: TripManager(trip: itinerary4), addingEvent: .constant(false), previousView: .constant(false))
}

struct AddEventForm1_Previews: PreviewProvider {
    @Namespace static var namespace // <- This

    static var previews: some View {
        AddEventForm(tripManager: TripManager(trip: itinerary1), animation: namespace)
    }
}

struct AddEventForm2_Previews: PreviewProvider {
    @Namespace static var namespace // <- This

    static var previews: some View {
        AddEventForm(tripManager: TripManager(trip: itinerary4), animation: namespace)
    }
}

