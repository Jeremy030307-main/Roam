//
//  User.swift
//  Roam
//
//  Created by Jeremy Teng  on 25/04/2024.
//

import Foundation
import SwiftUI

struct User: Identifiable, Hashable, Codable{
    
    var id: String?
    var name: String?
    var username: String?
    var email: String?
    var password: String?
    var image: String?
    
    var posts: [Post] = []
    var guides: [Guide] = []
    var followers: [User] = []
    var following: [User] = []
    var trips: [Trip] = []
}
