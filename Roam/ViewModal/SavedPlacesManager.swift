//
//  SavedPlacesManager.swift
//  Roam
//
//  Created by Jeremy Teng  on 29/04/2024.
//

import UIKit

class SavedPlacesManager: ObservableObject {

    @Published var savedPlace: SavedPlace
    
    init(savedPlace: SavedPlace) {
        self.savedPlace = savedPlace
    }
}
