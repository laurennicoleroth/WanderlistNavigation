//
//  Wanderlist.swift
//  Wanderlist
//
//  Created by Lauren Nicole Roth on 3/11/19.
//  Copyright © 2019 Lauren Nicole Roth. All rights reserved.
//

import Foundation
import CoreLocation
import InstantSearch
import InstantSearchCore

struct Wanderlist {
  var objectID : String = ""
  var title : String = ""
  var about : String = ""
  var creatorID : String = ""
  var city : String = ""
  var zipcode : String = ""
  var latitude : Double = 0.0
  var longitude : Double = 0.0
  var categories : String = ""
  var spotsCount : Int = 1
  var wanderspots : [Wanderspot] = []
  
  init(json: [String: Any]) {
    self.title = json["title"] as? String ?? ""
    self.about = json["about"] as? String ?? ""
    self.objectID = json["objectID"] as? String ?? ""
    self.creatorID = json["creatorID"] as? String ?? ""
    self.city = json["city"] as? String ?? ""
    self.spotsCount = json["spots_count"] as? Int ?? 1
    self.zipcode = json["zipcode"] as? String ?? ""
    self.latitude = json["latitude"] as? Double ?? 0.0
    self.longitude = json["longitude"] as? Double ?? 0.0
    self.categories = json["categories"] as? String ?? ""
  }
  
  func distanceFromCurrentLocation(origin: CLLocation) -> CLLocationDistance {
    let destination = CLLocation(latitude: latitude, longitude: longitude)
    return destination.distance(from: origin) / 1609.344
  }
  
  func addWanderlistToAlgolia() {
    let client = Client(appID: ALGOLIA_APPLICATION_ID, apiKey: ALGOLIA_API_KEY)
    let index = client.index(withName: "wanderlist_search")
    
    let wanderlist : [String: Any] = [
      "objectID" : self.objectID,
      "title": self.title,
      "about": self.about,
      "zipcode": self.zipcode,
      "latitude": self.latitude,
      "longitude": self.longitude,
      "categories": "Film & TV, Arts & Culture, Date Night",
      "city": self.city,
      "_geoloc": ["lat": self.latitude, "lng": self.longitude],
      "spots_count": self.wanderspots.count
    ]
    index.addObject(wanderlist, completionHandler: { (content, error) -> Void in
      if error == nil {
        
      } else {
        print("Error indexing")
      }
    })
  }

}
