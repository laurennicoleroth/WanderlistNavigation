//
//  Geocode.swift
//  Wanderlist
//
//  Created by Lauren Nicole Roth on 3/15/19.
//  Copyright © 2019 Lauren Nicole Roth. All rights reserved.
//
/*
import Foundation
import CoreLocation

class GeocodingRequest {
  var address: String
  
  init(address: String) {
    self.address = address
  }
  
  func toParameters() -> Parameters {
    let parameters : Parameters = [
      "address": self.address,
      "key": GOOGLE_PLACES_API
    ]
    
    return parameters
  }
}

class GeocodingService {
  var geocodingUrl = URLGenerator.geocodingApiUrlForPathString(path: "json")
  var geocodingRequest: GeocodingRequest
  
  init(_ geocodingRequest: GeocodingRequest) {
    self.geocodingRequest = geocodingRequest
  }
  
  func getGeoCoding() -> Promise<Geocoding> {
    let parameters = geocodingRequest.toParameters()
    
    return Promise { fulfill, reject in
      Alamofire.request(geocodingUrl, method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
        switch response.result {
        case .success(let json):
          
          var geocoding: Geocoding? = nil
          if let geocodingManagerDictionary = json as? NSDictionary {
            let geocodingManager = GeocodingManager(geocodingDictionary: geocodingManagerDictionary)
            geocoding = geocodingManager.serialize()
          }
          
          if geocoding != nil {
            fulfill(geocoding!)
          } else {
//            reject(WeatherBotError.geocodingManagerDictionary)
          }
          
        case .failure(let error):
          reject(error)
        }
        
      }
    }
  }
}

class GeocodingResult {
  var native: Geocoding?
  var googleMaps: Geocoding?
  var address: String
  
  init(_ address: String) {
    self.address = address
  }
  
  func getDistance() -> Int? {
    if native != nil || googleMaps != nil {
      let coordinate1 = CLLocation(latitude: native!.coordinates.latitude, longitude: native!.coordinates.longitude)
      let coordinate2 = CLLocation(latitude: googleMaps!.coordinates.latitude, longitude: googleMaps!.coordinates.longitude)
      return Int(coordinate1.distance(from: coordinate2))
    } else {
      return nil
    }
  }
  
}


class GeocodingManager {
  
  var geocoding: Geocoding? = nil
  var geocodingDictionary: NSDictionary
  
  required init(geocodingDictionary: NSDictionary) {
    self.geocodingDictionary = geocodingDictionary
  }
  
  // MARK:- Geocoding serialize
  func serialize() -> Geocoding? {
    
    if let resultArray = self.geocodingDictionary["results"] as? NSArray {
      if let resultDictionary = resultArray[0] as? [String:AnyObject] {
        print("Result Dictionary: ", resultDictionary.first)
        //coordinates
        var coordinates = CLLocationCoordinate2D()
        if let value = resultDictionary["geometry"] as? NSDictionary {
          if let location = value["location"] as? [String:AnyObject] {
            let latitude = CLLocationDegrees(location["lat"]?.floatValue ?? 0.0)
            let longitude = CLLocationDegrees(location["lng"]?.floatValue ?? 0.0)
            coordinates.latitude = latitude
            coordinates.longitude = CLLocationDegrees(longitude)
          }
        }
        
        if coordinates.latitude != 0.0 {
          
          let geocoding = Geocoding(coordinates: coordinates)
          
          //name
          if let value = resultDictionary["address_components"] as? NSArray{
            if let component = value[0] as? [String:Any] {
              geocoding.name = component["long_name"] as? String
            }
          }
          
          //formattedAddress
          if let value = resultDictionary["formatted_address"] as? String {
            geocoding.formattedAddress = value
          }
          
          //bounds
          if let geometry = resultDictionary["geometry"] as? [String:Any] {
            
            if let bounds = geometry["bounds"] as? [String:AnyObject] {
              if let value = bounds["northeast"] as? [String:AnyObject] {
                geocoding.boundNorthEast = CLLocationCoordinate2D(latitude: CLLocationDegrees(value["lat"]!.floatValue), longitude: CLLocationDegrees(value["lng"]!.floatValue))
              }
              
              if let value = bounds["southwest"] as? [String:AnyObject] {
                geocoding.boundSouthWest = CLLocationCoordinate2D(latitude: CLLocationDegrees(value["lat"]!.floatValue), longitude: CLLocationDegrees(value["lng"]!.floatValue))
              }
            }
            
          }
          
          return geocoding
          
        } else {
          return nil
        }
        
      }
      
      
    }
    
    return nil
    
  }
  
}

class Geocoding {
  
  var coordinates: CLLocationCoordinate2D
  var name: String?
  var formattedAddress: String?
  var boundNorthEast: CLLocationCoordinate2D?
  var boundSouthWest: CLLocationCoordinate2D?
  
  init(coordinates: CLLocationCoordinate2D) {
    self.coordinates = coordinates
  }
  
}
 */
