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
        
    var db: Firestore
    var currentUser: FirebaseAuth.User?
    var errorMessage: String? 
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    private init(){
        db = Firestore.firestore()
        self.registerAuthStateHandler()
    }
    
    func registerAuthStateHandler() {
        if authStateHandler == nil {
          authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
              self.currentUser = user
              self.fetchUser()
          }
        }
    }
    
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
    
    func fetchUser() {
        
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
                print("User document was empty \(error)")
                return
            }
            print("userFetcher")
            self.user = User()
            self.post = []
            self.guide = []
            self.user.id = userSnapshot.documentID
            self.user.name = userData["name"] as? String
            self.user.username = userData["name"] as? String
            self.user.email = userData["email"] as? String
            
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
    
    func fetchTrip(tripIDs: [String]){
        
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
                    self.user.trips.insert(trip, at: Int(change.newIndex))
                    self.fetchEventPerDay(tripID: trip.id.uuidString, tripIndex: Int(change.newIndex))
                    self.fetchSavedPlace(tripID: trip.id.uuidString, tripIndex: Int(change.newIndex))
                    self.fetchExpensePerDay(tripID: trip.id.uuidString, tripIndex: Int(change.newIndex))
                    self.fetchChecklistCategory(tripID: trip.id.uuidString, tripIndex: Int(change.newIndex))
                    
                }
                if (change.type == .modified) {
                    self.user.trips.remove(at: Int(change.oldIndex))
                    self.user.trips.insert(trip, at: Int(change.newIndex))
                    self.fetchEventPerDay(tripID: trip.id.uuidString, tripIndex: Int(change.newIndex))
                    self.fetchSavedPlace(tripID: trip.id.uuidString, tripIndex: Int(change.newIndex))
                    self.fetchExpensePerDay(tripID: trip.id.uuidString, tripIndex: Int(change.newIndex))
                    self.fetchChecklistCategory(tripID: trip.id.uuidString, tripIndex: Int(change.newIndex))

                }
                if (change.type == .removed) {
                    self.user.trips.remove(at: Int(change.oldIndex))
                }
            }
        }
    }
    
    func fetchEventPerDay(tripID: String, tripIndex: Int){
        let docRef = db.collection("Trip").document(tripID)

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
                    print(change.document.documentID)
                    fatalError("Unable to decode Event Per Day: \(error.localizedDescription)")
                }
                
                var validIndex = true
                if tripIndex >= self.user.trips.count{
                    validIndex = false
                }
                                
                if (change.type == .modified) && validIndex {
                    self.user.trips[tripIndex].events.remove(at: Int(change.oldIndex))
                }
                
                var eventExist = false
                if validIndex{
                    if self.user.trips[tripIndex].events.contains(where: {$0.id == eventPerDay.id}){
                        eventExist = true
                    }
                }
                
                if ((change.type == .added) || (change.type == .modified)) && !eventExist && validIndex{
                    self.user.trips[tripIndex].events.insert(eventPerDay, at: Int(change.newIndex))
                    
                    if let eventReference = eventPerDayData["events"] as? [DocumentReference] {
                        
                        let eventIDs = eventReference.map({$0.documentID})
                        if !eventIDs.isEmpty{
                            self.fetchEvent(eventIDs: eventIDs, tripIndex: tripIndex, eventPerDayIndex: Int(change.newIndex))
                        }
                    }
                }
            }
        }
    }
    
    func fetchEvent(eventIDs: [String], tripIndex: Int, eventPerDayIndex: Int){
        
        db.collection("Event").whereField("id" , in: eventIDs).addSnapshotListener { querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
              print("Error fetching snapshots: \(error!)")
              return
            }

            snapshot.documentChanges.forEach { change in
                var event: Event
                do {
                    event = try change.document.data(as: Event.self)
                } catch {
                    fatalError("Unable to decode event: \(error)")
                }
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
                    self.user.trips[tripIndex].events[eventPerDayIndex].events.removeAll(where: {$0.id == event.id})
                }
            }
        }
    }
    
    func fetchExpensePerDay(tripID: String, tripIndex: Int){
        let docRef = db.collection("Trip").document(tripID)

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
                            self.fetchExepnse(expenseIDs: expenseIDs, tripIndex: tripIndex, expensePerDayIndex: Int(change.newIndex))
                        }
                    }
                }
            }
        }
    }
    
    func fetchExepnse(expenseIDs: [String], tripIndex: Int, expensePerDayIndex: Int){
        
        db.collection("Expense").whereField("id" , in: expenseIDs).addSnapshotListener { querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                var expenseItem: Expense
                do {
                    expenseItem = try change.document.data(as: Expense.self)
                } catch {
                    print(change.document.documentID)
                    fatalError("Unable to decode Expense: \(error)")
                }
                
                if (change.type == .added) && !self.user.trips[tripIndex].expenses[expensePerDayIndex].expensesPerDay.contains(where: {$0.id == expenseItem.id}){
                    self.user.trips[tripIndex].expenses[expensePerDayIndex].expensesPerDay.insert(expenseItem, at: Int(change.newIndex))
                }
                
                if (change.type == .modified) {
                    self.user.trips[tripIndex].expenses[expensePerDayIndex].expensesPerDay.remove(at: Int(change.oldIndex))
                    self.user.trips[tripIndex].expenses[expensePerDayIndex].expensesPerDay.insert(expenseItem, at: Int(change.newIndex))
                }
                
                if (change.type == .removed){
                    self.user.trips[tripIndex].expenses[expensePerDayIndex].expensesPerDay.removeAll(where: {$0.id == expenseItem.id})
                }
            }
        }
        
    }
    
    func fetchChecklistCategory(tripID: String, tripIndex: Int){
        let docRef = db.collection("Trip").document(tripID)

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
                            self.fetchChecklist(checklistIDs: checklistIDs, tripIndex: tripIndex, checklistCategoryIndex: Int(change.newIndex))
                        }
                    }
                }
            }
        }
    }
    
    func fetchChecklist(checklistIDs: [String], tripIndex: Int, checklistCategoryIndex: Int){
        
        db.collection("Checklist").whereField("id" , in: checklistIDs).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { change in
                var checklistItem: Checklist
                do {
                    checklistItem = try change.document.data(as: Checklist.self)
                } catch {
                    fatalError("Unable to decode checklist: \(error.localizedDescription)")
                }

                if (change.type == .added) && !self.user.trips[tripIndex].checklist[checklistCategoryIndex].checklists.contains(checklistItem){
                    self.user.trips[tripIndex].checklist[checklistCategoryIndex].checklists.insert(checklistItem, at: Int(change.newIndex))
                }

                if (change.type == .modified) {
                    self.user.trips[tripIndex].checklist[checklistCategoryIndex].checklists.remove(at: Int(change.oldIndex))
                    self.user.trips[tripIndex].checklist[checklistCategoryIndex].checklists.insert(checklistItem, at: Int(change.newIndex))

                    if (change.type == .removed){
                        self.user.trips[tripIndex].checklist[checklistCategoryIndex].checklists.removeAll(where: {$0.id == checklistItem.id})
                    }
                }
            }
        }
    }
    
    func fetchSavedPlace(tripID: String, tripIndex: Int){
        
        let docRef = db.collection("Trip").document(tripID)

        docRef.collection("savedPlaces").addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { change in
                
                var savedPlaces: SavedPlace
                do {
                    savedPlaces = try change.document.data(as: SavedPlace.self)
                } catch {
                    print(change.document.documentID)
                    fatalError("Unable to decode saved places: \(error)")
                }
                
                if (change.type == .added) && !self.user.trips[tripIndex].savedPlaces.contains(savedPlaces){
                    self.user.trips[tripIndex].savedPlaces.insert(savedPlaces, at: Int(change.newIndex))
                }
                if (change.type == .modified) {
                    self.user.trips[tripIndex].savedPlaces.remove(at: Int(change.oldIndex))
                    self.user.trips[tripIndex].savedPlaces.insert(savedPlaces, at: Int(change.newIndex))
                }
                if (change.type == .removed){
                    self.user.trips[tripIndex].savedPlaces.removeAll(where: {$0.id == savedPlaces.id})
                }
            }
        }
    }
    
    func fetchUserPost(){
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
                    self.user.posts.remove(at: Int(change.oldIndex))
                    self.user.posts.insert(post, at: Int(change.newIndex))
                    self.fetchComment(postIndex: Int(change.newIndex), type: .post)
                }
                if (change.type == .removed) {
                    self.user.posts.remove(at: Int(change.oldIndex))
                }
            }
        }
    }
    
    func fetchUserGuide(){
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
                    self.user.guides.remove(at: Int(change.oldIndex))
                }
            }
        }
    }
    
    func fetchUserGuideTrip(docRef: DocumentReference, postIndex: Int, belongToUser: Bool) async{
        
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
    
    func fetchComment(postIndex: Int, type: PostType){
        
        
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
    
    func fetchFeed(){
        
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
    
    func fetchFeedComment(postIndex: Int, type: PostType){
        
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
                        self.post[postIndex].comments.remove(at: Int(change.oldIndex))
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
                        self.guide[postIndex].comments.remove(at: Int(change.oldIndex))
                    }
                }
            }
        }
    }
}
    
