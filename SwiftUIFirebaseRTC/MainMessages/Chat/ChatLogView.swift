//
//  ChatLogView.swift
//  SwiftUIFirebaseRTC
//
//  Created by Ken Muyesu on 11/04/2022.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

class ChatLogViewModel: ObservableObject {
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    
    @Published var chatMessages = [ChatMessage]()
    
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        
        fetchMessages()
    }
    
    //fetch messages from Firestore
    private func fetchMessages() {
        guard let fromID = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        guard let toID = chatUser?.uid else {
            return
        }
        FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromID)
            .collection(toID)
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for messages: \(error)"
                    print(error)
                    return
                }
                
                //avoids message duplication
                querySnapshot?.documentChanges.forEach( { change in
                    if change.type == .added {
                        let data = change.document.data()
                        self.chatMessages.append(.init(documentID: change.document.documentID, data: data))
                    }
                })
                
                DispatchQueue.main.async {
                    self.count += 1
                }
                //                querySnapshot?.documents.forEach({ queryDocumentSnapshot in
                //                    let data = queryDocumentSnapshot.data()
                //                    let docID = queryDocumentSnapshot.documentID
                //                    self.chatMessages.append(.init(documentID: docID, data: data))
                //                })
            }
    }
    
    func handleSend() {
        //print(chatText)
        guard let fromID = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        
        guard let toID = chatUser?.uid else {
            return
        }
        
        let document = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromID)
            .collection(toID)
            .document()
        
        let messageData = [FirebaseConstants.fromID : fromID, FirebaseConstants.toID : toID, FirebaseConstants.text : self.chatText, "timestamp" : Timestamp()] as [String : Any]


        document.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Failed to save the text into Firestore: \(error)"
                return
            }
        
//        let msg = ChatMessage(id: nil, fromID: fromID, toID: toID, text: chatText, timestamp: Date())
//
//        try? document.setData(from: msg) { error in
//            if let error = error {
//                print(error)
//                self.errorMessage = "Failed to save message into Firestore: \(error)"
//                return
//            }
//            print("Successfully saved current user sending message")
//        }
            //            print("Successfully saved message sent")
            //clear chat field after saving
            
            self.persistRecentMessage()
            
            self.chatText = ""
            self.count += 1
        }
        
        //for the recepient
        let recipientMessageDocument = FirebaseManager.shared.firestore
            .collection("messages")
            .document(toID)
            .collection(fromID)
            .document()
        
        recipientMessageDocument.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Failed to save the text into Firestore: \(error)"
                return
            }
            
            //print("Successfully saved message received")
        }
    }
    
    private func persistRecentMessage() {
        guard let chatUser = chatUser else {
            return
        }
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        guard let toID = self.chatUser?.uid else { return }
        
        let document = FirebaseManager.shared.firestore
            .collection("recent_messages")
            .document(uid)
            .collection("messages")
            .document(toID)
        
        let data = [
            FirebaseConstants.timestamp : Timestamp(),
            FirebaseConstants.text : self.chatText,
            FirebaseConstants.fromID : uid,
            FirebaseConstants.toID : toID,
            FirebaseConstants.profileImageURL : chatUser.profileImageURL,
            FirebaseConstants.email : chatUser.email
        ] as [String: Any]
        
        document.setData(data) { error in
            if let error = error {
                self.errorMessage = "Failed to save recent message: \(error)"
                print("Failed to save recent message: \(error)")
                return
            }
        }
    }
    @Published var count = 0
}

//constants struct
struct FirebaseConstants {
    static let fromID = "fromID"
    static let toID = "toID"
    static let text = "text"
    static let timestamp = "timestamp"
    static let profileImageURL = "profileImageURL"
    static let email = "email"
}

struct ChatMessage: Identifiable {
    var id: String { documentID }

    let documentID: String
    //@DocumentID var id: String?
    
    let fromID, toID, text: String
//    let timestamp: Date
    init(documentID: String, data: [String: Any]) {
        self.documentID = documentID
        self.fromID = data[FirebaseConstants.fromID] as? String ?? ""
        self.toID = data[FirebaseConstants.toID] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""

    }
}

struct ChatLogView: View {
    @ObservedObject var vm: ChatLogViewModel
    
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        self.vm = .init(chatUser: chatUser)
    }
    
    var body: some View {
        ZStack {
            messagesView
            Text(vm.errorMessage)
            
            VStack {
                Spacer()
                bottomChatView
                    .background(Color.white)
            }
        }
    }
    
    static let emptyScrollToString = "Empty"
    
    private var messagesView: some View {
        ScrollView {
            ScrollViewReader { scrollViewProxy in
                VStack {
                    ForEach(vm.chatMessages) { message in
                        MessageView(message: message)
                    }
                }
                .onReceive(vm.$count) { _ in
                    withAnimation(.easeOut(duration: 0.5)) {
                        scrollViewProxy.scrollTo(Self.emptyScrollToString, anchor: .bottom )
                    }
                }
                HStack {
                    Spacer()
                }
                .id(Self.emptyScrollToString)
                
            }
        }
        .padding(.bottom, 80)
        .padding(.top, 5)
        .background(Color(.init(white: 0.85, alpha: 1)))
        .navigationTitle(chatUser?.email ?? "")
        .navigationBarTitleDisplayMode(.inline)
//        .navigationBarItems(trailing: Button(action: {
//            vm.count += 1
//        }, label: {
//            Text("Count: \(vm.count)")
//        }) )
    }
    
    private var bottomChatView: some View {
        HStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.title)
                .foregroundColor(Color(.darkGray))
            //            TextField("Message description", text: $chatText)
            
            //unfinished solution?
            //DescriptionPlaceholder()
            
            ZStack {
                //                DescriptionPlaceholder()
                TextEditor(text: $vm.chatText)
                    .opacity(vm.chatText.isEmpty ? 0.5 : 1)
            }
            .frame(maxWidth: .infinity, maxHeight: 50)
            
            Button {
                vm.handleSend()
            } label: {
                Text("Send")
            }
            .padding()
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding()
    }
    
}

struct MessageView: View {
    
    let message: ChatMessage
    
    var body: some View {
        VStack {
            if message.fromID == FirebaseManager.shared.auth.currentUser?.uid {
                HStack {
                    Spacer()
                    HStack {
                        Text(message.text)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
            } else {
                HStack {
                    HStack {
                        Text(message.text)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.mint)
                    .cornerRadius(12)
                    
                    Spacer()
                }
            }
        }
        .padding([.horizontal, .top])
    }
    
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatLogView(chatUser: .init(data: ["uid" : "3xhCxPVQEYMXjrd4Zf8uABnvs4f2", "email" : "avon@barksdale.com"]))
        }
    }
}
