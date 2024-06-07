//
//  Event.swift
//  Roam
//
//  Created by Jeremy Teng  on 30/04/2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Location: Hashable , Identifiable, Codable{
    
    @DocumentID var id: String?
    var name: String?
    var address: String?
    var rating: Double?
    var price: String?
    var phone: String?
    var operatingHour: String?
    var image: String?
    
    init(name: String, address: String, rating: Double, phone: String, operatingHour: String, image: String? = nil, price: String) {
        self.id = UUID().uuidString
        self.name = name
        self.address = address
        self.rating = rating
        self.phone = phone
        self.operatingHour = operatingHour
        self.image = image
        self.price = price
    }
    
    init(locationData: LocationData){
        
        self.id = locationData.id ?? ""
        self.name = locationData.name ?? ""
        self.address = locationData.address ?? ""
        self.rating = locationData.rating ?? 0
        self.phone = locationData.phone ?? ""
        self.image = locationData.imageURL ?? ""
        self.price = locationData.price ?? ""        
    }
}
