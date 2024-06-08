//
//  AuthenticationView.swift
//  Roam
//  The first page of the application that allow user to log in
//  Created by Jeremy Teng  on 23/05/2024.
//

import SwiftUI

enum AuthenticationFlow {
    case signIn, signUp
}

struct AuthenticationView: View {
    
    @ObservedObject var authViewModel: AuthenticationVM
    @State var authenticationFail = false
    @State var alertMessage = ""
    @State var authenticationFlow: AuthenticationFlow = .signIn
    
    var body: some View {
        let targetSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height / 4.5)

        NavigationStack {
            ZStack(alignment: .top){
                VStack {
                    Color.accentColor
                        .frame(width: targetSize.width, height: targetSize.height)
                        .cornerRadius(50)
                }
                .ignoresSafeArea()
                
                VStack{
                    Image("Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: targetSize.height/2)
                        .fixedSize()
                }
            }
            .fixedSize()
            
            VStack(spacing: 30 ){

                if authenticationFlow == .signUp{
                    VStack(alignment:.leading) {
                        Text("Username").font(.headline)
                        TextField("\("enter name")", text: $authViewModel.username)
                            .padding()
                            .background(Color.gray.opacity(0.4))
                            .clipShape(.buttonBorder)
                    }
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
                    if authenticationFlow == .signUp{
                        HStack{
                            Text(authViewModel.validPasswordLength ?  " ✔ Password have minimum 8 characters": "✖ Password have minimum 8 characters").foregroundStyle(authViewModel.validPasswordLength ? .green:.red)
                        }
                    }
                }
                
                Spacer()
                
                VStack{
                    if authViewModel.authenticationState != .authenticating{
                        switch authenticationFlow {
                        case .signIn:
                            Button(action: signIn) {
                                Text("Sign In")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height:40)
                            }.buttonStyle(.borderedProminent)
                            HStack{
                                Text("Need an account?")
                                Button("Sign Up"){
                                    authenticationFlow = .signUp
                                }
                            }
                        case .signUp:
                            Button(action: signUp) {
                                Text("Sign Up")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height:40)
                            }.buttonStyle(.borderedProminent)
                            HStack{
                                Text("Need an account?")
                                Button("Sign In"){
                                    authenticationFlow = .signIn
                                }
                            }
                        }
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                    }
                    
                }.frame(minHeight: 150)
            }
            .padding()
            .alert(  // prommpt alert message if the description is empty
                "Authentication Failed",
                isPresented: $authenticationFail
            ) {
                Button("Retry") {
                    
                }
            } message: {
                Text("\(authViewModel.errorMessage)")
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
