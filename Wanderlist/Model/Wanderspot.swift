//
//  Wanderspot.swift
//  Wanderlist
//
//  Created by Lauren Nicole Roth on 3/5/19.
//  Copyright © 2019 Lauren Nicole Roth. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation
import InstantSearch
import InstantSearchCore
import UIKit
import GEOSwift
import Mapbox

//struct PlaceWithDistance {
//  var place: GMSPlace
//  var milesDistance: CLLocationDistance
//}

class Wanderspot: NSObject {
  var  wanderlistOwnerIDs: [String] = []
  var  name: String = ""
  var  creatorID: String = ""
  var  address: String = ""
  var  latitude: Double = 0.0
  var  longitude: Double = 0.0
  var  placeID: String = ""
  var  distanceAway: Double = 0.0
  var  categories: [String] = []
  var  sundayHours: String = ""
  var  mondayHours: String = ""
  var  tuesdayHours: String = ""
  var  wednesdayHours: String = ""
  var  thursdayHours: String = ""
  var  fridayHours: String = ""
  var  saturdayHours: String = ""
  var  city: String = ""
  var  zipcode: String?
  var  image : UIImage?
  var  geoPoint : [String: Any] {
    let point : [String: Any] = [
      "type" : "Point",
      "coordinate": [self.latitude, self.longitude]
    ]
    return point
  }
  
  func toJSON() -> [String: Any] {
    var json = [String: Any]()
    json = [
      "name": self.name,
      "creatorID": self.creatorID,
      "address": self.address,
      "latitude": self.latitude,
      "longitude": self.longitude,
      "placeID": self.placeID,
      "distanceAway": self.distanceAway,
      "categories": self.categories,
      "sundayHours": self.sundayHours,
      "mondayHours": self.mondayHours,
      "tuesdayHours": self.tuesdayHours,
      "wednesdayHours": self.wednesdayHours,
      "thursdayHours": self.thursdayHours,
      "fridayHours": self.fridayHours,
      "saturdayHours": self.saturdayHours,
      "city": self.city,
      "zipcode": self.zipcode,
      "image": self.image as! UIImage,
      "geoPoint": self.geoPoint
    ]
    return json
  }
  
  class func saveToAlgolia(wanderlistID: String, wanderspot: Wanderspot) {
    let client = Client(appID: ALGOLIA_APPLICATION_ID, apiKey: ALGOLIA_API_KEY)
    let index = client.index(withName: "wanderspot_search")
    wanderspot.wanderlistOwnerIDs.append(wanderlistID)
    print("Saving spot to algolia: ", wanderspot)
    let wanderspotJSON: [String: Any] = [
      "wanderlistOwnerIDs": wanderspot.wanderlistOwnerIDs.joined(separator: ", "),
      "name": wanderspot.name as! String,
      "creatorID": wanderspot.creatorID as! String,
      "address": wanderspot.address as! String,
      "latitude": wanderspot.latitude as! Double,
      "longitude": wanderspot.longitude as! Double,
      "placeID": wanderspot.placeID as! String,
      "distanceAway": wanderspot.distanceAway as! Double,
      "categories": wanderspot.categories.joined(separator: ", ") as! String,
      "sundayHours": wanderspot.sundayHours as! String,
      "mondayHours": wanderspot.mondayHours as! String,
      "tuesdayHours": wanderspot.tuesdayHours as! String,
      "wednesdayHours": wanderspot.wednesdayHours as! String,
      "thursdayHours": wanderspot.thursdayHours as! String,
      "fridayHours": wanderspot.fridayHours as! String,
      "saturdayHours": wanderspot.saturdayHours as! String,
      "city": wanderspot.city as! String,
      "zipcode": wanderspot.zipcode as! String
    ]
    
    print("Spot json: ", wanderspotJSON)
    
    index.addObject(wanderspotJSON, completionHandler: { (content, error) -> Void in
      if error == nil {
        
      } else {
        print("Error indexing")
      }
    })
  }
  

  
  func getHoursForTodayFor(_ wanderspot: Wanderspot) -> String? {
    
    let date = Date()
    let calendar = Calendar.current
    let dayOfWeek = calendar.component(.weekday, from: date)
    
    switch dayOfWeek {
    case 0:
      return wanderspot.saturdayHours
    case 1:
      return wanderspot.sundayHours
    case 2:
      return wanderspot.mondayHours
    case 3:
      return wanderspot.tuesdayHours
    case 4:
      return wanderspot.wednesdayHours
    case 5:
      return wanderspot.thursdayHours
    case 6:
      return wanderspot.fridayHours
    default:
      return "No hours"
    }
  }
  
  func testAddresses() {
    for address in getAddresses() {
      
      var geocodingResult = GeocodingResult(address)
      print("Geocoding result: ", geocodingResult)
      
      //initialize a NativeGeocoding Obj
      let nativeGeocoding = NativeGeocoding(address)
      
      //configure Geocoding
      let geocodingRequest = GeocodingRequest(address: address)
      let geocodingService = GeocodingService(geocodingRequest)
      
      firstly {
        //use native geocoding
        nativeGeocoding.geocode()
        }.then { (geocoding) -> Void in
          geocodingResult.native = geocoding
        }.then {() -> Promise<Geocoding> in
          //use google maps geocoding
          geocodingService.getGeoCoding()
        }.then {(geocoding) -> Void in
          geocodingResult.googleMaps = geocoding
        }.always {() -> Void in
          self.addGeocodingResult(geocodingResult)
        }.catch { (error) in
          //manage error here!
      }
    }
  }
  
  private func addGeocodingResult(_ geocodingResult: GeocodingResult) {
    let geocodingResults : [GeocodingResult] = []
    geocodingResults.append(geocodingResult)
    
    if geocodingResults.count == getAddresses().count {
      //      tableView.reloadData()
      //      tableView.tableHeaderView = UIView()
    }
  }
  
  private func getAddresses() -> [String] {
    return [
      "700 West End Ave, New York, NY",
      "18 w 18th St., New York, NY",
      "New York, NY",
      "Empire State Building, New York, NY",
      "Guggenheim, New York",
      "Central Park Tennis Center, NY",
      "Flatiron Building, NY"
    ]
  }
}