// update functionality of making changes to the Firebase
extension FirebaseController{
    
    /**
     Add a codable object into first layer document of firebase with specific document path
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
     Add a reference
     - Parameters:
        - itemToAdd: codable item to be add into Firebase
        - collectionPath: the path name of the collection added into
        - documentPath: the path name of the document added into
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
    
    func removeFromArray(itemToremove: Codable,collectionPath: String, documentPath: String, attributeName: String) async{
        do {
            let encodedData = try Firestore.Encoder().encode(itemToremove)
            try await db.collection(collectionPath).document(documentPath).updateData([attributeName: FieldValue.arrayRemove([encodedData])])
            print("Document successfully updated")
        } catch {
          print("Error updating document: \(error)")
        }
    }
    
    
    func addReferenceToArray(referenceToAdd: DocumentReference,collectionPath: String, documentPath: String, attributeName: String){
        db.collection(collectionPath).document(documentPath).updateData([attributeName: FieldValue.arrayUnion([referenceToAdd])])
    }
    
    func removeReferenceFromarray(referenceToRemove: DocumentReference,collectionPath: String, documentPath: String, attributeName: String) async {
        do {
            try await db.collection(collectionPath).document(documentPath).updateData([attributeName: FieldValue.arrayRemove([referenceToRemove])])
            print("Document successfully updated")
        } catch {
            print("Error updating document: \(error)")
        }
    }
    
    func updateField(object: Any,collectionPath: String, documentPath: String, attributeName: String){
        db.collection(collectionPath).document(documentPath).updateData([attributeName: object])
    }
    
    func addStringToArray(stringtoAdd: Any ,collectionPath: String, documentPath: String, attributeName: String){
        db.collection(collectionPath).document(documentPath).updateData([attributeName: FieldValue.arrayUnion([stringtoAdd])])
    }
    
    func removeStringFromArray(stringToremove: Any,collectionPath: String, documentPath: String, attributeName: String) async{
        do {
            try await db.collection(collectionPath).document(documentPath).updateData([attributeName: FieldValue.arrayRemove([stringToremove])])
            print("Document successfully updated")
        } catch {
          print("Error updating document: \(error)")
        }
    }

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
