//
//  YelpFetcher.swift
//  Roam
//
//  Created by Jeremy Teng  on 08/05/2024.
//

import Foundation
import SwiftUI


@MainActor
class YelpFetcher: ObservableObject {
    let QUERY_LIMIT = 20
    
    @Published var searchText: String = ""
    @Published var locations = [LocationData]()
    @Published var locationDetail: LocationDetail?
    @Published var searchingState: FetchingState = .noSearch
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var reviews = [LocationReview]()
    
    let service = APISerivce()
    
    private let apiKey: String = {
        if let key = ProcessInfo.processInfo.environment["YELP_API_KEY"] {
            return key
        } else {
            fatalError("YELP_API_KEY environment variable not set")
        }
    }()
    private var searchURLComponents = URLComponents()
    
    init(){
        searchURLComponents.scheme = "https"
        searchURLComponents.host = "api.yelp.com"
    }
    
    
    /**
    Fetch several buisiness from a Yelp api of a certain location
     - Parameters:
        - categories: Categories of the buisiness
        - requestIndex: the frequency of the request
    */
    func fetchBeuisinessByLocation(categories: String?, requestIndex: Int = 0) async {
        
        if requestIndex == 0 {
            locations.removeAll()
            isLoading  = true
        }
        
        searchURLComponents.path = "/v3/businesses/search"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "term", value: ""),
            URLQueryItem(name: "location", value: searchText),
            URLQueryItem(name: "categories", value: "bar"),
            URLQueryItem(name: "limit", value: "\(QUERY_LIMIT)"),
            URLQueryItem(name: "offset", value: "\(requestIndex * QUERY_LIMIT)"),
        ]
        
        await service.fetch(VolumeData.self, url: searchURLComponents.url, apiKey: apiKey) { result in
            
            switch result {
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                print(error)
            case .success(let volumeData):
                if let location = volumeData.businesses {
                    self.locations.append(contentsOf: location)
                    self.isLoading = false
                }
            }
        }
    }
    
    /**
    Fetch several buisiness from a Yelp api of a certain name
     - Parameters:
        - location: location of the serach scope
        - requestIndex: the frequency of the request
    */
    func fetchBeuisinessByName(location: String, requestIndex: Int = 0) async {
        
        if requestIndex == 0 {
            locations.removeAll()
            isLoading  = true
        }
        
        searchURLComponents.path = "/v3/businesses/search"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "term", value: searchText),
            URLQueryItem(name: "location", value: location),
            URLQueryItem(name: "categories", value: ""),
            URLQueryItem(name: "limit", value: "\(QUERY_LIMIT)"),
            URLQueryItem(name: "offset", value: "\(requestIndex * QUERY_LIMIT)"),
        ]
        
        await service.fetch(VolumeData.self, url: searchURLComponents.url, apiKey: apiKey) { result in
            
            switch result {
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                print(error)
            case .success(let volumeData):
                if let location = volumeData.businesses {
                    self.locations.append(contentsOf: location)
                    self.isLoading = false
                }
            }
        }
    }
    
    /**
    Fetch the detail of a specific buisiness
     - Parameters:
        - id: id that directly reference to the buisines to search
    */
    func fetchLocationDetail(id: String) async{
        
        isLoading  = true
        let url = URL(string: "https://api.yelp.com/v3/businesses/\(id)")

        await service.fetch(LocationDetail.self, url: url, apiKey: apiKey) { result in
            
            switch result {
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                print(error)
            case .success(let detail):
                self.locationDetail = detail
                self.searchingState = .completesSearching
                self.isLoading = false
            }
        }
        
        await fetchLocationReview(id: id)
    }
    
    /**
    Fetch the review of a specific buisiness
     - Parameters:
        - id: id that directly reference to the buisines to search
    */
    func fetchLocationReview(id: String) async {
        isLoading  = true
        let url = URL(string: "https://api.yelp.com/v3/businesses/\(id)/reviews")
        
        searchURLComponents.path = "/v3/businesses/\(id)/reviews"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "limit", value: "50")
        ]
        
        await service.fetch(VolumeReviews.self, url: url, apiKey: apiKey) { result in
            
            switch result {
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                print(error)
            case .success(let reviews):
                if let reviews = reviews.reviews {
                    self.searchingState = .completesSearching
                    self.reviews.append(contentsOf: reviews)
                    self.isLoading = false
                }
            }
        }
    }
}
