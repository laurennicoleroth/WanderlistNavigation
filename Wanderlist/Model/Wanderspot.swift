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
import GooglePlaces
import InstantSearch
import InstantSearchCore
import UIKit

struct PlaceWithDistance {
  var place: GMSPlace
  var milesDistance: CLLocationDistance
}

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
  
  init(place: GMSPlace?) {
    if let place = place {
      self.name = place.name ?? ""
      self.address = place.formattedAddress ?? ""
      self.latitude = place.coordinate.latitude
      self.longitude = place.coordinate.longitude
      self.placeID = place.placeID ?? ""
      if let categories = place.types {
        self.categories = categories
      }
      
      if let week = place.openingHours?.weekdayText {
        self.mondayHours = week[0]
        self.tuesdayHours = week[1]
        self.wednesdayHours = week[2]
        self.thursdayHours = week[3]
        self.fridayHours = week[4]
        self.saturdayHours = week[5]
        self.sundayHours = week[6]
      }
      
      if let components = place.addressComponents {
        for component in components {
          if component.type == "locality" {
            self.city = component.name
          } else if component.type == "postal_code" {
            self.zipcode = component.name
          }
        }
      }
    }
  }
  
  func addPhotoToWanderspot() {
    if self.placeID != "" {
      let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.photos.rawValue))!
      let placesClient = GMSPlacesClient()
      placesClient.fetchPlace(fromPlaceID: self.placeID, placeFields: fields, sessionToken: nil, callback: { (place: GMSPlace?, error: Error?) in
        if let error = error {
          print("An error occurred: \(error.localizedDescription)")
          return
        }
        if let place = place {
          let photoMetadata: GMSPlacePhotoMetadata = place.photos![0]
          placesClient.loadPlacePhoto(photoMetadata, callback: { (photo, error) -> Void in
            if let error = error {
              print("Error loading photo metadata: \(error.localizedDescription)")
              return
            } else {
              print("Got a photo: " , photo)
              self.image = photo
            }
          })
        }
      })
    } else {
      print("Can't get photo because the placeID is nil")
    }
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
      "image": self.image as! UIImage
    ]
    return json
  }
  
  func saveToFirestore() {
    
  }
  
  func toGeoJSON() {
    
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
  
  class func getPhotoFor(_ placeID: String, completion: @escaping (UIImage?) -> Void ) {
    // Specify the place data types to return (just photos).
    let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.photos.rawValue))!
    let placesClient = GMSPlacesClient()
    placesClient.fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: nil, callback: { (place: GMSPlace?, error: Error?) in
      if let error = error {
        // TODO: Handle the error.
        print("An error occurred: \(error.localizedDescription)")
        return
      }
      if let place = place {
        if place.photos?[0] != nil {
          let photoMetadata: GMSPlacePhotoMetadata = place.photos![0]
          
          placesClient.loadPlacePhoto(photoMetadata, callback: { (photo, error) -> Void in
            if let error = error {
              print("Error loading photo metadata: \(error.localizedDescription)")
              return
            } else {
              completion(photo)
            }
          })
        } else {
          completion(UIImage(named: "wanderlist-8"))
        }
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
}
