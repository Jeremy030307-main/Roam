//
//  AuthenticationView.swift
//  Roam
//
//  Created by Jeremy Teng  on 23/05/2024.
//

import SwiftUI

struct AuthenticationView: View {
    
    @ObservedObject var authViewModel: AuthenticationVM
    @State var authenticationFail = false
    @State var alertMessage = ""
    
    var body: some View {
        
        NavigationStack {
            VStack(spacing: 30 ){
                Text(authViewModel.currentUser?.uid ?? "none")
                Spacer()

                VStack(alignment:.leading) {
                    Text("Username").font(.headline)
                    TextField("\("enter name")", text: $authViewModel.username)
                        .padding()
                        .background(Color.gray.opacity(0.4))
                        .clipShape(.buttonBorder)
                }
                VStack(alignment:.leading) {
                    Text("Email").font(.headline)
                    TextField("\("example.@gmail.com")", text: $authViewModel.email)
                        .padding()
                        .background(Color.gray.opacity(0.4))
                        .clipShape(.buttonBorder)
                }
                VStack(alignment:.leading) {
                    Text("Password").font(.headline)
                    SecureField("", text: $authViewModel.password)
                        .padding()
                        .background(Color.gray.opacity(0.4))
                        .clipShape(.buttonBorder)
                    
                }
                Spacer()
                
                VStack{
                    if authViewModel.authenticationState != .authenticating{
                        Button(action: signIn) {
                            Text("Sign In")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height:40)
                        }.buttonStyle(.borderedProminent)
                        
                        Button(action: signUp) {
                            Text("Sign Up")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height:40)
                        }.buttonStyle(.borderedProminent)
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                    }
                    
                }.frame(minHeight: 150)
            }
            .padding()
            .navigationTitle("Sign Up/ Login")
            .alert(  // prommpt alert message if the description is empty
                "Authentication Failed",
                isPresented: $authenticationFail
            ) {
                Button("Retry") {
                    
                }
            } message: {
                Text("\($alertMessage.wrappedValue)")
            }
        }
    }
    
    func signIn() {
        Task {
            alertMessage = "You have to sign up first. "
            await authenticationFail = !authViewModel.signInWithEmailPassword()
        }
    }
    
    func signUp() {
        Task {
            alertMessage = "Invalid Email Address"
            await authenticationFail = !authViewModel.signUpWithEmailPassword()
        }
    }
}

#Preview {
    AuthenticationView(authViewModel: AuthenticationVM())
}
