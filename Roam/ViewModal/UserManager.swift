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
    
    func deleteTrip(offset: IndexSet){
        self.user.itinerary.remove(atOffsets: offset)
    }
}
