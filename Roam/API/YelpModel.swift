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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.businesses = try container.decodeIfPresent([LocationData].self, forKey: .businesses)
    }
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
    
    init(id: String?,name: String?,rating: Double?,price: String?,phone: String?,categories: [String]?,reviewCount: Int?,imageURL: String?,latitude: Double?,longitude: Double?,address: String?){
        self.id = id
        self.name = name
        self.rating = rating
        self.price = price
        self.phone = phone
        self.categories = categories
        self.reviewCount = reviewCount
        self.imageURL = imageURL
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
    }
    
    init(location: Location){
        self.id = location.id
        self.name = location.name
        self.rating = location.rating
        self.price = location.price
        self.phone = location.phone
        self.imageURL = location.image
        self.address = location.address
    }
}

struct LocationDetail: Codable, Hashable {
    
    var photos: [String]?
    var open: [String: [String]]?
    var address: String?

    private enum RootKeys: String, CodingKey {
        case hours
        case photos
        case location
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
    
    private struct Hours: Codable, Hashable{
        
        var hours_type: String?
        var open: [String: [String]]?
        
        private enum RootKeys: String, CodingKey{
            case hours_type
            case open
            case is_open_now
        }
        
        private struct Openingtime: Decodable {
            var is_overnight: Bool
            var end: String
            var day: Int
            var start: String
        }
        
        init(from decoder: Decoder) throws {
            
            // get the root key container
            let rootContainer = try decoder.container(keyedBy: RootKeys.self)
            self.hours_type = try? rootContainer.decode(String.self, forKey: .hours_type)
            
            if let openingHours = try? rootContainer.decodeIfPresent([Openingtime].self, forKey: .open){
                self.open = [:]
                for openTime in openingHours{
                    print(openTime.start)
                    print(openTime.end)
                    self.open?[Weekday(rawValue: openTime.day)?.day ?? " "] = [openTime.start, openTime.end]
                }
            }
        }
    }
    
    init(from decoder: Decoder) throws {
        
        // get the root container
        let rootContainer = try decoder.container(keyedBy: RootKeys.self)
                
        // get the locatoin container
        let locationContainer = try rootContainer.nestedContainer(keyedBy: LocationKeys.self, forKey: .location)
        
        // get the location details
        photos = try? rootContainer.decode([String].self, forKey: .photos)
        
        if let hours = try? rootContainer.decode([Hours].self, forKey: .hours){
            for hour in hours{
                if hour.hours_type == "REGULAR"{
                    self.open = hour.open
                }
            }
        }
        // get the address
        let address1 = try? locationContainer.decode(String.self, forKey: .address1)
        let zip = try? locationContainer.decode(String.self, forKey: .zip)
        let city = try? locationContainer.decode(String.self, forKey: .city)
        let country = try? locationContainer.decode(String.self, forKey: .country)
        
        address = "\(address1 ?? ""), \(zip ?? ""), \(city ?? ""), \(country ?? "")"
    }
    
    init(photos: [String]?, open: [String: [String]]?, address: String?){
        self.photos = photos
        self.open = open
        self.address = address
    }
}

struct VolumeReviews: Codable, Hashable{
    
    var reviews: [LocationReview]?
    
}

struct LocationReview: Codable, Hashable {
    
    var text: String?
    var userName: String?
    var userImage: String?
    var rating: Double?
    var reviewLink: String?
    
    private enum ReviewKeys: String, CodingKey {
        case text
        case user
        case rating
        case url
    }
    
    private enum UserKeys: String, CodingKey {
        case image_url
        case name
    }
    
    init(from decoder: Decoder) throws {
        let reviewContainer = try decoder.container(keyedBy: ReviewKeys.self)
        let userContainer = try reviewContainer.nestedContainer(keyedBy: UserKeys.self   , forKey: .user)
        
        text = try? reviewContainer.decode(String.self, forKey: .text)
        rating = try? reviewContainer.decode(Double.self, forKey: .rating)
        reviewLink = try? reviewContainer.decode(String.self, forKey: .url)
        userName = try? userContainer.decode(String.self, forKey: .name)
        userImage = try? userContainer.decode(String.self, forKey: .image_url)
    }
    
    init(text: String?, userName: String?, userImage: String?, rating: Double?, reviewLink: String?){
        self.text = text
        self.userName = userName
        self.userImage = userImage
        self.reviewLink = reviewLink
    }
}
