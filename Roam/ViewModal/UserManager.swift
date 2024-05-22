//
//  UserManager.swift
//  Roam
//
//  Created by Jeremy Teng  on 30/04/2024.
//

import Foundation

class UserManager: ObservableObject {
    
    @Published var user: User
    
    init(user: User) {
        self.user = user
    }
    
    func addNewTrip(title: String, destination: String, totalDays: Int,startDate: Date?, endDate: Date?, pax: Int?){
        let trip = Trip(image: "sfs", title: title, destination: destination, startDate: startDate, endDate: endDate, totalDays: totalDays, pax: pax)
        user.itinerary.append(trip)
    }
    
    func deleteTrip(offset: IndexSet){
        self.user.itinerary.remove(atOffsets: offset)
    }
}
