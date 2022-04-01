//
//  LoginView.swift
//  SwiftUIFirebaseRTC
//
//  Created by Ken Muyesu on 29/03/2022.
//

import SwiftUI
import Firebase

//initializing Firebase SDK using singleton approach
class FirebaseManager: NSObject {
    let auth: Auth
    let storage: Storage
    
    static let shared = FirebaseManager()
    
    override init() {
        FirebaseApp.configure()
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        super.init()
    }
}

struct LoginView: View {
    @State var isLoginMode = false
    @State var email = ""
    @State var password = ""
    
    @State private var shouldShowImagePicker = false
    
    @State var image: UIImage?

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
                            shouldShowImagePicker.toggle()
                        } label: {
                            VStack {
                                if let image = self.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 150, height: 150)
                                        .cornerRadius(75)
                                } else {
                                    Image(systemName: "person")
                                        .font(.system(size: 75))
                                        .padding()
                                        .foregroundColor(Color(.label))
                                }
                            }
                            .overlay(RoundedRectangle(cornerRadius: 75)
                                        .stroke(Color.black, lineWidth: 2))
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
                    Text(self.loginStatusMessage)
                        .foregroundColor(Color.red)
                }
                .padding()
            }
            .navigationTitle(isLoginMode ? "Log In" : "Create Account")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.init(white: 0, alpha: 0.15))
                            .ignoresSafeArea())
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
            ImagePicker(image: $image)
                .ignoresSafeArea()
        }
    }
    
    private func handleAction() {
        if isLoginMode {
            //print("Should login into Firebase with existing credentials.")
            loginUser()
        } else {
            createNewAccount()
//            print("Register a new account inside of Firebase Auth and then store image in storage...")
        }
    }
    
    //create new Firebase account
    @State private var loginStatusMessage = ""
    
    private func createNewAccount() {
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) {
            result, err in
            if let err = err {
                print("Failed to create user: ", err)
                self.loginStatusMessage = "Failed to create user: \(err)"
                return
            }
            print("Successfully created user: \(result?.user.uid ?? "")")
            self.loginStatusMessage = "Successfully created user: \(result?.user.uid ?? "")"
            
            self.persistImageToStorage()
        }
    }
    
    //login user functionality
    private func loginUser() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) {
            result, err in
            if let err = err {
                print("Failed to log in user: ", err)
                self.loginStatusMessage = "Failed to log in user: \(err)"
                return
            }
            print("Successfully logged in as user: \(result?.user.uid ?? "")")
            self.loginStatusMessage = "Successfully logged in as user: \(result?.user.uid ?? "")"
        }
    }
    
    //save image to Firebase Storage
    private func persistImageToStorage() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else {
            return
        }
        ref.putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
                self.loginStatusMessage = "Failed to push image to Storage: \(err)"
                return
            }
            ref.downloadURL { url, err in
                if let err = err {
                    self.loginStatusMessage = "Failed to retrieve downloadURL: \(err)"
                    return
                }
                
                self.loginStatusMessage = "Successfully stored image with URL: \(url?.absoluteString ?? "")"
                //print(url?.absoluteString as Any)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
