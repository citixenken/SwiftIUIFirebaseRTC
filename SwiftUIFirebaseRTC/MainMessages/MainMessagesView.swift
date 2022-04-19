//
//  MainMessagesView.swift
//  SwiftUIFirebaseRTC
//
//  Created by Ken Muyesu on 04/04/2022.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

class MainMessagesViewModel: ObservableObject {
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    
    init() {
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        fetchCurrentUser()
        fetchRecentMessages()
    }
    
    func fetchCurrentUser() {
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
            
            self.chatUser = .init(data: data)

//            print(data)
            
//            self.errorMessage = "\(data.description)"
//            let uid = data["uid"] as? String ?? ""
//            let email = data["email"] as? String ?? ""
//            let profileImageURL = data["profileImageURL"] as? String ?? ""
            
            //#"([^@]+)"#
//            self.chatUser = ChatUser(uid: uid, email: email, profileImageURL: profileImageURL)
            
//            self.errorMessage = chatUser.uid
        }
    }
    
    @Published var recentMessages = [RecentMessage]()
    
    private func fetchRecentMessages() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        FirebaseManager.shared.firestore
            .collection("recent_messages")
            .document(uid)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen to recent messages: \(error)"
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    let docID = change.document.documentID
                    
                    if let index = self.recentMessages.firstIndex(where: { rm in
                        return rm.documentID == docID
                    }) {
                        self.recentMessages.remove(at: index)
                    }
                    self.recentMessages.insert(.init(documentID: docID, data: change.document.data()), at: 0)

                    //self.recentMessages.append(.init(documentID: docID, data: change.document.data()))
                })
            }
    }
    
    @Published var isUserCurrentlyLoggedOut = false
    
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
}

struct RecentMessage: Identifiable {
    var id: String { documentID }
    
    let documentID: String
    let text, email: String
    let fromID, toID: String
    let profileImageURL: String
    let timestamp: Timestamp
    
    init(documentID: String, data: [String : Any]) {
        self.documentID = documentID
        self.text = data["text"] as? String ?? ""
        self.fromID = data["fromID"] as? String ?? ""
        self.toID = data["toID"] as? String ?? ""
        self.profileImageURL = data["profileImageURL"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.timestamp = data["timestamp"] as? Timestamp ?? Timestamp(date: Date())
    }
}

struct MainMessagesView: View {
    @State private var logOutOptions = false
    
    @State var shouldNavigateToChatLogView = false
    
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
            .init(title: Text("What do you want to do?"), buttons: [.destructive(Text("Sign Out"), action: {
                viewModel.handleSignOut()
            }),
            .cancel()])
        }
        .fullScreenCover(isPresented: $viewModel.isUserCurrentlyLoggedOut, onDismiss: nil) {
            LoginView(didCompleteLoginProcess: {
                self.viewModel.isUserCurrentlyLoggedOut = false
                self.viewModel.fetchCurrentUser()
            },
                      didCompleteAccountCreationProcess: {
                self.viewModel.isUserCurrentlyLoggedOut = false
                self.viewModel.fetchCurrentUser()
            })
        }
    }
    
    private var messagesView: some View {
        ScrollView {
            ForEach(viewModel.recentMessages) { recentMessage in
                VStack {
                    NavigationLink {
                        Text("Destination")
                        
                    } label: {
                        HStack(spacing: 16) {
                            WebImage(url: URL(string: recentMessage.profileImageURL))
                                .resizable()
                                .frame(width: 64, height: 64)
                                .cornerRadius(32)
                                .shadow(radius: 10)
                                .overlay(RoundedRectangle(cornerRadius: 32)
                                            .stroke(Color(.label), lineWidth: 1))
                            VStack(alignment: .leading, spacing: 8) {
                                Text(recentMessage.email)
                                    .font(.system(size: 16, weight: .bold))
                                Text(recentMessage.text)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            
                            Text("69d")
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                    Divider()
                        .padding(.vertical, 8)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 50)
        }
    }
    
    @State var showNewMessageScreen = false
    
    private var newMessageButton: some View {
        Button {
            showNewMessageScreen.toggle()
            
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
        .fullScreenCover(isPresented: $showNewMessageScreen) {
            NewMessageView(didSelectNewUser: { user in
                print(user.email)
                self.shouldNavigateToChatLogView.toggle()
                self.chatUser = user
            })
        }
    }
    
    @State var chatUser: ChatUser?
    
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
                
                NavigationLink("", isActive: $shouldNavigateToChatLogView) {
                    ChatLogView(chatUser: self.chatUser)
                }
            }
            .navigationBarHidden(true)
            
            //new message button
            .overlay(newMessageButton, alignment: .bottom)
        }
    }
}

struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()
            .preferredColorScheme(.dark)
        
       // MainMessagesView()
    }
}
