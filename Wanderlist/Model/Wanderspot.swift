//
//  Wanderspot.swift
//  Wanderlist
//
//  Created by Lauren Nicole Roth on 3/5/19.
//  Copyright © 2019 Lauren Nicole Roth. All rights reserved.
//

import Foundation
import InstantSearchCore
import UIKit

class Wanderspot: NSObject {
  var name: String = ""
  var about: String = ""
  var address: String = ""
  var neighborhood: String = ""
  var latitude: Double = 0.0
  var longitude: Double = 0.0

  
  func toJSON() -> [String: Any] {
    var json = [String: Any]()
    json = [
      "name": self.name,
      "about": self.about,
      "address": self.address,
      "latitude": self.latitude,
      "longitude": self.longitude,
    ]
    return json
  }
  
  init(result: Result) {
    self.name = result.name as! String
    self.address = result.address as! String
    self.latitude = result.coordinate?.latitude as! Double
    self.longitude = result.coordinate?.longitude as! Double
  }
  
  class func saveToAlgolia(wanderlistID: String, wanderspot: Wanderspot) {
    let client = Client(appID: ALGOLIA_APPLICATION_ID, apiKey: ALGOLIA_API_KEY)
    let index = client.index(withName: "wanderspot_search")
    print("Saving spot to algolia: ", wanderspot)
    let wanderspotJSON: [String: Any] = [
      "name": wanderspot.name as! String,
      "address": wanderspot.address as! String,
      "latitude": wanderspot.latitude as! Double,
      "longitude": wanderspot.longitude as! Double
    ]
 
    index.addObject(wanderspotJSON, completionHandler: { (content, error) -> Void in
      if error == nil {
        
      } else {
        print("Error indexing")
      }
    })
  }
}
