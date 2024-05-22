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
    @State var selectedCategory = false
    @State var didError = false
    
    @Namespace var enterCatogeoryFormAnimation
    
    var body: some View {
        NavigationStack{
            
            Form{
            switch selectedCategory {
            case true:
                AddEventForm(tripManager: tripManager, animation: enterCatogeoryFormAnimation)
            case false:
                    Section("Add New Event"){
                        ForEach(EventType.allCases) {type in
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
                    .headerProminence(.increased)
                }
            }
            .toolbar{
                ToolbarItem(placement: .topBarLeading) {
                    if selectedCategory == true{
                        Button("Cancel"){
                            withAnimation {
                                selectedCategory.toggle()
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
                            let result = tripManager.saveEvent()
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

    var body: some View {
//        Form{
            Section{
                Text(tripManager.trip.title).foregroundStyle(.secondary)
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
            Section("Name"){
                TextField("e.g., Morning Jog", text: $tripManager.newEventName)
            }
            AddEventDuration(tripManager: tripManager, startTimePrompt: "Start", endTimePrompt: "End")
            AddEventLocationSearch(tripManager: tripManager, locationType: .location, sectionName: "Location", prompt: "e.g., Library, Musuem")
        case .flight:
            AddEventDuration(tripManager: tripManager, startTimePrompt: "Depature", endTimePrompt: "Arrival")
            AddEventLocationSearch(tripManager: tripManager, locationType: .location, sectionName: "Depature Location", prompt: "e.g., Train Station, Bus Station")
            AddEventLocationSearch(tripManager: tripManager, locationType: .arrival, sectionName: "Arrival Location", prompt: "e.g., Train Station, Bus Station")
        case .accomodation:
            AddEventDuration(tripManager: tripManager, startTimePrompt: "Check In", endTimePrompt: "Check Out")
            AddEventLocationSearch(tripManager: tripManager, locationType: .location, sectionName: "Accomodation Name", prompt: "e.g., Hyatt, Shangri-La")
        case .restaurant:
            AddEventDuration(tripManager: tripManager, startTimePrompt: "Start", endTimePrompt: "End")
            AddEventLocationSearch(tripManager: tripManager, locationType: .location, sectionName: "Restaurant Name", prompt: "e.g., Italian, Starbucks")
        case .tour:
            Section("Tour Name"){
                TextField("e.g., Heli Tour, City One Day Trip", text: $tripManager.newEventName)
            }
            AddEventDuration(tripManager: tripManager, startTimePrompt: "Start", endTimePrompt: "End")
            AddEventLocationSearch(tripManager: tripManager, locationType: .location, sectionName: "Location", prompt: "e.g., Mountain, Train Station")
        case .transportation:
            AddEventDuration(tripManager: tripManager, startTimePrompt: "Depature", endTimePrompt: "Arrival")
            AddEventLocationSearch(tripManager: tripManager, locationType: .location, sectionName: "Depature Location", prompt: "e.g., Train Station, Bus Station")
            AddEventLocationSearch(tripManager: tripManager, locationType: .arrival, sectionName: "Arrival Location", prompt: "e.g., Train Station, Bus Station")
        case .carRental:
            AddEventDuration(tripManager: tripManager, startTimePrompt: "Pick Up", endTimePrompt: "Drop Off")
            AddEventLocationSearch(tripManager: tripManager, locationType: .location, sectionName: "Pick Up Location", prompt: "e.g., Train Station, Bus Station")

            AddEventLocationSearch(tripManager: tripManager, locationType: .arrival, sectionName: "Drop Off Location", prompt: "e.g., Train Station, Bus Station")
        }
//        }
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
    
    var body: some View{
        
        Section{
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

        } header: {
            Text(sectionName)
        } footer: {
            if locationType == .location{
                Text(tripManager.newEventLocation?.address ?? "")
            } else {
                Text(tripManager.newEventDestination?.address ?? "")
            }
        }
        
        .sheet(isPresented: $searchLocation){
            EventSearchLocationView(tripManager: tripManager, prompt: prompt, locationType: locationType)
        }
    }
    
    struct EventSearchLocationView: View {
        
        @Environment(\.dismiss) private var dismiss
        @ObservedObject var yelpFetcher = YelpFetcher()
        @ObservedObject var tripManager: TripManager
        @FocusState var isFocus: Bool
        var prompt: String
        var locationType: LocationType

        
        var body: some View{
            
            Form{
                Section("Location"){
                    TextField(prompt, text: $yelpFetcher.searchText)
                        .focused($isFocus)
                        .onSubmit {
                            Task{
                                await yelpFetcher.fetchAllLocation(categories:"")
                            }
                        }
                }

                ForEach(yelpFetcher.locations, id: \.self){ location in
                    Button {
                        switch locationType {
                        case .location:
                            tripManager.newEventLocation = location
                        case .arrival:
                            tripManager.newEventDestination = location
                        }
                        yelpFetcher.searchText = ""
                        dismiss()
                    } label: {
                        VStack(alignment: .leading){
                            Text(location.name ?? "").font(.headline)
                            Text(location.address ?? "").font(.subheadline)
                        }
                    }
                }
            }
            .onAppear{
                isFocus = true
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
                Picker("Day", selection: $tripManager.newEventStartDay){
                    ForEach(1..<tripManager.trip.totalDays){ day in
                        Text("Day \(day)").tag(day)
                    }
                }
                DatePicker("Time", selection: $tripManager.newEventStartTime, displayedComponents: .hourAndMinute)
            }
            
            Section(endTimePrompt){
                Picker("Day", selection: $tripManager.newEventStartDay){
                    ForEach(1..<tripManager.trip.totalDays){ day in
                        Text("Day \(day)").tag(day)
                    }
                }
                DatePicker("Time", selection: $tripManager.newEventEndTime, displayedComponents: .hourAndMinute)
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
        }
    }
}

#Preview("Main View") {
    AddEventView(tripManager: TripManager(trip: itinerary4), addingEvent: .constant(false))
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

