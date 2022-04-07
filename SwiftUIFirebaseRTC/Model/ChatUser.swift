//
//  ChatUser.swift
//  SwiftUIFirebaseRTC
//
//  Created by Ken Muyesu on 07/04/2022.
//

import Foundation

struct ChatUser {
    let uid, email, profileImageURL: String
    
    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageURL = data["profileImageURL"] as? String ?? ""
    }
}
