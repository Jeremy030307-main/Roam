//
//  Event.swift
//  Roam
//
//  Created by Jeremy Teng  on 30/04/2024.
//

import Foundation

struct Location: Hashable , Identifiable{
    
    var id = UUID()
    var name: String
    var address: String
    var rating: Double
    var descrition: String
    var phone: String
    var operatingHour: String
    var image: String?
}
