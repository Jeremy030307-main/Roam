//
//  AuthenticatedView.swift
//  Roam
//
//  Created by Jeremy Teng  on 25/05/2024.
//

import SwiftUI

struct AuthenticatedView: View {
    
    @StateObject var firebaseController = FirebaseController.shared
    @StateObject var authViewModel = AuthenticationVM()

    var body: some View {
        switch authViewModel.authenticationState {
        case .unauthenticated, .authenticating:
            AuthenticationView(authViewModel: authViewModel)
        case .authenticated:
            ContentView()
            .environmentObject(authViewModel)
            .environmentObject(firebaseController)
        }
    }
}

#Preview {
    AuthenticatedView()
}
