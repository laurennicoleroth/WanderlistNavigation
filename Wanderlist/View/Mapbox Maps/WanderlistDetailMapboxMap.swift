//
//  WanderlistDetailMapboxMap.swift
//  Wanderly
//
//  Created by Lauren Nicole Roth on 3/1/19.
//  Copyright © 2019 Lauren Nicole Roth. All rights reserved.
//

import Foundation
import CoreLocation
import InstantSearchCore
import Mapbox
import MapboxGeocoder
import SwiftLocation

class WanderlistDetailMapboxMap: MGLMapView {
  var wanderlist : Wanderlist?
  var currentLocation : CLLocationCoordinate2D?
  
  var wanderspots : [Wanderspot] = [] {
    didSet {
      if wanderspots.count == 1 {
        setCenter(CLLocationCoordinate2D(latitude: wanderspots.first?.latitude ?? 0.0, longitude: wanderspots.first?.longitude ?? 0.0), zoomLevel: 14, animated: true)
        addWanderspotToMap(wanderspot: wanderspots.first!)
      } else {
        fitMapToWanderspots()
      }
    }
  }
  
  func showCurrentLocation() {
    Locator.currentPosition(accuracy: .city, onSuccess: { (location) -> Void in
      self.setCenter(location.coordinate, zoomLevel: 12, animated: false)
    }) { (error, location) -> Void in
      debugPrint(error)
    }
  }
  
  
  func fitMapToWanderspots() {
    var coordinates = [CLLocationCoordinate2D]()
    for spot in self.wanderspots {
      let latitude = spot.latitude
      let longitude = spot.longitude
      coordinates.append(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
      addWanderspotAsAnnotation(wanderspot: spot)
      self.setVisibleCoordinates(
        coordinates,
        count: UInt(coordinates.count),
        edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40),
        animated: true
      )
    }
  }
  
  func addPlacemarkToMap(placemark: Placemark ) {
    let annotation = MGLPointAnnotation()
    let latitude = placemark.location?.coordinate.latitude as! Double
    let longitude = placemark.location?.coordinate.longitude as! Double
    
    annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    annotation.title = placemark.name
    self.addAnnotation(annotation)
  }
  
  func addWanderspotToMap(wanderspot: Wanderspot) {
    let annotation = MGLPointAnnotation()
    let latitude = wanderspot.latitude
    let longitude = wanderspot.longitude
    annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    annotation.title = wanderspot.name
    annotation.subtitle = "\(wanderspot.distanceAway) away"
    self.addAnnotation(annotation)
  }
  
  func zoomToWanderlistWithMapPreview(wanderlist: Wanderlist?) {
    if let latitude = wanderlist?.latitude, let longitude = wanderlist?.longitude {
      let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
      self.setCenter(coordinate, zoomLevel: 12, animated: true)
      let currentLocation = MGLPointAnnotation()
      currentLocation.coordinate = coordinate
      currentLocation.title = wanderlist?.title
      
      self.addAnnotation(currentLocation)
    }
  }
  
  func getWanderlistsNear(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
    let client = Client(appID: ALGOLIA_APPLICATION_ID, apiKey: ALGOLIA_API_KEY)
    let index = client.index(withName: "wanderlist_search")
    
    let query = Query(query: "")
    query.aroundLatLng = LatLng(lat: latitude, lng: longitude)
    query.attributesToRetrieve = ["title", "city", "latitude", "longitude", "about", "spots_count", "objectID", "zipcode", "_geoloc"]
    
    index.search(query, completionHandler: { (results, error) in
      guard let results = results else {
        return
      }
      
      guard let hits = results["hits"] as? [[String: AnyObject]] else { return }
      
      self.addHitsToMap(hits: hits)
    })
  }
  
  func drawWanderlistPathForWanderlist(wanderlist: Wanderlist) {
    //    if let id = wanderlist.objectID {
    //      Wanderlist.get(id) { [unowned self] (wanderlist, error) in
    //        var wanderspots = [Wanderspot]()
    //        if wanderlist != nil && wanderlist?.wanderspots != nil {
    //          for spot in (wanderlist?.wanderspots.makeIterator())! {
    //            wanderspots.append(spot)
    //          }
    //          wanderspots = wanderspots.sorted(by: { $0.distanceAway ?? 0.0 < $1.distanceAway ?? 0.0 })
    //          self.addWanderspotsToMap(wanderspots)
    //        }
    //      }
    //    }
  }
  
  func addWanderspotsToMap(_ wanderspots: [Wanderspot]) {
    
    var annotations = [MGLPointAnnotation]()
    var coordinates = [CLLocationCoordinate2D]()
    for spot in wanderspots {
      let latitude = spot.latitude
      let longitude = spot.longitude
      
      addWanderspotAsAnnotation(wanderspot: spot)
      self.setVisibleCoordinates(
        coordinates,
        count: UInt(coordinates.count),
        edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 80, right: 40),
        animated: true
      )
    }
  }
  
  func addWanderspotAsAnnotation(wanderspot: Wanderspot) {
    let annotation = MGLPointAnnotation()
    let latitude = wanderspot.latitude
    let longitude = wanderspot.longitude
    annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    annotation.title = wanderspot.name
    annotation.subtitle = "\(wanderspot.distanceAway) away"
    self.addAnnotation(annotation)
  }
  
  func searchQueryForWanderlistsNear(query: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
    let client = Client(appID: ALGOLIA_APPLICATION_ID, apiKey: ALGOLIA_API_KEY)
    let index = client.index(withName: "wanderlist_search")
    
    let query = Query(query: query)
    query.aroundLatLng = LatLng(lat: latitude, lng: longitude)
    query.attributesToRetrieve = ["title", "city", "latitude", "longitude", "about", "spots_count", "objectID", "zipcode", "_geoloc"]
    
    index.search(query, completionHandler: { (results, error) in
      guard let results = results else {
        return
      }
      
      guard let hits = results["hits"] as? [[String: AnyObject]] else { return }
      
      self.addHitsToMap(hits: hits)
    })
  }
  
  func addHitsToMap(hits: [[String: Any]]) {
    var coordinates = [CLLocationCoordinate2D]()
    for hit in hits {
      let hello = MGLPointAnnotation()
      let latitude = hit["latitude"] as! Double
      let longitude = hit["longitude"] as! Double
      hello.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
      coordinates.append(hello.coordinate)
      //      hello.title = hit["title"] as! String
      hello.title = "title"
      
      self.addAnnotation(hello)
    }
    
    self.setVisibleCoordinates(
      coordinates,
      count: UInt(coordinates.count),
      edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
      animated: true
    )
  }
  
  func removeAllAnnotations() {
    
    guard let annotations = self.annotations else { return print("Annotations Error") }
    
    if annotations.count != 0 {
      for annotation in annotations {
        self.removeAnnotation(annotation)
      }
    } else {
      return
    }
  }
}
