//
//  Wanderlist.swift
//  Wanderlist
//
//  Created by Lauren Nicole Roth on 3/11/19.
//  Copyright © 2019 Lauren Nicole Roth. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation
import InstantSearchCore

class Wanderlist {
  var  objectID: String = ""
  var  title: String = ""
  var  about: String = ""
  var  city: String = ""
  var  zipcode: String = ""
  var  latitude: Double = 0.0
  var  longitude: Double = 0.0
  var  imageURL: String = ""
  var  categories: String = ""
  var  spotsCount: Int = 0
  var  geoloc : [String: Double] = ["latitude": 0.0, "longitude": 0.0]
  var wanderspots : [[String: Any]] = [[:]]
  
  init(json: [String: Any]) {
    self.title = json["title"] as? String ?? ""
    self.about = json["about"] as? String ?? ""
    self.objectID = json["objectID"] as? String ?? ""
    self.city = json["city"] as? String ?? ""
    self.spotsCount = json["spots_count"] as? Int ?? 1
    self.zipcode = json["zipcode"] as? String ?? ""
    self.latitude = json["latitude"] as? Double ?? 0.0
    self.longitude = json["longitude"] as? Double ?? 0.0
    self.imageURL = json["imageURL"] as? String ?? ""
    self.categories = json["categories"] as? String ?? ""
  }
  
  func toJSON() -> [String: Any] {
    var json = [String: Any]()
    json = [
      "objectID" : self.objectID,
      "title": self.title,
      "about": self.about,
      "city": self.city,
      "zipcode": self.zipcode,
      "latitude": self.latitude,
      "longitude": self.longitude,
      "imageURL": self.imageURL,
      "categories": self.categories,
      "_geoloc" : self.geoloc
    ]
    return json
  }
  
  func distanceFromCurrentLocation(origin: CLLocation) -> CLLocationDistance {
    let destination = CLLocation(latitude: latitude, longitude: longitude)
    return destination.distance(from: origin) / 1609.344
  }
  
  func addWanderlistToFirestore() {
    let db = Firestore.firestore()
    var wanderlistsRef : DocumentReference? = nil
    wanderlistsRef = db.collection("wanderlists").addDocument(data: self.toJSON()) {
      err in
      if let err = err {
        print("Error adding wanderlist to Firestore: \(err)")
      } else {
        print("Wanderlist added with id: \(wanderlistsRef!.documentID)")
      }
    }
  }
  
  func addWanderlistToAlgolia() {
    let client = Client(appID: ALGOLIA_APPLICATION_ID, apiKey: ALGOLIA_API_KEY)
    let index = client.index(withName: "wanderlist_search")
    
    let wanderlist: [String: Any] = self.toJSON()
    index.addObject(wanderlist, completionHandler: { (content, error) -> Void in
      if error == nil {
        
      } else {
        print("Error indexing")
      }
    })
  }
  
}
