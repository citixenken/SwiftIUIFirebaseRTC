//
//  ChatLogView.swift
//  SwiftUIFirebaseRTC
//
//  Created by Ken Muyesu on 11/04/2022.
//

import SwiftUI
import Firebase

class ChatLogViewModel: ObservableObject {
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
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
        
        let messageData = ["fromID" : fromID, "toID" : toID, "text" : self.chatText, "timestamp" : Timestamp()] as [String : Any]
        
        
        document.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Failed to save the text into Firestore: \(error)"
                return
            }
//            print("Successfully saved message sent")
            //clear chat field after saving
            self.chatText = ""
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
    
    private var messagesView: some View {
        ScrollView {
            ForEach(0..<16) { num in
                HStack {
                    Spacer()
                    HStack {
                        Text("Placeholder message")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding([.horizontal, .top])
            }
            HStack {
                Spacer()
            }
        }
        .padding(.bottom, 80)
        .padding(.top, 5)
        .background(Color(.init(white: 0.85, alpha: 1)))
        .navigationTitle(chatUser?.email ?? "")
        .navigationBarTitleDisplayMode(.inline)
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

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatLogView(chatUser: .init(data: ["uid" : "3xhCxPVQEYMXjrd4Zf8uABnvs4f2", "email" : "avon@barksdale.com"]))
        }
    }
}
