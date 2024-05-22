//
//  YelpFetcher.swift
//  Roam
//
//  Created by Jeremy Teng  on 08/05/2024.
//

import Foundation
import SwiftUI

enum FetchingState{
    
    case noSearch
    case enterSearch(fromMainPage: Bool)  // 0 means it come from main page, 1 means it come from search result page
    case completesSearching
}

@MainActor
class YelpFetcher: ObservableObject {
    
    @Published var searchText: String = ""
    @Published var locations = [LocationData]()
    @Published var locationDetail: LocationDetail?
    @Published var searchingState: FetchingState = .noSearch
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var reviews = [LocationReview]()
    
    let service = APISerivce()
    
    private let apiKey = "rdgyPRJcyqMJinNN8UPBa3Yam7wBz5MQzUSvWH0k5k-zegy5uHEj0NDe_XRl0expZwAVsQYrkCD-bN69nsjzCyp4brExwKjCOhhBvh4ofKTE8rmswYfzgFDsoCz3ZXYx"
    private var searchURLComponents = URLComponents()
    
    init(){
        searchURLComponents.scheme = "https"
        searchURLComponents.host = "api.yelp.com"
    }
    
    func fetchAllLocation(categories: String?) async {
        
        locations.removeAll()
        isLoading  = true
        
        searchURLComponents.path = "/v3/businesses/search"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "term", value: ""),
            URLQueryItem(name: "location", value: searchText),
            URLQueryItem(name: "categories", value: categories ?? "")
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
    }
    
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
