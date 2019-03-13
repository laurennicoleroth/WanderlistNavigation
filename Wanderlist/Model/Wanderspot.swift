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

struct PlaceWithDistance {
  var place: GMSPlace
  var milesDistance: CLLocationDistance
}

class Wanderspot: NSObject {
   var wanderlistOwnerIDs: [String] = []
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
