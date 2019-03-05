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
import Pring
import InstantSearch
import InstantSearchCore

struct PlaceWithDistance {
  var place : GMSPlace
  var milesDistance : CLLocationDistance
}

@objcMembers
class Wanderspot: Object {
  dynamic var wanderlistOwnerIDs: [String] = []
  dynamic var name: String = ""
  dynamic var imageFile: File?
  dynamic var creatorID: String = ""
  dynamic var address: String = ""
  dynamic var latitude : Double = 0.0
  dynamic var longitude: Double = 0.0
  dynamic var placeID: String = ""
  dynamic var distanceAway: Double = 0.0
  dynamic var categories: [String] = []
  dynamic var sundayHours : String = ""
  dynamic var mondayHours : String = ""
  dynamic var tuesdayHours : String = ""
  dynamic var wednesdayHours : String = ""
  dynamic var thursdayHours : String = ""
  dynamic var fridayHours : String = ""
  dynamic var saturdayHours : String = ""
  dynamic var city: String = ""
  dynamic var zipcode: String?
  
  class func createNewWanderspot(_ place: GMSPlace, distanceAway: Double?, completion: @escaping (Wanderspot) -> Void) {
    let newWanderspot = Wanderspot()
    if let name = place.name,
      let creatorID = AuthService.instance.currentUid,
      let address = place.formattedAddress,
      let placeID = place.placeID,
      let distanceAway = distanceAway,
      let components = place.addressComponents {
      
      newWanderspot.name = name
      newWanderspot.creatorID = creatorID
      newWanderspot.address = address
      newWanderspot.latitude = place.coordinate.latitude
      newWanderspot.longitude = place.coordinate.longitude
      newWanderspot.placeID = placeID
      newWanderspot.distanceAway = distanceAway
      
      if let categories = place.types {
        newWanderspot.categories = categories
      }
      
      if let week = place.openingHours?.weekdayText {
        newWanderspot.mondayHours = week[0]
        newWanderspot.tuesdayHours = week[1]
        newWanderspot.wednesdayHours = week[2]
        newWanderspot.thursdayHours = week[3]
        newWanderspot.fridayHours = week[4]
        newWanderspot.saturdayHours = week[5]
        newWanderspot.sundayHours = week[6]
      }
      
      getPhotoFor(placeID, completion: { (image) in
        if image != nil {
          if let data = image!.jpegData(compressionQuality: 0.8) {
            newWanderspot.imageFile = File(data: data, mimeType: .jpeg)
          }
        }
      })
      
      for component in components {
        if component.type == "locality" {
          newWanderspot.city = component.name
        } else if component.type == "postal_code" {
          newWanderspot.zipcode = component.name
        }
      }
      completion(newWanderspot)
    }
}
