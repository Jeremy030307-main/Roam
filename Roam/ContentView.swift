//
//  ContentView.swift
//  Roam
//
//  Created by Jeremy Teng  on 11/04/2024.
//

import SwiftUI
import CoreData

struct ContentView: View {

    var body: some View {
        TabView{
            HomePage()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            TripPage()
                .tabItem {
                    Label("Trip", systemImage: "airplane.departure")
                }
            
            NotificationPage()
                .tabItem {
                    Label("Notification", systemImage: "bell.fill")
                }
            
            ProfilePage()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
       
}

#Preview {
    ContentView()
}
