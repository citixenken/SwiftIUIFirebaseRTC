//
//  MainMessagesView.swift
//  SwiftUIFirebaseRTC
//
//  Created by Ken Muyesu on 04/04/2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct ChatUser {
    let uid, email, profileImageURL: String
}

class MainMessagesViewModel: ObservableObject {
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    
    init() {
        fetchCurrentUser()
    }
    
    private func fetchCurrentUser() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find Firebase UID"
            return
        }
//        self.errorMessage = "\(uid)"
        
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Failed to fetch current user: ", error)
                return
            }
            
            guard let data = snapshot?.data() else { return }
//            print(data)
            
//            self.errorMessage = "\(data.description)"
            let uid = data["uid"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            let profileImageURL = data["profileImageURL"] as? String ?? ""

            //#"([^@]+)"#
            self.chatUser = ChatUser(uid: uid, email: email, profileImageURL: profileImageURL)
            
//            self.errorMessage = chatUser.uid
        }
    }
}

struct MainMessagesView: View {
    @State private var logOutOptions = false
    
    @ObservedObject private var viewModel = MainMessagesViewModel()
    
    private var customNavBar: some View {
        HStack(spacing: 14) {
            
            WebImage(url: URL(string: viewModel.chatUser?.profileImageURL ?? ""))
                .resizable()
                .frame(width: 64, height: 64)
                .cornerRadius(32)
                .overlay(RoundedRectangle(cornerRadius: 32)
                            .stroke(Color(.label), lineWidth: 1))
                .shadow(radius: 10)
//            Image(systemName: "person.fill")
//                .font(.system(size: 16, weight: .heavy))
            
            VStack(alignment: .leading, spacing: 4) {
                //find better way of handling this???? -> Found it...Line 74
                
//                Text("\(viewModel.chatUser?.email.replacingOccurrences(of: "@jordan.com", with: "") ?? "")")
                Text("\(viewModel.chatUser?.email.split(separator: "@").dropLast().joined() ?? "")")
                    .font(.system(size: 24, weight: .bold))
                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("Online")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            
            Button {
                logOutOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
            }
        }
        .padding()
        .actionSheet(isPresented: $logOutOptions) {
            .init(title: Text("What do you want to do?"), buttons: [.destructive(Text("Sign Out")),
                                                                    .cancel()])
        }
    }
    
    private var messagesView: some View {
        ScrollView {
            ForEach(0..<10, id: \.self) { row in
                VStack {
                    HStack(spacing: 16) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 32))
                            .padding(8
                            )
                            .overlay(RoundedRectangle(cornerRadius: 32)
                                        .stroke(Color(.label), lineWidth: 1))
                        VStack(alignment: .leading) {
                            Text("Username \(row)")
                                .font(.system(size: 16, weight: .bold))
                            Text("Message sent to user")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        
                        Text("69d")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    Divider()
                        .padding(.vertical, 8)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 50)
        }
    }
    
    private var newMessageButton: some View {
        Button {
            
        } label: {
            HStack {
                Spacer()
                Text("+ New Message")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical)
            .background(.blue)
            .cornerRadius(24)
            .padding(.horizontal)
            .shadow(radius: 20)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
//                Text("Current User ID: \(viewModel.chatUser?.uid ?? "")")
                
                //custom nav bar
                customNavBar
                
                //messages view
                messagesView
                    
                //                .navigationTitle("Main Message View")
                //                .navigationBarTitleDisplayMode(.inline)
            }
            .navigationBarHidden(true)
            
            //new message button
            .overlay(newMessageButton, alignment: .bottom)
        }
    }
}

struct MainMessages_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()
            .preferredColorScheme(.dark)
        
        MainMessagesView()
    }
}
