//
//  Wanderlist.swift
//  Wanderlist
//
//  Created by Lauren Nicole Roth on 3/5/19.
//  Copyright © 2019 Lauren Nicole Roth. All rights reserved.
//

import Foundation
import Firebase
import GooglePlaces
import Pring
import InstantSearch

@objcMembers
class Wanderlist: Object {
  dynamic var objectID: String?
  dynamic var title: String?
  dynamic var about: String?
  dynamic var creatorID: String?
  dynamic var city: String?
  dynamic var zipcode: String?
  dynamic var latitude : Double = 0.0
  dynamic var longitude : Double = 0.0
  dynamic var categories : [String]?
  dynamic var spotsCount : Int = 0
  dynamic var wanderspots: List<Wanderspot> = []
  
  func distanceFromUserAt(origin: CLLocation) -> String {
    let destination = CLLocation(latitude: latitude, longitude: longitude)
    let distance = destination.distance(from: origin) / 1609.344
    
    return String(format: "%.2f", distance)
  }
  
  required init() {
    super.init()
  }
  
  init(json: [String: Any]) {
    self.title = json["title"] as? String
    self.about = json["about"] as? String
    self.objectID = json["objectID"] as? String
    self.creatorID = json["creatorID"] as? String
    self.city = json["city"] as? String
    self.zipcode = json["zipcode"] as? String
    self.latitude = json["latitude"] as? Double ?? 0.0
    self.longitude = json["longitude"] as? Double ?? 0.0
    self.categories = json["categories"] as? [String]
  }
  
  func initializeWithData(title: String, about: String, wanderspots: [Wanderspot]) -> Wanderlist {
    let newWanderlist = Wanderlist()
    newWanderlist.title = title
    newWanderlist.about = about
    newWanderlist.creatorID = AuthService.instance.currentUid
    if let firstSpot = wanderspots.first {
      newWanderlist.city = firstSpot.city
      newWanderlist.zipcode = firstSpot.zipcode
      newWanderlist.latitude = firstSpot.latitude
      newWanderlist.longitude = firstSpot.longitude
    }
    
    for wanderspot in wanderspots {
      newWanderlist.wanderspots.append(wanderspot)
      if wanderspot.categories != nil {
        for category in wanderspot.categories {
          newWanderlist.categories?.append(category)
          newWanderlist.categories?.unique
        }
      }
    }
    return newWanderlist
  }
  
  
  
  class func addWanderlistToAlgolia(wanderlist: Wanderlist) {
    let client = Client(appID: ALGOLIA_APPLICATION_ID, apiKey: ALGOLIA_API_KEY)
    let index = client.index(withName: "wanderlist_search")
    
    let wanderlist : [String: Any] = [
      "objectID" : wanderlist.id,
      "title": wanderlist.title as! String,
      "about": wanderlist.about as! String,
      "zipcode": wanderlist.zipcode as! String,
      "latitude": wanderlist.latitude as Double,
      "longitude": wanderlist.longitude as Double,
      "categories": "Film & TV, Arts & Culture, Date Night",
      "city": wanderlist.city,
      "_geoloc": ["lat": wanderlist.latitude, "lng": wanderlist.longitude],
      "spots_count": wanderlist.wanderspots.count as Int
    ]
    index.addObject(wanderlist, completionHandler: { (content, error) -> Void in
      if error == nil {
        
      } else {
        print("Error indexing")
      }
    })
  }
  
  func getOrderedByTitle() {
    Wanderlist.order(by: \Wanderlist.title).get { (snapshot, error) in
      guard let snapshotDocuments = snapshot?.documents else {
        print("Error fetching documents: \(error!)")
        
        return
      }
      
      var wanderlists = [Wanderlist]()
      
      for snap in snapshotDocuments {
        wanderlists.append(Wanderlist(snapshot: snap)!)
      }
    }
  }
  
  func getPhotoFor(_ wanderlist: Wanderlist, completion: @escaping (UIImage?) -> Void ) {
    // Specify the place data types to return (just photos).
    let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.photos.rawValue))!
    let placesClient = GMSPlacesClient()
    if let placeID = wanderlist.wanderspots.first?.placeID {
      placesClient.fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: nil, callback:
        { (place: GMSPlace?, error: Error?) in
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
  }
  
}



