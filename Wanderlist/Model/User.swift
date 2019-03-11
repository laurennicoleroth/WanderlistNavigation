//
//  User.swift
//  Wanderlist
//
//  Created by Lauren Nicole Roth on 3/8/19.
//  Copyright © 2019 Lauren Nicole Roth. All rights reserved.
//

import Foundation
import Pring

@objcMembers
class User: Object {

  dynamic var userID: String?
  dynamic var fullName: String?
  dynamic var email: String?
  dynamic var followers: ReferenceCollection<User> = []
  dynamic var favoriteWanderlists: ReferenceCollection<Wanderlist> = []
  
  func addUserToFirestore(userID: String, fullName: String, email: String) {
    let user = User()
    user.userID = userID
    user.fullName = fullName
    user.email = email
    user.save() { (ref, error) in
      print("User saved to firestore: ", ref?.documentID)
    }
  }
  
  
}
