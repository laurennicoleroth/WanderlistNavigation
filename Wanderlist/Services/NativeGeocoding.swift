//
//  NativeGeocoding.swift
//  Wanderlist
//
//  Created by Lauren Nicole Roth on 3/15/19.
//  Copyright © 2019 Lauren Nicole Roth. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire
import CoreLocation

class NativeGeocoding {
  var address: String
  lazy var geocoder = CLGeocoder()
  
  init(_ address: String) {
    self.address = address
  }
  
  func geocode() -> Promise<Geocoding> {
    return Promise { fulfill, reject in
      firstly{
        self.geocodeAddressString()
        }.then { (placemarks) -> Promise<Geocoding> in
          self.processResponse(withPlacemarks: placemarks)
        }.then { (geocoding) -> Void in
          fulfill(geocoding)
        }.catch { (error) in
          reject(error)
      }
    }
  }
  
  private func geocodeAddressString() -> Promise<[CLPlacemark]> {
    return Promise { fulfill, reject in
      geocoder.geocodeAddressString(address) { (placemarks, error) in
        if (error != nil) {
          reject(error!)
        } else {
          fulfill(placemarks!)
        }
      }
    }
  }
  
  private func processResponse(withPlacemarks placemarks: [CLPlacemark]?) -> Promise<Geocoding> {
    return Promise { fulfill, reject in
      
      var location: CLLocation?
      
      if let placemarks = placemarks, placemarks.count > 0 {
        location = placemarks.first?.location
      }
      
      if let location = location {
        let geocoding = Geocoding(coordinates: location.coordinate)
        fulfill(geocoding)
      } else {
        reject(Errors.noMatchingLocation)
      }
    }
  }
}
