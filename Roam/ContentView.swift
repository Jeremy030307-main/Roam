//
//  ContentView.swift
//  Roam
//
//  Created by Jeremy Teng  on 11/04/2024.
//

import SwiftUI
import CoreData

struct ContentView: View {

    @State var enterPerDayView = false
    
    var body: some View {
        TabView{
            HomePage()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            TripPage(enterPerDayView: $enterPerDayView)
                .tabItem {
                    Label("Trip", systemImage: "airplane.departure")
                }
                .toolbarBackground(enterPerDayView==true ? .visible: .automatic, for: .tabBar)
            
            
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
