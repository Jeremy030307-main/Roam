//
//  APISerivce.swift
//  Roam
//
//  Created by Jeremy Teng  on 09/05/2024.
//

import Foundation

struct APISerivce {
    
    func fetch<T: Decodable>(_ type: T.Type, url: URL?, apiKey: String?, completion: @escaping(Result<T,APIError>) -> Void) async{
                
        guard let requestURL = url else {
            let error = APIError.badURL
            completion(Result.failure(error))
            return
        }
        
        var urlRequest = URLRequest(url: requestURL)
        if let apiKey = apiKey{
            urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }
        urlRequest.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode){
                let error = APIError.badResponse(statusCode: response.statusCode)
                completion(Result.failure(error))
            }
            
            do {
                let decoder = JSONDecoder()
                let volumeData = try decoder.decode(type, from: data)
                completion(Result.success(volumeData))
            }catch {
                let error = APIError.parsing(error as? DecodingError)
                completion(Result.failure(error))
            }
        } catch let error{
            print(error)
        }
    }
}
