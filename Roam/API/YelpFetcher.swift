//
//  YelpFetcher.swift
//  Roam
//
//  Created by Jeremy Teng  on 08/05/2024.
//

import Foundation

@MainActor
class YelpFetcher: ObservableObject {
    
    @Published var searchText: String = ""
    @Published var locations = [LocationData]()
    @Published var locationDetail: LocationDetail?
    @Published var isLoading: Bool  = false
    @Published var errorMessage: String? = nil
    
    let service = APISerivce()
    
    private let apiKey = "rdgyPRJcyqMJinNN8UPBa3Yam7wBz5MQzUSvWH0k5k-zegy5uHEj0NDe_XRl0expZwAVsQYrkCD-bN69nsjzCyp4brExwKjCOhhBvh4ofKTE8rmswYfzgFDsoCz3ZXYx"
    private var searchURLComponents = URLComponents()
    
    init(){
        searchURLComponents.scheme = "https"
        searchURLComponents.host = "api.yelp.com"
    }
    
    func fetchAllLocation() async {
        
        locations.removeAll()
        isLoading = true
        
        searchURLComponents.path = "/v3/businesses/search"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "term", value: searchText),
            URLQueryItem(name: "location", value: "Australia")
        ]
        
        await service.fetch(VolumeData.self, url: searchURLComponents.url, apiKey: apiKey) { result in
            
            switch result {
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                print(error)
            case .success(let volumeData):
                if let location = volumeData.businesses {
                    self.isLoading = false
                    self.locations.append(contentsOf: location)
                }
            }
        }
    }
    
    func fetchLocationDetail(id: String) async{
        
        isLoading = true
        let url = URL(string: "https://api.yelp.com/v3/businesses/\(id)")!

//        searchURLComponents.path = "v3/businesses/north-india-restaurant-san-francisco"
        print(url)
        await service.fetch(LocationDetail.self, url: url, apiKey: apiKey) { result in
            
            switch result {
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                print(error)
            case .success(let detail):
                self.locationDetail = detail
            }
        }
    }
    
    
}
