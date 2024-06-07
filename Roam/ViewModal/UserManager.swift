//
//  UserManager.swift
//  Roam
//
//  Created by Jeremy Teng  on 30/04/2024.
//

import Foundation
import FirebaseFirestore

class UserManager: ObservableObject {
    
    private var firebaseController = FirebaseController.shared
    @Published var user: User
    
    init(user: User) {
        self.user = user
    }
    
    func addNewTrip(title: String, destination: String, totalDays: Int,startDate: Date?, endDate: Date?, pax: Int?) async -> Bool{
        
        // check is the endDate after startDate
        if let endDate = endDate, let startDate = startDate {
            if endDate < startDate{
                return false
            }
        }
        
        let tripImage = await UnsplashAPI(query: destination)
        print("New trip", tripImage.imageURL)
        
        var trip = Trip(image: tripImage.imageURL, title: title, destination: destination, startDate: startDate, endDate: endDate, totalDays: totalDays, pax: pax)
        
        for day in 0..<totalDays{
            trip.events.append(EventPerDay(day: day, events: []))
            trip.expenses.append(ExpensePerDay(day: day, expensesPerDay: []))
        }
        
        // add trip into the Firebase Trip collection
        if let documentReference = firebaseController.addDocument(itemToAdd: trip, collectionPath: "Trip", documentPath: trip.id.uuidString){
            
            // continue to add each array to a sepearate document in collection
            for day in 0..<totalDays{
                let _ = firebaseController.addDocument(itemToAdd: trip.events[day], collectionPath: "Trip/\(trip.id.uuidString)/events", documentPath: trip.events[day].id.uuidString)
                let _ = firebaseController.addDocument(itemToAdd: trip.expenses[day], collectionPath: "Trip/\(trip.id.uuidString)/expenses", documentPath: trip.expenses[day].id.uuidString)
            }
            
            // if add succesful, add reference into User document
            firebaseController.addReferenceToArray(referenceToAdd: documentReference,
                                                   collectionPath: "User",
                                                   documentPath: firebaseController.currentUser?.uid ?? "",
                                                   attributeName: "trips")
        }
        return true
    }
    
    func deleteTrip(indexSet: IndexSet){
        for offset in indexSet{
            let tripDeleted = self.user.trips[offset]
            Task{
                // first delete the document from Trip collection
                if let documentReference = await firebaseController.deleteDocument(collectionPath: "Trip", documentPath: tripDeleted.id.uuidString){
                    
                    // if delete successful, delete reference from User document
                    await firebaseController.removeReferenceFromarray(referenceToRemove: documentReference, collectionPath: "User", documentPath: firebaseController.currentUser?.uid ?? "", attributeName: "trips")
                    
                    for day in 0..<(tripDeleted.totalDays ?? 0){
                        let _ = await firebaseController.deleteDocument(collectionPath: "Trip/\(tripDeleted.id.uuidString)/events", documentPath: tripDeleted.events[day].id.uuidString)
                        let _ = await firebaseController.deleteDocument(collectionPath: "Trip/\(tripDeleted.id.uuidString)/expenses", documentPath: tripDeleted.expenses[day].id.uuidString)
                    }
                    
                }
            }
        }
    }
    
    func addTripFromGuide(guideTrip: Trip, name: String){
        
        // first, we need to deep coopy the trip
    }
    
    func addNewPost(title: String, content: String){
        
        let newPost = Post(authorID: user.id ?? "", authorName: user.name ?? "", authorImage: user.image ?? "", title: title, content: content)
        
        // creat a document to save post into Post collection
        if let documentPath = firebaseController.addDocument(itemToAdd: newPost, collectionPath: "Post", documentPath: newPost.id.uuidString){
            
            // then stored its reference into user documet
            firebaseController.addReferenceToArray(referenceToAdd: documentPath, collectionPath: "User", documentPath: firebaseController.currentUser?.uid ?? "", attributeName: "posts")
        }
    }
    
