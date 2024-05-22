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

struct Trip: Hashable , Identifiable{
    
    var id = UUID()
    
    var image: String
    var title: String
    var destination: String
    
    var startDate: Date?
    var endDate: Date?
    var totalDays: Int
    
    var pax: Int?
    var totalSpent: Int?
    
    var savedPlaces: [SavedPlace] = []
    var events: [Int : [Event]] = [:]
    var expenses: [Int: [Expense]] = [:]
    var checklist: [Checklist] = []
}

struct SavedPlace: Hashable , Identifiable{
    
    var id = UUID()
    var title: String
    var icon: String
    var color: Int
    var places: [String] = []
}

struct Event: Hashable, Identifiable {
    
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

struct Expense: Hashable, Identifiable {
    
    var id = UUID()
    var catogery: Int
    var title: String
    var amount: Double
    var day: Int
    var date: Date?
}


struct Checklist: Hashable, Identifiable {
    
    var id = UUID()
    var title: String
    var completed: Bool = false
}
