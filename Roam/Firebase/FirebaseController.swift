//
//  FirebaseController.swift
//  Roam
//
//  Created by Jeremy Teng  on 23/05/2024.
//

import Foundation
import Foundation
import FirebaseFirestore
import Firebase
import FirebaseAuth

class FirebaseController: ObservableObject{
    
    public static let shared = FirebaseController()
    @Published var user = User()
    @Published var post = [Post]()
    @Published var guide = [Guide]()
        
    private var db: Firestore
    var currentUser: FirebaseAuth.User?
    var errorMessage: String? 
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    private init(){
        db = Firestore.firestore()
        self.registerAuthStateHandler()
    }
    
    private func registerAuthStateHandler() {
        if authStateHandler == nil {
          authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
              self.currentUser = user
              self.fetchUser()
          }
        }
    }
    
    /**
     Add a user docuemnt into User collection
     - Parameters:
        - name: name of the user
        - username: username of user,
        - email: email of user
     */
    func addUser(name: String, username: String, email: String) -> Bool{
        
        guard let userID = currentUser?.uid else {
            print("User is nil")
            return false
        }
        
        let user = User(id: userID, name: name, username: username, email: email)
        do {
            try db.collection("User").document("\(userID)").setData(from: user)
            return true
        } catch let error {
          print("Error writing user to Firestore: \(error)")
        }
        return false
    }
}

// update functionality of fetching data from Firebase
extension FirebaseController{
    
    /**
     Fetch the docuemnt of the current log in user
     */
    private func fetchUser() {
        
        guard let userID = currentUser?.uid else {
            print("User is nil")
            return
        }
        
        db.collection("User").document(userID).addSnapshotListener(includeMetadataChanges: true) { userSnapshot, error in
            
            guard let userSnapshot = userSnapshot else {
                print("Error fetching current user. \(error!)")
                return
            }
            
            guard let userData = userSnapshot.data() else {
                print("User document was empty \(String(describing: error))")
                return
            }
            
            print(userSnapshot)
            print(userData)
            
            DispatchQueue.main.async {
                self.user = User()
                self.post = []
                self.guide = []
                self.user.id = userSnapshot.documentID
                self.user.name = userData["name"] as? String
                self.user.username = userData["name"] as? String
                self.user.email = userData["email"] as? String
                
                print(self.user)
                
                // convert the array of data to a list of documentReference that link to a specific file of firebase
                if let tripReferences = userData["trips"] as? [DocumentReference] {

                    let tripIDs = tripReferences.map({$0.documentID})
                    if !tripIDs.isEmpty{
                        self.fetchTrip(tripIDs: tripIDs)
                    }
                }
                
                self.fetchUserPost()
                self.fetchUserGuide()
                self.fetchFeed()

            }
        }
    }
    