    func addNewGuide(trip: Trip){
        
        let tripCopy = Trip(trip: trip)
        let newGuide = Guide(authorID: user.id ?? "", authorName: user.name ?? "", authorImage: user.image ?? "", itinerary: tripCopy)

        var tripDocRef = self.tripDeepCopy(tripCopy: trip)
                
//         creat a document to save post into Post collection
        if let documentPath = firebaseController.addDocument(itemToAdd: newGuide, collectionPath: "Guide", documentPath: newGuide.id.uuidString){
            
            // add the trip document reference into the guide document
            if let tripDocRef = tripDocRef{
                firebaseController.updateField(object: tripDocRef, collectionPath: "Guide", documentPath: newGuide.id.uuidString, attributeName: "itinerary")
            }
            
            // then stored its reference into user documet
            firebaseController.addReferenceToArray(referenceToAdd: documentPath, collectionPath: "User", documentPath: firebaseController.currentUser?.uid ?? "", attributeName: "guides")
        }
    }
    
    
    func deletePost(){
        
    }
    
    func editPost(){
        
    }
    
    private func tripDeepCopy(tripCopy: Trip) -> DocumentReference?{
        
        let tripDocRef = firebaseController.addDocument(itemToAdd: tripCopy, collectionPath: "Trip", documentPath: tripCopy.id.uuidString)
        
        // add each of the event per day as a subcollection in trip document
        for eventPerDay in tripCopy.events {
            let _ = firebaseController.addDocument(itemToAdd: eventPerDay, collectionPath: "Trip/\(tripCopy.id.uuidString)/events", documentPath: eventPerDay.id.uuidString)
            for event in eventPerDay.events {
                
                // create a new documennt inside the event collection, then store the reference inside the event per day document
                if let eventDoocRef = firebaseController.addDocument(itemToAdd: event, collectionPath: "Event", documentPath: event.id.uuidString){
                    firebaseController.addReferenceToArray(referenceToAdd: eventDoocRef, collectionPath: "Trip/\(tripCopy.id.uuidString)/events", documentPath: eventPerDay.id.uuidString, attributeName: "events")
                }
            }
        }
        
        for expensePerDay in tripCopy.expenses{
            let _ = firebaseController.addDocument(itemToAdd: expensePerDay, collectionPath: "Trip/\(tripCopy.id.uuidString)/expenses", documentPath: expensePerDay.id.uuidString)
            for expense in expensePerDay.expensesPerDay {
                
                if let expenseDocRef = firebaseController.addDocument(itemToAdd: expense, collectionPath: "Expense", documentPath: expense.id.uuidString){
                    firebaseController.addReferenceToArray(referenceToAdd: expenseDocRef, collectionPath: "Trip/\(tripCopy.id.uuidString)/expenses", documentPath: expensePerDay.id.uuidString, attributeName: "expensesPerDay")
                }
            }
        }
        
        for checklistCategory in tripCopy.checklist{
            let _ = firebaseController.addDocument(itemToAdd: checklistCategory, collectionPath: "Trip/\(tripCopy.id.uuidString)/checklists", documentPath: checklistCategory.id.uuidString)
            
            for checklist in checklistCategory.checklists {
                
                if let checklistDocRef = firebaseController.addDocument(itemToAdd: checklist, collectionPath: "Checklist", documentPath: checklist.id.uuidString){
                    firebaseController.addReferenceToArray(referenceToAdd: checklistDocRef, collectionPath: "Trip/\(tripCopy.id.uuidString)/checklists", documentPath: checklistCategory.id.uuidString, attributeName: "checklists")
                }
            }
        }
        
        for savedPlace in tripCopy.savedPlaces {
            let _ = firebaseController.addDocument(itemToAdd: savedPlace, collectionPath: "Trip/\(tripCopy.id.uuidString)/savedPlaces", documentPath: savedPlace.id.uuidString)
        }
        
        if let tripDocRef = tripDocRef{
            return tripDocRef
        }
        return nil
    }
}
