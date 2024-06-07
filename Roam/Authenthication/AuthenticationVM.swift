//
//  AuthenticationVM.swift
//  Roam
//
//  Created by Jeremy Teng  on 23/05/2024.
//

import Foundation
import FirebaseAuth

enum AuthenticationState: String {
    
    case unauthenticated = "Unauthenticated"
    case authenticating = "authenticating"
    case authenticated = "authenticated"
}

class AuthenticationVM: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var username: String = ""
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var currentUser: FirebaseAuth.User?
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    init(){
        registerAuthStateHandler()
    }
    
    func registerAuthStateHandler() {
        if authStateHandler == nil {
          authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
            self.currentUser = user
            self.authenticationState = user == nil ? .unauthenticated : .authenticated
          }
        }
    }
}

// Email and password Authentication
extension AuthenticationVM {
    
    func signInWithEmailPassword() async -> Bool{
        authenticationState = .authenticating
        do {
            try await Auth.auth().signIn(withEmail: self.email, password: self.password)
            return true
        } catch {
            print("Failed to Sign In \(error.localizedDescription)")
            self.authenticationState = .unauthenticated
            clearInput()
            return false
        }
    }
    
    func signUpWithEmailPassword() async -> Bool {
        authenticationState = .authenticating
        if password.count > 0{
            do {
                try await Auth.auth().createUser(withEmail: self.email, password: self.password)
                let textBfrEmail = email.components(separatedBy: "@")
                let _ = FirebaseController.shared.addUser(name: self.username, username: textBfrEmail[0], email: self.email)
                authenticationState = .authenticated
                print("fdsfdfsd")
                return true
            } catch {
                print("Failed to Sign Up \(error.localizedDescription)")
                self.authenticationState = .unauthenticated
                clearInput()
                return false
            }
        }
        return false
    }
    
    func signOut() {
        do{
            try Auth.auth().signOut()
            clearInput()
        } catch {
            print("Failed to Sign Out. \(error.localizedDescription)")
        }
    }
    
    func clearInput(){
        email = ""
        password = ""
    }
}
