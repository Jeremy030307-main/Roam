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
    
    private var firebaseController = FirebaseController.shared
    
    init(trip: Trip){
        self.trip = trip
    }
    
    func getTripRange() -> ClosedRange<Date> {
        return Calendar.current.startOfDay(for: trip.startDate ?? Date()) ... Calendar.current.startOfDay(for: trip.endDate ?? Date())
    }
    
    func getDistanceTwoEvent(day: Int, eventIndex: Int) -> Int{
        
        let event = trip.events[day-1].events[eventIndex]
        let component = Calendar.current.dateComponents([.hour, .minute], from: event.startTime)
        let minutes = (component.hour ?? 0) * 60 + (component.minute ?? 0)

        if eventIndex == 0 {
            if event.startDay == event.endDay || event.startDay == day{
                return Int(Double(minutes) * 1.5)
            } else {
                return 0
            }
        }
        let previousEvent = trip.events[day-1].events[eventIndex-1]
        if previousEvent.endDay == event.startDay{
            let previousComponent = Calendar.current.dateComponents([.hour, .minute], from: previousEvent.endTime)
            let previousMinutes = (previousComponent.hour ?? 0) * 60 + (previousComponent.minute ?? 0)
            return Int(Double(minutes-previousMinutes) * 1.5)
        } else{
            let previousComponent = Calendar.current.dateComponents([.hour, .minute], from: previousEvent.startTime)
            let previousMinutes = (previousComponent.hour ?? 0) * 60 + (previousComponent.minute ?? 0)
            return Int(Double(minutes-previousMinutes-45) * 1.5)
        }
    }
}

// Functionality of SavePlaceList
extension TripManager {
    
    func addNewList(){
        let newSavedPlace = SavedPlace(title: newListTitle, icon: newListIcon.rawValue, color: newListColor.rawValue)
        
        let _ = firebaseController.addDocument(itemToAdd: newSavedPlace, collectionPath: "Trip/\(trip.id.uuidString)/savedPlaces", documentPath: newSavedPlace.id.uuidString)
        
        newListTitle = ""
        newListIcon = .mappin
        newListColor = .red
    }
    
    func deleteList(at indexSet: IndexSet){        
        for offset in indexSet{
            let deleteSavedPlace = trip.savedPlaces[offset]
            Task{
                await firebaseController.deleteDocument(collectionPath:"Trip/\(trip.id.uuidString)/savedPlaces", documentPath:deleteSavedPlace.id.uuidString)
            }
        }
    }
    
    func addItemToList(categoryIndex: Int, locationData: LocationData){
        
        let category = trip.savedPlaces[categoryIndex]
        let newLocation = Location(locationData: locationData)
        firebaseController.addToArray(itemToAdd: newLocation, collectionPath: "Trip/\(trip.id.uuidString)/savedPlaces", documentPath: category.id.uuidString, attributeName: "places")
    }
    
    func deleteSavedPlace(categoryIndex: Int, itemIndex: Int){
        
        let savedPlacesList = trip.savedPlaces[categoryIndex]
        let itemToDelete = savedPlacesList.places[itemIndex]
        
        Task {
            await firebaseController.removeFromArray(itemToremove: itemToDelete, collectionPath: "Trip/\(trip.id.uuidString)/savedPlaces", documentPath: savedPlacesList.id.uuidString, attributeName: "places")
        }
    }
}

// Functionlity of trip Event
extension TripManager {
    
