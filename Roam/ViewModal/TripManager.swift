//
//  TripManager.swift
//  Roam
//
//  Created by Jeremy Teng  on 28/04/2024.
//

import UIKit

class TripManager: ObservableObject {

    @Published var trip: Trip;
    
    @Published var newListTitle: String = ""
    @Published var newListIcon: SavePlaceIcon = .mappin
    @Published var newListColor: SavedPlaceColor = .red
    @Published var selectedDay: Int = 1
    
    @Published var newEventType: EventType = EventType.activity
    @Published var newEventStartTime: Date = .now
    @Published var newEventEndTime: Date = .now
    @Published var newEventLocation: Location = Location(name: "Example", address: "blablabal", rating: 3.5, descrition: "blablabla", phone: "2343245324324", operatingHour: "Fri - Mon")
    
    init(trip: Trip){
        self.trip = trip
    }
    
    func addNewList(){
        let newSavedPlace = SavedPlace(title: newListTitle, icon: newListIcon.rawValue, color: newListColor.rawValue)
        trip.savedPlaces.append(newSavedPlace)
        newListTitle = ""
        newListIcon = .mappin
        newListColor = .red
    }
    
    func deleteList(at offset: IndexSet){
        trip.savedPlaces.remove(atOffsets: offset)
    }
    
    func moveList(from source: IndexSet, to destination: Int) {
        trip.savedPlaces.move(fromOffsets: source, toOffset: destination)
        }
    
    func getDistanceTwoEvent(itineraryDay: [Event], event:Event ) -> Int{
        
        // get the index of event in itineraryDay
        let index = itineraryDay.firstIndex(of: event)
        if index == 0 {
            let component = Calendar.current.dateComponents([.hour, .minute], from: event.startTime)
            let minutes = (component.hour ?? 0) * 60 + (component.minute ?? 0)
            return Int(Double(minutes) * 1.5)
        }
        
        let component = Calendar.current.dateComponents([.minute], from: itineraryDay[(index ?? 0)-1].endTime, to: event.startTime)
        return Int(Double(component.minute ?? 0) * 1.5)
    }
    
    func savedEvent() -> Bool {

//        newEventStartTime = formatter1.date(from: "2024-03-07 22:10") ?? .now
//        newEventEndTime = formatter1.date(from: "2024-03-07 23:10") ?? .now
        
        let event = Event(type: newEventType.rawValue,
                          startTime: newEventStartTime,
                          endTime: newEventEndTime,
                          location: Location(name: "Example", address: "blablabal", rating: 3.5, descrition: "blablabla", phone: "2343245324324", operatingHour: "Fri - Mon"))
        
        if newEventStartTime > newEventEndTime{
            return false
        }
        trip.days[1]?.append(event)
        
        // check is the starTime is within temporary
        if trip.startDate != nil && trip.endDate != nil {
            if (newEventStartTime < trip.startDate!) || (newEventEndTime > trip.endDate!){
                return false
            }
        } else {
            if trip.days[selectedDay] == nil {
                trip.days.updateValue([event], forKey: selectedDay)
            } else {
                trip.days[selectedDay]?.append(event)
            }
        }
        
        // get the date out from datetime
        let dateComponent1 = Calendar.current.dateComponents([.day, .month, .year], from: newEventStartTime)
        let dateComponent2 = Calendar.current.dateComponents([.day, .month, .year], from: newEventEndTime)
        
        let formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()
        
        let eventStartDate = formatter.date(from: "\(dateComponent1.year ?? 0)-\(dateComponent1.month ?? 0)-\(dateComponent1.day ?? 00)") ?? .now
        let eventEndDate = formatter.date(from: "\(dateComponent2.year ?? 0)-\(dateComponent2.month ?? 0)-\(dateComponent2.day ?? 00)") ?? .now
        
        // get the number of day in this trip
        let eventStartDay = (Calendar.current.dateComponents([.day], from: trip.startDate ?? .now, to: eventStartDate).day ?? 0)+1
        let eventEndDay = (Calendar.current.dateComponents([.day], from: trip.startDate ?? .now, to: eventEndDate).day ?? 0)+1
        
        if eventStartDay == eventEndDay {
            let event = Event(type: newEventType.rawValue, startTime: newEventStartTime, endTime: newEventEndTime, location: newEventLocation)
            if trip.days[eventStartDay] == nil {
                trip.days.updateValue([event], forKey: eventStartDay)
            } else {
                trip.days[eventStartDay]?.append(event)
            }
            return true
        } else {
            let event1 = Event(type: newEventType.rawValue, startTime: newEventStartTime, endTime: eventEndDate, location: newEventLocation)
            let event2 = Event(type: newEventType.rawValue, startTime: eventEndDate, endTime: newEventEndTime, location: newEventLocation)
            trip.days[eventStartDay]?.append(event1)
            trip.days[eventEndDay]?.append(event2)
            return true
        }
        
    }
    
}

