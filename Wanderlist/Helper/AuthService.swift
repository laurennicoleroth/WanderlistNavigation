//
//  AuthService.swift
//  Wanderlist
//
//  Created by Lauren Nicole Roth on 3/5/19.
//  Copyright © 2019 Lauren Nicole Roth. All rights reserved.
//

import FirebaseAuth

class AuthService {
  static let instance = AuthService()
  var currentUid: String?
  var userDisplayName: String?
  var loggedIn: Bool
  var email: String?

  init() {

    self.currentUid = Auth.auth().currentUser?.uid
    self.userDisplayName = Auth.auth().currentUser?.displayName
    if currentUid != nil {
      self.loggedIn = true
    } else {
      self.loggedIn = false
    }
  }

  func logout() {
    do {
      try Auth.auth().signOut()
      print("User logged out")
    } catch let signOutError as NSError {
      print ("Error signing out: %@", signOutError)
    }
  }
}
