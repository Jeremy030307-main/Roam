//
//  RoamApp.swift
//  Roam
//
//  Created by Jeremy Teng  on 11/04/2024.
//

import SwiftUI

@main
struct RoamApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