    func saveEvent(defaultLocation: Location?) -> Bool{
        
        // error handling to prevent user to save event with invalid time period and location
        if trip.startDate != nil {
            
            if newEventStartTime > newEventEndTime {
                newEventErrorMessage = "End time cannot be before start time."
                return false
            }
            
            // get the number of day in a trip with the date given
            let tripStartDate = Calendar.current.dateComponents([.day], from: trip.startDate ?? .now).day ?? 0
            newEventStartDay = (Calendar.current.dateComponents([.day], from: newEventStartTime).day ?? 0) - tripStartDate + 1
            newEventEndDay = (Calendar.current.dateComponents([.day], from: newEventEndTime).day ?? 0) - tripStartDate + 1
            
        } else {
            if newEventStartDay > newEventEndDay{
                newEventErrorMessage = "End time cannot be before start time."
                return false
            } else if newEventStartDay == newEventEndDay {
                
                let startHour = Calendar.current.dateComponents([.hour], from: newEventStartTime).hour ?? 0
                let startMin = Calendar.current.dateComponents([.minute], from: newEventStartTime).minute ?? 0
                let endHour = Calendar.current.dateComponents([.hour], from: newEventEndTime).hour ?? 0
                let endMin = Calendar.current.dateComponents([.minute], from: newEventEndTime).minute ?? 0
                if (endHour*60 + endMin) < (startHour*60 + startMin) {
                    newEventErrorMessage = "End time cannot be before start time."
                    return false
                }
            }
        }
        
        let locationToSave: Location
        if let defaultLocation = defaultLocation {
            locationToSave = defaultLocation
        } else {
            guard let location = newEventLocation else {
                newEventErrorMessage = "Event must have a location."
                return false
            }
            locationToSave = Location(locationData: location)
        }
        
        let newEvent = Event(type: newEventType.rawValue, startDay: newEventStartDay, endDay: newEventEndDay, startTime: newEventStartTime, endTime: newEventEndTime, location:locationToSave)
        
        // check is the event clash with another event
        if let eventclash = self.isPeriodOccupied(newEvent: newEvent){
            var dateFormatter: DateFormatter {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.dateFormat = "HH:mm"
                return formatter
            }

            newEventErrorMessage = "Clash with \(eventclash.location.name ?? "") at \(dateFormatter.string(from: eventclash.startTime)) - \(dateFormatter.string(from: eventclash.endTime))"
            return false
        }
        
        // if the event created is a valid event, start to add into Firebase
        if let documentPath = firebaseController.addDocument(itemToAdd: newEvent, collectionPath: "Event", documentPath: newEvent.id.uuidString){
            for day in newEventStartDay ... newEventEndDay {
                let eventPerDay = trip.events[day-1]
                firebaseController.addReferenceToArray(referenceToAdd: documentPath, collectionPath: "Trip/\(trip.id.uuidString)/events", documentPath: eventPerDay.id.uuidString, attributeName: "events")
            }
            return true
        }
        return false
    }
    
    func deleteEvent(eventDay: Int, eventIndex: Int){
        
        let eventToDelete = trip.events[eventDay-1].events[eventIndex]
        
        for day in eventToDelete.startDay ... eventToDelete.endDay {
            if let index = trip.events[day-1].events.firstIndex(where: {$0.id == eventToDelete.id }){
                trip.events[day-1].events.remove(at: index)
            }
        }
        
        Task{
            // first delete the document from Event collection
            if let documentReference = await firebaseController.deleteDocument(collectionPath: "Event", documentPath: eventToDelete.id.uuidString){
                
                for day in eventToDelete.startDay ... eventToDelete.endDay {
                    let eventPerDay = trip.events[day-1]
                    // next delete it reference from events document
                    await firebaseController.removeReferenceFromarray(referenceToRemove: documentReference, collectionPath: "Trip/\(trip.id.uuidString)/events", documentPath: eventPerDay.id.uuidString, attributeName: "events")
                }
            }
        }
    }
    
    func editEvent(eventDay: Int, eventIndex: Int,eventCategory: EventType, startDay: Int, endDay: Int, startTime: Date, endTime: Date, location: LocationData?, destination: LocationData?) -> Bool {
        
        let eventToEdit = trip.events[eventDay-1].events[eventIndex]
        var edittingStartDay = startDay
        var edittingEndDay = endDay
        
        // if trip have exact date
        if trip.startDate != nil {
            
            if startTime > endTime {
                newEventErrorMessage = "End time cannot be before start time."
                return false
            }
            // get the number of day in a trip with the date given
            let tripStartDate = Calendar.current.dateComponents([.day], from: trip.startDate ?? .now).day ?? 0
            edittingStartDay = (Calendar.current.dateComponents([.day], from: startTime).day ?? 0) - tripStartDate + 1
            edittingEndDay = (Calendar.current.dateComponents([.day], from: endTime).day ?? 0) - tripStartDate + 1
        } else {
            if edittingStartDay > edittingEndDay{
                newEventErrorMessage = "End time cannot be before start time."
                return false
            } else if edittingStartDay == edittingEndDay {
                
                let startHour = Calendar.current.dateComponents([.hour], from: newEventStartTime).day ?? 0
                let startMin = Calendar.current.dateComponents([.minute], from: newEventStartTime).day ?? 0
                let endHour = Calendar.current.dateComponents([.hour], from: newEventEndTime).day ?? 0
                let endMin = Calendar.current.dateComponents([.minute], from: newEventEndTime).day ?? 0
                if (endHour*60 + endMin) < (startHour*60 + startMin) {
                    newEventErrorMessage = "End time cannot be before start time."
                    return false
                }
            }
        }
        
        guard let location = location else {
            newEventErrorMessage = "Event must have a location."
            return false
        }
        
        var newEvent = Event(type: eventCategory.rawValue, startDay: edittingStartDay, endDay: edittingEndDay, startTime: startTime, endTime: endTime, location:Location(locationData: location), expense: eventToEdit.expense)
        newEvent.id = eventToEdit.id
        
        let _ = firebaseController.addDocument(itemToAdd: newEvent, collectionPath: "Event", documentPath: newEvent.id.uuidString)

        return true
    }
    