    /**
     Fetch all the trip of the tripIDs and add into current usert
     - Parameters:
        - tripIDs: a list of string whic represent the id of an Trip object
     */
    private func fetchTrip(tripIDs: [String]){
        
        // fetch all the trip in the firebase that have the id within the provided string
        self.db.collection("Trip").whereField("id", in: tripIDs).addSnapshotListener { querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
              print("Error fetching snapshots: \(error!)")
              return
            }
            
            snapshot.documentChanges.forEach { change in
                var trip: Trip
                do {
                    trip = try change.document.data(as: Trip.self)
                } catch {
                    fatalError("Unable to decode trip: \(error)")
                }
                
                if (change.type == .added) && (!self.user.trips.contains(trip)){
                    DispatchQueue.main.async {
                        self.user.trips.insert(trip, at: Int(change.newIndex))
                    }
                    self.fetchEventPerDay(tripID: trip.id.uuidString, tripIndex: Int(change.newIndex), docRef: change.document.reference)
                    self.fetchSavedPlace(tripID: trip.id.uuidString, tripIndex: Int(change.newIndex), docRef: change.document.reference)
                    self.fetchExpensePerDay(tripID: trip.id.uuidString, tripIndex: Int(change.newIndex), docRef: change.document.reference)
                    self.fetchChecklistCategory(tripID: trip.id.uuidString, tripIndex: Int(change.newIndex), docRef: change.document.reference)
                    
                }
                if (change.type == .modified) {
                    DispatchQueue.main.async {
                        self.user.trips.remove(at: Int(change.oldIndex))
                        self.user.trips.insert(trip, at: Int(change.newIndex))
                    }
                    self.fetchEventPerDay(tripID: trip.id.uuidString, tripIndex: Int(change.newIndex), docRef: change.document.reference)
                    self.fetchSavedPlace(tripID: trip.id.uuidString, tripIndex: Int(change.newIndex), docRef: change.document.reference)
                    self.fetchExpensePerDay(tripID: trip.id.uuidString, tripIndex: Int(change.newIndex), docRef: change.document.reference)
                    self.fetchChecklistCategory(tripID: trip.id.uuidString, tripIndex: Int(change.newIndex), docRef: change.document.reference)

                }
                if (change.type == .removed) {
                    DispatchQueue.main.async {
                        self.user.trips.removeAll(where: {$0.id == trip.id})
                    }
                }
            }
        }
    }
    
    /**
     fetch all the EventPerDay object and add into the specific trip of a user
     - Parameters:
        - tripID: id of trip to add into
        - tripIndex: index of the trip in the user document
     */
    private func fetchEventPerDay(tripID: String, tripIndex: Int, docRef: DocumentReference){

        // fetch all the document in the subcollection "events" within a trip document
        docRef.collection("events").order(by: "day").addSnapshotListener { querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                
                let eventPerDayData = change.document.data()
                var eventPerDay: EventPerDay
                do {
                    eventPerDay = try change.document.data(as: EventPerDay.self)
                } catch {
                    fatalError("Unable to decode Event Per Day: \(error.localizedDescription)")
                }
                
                var validIndex = true
                if tripIndex >= self.user.trips.count{
                    validIndex = false
                }
                                
                if (change.type == .modified) && validIndex {
                    DispatchQueue.main.async {
                        self.user.trips[tripIndex].events.remove(at: Int(change.oldIndex))
                    }
                }
                
                var eventExist = false
                if validIndex{
                    if self.user.trips[tripIndex].events.contains(where: {$0.id == eventPerDay.id}){
                        eventExist = true
                    }
                }
                
                if ((change.type == .added) || (change.type == .modified)) && !eventExist && validIndex{
                    DispatchQueue.main.async {
                        self.user.trips[tripIndex].events.insert(eventPerDay, at: Int(change.newIndex))
                    }
                    
                    // convert that array od data fetched into a list of documentReference, then convert each of them to respective documentID
                    if let eventReference = eventPerDayData["events"] as? [DocumentReference] {
                        
                        let eventIDs = eventReference.map({$0.documentID})
                        if !eventIDs.isEmpty{
                            self.fetchEvent(eventIDs: eventIDs, tripIndex: tripIndex, eventPerDayIndex: Int(change.newIndex), tripID: tripID)
                        }
                    }
                }
            }
        }
    }
    
    /**
     fetch all the Event in the eventPerday object and add under user document
     - Parameters:
        - eventIDs: id of event to add into
        - tripIndex: index of the trip in the user document
        - eventPerDayIndex: index of the evertPerDay object in the trip document
        - tripID: id of trip to add into
     */
    private func fetchEvent(eventIDs: [String], tripIndex: Int, eventPerDayIndex: Int, tripID: String){
        
        db.collection("Event").whereField("id" , in: eventIDs).addSnapshotListener { querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
              print("Error fetching snapshots: \(error!)")
              return
            }

            snapshot.documentChanges.forEach { change in
                var event: Event
                do {
                    event = try change.document.data(as: Event.self)

                    if (change.type == .added) && (!self.user.trips[tripIndex].events[eventPerDayIndex].events.contains(event)){
                        self.user.trips[tripIndex].events[eventPerDayIndex].events.insert(event, at: Int(change.newIndex))
                        self.user.trips[tripIndex].events[eventPerDayIndex].events.sort(by: {
                            if $0.startDay == $1.startDay{
                                let firstStartHour = Calendar.current.dateComponents([.hour], from: $0.startTime).hour ?? 0
                                let firstStartMin = Calendar.current.dateComponents([.minute], from: $0.startTime).minute ?? 0
                                let secondStartHour = Calendar.current.dateComponents([.hour], from: $1.startTime).hour ?? 0
                                let secondStartMin = Calendar.current.dateComponents([.minute], from: $1.startTime).minute ?? 0
                                let first = firstStartHour*60 + firstStartMin
                                let second = secondStartHour*60 + secondStartMin
                                return first < second
                            } else {
                                return $0.startDay < $1.startDay
                            }
                        })
                    }
                    if (change.type == .modified) {
                        self.user.trips[tripIndex].events[eventPerDayIndex].events.remove(at: Int(change.oldIndex))
                        self.user.trips[tripIndex].events[eventPerDayIndex].events.insert(event, at: Int(change.newIndex))
                        self.user.trips[tripIndex].events[eventPerDayIndex].events.sort(by: {
                            if $0.startDay == $1.startDay{
                                let firstStartHour = Calendar.current.dateComponents([.hour], from: $0.startTime).hour ?? 0
                                let firstStartMin = Calendar.current.dateComponents([.minute], from: $0.startTime).minute ?? 0
                                let secondStartHour = Calendar.current.dateComponents([.hour], from: $1.startTime).hour ?? 0
                                let secondStartMin = Calendar.current.dateComponents([.minute], from: $1.startTime).minute ?? 0
                                let first = firstStartHour*60 + firstStartMin
                                let second = secondStartHour*60 + secondStartMin
                                return first < second
                            } else {
                                return $0.startDay < $1.startDay
                            }
                        })
                    }
                    if (change.type == .removed) {
                        if self.user.trips.contains(where: {$0.id.uuidString == tripID}){
                            self.user.trips[tripIndex].events[eventPerDayIndex].events.removeAll(where: {$0.id == event.id})
                        }
                    }
                } catch {
                    fatalError("Unable to decode event: \(error)")
                }
            }
        }
    }
    
    /**
     fetch all the ExpensePerDay object and add into the specific trip of a user
     - Parameters:
        - tripID: id of trip to add into
        - tripIndex: index of the trip in the user document
     */
    private func fetchExpensePerDay(tripID: String, tripIndex: Int, docRef: DocumentReference){

        docRef.collection("expenses").order(by: "day").addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { change in
                
                let expensePerDayData = change.document.data()
                var expensePerDay: ExpensePerDay
                do {
                    expensePerDay = try change.document.data(as: ExpensePerDay.self)
                } catch {
                    print(change.document.documentID)
                    fatalError("Unable to decode Expense Per Day: \(error.localizedDescription)")
                }
                
                var validIndex = true
                if tripIndex >= self.user.trips.count{
                    validIndex = false
                }
                                
                if (change.type == .modified) && validIndex {
                    self.user.trips[tripIndex].expenses.remove(at: Int(change.oldIndex))
                }
                
                var eventExist = false
                if validIndex{
                    if self.user.trips[tripIndex].expenses.contains(where: {$0.id == expensePerDay.id}){
                        eventExist = true
                    }
                }
                
                if ((change.type == .added) || (change.type == .modified)) && !eventExist && validIndex{
                    self.user.trips[tripIndex].expenses.insert(expensePerDay, at: Int(change.newIndex))
                    
                    if let expenseReferences = expensePerDayData["expensesPerDay"] as? [DocumentReference] {
                        print("fetching expemse")
                        let expenseIDs = expenseReferences.map({$0.documentID})
                        if !expenseIDs.isEmpty{
                            self.fetchExepnse(expenseIDs: expenseIDs, tripIndex: tripIndex, expensePerDayIndex: Int(change.newIndex), tripID: tripID)
                        }
                    }
                }
            }
        }
    }
    
    /**
     fetch all the Expense in the ExpensePerDay object and add under user document
     - Parameters:
        - expenseIDs: id of expnese to add into
        - tripIndex: index of the trip in the user document
        - eventPerDayIndex: index of the evertPerDay object in the trip document
        - tripID: id of trip to add into
     */
    private func fetchExepnse(expenseIDs: [String], tripIndex: Int, expensePerDayIndex: Int, tripID: String){
        
        db.collection("Expense").whereField("id" , in: expenseIDs).addSnapshotListener { querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                var expenseItem: Expense
                do {
                    expenseItem = try change.document.data(as: Expense.self)
                    
                    if (change.type == .added) && !self.user.trips[tripIndex].expenses[expensePerDayIndex].expensesPerDay.contains(where: {$0.id == expenseItem.id}){
                        self.user.trips[tripIndex].expenses[expensePerDayIndex].expensesPerDay.insert(expenseItem, at: Int(change.newIndex))
                    }
                    
                    if (change.type == .modified) {
                        self.user.trips[tripIndex].expenses[expensePerDayIndex].expensesPerDay.remove(at: Int(change.oldIndex))
                        self.user.trips[tripIndex].expenses[expensePerDayIndex].expensesPerDay.insert(expenseItem, at: Int(change.newIndex))
                    }
                    
                    if (change.type == .removed){
                        if self.user.trips.contains(where: {$0.id.uuidString == tripID}){
                            self.user.trips[tripIndex].expenses[expensePerDayIndex].expensesPerDay.removeAll(where: {$0.id == expenseItem.id})
                        }
                    }
                } catch {
                    fatalError("Unable to decode Expense: \(error)")
                }
            }
        }
        
    }
    
    /**
     fetch all the ChecklistCategory object and add into the specific trip of a user
     - Parameters:
        - tripID: id of trip to add into
        - tripIndex: index of the trip in the user document
     */
    private func fetchChecklistCategory(tripID: String, tripIndex: Int, docRef: DocumentReference){

        docRef.collection("checklists").order(by: "dateCreated").addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { change in
                
                let checklistCategoryData = change.document.data()
                var checklistCategory: ChecklistCateogry
                do {
                    checklistCategory = try change.document.data(as: ChecklistCateogry.self)
                } catch {
                    print(change.document.documentID)
                    fatalError("Unable to decode Checklist Category: \(error.localizedDescription)")
                }
                
                var validIndex = true
                if tripIndex >= self.user.trips.count{
                    validIndex = false
                }
                                
                if (change.type == .modified) && validIndex {
                    self.user.trips[tripIndex].checklist.remove(at: Int(change.oldIndex))
                }
                
                var checklistCategoryExist = false
                if validIndex{
                    if self.user.trips[tripIndex].checklist.contains(where: {$0.id == checklistCategory.id}){
                        checklistCategoryExist = true
                    }
                }
                
                if ((change.type == .added) || (change.type == .modified)) && !checklistCategoryExist && validIndex{
                    self.user.trips[tripIndex].checklist.insert(checklistCategory, at: Int(change.newIndex))
                    
                    if let checklistReference = checklistCategoryData["checklists"] as? [DocumentReference] {
                        let checklistIDs = checklistReference.map({$0.documentID})
                        if !checklistIDs.isEmpty{
                            self.fetchChecklist(checklistIDs: checklistIDs, tripIndex: tripIndex, checklistCategoryIndex: Int(change.newIndex), tripID: tripID)
                        }
                    }
                }
            }
        }
    }
    
    /**
     fetch all the Checklist in the ChecklistCateogry object and add under user document
     - Parameters:
        - checklistIDs: id of checklist to add into
        - tripIndex: index of the trip in the user document
        - eventPerDayIndex: index of the evertPerDay object in the trip document
        - tripID: id of trip to add into
     */
    private func fetchChecklist(checklistIDs: [String], tripIndex: Int, checklistCategoryIndex: Int, tripID: String){
        
        db.collection("Checklist").whereField("id" , in: checklistIDs).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { change in
                var checklistItem: Checklist
                do {
                    checklistItem = try change.document.data(as: Checklist.self)
                    
                    if (change.type == .added) && !self.user.trips[tripIndex].checklist[checklistCategoryIndex].checklists.contains(checklistItem){
                        self.user.trips[tripIndex].checklist[checklistCategoryIndex].checklists.insert(checklistItem, at: Int(change.newIndex))
                    }
                    
                    if (change.type == .modified) {
                        self.user.trips[tripIndex].checklist[checklistCategoryIndex].checklists.remove(at: Int(change.oldIndex))
                        self.user.trips[tripIndex].checklist[checklistCategoryIndex].checklists.insert(checklistItem, at: Int(change.newIndex))
                        
                        if (change.type == .removed){
                            if self.user.trips.contains(where: {$0.id.uuidString == tripID}){
                                self.user.trips[tripIndex].checklist[checklistCategoryIndex].checklists.removeAll(where: {$0.id == checklistItem.id})
                            }
                        }
                    }
                } catch {
                    fatalError("Unable to decode checklist: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /**
     fetch all the SavedPalce object and add into the specific trip of a user
     - Parameters:
        - tripID: id of trip to add into
        - tripIndex: index of the trip in the user document
     */
    private func fetchSavedPlace(tripID: String, tripIndex: Int, docRef: DocumentReference){
        
        docRef.collection("savedPlaces").addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { change in
                
                var savedPlaces: SavedPlace
                do {
                    savedPlaces = try change.document.data(as: SavedPlace.self)
                    print("here here", savedPlaces)
                    
                    if (change.type == .added) && !self.user.trips[tripIndex].savedPlaces.contains(savedPlaces){
                        self.user.trips[tripIndex].savedPlaces.insert(savedPlaces, at: Int(change.newIndex))
                        print(self.user.trips[tripIndex].savedPlaces[Int(change.newIndex)])
                    }
                    if (change.type == .modified) {
                        self.user.trips[tripIndex].savedPlaces.remove(at: Int(change.oldIndex))
                        self.user.trips[tripIndex].savedPlaces.insert(savedPlaces, at: Int(change.newIndex))
                    }
                    if (change.type == .removed){
                        if self.user.trips.contains(where: {$0.id.uuidString == tripID}){
                            self.user.trips[tripIndex].savedPlaces.removeAll(where: {$0.id == savedPlaces.id})
                        }
                    }
                } catch {
                    print(change.document.documentID)
                    fatalError("Unable to decode saved places: \(error)")
                }
            }
        }
    }
    
    /**
     Fetch all the post of the user
     */
    private func fetchUserPost(){
        db.collection("Post").whereField("authorID", isEqualTo: user.id!).addSnapshotListener { querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
              print("Error fetching snapshots: \(error!)")
              return
            }

            snapshot.documentChanges.forEach { change in
                var post: Post
                do {
                    post = try change.document.data(as: Post.self)
                } catch {
                    fatalError("Unable to decode post: \(error)")
                }
                if (change.type == .added) && (!self.user.posts.contains(post)){
                    self.user.posts.insert(post, at: Int(change.newIndex))
                    self.fetchComment(postIndex: Int(change.newIndex), type: .post)
                }
                if (change.type == .modified) {
                    self.user.posts.removeAll(where: {$0.id == post.id})
                    self.user.posts.insert(post, at: Int(change.newIndex))
                    self.fetchComment(postIndex: Int(change.newIndex), type: .post)
                }
                if (change.type == .removed) {
                    self.user.posts.removeAll(where: {$0.id == post.id})
                }
            }
        }
    }
    
    /**
     Fetch the all the guide of the user
     */
    private func fetchUserGuide(){
        db.collection("Guide").whereField("authorID", isEqualTo: user.id!).addSnapshotListener { querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
              print("Error fetching snapshots: \(error!)")
              return
            }

            snapshot.documentChanges.forEach { change in
                var guide: Guide
                do {
                    guide = try change.document.data(as: Guide.self)
                    if let tripID = change.document.data()["itinerary"] as? DocumentReference {
                        Task{
                            await self.fetchUserGuideTrip(docRef:tripID , postIndex:Int(change.newIndex), belongToUser: true)
                        }
                    }
                } catch {
                    fatalError("Unable to decode guide: \(error)")
                }
                if (change.type == .added) && (!self.user.guides.contains(guide)){
                    self.user.guides.insert(guide, at: Int(change.newIndex))
                    self.fetchComment(postIndex: Int(change.newIndex), type: .guide)
                }
                if (change.type == .modified) {
                    var currentIndex = 0
                    if let index = self.user.guides.firstIndex(where: {$0.id == guide.id}){
                        self.user.guides[index].vote_count = guide.vote_count
                        self.user.guides[index].comment_count = guide.comment_count
                        self.user.guides[index].upvote = guide.upvote
                        self.user.guides[index].downvote = guide.downvote
                        currentIndex = index
                    }else {
                        self.user.guides.insert(guide, at: Int(change.newIndex))
                        currentIndex = Int(change.newIndex)
                    }
                    self.fetchComment(postIndex: currentIndex, type: .guide)
                }
                if (change.type == .removed) {
                    self.user.guides.removeAll(where: {$0.id == guide.id})
                }
            }
        }
    }
    
    /**
     Fetch all the information of the trip that is posted in the guide
     - Parameters:
        - docRef: documentReference that directly refer to the trip posed in the Guide
        - postIndex: index of the post in the list
        - belongToUser: is this guide belong to the current user, ot belong to the feed
     */
    @MainActor
    private func fetchUserGuideTrip(docRef: DocumentReference, postIndex: Int, belongToUser: Bool) async{
        
        do {
            var trip = try await docRef.getDocument(as: Trip.self)
            
            let querySnapshot1 = try await docRef.collection("events").order(by: "day").getDocuments()
            for document in querySnapshot1.documents {
                let eventPerDay = try document.data(as: EventPerDay.self)
                trip.events.append(eventPerDay)
                
                if let eventReference = document.data()["events"] as? [DocumentReference] {
                    for reference in eventReference {
                        let event = try await reference.getDocument(as: Event.self)
                        let size = trip.events.count
                        if size > 0 {
                            trip.events[size-1].events.append(event)
                        }
                    }
                }
            }
                
                
            let querySnapshot2 = try await docRef.collection("expenses").order(by: "day").getDocuments()
            for document in querySnapshot2.documents {
                let expensePerDay = try document.data(as: ExpensePerDay.self)
                trip.expenses.append(expensePerDay)
                
                if let eventReference = document.data()["expensesPerDay"] as? [DocumentReference] {
                    for reference in eventReference {
                        let expense = try await reference.getDocument(as: Expense.self)
                        let size = trip.expenses.count
                        if size > 0 {
                            trip.expenses[size-1].expensesPerDay.append(expense)
                        }
                    }
                }
            }
                
            let querySnapshot3 = try await docRef.collection("checklists").order(by: "dateCreated").getDocuments()
            for document in querySnapshot3.documents {
                let checklistCategory = try document.data(as: ChecklistCateogry.self)
                trip.checklist.append(checklistCategory)
                
                if let eventReference = document.data()["checklists"] as? [DocumentReference] {
                    for reference in eventReference {
                        let checklist = try await reference.getDocument(as: Checklist.self)
                        let size = trip.checklist.count
                        if size > 0 {
                            trip.checklist[size-1].checklists.append(checklist)
                        }
                    }
                }
            }
                
            let querySnapshot = try await docRef.collection("savedPlaces").getDocuments()
            for document in querySnapshot.documents {
                let savedPlaces = try document.data(as: SavedPlace.self)
                trip.savedPlaces.append(savedPlaces)
            }
            
            if belongToUser{
                self.user.guides[postIndex].itinerary = trip
            } else {
                self.guide[postIndex].itinerary = trip
            }

        } catch {
            print("Error decoding Trip object.")
        }
    }
    
    /**
     Fetch all the comment under a specific post/guide of current user
     - Parameters:
        - postIndex: index of the post in the list
        - type: type of post (Post/ Guide)
     */
    private func fetchComment(postIndex: Int, type: PostType){
        
        
        db.collection(type == .post ? "Post": "Guide")
            .document(type == .post ? user.posts[postIndex].id.uuidString: user.guides[postIndex].id.uuidString)
            .collection("Comment")
            .order(by: "vote_count", descending: true)
            .order(by: "date_created") .addSnapshotListener{ querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                var comment: Comment
                do {
                    comment = try change.document.data(as: Comment.self)
                } catch {
                    fatalError("Unable to decode post: \(error)")
                }
                if type == .post{
                    if (change.type == .added) && (!self.user.posts[postIndex].comments.contains(comment)){
                        self.user.posts[postIndex].comments.insert(comment, at: Int(change.newIndex))
                    }
                    if (change.type == .modified) {
                        if let index = self.user.posts[postIndex].comments.firstIndex(where: {$0.id == comment.id}){
                            self.user.posts[postIndex].comments[index] = comment
                        }
                    }
                    if (change.type == .removed) {
                        self.user.posts[postIndex].comments.remove(at: Int(change.oldIndex))
                        print(3)
                    }
                } else {
                    if (change.type == .added) && (!self.user.guides[postIndex].comments.contains(comment)){
                        self.user.guides[postIndex].comments.insert(comment, at: Int(change.newIndex))
                    }
                    if (change.type == .modified) {
                        if let index = self.user.guides[postIndex].comments.firstIndex(where: {$0.id == comment.id}){
                            self.user.guides[postIndex].comments[index] = comment
                        }
                    }
                    if (change.type == .removed) {
                        self.user.guides[postIndex].comments.remove(at: Int(change.oldIndex))
                        print(3)
                    }
                }
            }
        }
    }
    
    /**
     Fetch the feed to show on main page
     */
    private func fetchFeed(){
        
        db.collection("Post").whereField("authorID", isNotEqualTo: user.id!).limit(to: 10).addSnapshotListener { querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
              print("Error fetching snapshots: \(error!)")
              return
            }

            snapshot.documentChanges.forEach { change in
                var post: Post
                do {
                    post = try change.document.data(as: Post.self)
                } catch {
                    fatalError("Unable to decode post: \(error)")
                }
                if (change.type == .added) && (!self.post.contains(where: {$0.id == post.id})){
                    self.post.insert(post, at: Int(change.newIndex))
                    self.fetchFeedComment(postIndex: Int(change.newIndex), type: .post)
                }
                if (change.type == .modified) {
                    self.post.removeAll(where: {$0.id == post.id})
                    self.post.insert(post, at: Int(change.newIndex))
                    self.fetchFeedComment(postIndex: Int(change.newIndex), type: .post)
                }
                if (change.type == .removed) {
                    self.post.removeAll(where: {$0.id == post.id})
                }
            }
        }
        
        db.collection("Guide").whereField("authorID", isNotEqualTo: user.id!).addSnapshotListener { querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
              print("Error fetching snapshots: \(error!)")
              return
            }

            snapshot.documentChanges.forEach { change in
                var guide: Guide
                do {
                    guide = try change.document.data(as: Guide.self)
                } catch {
                    fatalError("Unable to decode guide: \(error)")
                }
                if (change.type == .added) && (!self.guide.contains(guide)){
                    var newIndex: Int
                    if self.guide.contains(where: {$0.id == guide.id}){
                        let index = self.guide.firstIndex(where: {$0.id == guide.id})
                        self.guide[index ?? 0] = guide
                        newIndex = index ?? 0
                    } else {
                        self.guide.insert(guide, at: Int(change.newIndex))
                        newIndex = Int(change.newIndex)
                    }
                    self.fetchFeedComment(postIndex: newIndex, type: .guide)
                    if let tripID = change.document.data()["itinerary"] as? DocumentReference {
                        Task{
                            await self.fetchUserGuideTrip(docRef:tripID , postIndex:Int(change.newIndex), belongToUser: false)
                        }
                    }
                }
                if (change.type == .modified) {
                    self.guide.removeAll(where: {$0.id == guide.id})
                    self.guide.insert(guide, at: Int(change.newIndex))
                    self.fetchFeedComment(postIndex: Int(change.newIndex), type: .guide)
                    if let tripID = change.document.data()["itinerary"] as? DocumentReference {
                        Task{
                            await self.fetchUserGuideTrip(docRef:tripID , postIndex:Int(change.newIndex), belongToUser: false)
                        }
                    }
                }
                if (change.type == .removed) {
                    self.guide.removeAll(where: {$0.id == guide.id})
                }
            }
        }
    }
    
    /**
     Fetch all the comment under a specific post/guide of feed
     - Parameters:
        - postIndex: index of the post in the list
        - type: type of post (Post/ Guide)
     */
    private func fetchFeedComment(postIndex: Int, type: PostType){
        
        db.collection(type == .post ? "Post": "Guide")
            .document(type == .post ? post[postIndex].id.uuidString: guide[postIndex].id.uuidString)
            .collection("Comment")
            .order(by: "vote_count", descending: true)
            .order(by: "date_created") .addSnapshotListener{ querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                var comment: Comment
                do {
                    comment = try change.document.data(as: Comment.self)
                } catch {
                    fatalError("Unable to decode post: \(error)")
                }
                if type == .post{
                    if (change.type == .added) && (!self.post[postIndex].comments.contains(comment)){
                        self.post[postIndex].comments.insert(comment, at: Int(change.newIndex))
                    }
                    if (change.type == .modified) {
                        if let index = self.post[postIndex].comments.firstIndex(where: {$0.id == comment.id}){
                            self.post[postIndex].comments[index] = comment
                        }
                    }
                    if (change.type == .removed) {
                        self.post[postIndex].comments.removeAll(where: {$0.id == comment.id})
                    }
                } else {
                    if (change.type == .added) && (!self.guide[postIndex].comments.contains(comment)){
                        self.guide[postIndex].comments.insert(comment, at: Int(change.newIndex))
                    }
                    if (change.type == .modified) {
                        if let index = self.guide[postIndex].comments.firstIndex(where: {$0.id == comment.id}){
                            self.guide[postIndex].comments[index] = comment
                        }
                    }
                    if (change.type == .removed) {
                        self.guide[postIndex].comments.removeAll(where: {$0.id == comment.id})
                    }
                }
            }
        }
    }
}
    
