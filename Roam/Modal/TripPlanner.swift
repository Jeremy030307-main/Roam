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
    
    case walk = "figure.walk"
    case coffee = "cup.and.saucer.fill"
    case food = "fork.knife"
    case wine = "wineglass.fill"
    case petrol = "fuelpump.fill"
    case bus = "bus"
    case ferry = "ferry.fill"
    case bed = "bed.double.fill"
    case cart = "cart.fill"
    case mappin = "mappin"
    
    var id: Self{ self }

}

enum EventType: Int, CaseIterable,Identifiable {
    
    case flight = 0
    case accomodation = 1
    case restaurant = 2
    case activity = 3
    case tour = 4
    case transportation = 5
    
    var id: Self{ self }

    var icon: String {
        switch self {
        case .flight:
            "airplane"
        case .accomodation:
            "bed.double.fill"
        case .restaurant:
            "fork.knife"
        case .activity:
            "figure.walk"
        case .tour:
            "flag.fill"
        case .transportation:
            "bus.fill"
        }
    }
    
    var name: String {
        switch self {
        case .flight:
            return "Flight"
        case .accomodation:
            return "Accomodation"
        case .restaurant:
            return "Restaurant"
        case .activity:
            return "Activity"
        case .tour:
            return "Tour"
        case .transportation:
            return "Transportation"
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
    var days: [Int : [Event]] = [:]
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
    var startTime: Date
    var endTime: Date
    var location: Location
    var destination: Location?
}
