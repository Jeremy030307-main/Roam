//
//  YelpAPI.swift
//  Roam
//
//  Created by Jeremy Teng  on 07/05/2024.
//

import Foundation

struct VolumeData: Codable {
    var businesses: [LocationData]?
}

struct LocationData: Codable {
    
    var name: String?
    var rating: Double?
    var price: String?
    var phone: String?
    var categories: [String]?
    var reviewCount: Int?
    var imageURL: String?
    var latitude: Double?
    var longitude: Double?
    var address: String?
    
    private enum RootKeys: String, CodingKey {
        case rating
        case price
        case phone
        case categories
        case reviewCount = "review_count"
        case name
        case coordinates
        case imageURL = "image_url"
        case location
    }
    
    private enum CoordinateKeys: String, CodingKey {
        case latitude
        case longitude
    }
    
    private enum LocationKeys: String, CodingKey {
        case address1
        case zip = "zip_code"
        case city
        case country
    }
    
    private struct Category: Decodable {
        var alias: String
        var title: String
    }
    
    init(from decoder: Decoder) throws {
        
        // get the root container
        let rootContainer = try decoder.container(keyedBy: RootKeys.self)
        
        // get the coordinate container
        let coordinateContainer = try rootContainer.nestedContainer(keyedBy: CoordinateKeys.self, forKey: .coordinates)
        
        // get the location container
        let locationcontainer = try rootContainer.nestedContainer(keyedBy: LocationKeys.self, forKey: .location)

        // get the location info
        name = try rootContainer.decode(String.self, forKey: .name)
        rating = try? rootContainer.decode(Double.self, forKey: .rating)
        price = try? rootContainer.decode(String.self, forKey: .price)
        phone = try? rootContainer.decode(String.self, forKey: .phone)
        reviewCount = try? rootContainer.decode(Int.self, forKey: .reviewCount)
        imageURL = try? rootContainer.decode(String.self, forKey: .imageURL)
        
        // get the coordinate
        latitude = try? coordinateContainer.decode(Double.self, forKey: .latitude)
        longitude = try? coordinateContainer.decode(Double.self, forKey: .longitude)
        
        // get the address
        let address1 = try? locationcontainer.decode(String.self, forKey: .address1)
        let zip = try? locationcontainer.decode(String.self, forKey: .zip)
        let city = try? locationcontainer.decode(String.self, forKey: .city)
        let country = try? locationcontainer.decode(String.self, forKey: .country)
        
        address = "\(address1 ?? ""), \(zip ?? ""), \(city ?? ""), \(country ?? "")"

        
        // get the catogories
        if let catogoriesList = try? rootContainer.decodeIfPresent([Category].self, forKey: .categories) {
            // loop through array to add the catogory title in list
            for category in catogoriesList {
                categories?.append(category.title)
            }
        }
        
        
        
    }
    
}