    func isPeriodOccupied(newEvent: Event) -> Event?{
                
        let eventStartDay = newEvent.startDay
        let eventEndDay = newEvent.endDay
        
        let startHour = Calendar.current.dateComponents([.hour], from: newEvent.startTime).hour ?? 0
        let startMin = Calendar.current.dateComponents([.minute], from: newEvent.startTime).minute ?? 0
        let endHour = Calendar.current.dateComponents([.hour], from: newEvent.endTime).hour ?? 0
        let endMin = Calendar.current.dateComponents([.minute], from: newEvent.endTime).minute ?? 0
        
        for day in eventStartDay ... eventEndDay {
            
            var startMinutesAfter = startHour*60 + startMin
            var endMinutesAfter = endHour*60 + endMin
            
            if eventStartDay != eventEndDay {
                if day != eventStartDay{
                    startMinutesAfter = 0
                }
                if day != eventEndDay {
                    endMinutesAfter = 12*60
                }
            }
            
            let eventAddedRange = startMinutesAfter ... endMinutesAfter

            for event in trip.events[day-1].events{
                let existStartHour = Calendar.current.dateComponents([.hour], from: event.startTime).hour ?? 0
                let existStartMin = Calendar.current.dateComponents([.minute], from: event.startTime).minute ?? 0
                let existEndHour = Calendar.current.dateComponents([.hour], from: event.endTime).hour ?? 0
                let existEndMin = Calendar.current.dateComponents([.minute], from: event.endTime).minute ?? 0
                var existStartMinutesAfter = existStartHour*60 + existStartMin
                var existEndMinutesAfter = existEndHour*60 + existEndMin
                
                if event.startDay != event.endDay {
                    if day != event.startDay{
                        existStartMinutesAfter = 0
                    }
                    if day != event.endDay {
                        existEndMinutesAfter = 12*60
                    }
                }
                let eventExistRange = existStartMinutesAfter ... existEndMinutesAfter
                
                // check weather the existing start time or end time is withini the ragne of newly added event, if yes it is occupied
                if eventAddedRange.contains(existStartMinutesAfter) && eventAddedRange.contains(existEndMinutesAfter) {
                    return event
                }
                if eventExistRange.contains(startMinutesAfter) || eventExistRange.contains(endMinutesAfter){
                    return event
                }
                
            }
        }
        return nil
    }
    
    func updateEventExpense(eventDay: Int, eventIndex: Int, amount: Double){
        
        let eventToAddExpense = trip.events[eventDay-1].events[eventIndex]
        firebaseController.updateField(object: amount, collectionPath:"Event", documentPath:eventToAddExpense.id.uuidString, attributeName:"expense")
    }
}

// Functionality of expense
extension TripManager{
    
    func saveNewExpense(){
        
        var newExpense: Expense
        // if trip have exact date
        if trip.startDate != nil {
            // get the number of day in a trip based ont he date given
            let tripStartDate = Calendar.current.dateComponents([.day], from: trip.startDate ?? .now).day ?? 0
            newExpenseDay = (Calendar.current.dateComponents([.day], from: newExpenseDate).day ?? 0) - tripStartDate + 1
            newExpense = Expense(catogery: newExpenseType.rawValue, title: newExpenseTitle, amount: newExpenseAmount, day: newExpenseDay, date: newExpenseDate)
        } else{
            newExpense = Expense(catogery: newExpenseType.rawValue, title: newExpenseTitle, amount: newExpenseAmount, day: newExpenseDay)
        }
        
        let expenseDay = trip.expenses[newExpenseDay-1]
        // add expense into trip
        trip.expenses[newExpenseDay-1].expensesPerDay.append(newExpense)
        
        // first add expense into Expense collection
        if let documentPath = firebaseController.addDocument(itemToAdd: newExpense, collectionPath: "Expense", documentPath: newExpense.id.uuidString){
            
            firebaseController.addReferenceToArray(referenceToAdd: documentPath, collectionPath: "Trip/\(trip.id.uuidString)/expenses", documentPath: expenseDay.id.uuidString, attributeName: "expensesPerDay")
        }
    }
    
