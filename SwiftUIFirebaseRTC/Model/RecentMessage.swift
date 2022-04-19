//
//  RecentMessage.swift
//  SwiftUIFirebaseRTC
//
//  Created by Ken Muyesu on 19/04/2022.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct RecentMessage: Identifiable, Codable {
//    var id: String { documentID }
//
//    let documentID: String
    @DocumentID var id: String?
    
    let text, email: String
    let fromID, toID: String
    let profileImageURL: String
//    let timestamp: Timestamp
    let timestamp: Date
    
//    init(documentID: String, data: [String : Any]) {
//        self.documentID = documentID
//        self.text = data["text"] as? String ?? ""
//        self.fromID = data["fromID"] as? String ?? ""
//        self.toID = data["toID"] as? String ?? ""
//        self.profileImageURL = data["profileImageURL"] as? String ?? ""
//        self.email = data["email"] as? String ?? ""
//        //self.timestamp = data["timestamp"] as? Timestamp ?? Timestamp(date: Date())
//    }
}
