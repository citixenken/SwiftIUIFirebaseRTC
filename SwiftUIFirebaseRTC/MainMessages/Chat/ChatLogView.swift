//
//  ChatLogView.swift
//  SwiftUIFirebaseRTC
//
//  Created by Ken Muyesu on 11/04/2022.
//

import SwiftUI

struct ChatLogView: View {
     
    let chatUser: ChatUser?
    
    @State var chatText = ""
    
    var body: some View {
        ZStack {
            messagesView
            
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
            //TextField("Message description", text: $chatText)
            TextEditor(text: $chatText)
                .frame(maxWidth: .infinity, maxHeight: 50)
            Button {} label: {
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
