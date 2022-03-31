//
//  LoginView.swift
//  SwiftUIFirebaseRTC
//
//  Created by Ken Muyesu on 29/03/2022.
//

import SwiftUI
import Firebase

struct LoginView: View {
    @State var isLoginMode = false
    @State var email = ""
    @State var password = ""
    
    //initializing Firebase SDK
//    init() {
//        FirebaseApp.configure()
//    }
    
    private func handleAction() {
        if isLoginMode {
            print("Should login into Firebase with existing credentials.")
        } else {
            print("Register a new account inside of Firebase Auth and then store image in storage...")
        }
    }
    var body: some View { //opaque return type
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Picker(selection: $isLoginMode, label: Text("This is a picker")) {
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    //.padding()
                    
                    if !isLoginMode {
                        Button {
                            
                        } label: {
                            Image(systemName: "person")
                                .font(.system(size: 128))
                                .padding()
                        }
                    }
                    
                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        SecureField("Password", text: $password)
                    }
                    //.textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .background(.white)
                    .cornerRadius(10)
                    
                    Button {
                        handleAction()
                    } label: {
                        HStack {
                            Spacer()
                            Text(isLoginMode ? "Log In" : "Create Account")
                                .foregroundColor(.white)
                                .padding()
                                .font(.system(size: 18, weight: .semibold))
                            Spacer()
                        }
                        .background(.blue)
                        .cornerRadius(10)
                        //.padding()
                    }
                }
                .padding()
            }
            .navigationTitle(isLoginMode ? "Log In" : "Create Account")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.init(white: 0, alpha: 0.15))
                            .ignoresSafeArea())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