// update functionality of making changes to the Firebase
extension FirebaseController{
    
    /**
     Add a codable object into a collection of firebase with specific document path
     - Parameters:
        - itemToAdd: codable item to be add into Firebase
        - collectionPath: the path name of the collection added into
        - documentPath: the path name of the document added into
     */
    func addDocument(itemToAdd: Codable, collectionPath: String, documentPath: String) -> DocumentReference?{
        do{
            let encodedData = try Firestore.Encoder().encode(itemToAdd)
            db.collection(collectionPath).document(documentPath).setData(encodedData)
            return db.collection(collectionPath).document(documentPath)
        } catch let error {
            print("Error writting to Firestore \(error.localizedDescription)")
            return nil
        }
    }
    
    /**
     Delete a document of the specific document id in a collection
     - Parameters:
        - collectionPath: the path name of the collection added into
        - documentPath: the path name of the document added into
     */
    func deleteDocument(collectionPath: String, documentPath: String) async -> DocumentReference?{
        do {
            let docRef = db.collection(collectionPath).document(documentPath)
            try await docRef.delete()
            return docRef
        } catch {
            print("Error removing document: \(error)")
            return nil
        }
    }
    
    /**
     Add  a item into an array
     - Parameters:
        - itemToAdd: codable item to be add into Firebase
        - collectionPath: the path name of the collection added into
        - documentPath: the path name of the document added into
        - attributeName: the name of the atribute that store an array
     */
    func addToArray(itemToAdd: Codable ,collectionPath: String, documentPath: String, attributeName: String){
        do{
            let encodedData = try Firestore.Encoder().encode(itemToAdd)
            db.collection(collectionPath).document(documentPath).updateData([attributeName: FieldValue.arrayUnion([encodedData])])
        } catch let error {
            print("Error writting to Firestore \(error.localizedDescription)")
            return
        }
    }
    
