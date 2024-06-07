//
//  UserManager.swift
//  Roam
//
//  Created by Jeremy Teng  on 30/04/2024.
//

import Foundation

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
    
    func addNewPost(title: String, content: String){
        
        let newPost = Post(authorID: user.id ?? "", authorName: user.name ?? "", authorImage: user.image ?? "", title: title, content: content)
        
        // creat a document to save post into Post collection
        if let documentPath = firebaseController.addDocument(itemToAdd: newPost, collectionPath: "Post", documentPath: newPost.id.uuidString){
            
            // then stored its reference into user documet
            firebaseController.addReferenceToArray(referenceToAdd: documentPath, collectionPath: "User", documentPath: firebaseController.currentUser?.uid ?? "", attributeName: "posts")
        }
    }
    
    func addNewGuide(trip: Trip){
        
        let newGuide = Guide(authorID: user.id ?? "", authorName: user.name ?? "", authorImage: user.image ?? "", itinerary: trip)
        
        // creat a document to save post into Post collection
        if let documentPath = firebaseController.addDocument(itemToAdd: newGuide, collectionPath: "Guide", documentPath: newGuide.id.uuidString){
            
            // add the trip document reference into the guide document
            firebaseController.updateField(object: firebaseController.db.collection("Trip").document(trip.id.uuidString),
                                           collectionPath: "Guide", documentPath: newGuide.id.uuidString, attributeName: "itinerary")
            
            // then stored its reference into user documet
            firebaseController.addReferenceToArray(referenceToAdd: documentPath, collectionPath: "User", documentPath: firebaseController.currentUser?.uid ?? "", attributeName: "guides")
        }
    }
    
    
    func deletePost(){
        
    }
    
    func editPost(){
        
    }
}
