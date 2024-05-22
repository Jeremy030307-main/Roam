//
//  CitySearchViewModal.swift
//  Roam
//
//  Created by Jeremy Teng  on 10/05/2024.
//

import Foundation
import MapKit
import Combine

class CitySearchViewModal: NSObject,ObservableObject {
    
    enum LocationStatus: Equatable {
            case idle
            case noResults
            case isSearching
            case error(String)
            case result
        }

        @Published var queryFragment: String = ""
        @Published private(set) var status: LocationStatus = .idle
        @Published private(set) var searchResults: [(String, String)] = []

        private var queryCancellable: AnyCancellable?
        private let searchCompleter: MKLocalSearchCompleter!

        init(searchCompleter: MKLocalSearchCompleter = MKLocalSearchCompleter()) {
            self.searchCompleter = searchCompleter
            super.init()
            self.searchCompleter.delegate = self
            self.searchCompleter.region = MKCoordinateRegion(.world)
            self.searchCompleter.resultTypes = MKLocalSearchCompleter.ResultType([.address])

            queryCancellable = $queryFragment
                .receive(on: DispatchQueue.main)
                // we're debouncing the search, because the search completer is rate limited.
                // feel free to play with the proper value here
                .debounce(for: .milliseconds(250), scheduler: RunLoop.main, options: nil)
                .sink(receiveValue: { fragment in
                    self.status = .isSearching
                    if !fragment.isEmpty {
                        self.searchCompleter.queryFragment = fragment
                    } else {
                        self.status = .idle
                        self.searchResults = []
                    }
            })
        }
}

extension CitySearchViewModal: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let result = self.getCityList(results: completer.results)
        if result.isEmpty{
            self.status = .noResults
        } else {
            self.searchResults = result
            self.status = .result
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        self.status = .error(error.localizedDescription)
    }
    
    func getCityList(results: [MKLocalSearchCompletion]) -> [(city: String, country: String)]{
        
        var searchResults: [(city: String, country: String)] = []
        
        for result in results {
            
            let titleComponents = result.title.components(separatedBy: ", ")
            let subtitleComponents = result.subtitle.components(separatedBy: ", ")
            
            buildCityTypeA(titleComponents, subtitleComponents){place in
                
                if place.city != "" && place.country != ""{
                    
                    searchResults.append(place)
                }
            }
            
            buildCityTypeB(titleComponents, subtitleComponents){place in
                
                if place.city != "" && place.country != ""{
                    
                    searchResults.append(place)
                }
            }
        }
        
        return searchResults
    }
    
    func buildCityTypeA(_ title: [String],_ subtitle: [String], _ completion: @escaping ((city: String, country: String)) -> Void){
        
        var city: String = ""
        var country: String = ""
        
        if title.count > 1 && subtitle.count >= 1 {
            
            city = title.first!
            country = subtitle.count == 1 && subtitle[0] != "" ? subtitle.first! : title.last!
        }
        
        completion((city, country))
    }

    func buildCityTypeB(_ title: [String],_ subtitle: [String], _ completion: @escaping ((city: String, country: String)) -> Void){
        
        var city: String = ""
        var country: String = ""
        
        if title.count >= 1 && subtitle.count == 1 {
            
            city = title.first!
            country = subtitle.last!
        }
        
        completion((city, country))
    }
    
    func returnText() -> [String]{
        var returnList: [String] = []
        for (city, country) in searchResults{
            let text = "\(city), \(country)"
            returnList.append(text)
        }
        return Array(Set(returnList))
    }
}