    /**
     Remove an item from the array
     - Parameters:
        - itemToremove: codable item to be remove from Firebase
        - collectionPath: the path name of the collection removed from
        - documentPath: the path name of the document remove from
        - attributeName: the name of the atribute need to update
     */
    func removeFromArray(itemToremove: Codable,collectionPath: String, documentPath: String, attributeName: String) async{
        do {
            let encodedData = try Firestore.Encoder().encode(itemToremove)
            try await db.collection(collectionPath).document(documentPath).updateData([attributeName: FieldValue.arrayRemove([encodedData])])
            print("Document successfully updated")
        } catch {
          print("Error updating document: \(error)")
        }
    }
    
    /**
     Add a reference into array
     - Parameters:
        - referenceToAdd: document reference needed to add
        - collectionPath: the path name of the collection added into
        - documentPath: the path name of the document added into
        - attributeName: the name of the atribute need to update
     */
    func addReferenceToArray(referenceToAdd: DocumentReference,collectionPath: String, documentPath: String, attributeName: String){
        db.collection(collectionPath).document(documentPath).updateData([attributeName: FieldValue.arrayUnion([referenceToAdd])])
    }
    
    /**
     Remove a reference into array
     - Parameters:
        - referenceToAdd: document refernece needed to remove
        - collectionPath: the path name of the collection removed from
        - documentPath: the path name of the document remove from
        - attributeName: the name of the atribute need to update
     */
    func removeReferenceFromarray(referenceToRemove: DocumentReference,collectionPath: String, documentPath: String, attributeName: String) async {
        do {
            try await db.collection(collectionPath).document(documentPath).updateData([attributeName: FieldValue.arrayRemove([referenceToRemove])])
            print("Document successfully updated")
        } catch {
            print("Error updating document: \(error)")
        }
    }
    
