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
    @Published var newListIcon: SavePlaceIcon = .walk
    @Published var newListColor: SavedPlaceColor = .red
    @Published var selectedDay: Int = 1
    
    @Published var newEventType: EventType = .flight
    @Published var newEventName = ""
    @Published var newEventStartTime: Date = .now
    @Published var newEventEndTime: Date = .now
    @Published var newEventStartDay: Int = 1
    @Published var newEventEndDay: Int = 1
    @Published var newEventLocation: LocationData?
    @Published var newEventDestination: LocationData?
    @Published var newEventErrorMessage: String = ""
    
    @Published var newExpenseType: ExpenseCategory = .food
    @Published var newExpenseTitle: String = ""
    @Published var newExpenseDate: Date = .now
    @Published var newExpenseDay: Int = 1
    @Published var newExpenseAmount: Double = 0
    
    @Published var newCheckListContent: String = ""
    
    init(trip: Trip){
        self.trip = trip
    }
    
    func getTripRange() -> ClosedRange<Date> {
        return (trip.startDate ?? Date()) ... (trip.endDate ?? Date())
    }
    
    func getDistanceTwoEvent(day: Int, eventsOfTheDay: [Event], event:Event ) -> Int{
        
        // get the index of event in itineraryDay
        let index = eventsOfTheDay.firstIndex(of: event)
        if index == 0 {
            if event.startDay == event.endDay || event.startDay == day{
                let component = Calendar.current.dateComponents([.hour, .minute], from: event.startTime)
                let minutes = (component.hour ?? 0) * 60 + (component.minute ?? 0)
                return Int(Double(minutes) * 1.5)
            } else {
                return 0
            }
        }
        
        let component = Calendar.current.dateComponents([.minute], from: eventsOfTheDay[(index ?? 0)-1].endTime, to: event.startTime)
        return Int(Double(component.minute ?? 0) * 1.5)
    }
}

// Functionality of SavePlaceList
extension TripManager {
    
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
}

// Functionlity of trip Event
extension TripManager {
    func saveEvent() -> Bool{
        if newEventStartTime > newEventEndTime || newEventStartDay > newEventEndDay {
            newEventErrorMessage = "End time cannot be before start time."
            return false
        }
        
        // if trip have exact date
        if trip.startDate != nil {
            // get the number of day in a trip with the date given
            newEventStartDay = (Calendar.current.dateComponents([.day], from: trip.startDate ?? .now, to: newEventStartTime).day ?? 0)+1
            newEventEndDay = (Calendar.current.dateComponents([.day], from: trip.startDate ?? .now, to: newEventEndTime).day ?? 0)+1
        }
        
        guard let location = newEventLocation else {
            newEventErrorMessage = "Event must have a location."
            return false
        }
        
        let newEvent = Event(type: newEventType.rawValue, startDay: newEventStartDay, endDay: newEventEndDay, startTime: newEventStartTime, endTime: newEventEndTime, location:Location(locationData: location) )
        
        for day in newEventStartDay ... newEventEndDay {
            if trip.events[day] == nil {
                trip.events.updateValue([newEvent], forKey: day)
            } else {
                trip.events[day]?.append(newEvent)
            }
        }
        
        return true
    }
}

// Functionality of expense
extension TripManager{
    
    func saveNewExpense(){
        
        var newExpense: Expense
        // if trip have exact date
        if trip.startDate != nil {
            // get the number of day in a trip based ont he date given
            newExpenseDay = (Calendar.current.dateComponents([.day], from: trip.startDate ?? .now, to: newExpenseDate).day ?? 0)+1
            newExpense = Expense(catogery: newExpenseType.rawValue, title: newExpenseTitle, amount: newExpenseAmount, day: newExpenseDay, date: newExpenseDate)
        } else{
            newExpense = Expense(catogery: newExpenseType.rawValue, title: newExpenseTitle, amount: newExpenseAmount, day: newExpenseDay)
        }
        
        // add expense into trip
        if trip.expenses[newExpenseDay] == nil {
            trip.expenses.updateValue([newExpense], forKey: newExpenseDay)
        } else {
            trip.expenses[newExpenseDay]?.append(newExpense)
        }        
    }
}

extension TripManager{
    
    func check(checkList: Checklist){
        if let index = trip.checklist.firstIndex(of: checkList){
            var deletedItem = trip.checklist.remove(at: index)
            deletedItem.completed.toggle()
            trip.checklist.append(deletedItem)
        }
    }
    
    func uncheck(checkList: Checklist){
        if let index = trip.checklist.firstIndex(of: checkList){
            var uncheckItem = trip.checklist.remove(at: index)
            uncheckItem.completed.toggle()
            trip.checklist.insert(uncheckItem, at: 0)
        }
    }
    
    func addNewChecklistItem(){
        let newItem = Checklist(title: newCheckListContent)
        trip.checklist.append(newItem)
        newCheckListContent = ""
    }
}

