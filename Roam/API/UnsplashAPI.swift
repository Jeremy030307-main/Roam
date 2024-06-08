//
//  UnsplashAPI.swift
//  Roam
//  View Model to fetch data from Unsplace API

//  Created by Jeremy Teng  on 07/06/2024.
//

import Foundation

struct RandomPhotoData: Codable {
    
    var url: String?
    
    private enum RootKeys: String, CodingKey {
        case url = "urls"
    }
    
    private enum ImageTypeKeys: String, CodingKey {
        case regular
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: RootKeys.self)
        
        // get the image type container
        let imageContainer = try container.nestedContainer(keyedBy: ImageTypeKeys.self, forKey: .url)
        
        self.url = try? imageContainer.decode(String.self, forKey: .regular)
    }
}

struct TopicID: Codable {
    
    var id: String?
}

class UnsplashAPI: ObservableObject {
    
    @Published var imageURL: String = ""
    @Published var errorMessage: String? = nil
    @Published var isLoading = false
    @Published var testing:String? = nil
    private let apiKey = "_Szn5_A5xBPOTCCuYS3l80xX3PUpT4KXATrmIHVzCdI"
    private var topicID = ""

    
    let service = APISerivce()
    private var searchURLComponents = URLComponents()

    init(query: String) async {
        searchURLComponents.scheme = "https"
        searchURLComponents.host = "api.unsplash.com"
        
        await self.fetchTopic()
        await self.fetchRandomPhoto(query:query)
    }
    
    /**
    Get a random photo from Unspalsh API with specific search term
     - Parameters:
        - query: searh term
     */
    func fetchRandomPhoto(query: String) async {
        
        searchURLComponents.path = "/photos/random"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "client_id", value: "sl9iFlZMH_uie8SqfuDh0I2lsN7S1N1qhaJ46oYiu0c"),
            URLQueryItem(name: "topics", value: topicID)
        ]
        
        await service.fetch(RandomPhotoData.self, url: searchURLComponents.url, apiKey: nil) { result in
            
            switch result {
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.testing = error.description
                print("ffdsfd", error)
            case .success(let randomImage):
                if let image = randomImage.url {
                    self.imageURL = image
                    self.isLoading = false
                    print(image)
                }
            }
        }
        print("End")
    }
    
    /**
    Get he topic id from Unsplash API
     */
    func fetchTopic() async {
        
        searchURLComponents.path = "/topics/travel"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "client_id", value: "sl9iFlZMH_uie8SqfuDh0I2lsN7S1N1qhaJ46oYiu0c")
        ]
        
        await service.fetch(TopicID.self, url: searchURLComponents.url, apiKey: nil) { result in
            
            switch result {
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.testing = error.description
                print("ffdsfd", error)
            case .success(let topic):
                if let id = topic.id {
                    self.topicID = id
                    self.isLoading = false
                }
            }
        }
        print("End")
    }
}