    /**
     Update an attriibute in a document
     - Parameters:
        - object: updated value
        - collectionPath: the path name of the collection added into
        - documentPath: the path name of the document added into
        - attributeName: the name of the atribute need to update
     */
    func updateField(object: Any,collectionPath: String, documentPath: String, attributeName: String){
        db.collection(collectionPath).document(documentPath).updateData([attributeName: object])
    }
    
    /**
     Add any value into  in a array
     - Parameters:
        - valuetoAdd: value to added into the array
        - collectionPath: the path name of the collection added into
        - documentPath: the path name of the document added into
        - attributeName: the name of the atribute need to update
     */
    func addValueToArray(valuetoAdd: Any ,collectionPath: String, documentPath: String, attributeName: String){
        db.collection(collectionPath).document(documentPath).updateData([attributeName: FieldValue.arrayUnion([valuetoAdd])])
    }
    
    /**
     Remove any value into  in a array
     - Parameters:
        - valueToremove: value to remove from the array
        - collectionPath: the path name of the collection added into
        - documentPath: the path name of the document added into
        - attributeName: the name of the atribute need to update
     */
    func removeValueFromArray(valueToremove: Any,collectionPath: String, documentPath: String, attributeName: String) async{
        do {
            try await db.collection(collectionPath).document(documentPath).updateData([attributeName: FieldValue.arrayRemove([valueToremove])])
            print("Document successfully updated")
        } catch {
          print("Error updating document: \(error)")
        }
    }

    /**
     Decode an codable object into that is compatible to store in Firestore
     - Parameters:
        - object: codable object to decode
     */
    func decodeObject(object: Codable) -> [String : Any]?{
        
        do{
            let decodeObject = try Firestore.Encoder().encode(object)
            return decodeObject
        } catch {
            print("Failed to encode object \(error)")
            return nil
        }
    }
}
