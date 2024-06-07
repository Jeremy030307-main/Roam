//
//  Itinerary.swift
//  Roam
//
//  Created by Jeremy Teng  on 27/04/2024.
//

import Foundation
import SwiftUI

enum SavedPlaceColor: Int, CaseIterable, Identifiable{
    
    case red = 0
    case orange = 1
    case yellow = 2
    case green = 3
    case teal = 4
    case cyan = 5
    case blue = 6
    case indigo = 7
    case purple = 8
    case pink = 9
    case brown = 10
    case gray = 11
    
    var id: Self{ self }
    var copy: Color {
        switch self{
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .teal: return .teal
        case .cyan: return .cyan
        case .blue: return .blue
        case .indigo: return .indigo
        case .purple: return .purple
        case .pink: return .pink
        case .brown: return .brown
        case .gray: return .gray
        }
    }
    
}

enum SavePlaceIcon: String, CaseIterable, Identifiable {
    
    case walk = "figure.walk.circle.fill"
    case food = "fork.knife.circle.fill"
    case petrol = "fuelpump.circle.fill"
    case bus = "tram.circle.fill"
    case ferry = "sailboat.circle.fill"
    case bed = "bed.double.circle.fill"
    case cart = "cart.circle.fill"
    case mappin = "mappin.circle.fill"
    case tree = "tree.circle.fill"
    case capping = "tent.2.circle.fill"
    
    var id: Self{ self }
}

enum EventType: Int, CaseIterable,Identifiable {
    
    case flight = 0
    case accomodation = 1
    case restaurant = 2
    case activity = 3
    case tour = 4
    case transportation = 5
    case carRental = 6
    
    var id: Self{ self }

    var icon: String {
        switch self {
        case .flight: "airplane.circle.fill"
        case .accomodation: "bed.double.circle.fill"
        case .restaurant: "fork.knife.circle.fill"
        case .activity: "figure.walk.circle.fill"
        case .tour: "flag.circle.fill"
        case .transportation: "tram.circle.fill"
        case .carRental: "car.circle.fill"
        }
    }
    
    var name: String {
        switch self {
        case .flight: return "Flight"
        case .accomodation: return "Accomodation"
        case .restaurant: return "Restaurant"
        case .activity: return "Activity"
        case .tour: return "Tour"
        case .transportation: return "Transportation"
        case .carRental: return "Car Rental"
        }
    }
    
}

enum ExpenseCategory: Int, CaseIterable, Identifiable {
    case transportation = 0
    case food = 1
    case souvenier = 2
    case personalItem = 3
    case funMoney = 4
    case petrol = 5
    
    var id: Self{self}
    var name: String {
        switch self {
        case .transportation: return "Transportation"
        case .food: return "Food and Beverage"
        case .souvenier: return "Souvenir"
        case .personalItem: return "Personal Item"
        case .funMoney: return "Fun Money"
        case .petrol: return "Petrol"
        }
    }
    
    var icon: String {
        switch self {
        case .transportation: return "tram.circle.fill"
        case .food: return "fork.knife.circle.fill"
        case .souvenier: return "gift.circle.fill"
        case .personalItem: return "person.circle.fill"
        case .funMoney: return "popcorn.circle.fill"
        case .petrol: return "fuelpump.circle.fill"
        }
    }
    
    var color: Color {
        switch self{
        case .transportation: return .blue
        case .food: return .cyan
        case .souvenier: return .yellow
        case .personalItem: return .purple
        case .funMoney: return .mint
        case .petrol: return .brown
        }
    }
}

struct Trip: Hashable , Identifiable, Codable{
    
    var id = UUID()
    
    var image: String?
    var title: String?
    var destination: String?
    
    var startDate: Date?
    var endDate: Date?
    var totalDays: Int?
    
    var pax: Int?
    var totalSpent: Int?
    
    var savedPlaces: [SavedPlace] = []
    var events: [EventPerDay] = []
    var expenses: [ExpensePerDay] = []
    var checklist: [ChecklistCateogry] = []
    
    enum CodingKeys: String, CodingKey {
        case id
        case image
        case title
        case destination
        case startDate
        case endDate
        case totalDays
        case pax
        case totalSpent
    }
    
    init(id: UUID = UUID(), image: String? = nil, title: String? = nil, destination: String? = nil, startDate: Date? = nil, endDate: Date? = nil, totalDays: Int? = nil, pax: Int? = nil, totalSpent: Int? = nil, savedPlaces: [SavedPlace] = [], events: [EventPerDay]=[], expenses: [ExpensePerDay]=[], checklist: [ChecklistCateogry]=[]) {
        self.id = id
        self.image = image
        self.title = title
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.totalDays = totalDays
        self.pax = pax
        self.totalSpent = totalSpent
        self.savedPlaces = savedPlaces
        self.events = events
        self.expenses = expenses
        self.checklist = checklist
    }
    
    init(trip: Trip){
        self = trip
        
        self.id = UUID()
        for index in 0 ..< self.savedPlaces.count {
            self.savedPlaces[index].id = UUID()
        }
        
        for index in 0 ..< self.events.count {
            self.events[index].id = UUID()
            
            for eventIndex in 0 ..< self.events[index].events.count{
                self.events[index].events[eventIndex].id = UUID()
            }
        }
        
        for index in 0 ..< self.expenses.count{
            self.expenses[index].id = UUID()
            
            for expenseIndex in 0 ..< self.expenses[index].expensesPerDay.count{
                self.expenses[index].expensesPerDay[expenseIndex].id = UUID()
            }
        }
        
        for index in 0 ..< self.checklist.count{
            self.checklist[index].id = UUID()
            
            for checklistIndex in 0 ..< self.checklist[index].checklists.count{
                self.checklist[index].checklists[checklistIndex].id = UUID()
            }
        }
    }
    

}

struct SavedPlace: Hashable , Identifiable, Codable{
    
    var id = UUID()
    var title: String
    var icon: String
    var color: Int
    var places: [Location] = []
}

struct Event: Hashable, Identifiable, Codable {
    
    var id = UUID()
    var type: Int
    var startDay: Int
    var endDay: Int
    var startTime: Date
    var endTime: Date
    var location: Location
    var destination: Location?
    var expense: Double?
}

struct EventPerDay: Hashable, Identifiable, Codable {
    var id = UUID()
    var day: Int
    var events: [Event] = []
    
    enum CodingKeys: String, CodingKey {
        case id
        case day
    }
}

struct Expense: Hashable, Identifiable, Codable {
    var id = UUID()
    var catogery: Int
    var title: String
    var amount: Double
    var day: Int
    var date: Date?
}

struct ExpensePerDay: Hashable, Identifiable, Codable {
    var id = UUID()
    var day: Int
    var expensesPerDay: [Expense] = []
    
    enum CodingKeys: String, CodingKey {
        case id
        case day
    }
}

struct Checklist: Hashable, Identifiable, Codable {

    var id = UUID()
    var title: String?
    var completed: Bool? = false
    var catagoryID: String?
}

struct ChecklistCateogry: Hashable, Identifiable, Codable {
    var id = UUID()
    var category_name: String
    var checklists: [Checklist] = []
    var dateCreated: Date = .now
    
    enum CodingKeys: String, CodingKey {
        case id
        case category_name
        case dateCreated
    }
}