    func editExpense(expenseDay: Int, expenseIndex: Int, expenseCaegory: ExpenseCategory, title: String, amount: Double, date: Date?, day: Int?){
        
        let expenseToEdit = trip.expenses[expenseDay-1].expensesPerDay[expenseIndex]

        var newExpense: Expense
        // if trip have exact date
        if trip.startDate != nil {
            // get the number of day in a trip based ont he date given
            let tripStartDate = Calendar.current.dateComponents([.day], from: trip.startDate ?? .now).day ?? 0
            let updatedDay = (Calendar.current.dateComponents([.day], from: date!).day ?? 0) - tripStartDate + 1
            newExpense = Expense(catogery: expenseCaegory.rawValue, title: title, amount: amount, day: updatedDay, date: date)
        } else{
            newExpense = Expense(catogery: expenseCaegory.rawValue, title: title, amount: amount, day: day ?? 0)
        }
        
        newExpense.id = expenseToEdit.id
        
        let _ = firebaseController.addDocument(itemToAdd: newExpense, collectionPath: "Expense", documentPath: newExpense.id.uuidString)
    }
    
    func deleteExpense(expenseDay: Int, expenseIndex: Int){
        let expensePerDay = trip.expenses[expenseDay-1]
        let deleteExpense = expensePerDay.expensesPerDay[expenseIndex]
        
        Task{
            // first delete the document from ChecklistItem collection
            if let documentReference = await firebaseController.deleteDocument(collectionPath: "Expense", documentPath: deleteExpense.id.uuidString){
                
                // next delete it reference from Trip document
                await firebaseController.removeReferenceFromarray(referenceToRemove: documentReference, collectionPath: "Trip/\(trip.id.uuidString)/expenses", documentPath: expensePerDay.id.uuidString, attributeName: "expensesPerDay")
            }
        }
    }
    
}

// Functionality of checklist
extension TripManager{
    
    func check(categoryIndex: Int, checklistIndex: Int ) {
        
        let checkedItem = trip.checklist[categoryIndex].checklists[checklistIndex]
        let state = checkedItem.completed ?? false
    
        firebaseController.updateField(object: !state, collectionPath:"Checklist", documentPath: checkedItem.id.uuidString, attributeName: "completed")
    }

    func addNewCheckListItem(cateogryIndex: Int, newContent: String) {
        
        let checkListCategory = trip.checklist[cateogryIndex]
        let newChecklist = Checklist(title: newContent, catagoryID: checkListCategory.id.uuidString)
        
        // add new checklist item into Checklist collection
        if let documentRPath = firebaseController.addDocument(itemToAdd: newChecklist, collectionPath: "Checklist", documentPath: newChecklist.id.uuidString){
            
            firebaseController.addReferenceToArray(referenceToAdd: documentRPath, collectionPath: "Trip/\(trip.id.uuidString)/checklists", documentPath: checkListCategory.id.uuidString, attributeName: "checklists")
        }
        
    }
    
    func editChecklistItem(categoryIndex: Int, checklistIndex: Int, updatedContent: String){
        
        let checkedItem = trip.checklist[categoryIndex].checklists[checklistIndex]
        firebaseController.updateField(object: updatedContent, collectionPath:"Checklist", documentPath: checkedItem.id.uuidString, attributeName: "title")
    }
    
    func deleteChecklistItem(at indexSet: IndexSet, categoryIndex: Int){
        
        let checklistCategory = trip.checklist[categoryIndex]
        // update changes to dataabase
        
        for offset in indexSet{
            let checklistDeleted = checklistCategory.checklists[offset]
            Task{
                // first delete the document from ChecklistItem collection
                if let documentReference = await firebaseController.deleteDocument(collectionPath: "Checklist", documentPath: checklistDeleted.id.uuidString){
                    
                    // next delete it reference from Trip document
                    await firebaseController.removeReferenceFromarray(referenceToRemove: documentReference, collectionPath: "Trip/\(trip.id.uuidString)/checklists", documentPath: checklistCategory.id.uuidString, attributeName: "checklists")
                }
            }
        }
    }
    
    func addNewCheckCatogory(categoryName: String){
        let newCategory = ChecklistCateogry(category_name: categoryName, checklists: [])
        let _ = firebaseController.addDocument(itemToAdd: newCategory, collectionPath: "Trip/\(trip.id.uuidString)/checklists", documentPath: newCategory.id.uuidString)
    }
}

