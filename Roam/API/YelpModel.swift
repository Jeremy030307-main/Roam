//
//  YelpAPI.swift
//  Roam
//
//  Created by Jeremy Teng  on 07/05/2024.
//

import Foundation

enum Weekday: Int, CaseIterable, Identifiable{
    
    case Monday = 0
    case Tuesday = 1
    case Wednesday = 2
    case Thursday = 3
    case Friday = 4
    case Saturday = 5
    case Sunday = 7
    
    var id: Self {self}
    var day: String {
        switch self {
        case .Monday: return "Monday"
        case .Tuesday: return "Tuesday"
        case .Wednesday: return "Wednesday"
        case .Thursday: return "Thursday"
        case .Friday: return "Friday"
        case .Saturday: return "Saturday"
        case .Sunday: return "Sunday"
        }
    }
}

struct VolumeData: Codable {
    var businesses: [LocationData]?
}

struct LocationData: Codable, Hashable {
    
    var id: String?
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
        case id
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
        id = try rootContainer.decode(String.self, forKey: .id)
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
            categories = []
            for category in catogoriesList {
                categories?.append(category.title)
            }
        }
        
        
        
    }
    
}

struct LocationDetail: Codable, Hashable {
    
    var photos: [String]?
    var hours: String?
    var address: String?

    private enum RootKeys: String, CodingKey {
        case hours
        case photos
        case location
    }
    
    private struct Hours: Decodable {
        var hours_type: String
        var open: [Openingtime]
        var is_open_now: Bool
    }
    
    private struct Openingtime: Decodable {
        var is_overnight: Bool
        var end: Int
        var day: Int
        var start: Int
    }
    
    private enum LocationKeys: String, CodingKey {
        case city
        case country
        case address1
        case address2
        case address3
        case state
        case zip = "zip_code"
    }
    
    init(from decoder: Decoder) throws {
        
        // get the root container
        let rootContainer = try decoder.container(keyedBy: RootKeys.self)
        
        // get the hours container
        let hourContainer = try rootContainer.nestedContainer(keyedBy: HoursKey.self, forKey: .hours)
        
        // get the locatoin container
        let locationContainer = try rootContainer.nestedContainer(keyedBy: LocationKeys.self, forKey: .location)
        
        // get the location details
        photos = try? rootContainer.decode([String].self, forKey: .photos)
        
        hours = try? hourContainer.decode(String.self, forKey: .hours_type)
//         get the opening hours
//        if let opening = try? hourContainer.decodeIfPresent([Openingtime].self, forKey: .open){
//            
//            for time in opening{
//                hours?.append(time.day)
//            }
//        }
        
        // get the address
        let address1 = try? locationContainer.decode(String.self, forKey: .address1)
        let zip = try? locationContainer.decode(String.self, forKey: .zip)
        let city = try? locationContainer.decode(String.self, forKey: .city)
        let country = try? locationContainer.decode(String.self, forKey: .country)
        
        address = "\(address1 ?? ""), \(zip ?? ""), \(city ?? ""), \(country ?? "")"
        
    }
    
    
}
