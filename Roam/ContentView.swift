//
//  ContentView.swift
//  Roam
//
//  Created by Jeremy Teng  on 11/04/2024.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @EnvironmentObject var authViewModel: AuthenticationVM
    @EnvironmentObject var firebaseController: FirebaseController
    @StateObject var userManager = UserManager(user: FirebaseController.shared.user)
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
            
            ProfilePage()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .environmentObject(UserManager(user: firebaseController.user))
    }
       
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationVM())
        .environmentObject(FirebaseController.shared)

}
