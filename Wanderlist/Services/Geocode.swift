//
//  Geocode.swift
//  Wanderlist
//
//  Created by Lauren Nicole Roth on 3/15/19.
//  Copyright © 2019 Lauren Nicole Roth. All rights reserved.
//

import Foundation
import Alamofire

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
            reject(WeatherBotError.geocodingManagerDictionary)
          }
          
        case .failure(let error):
          reject(error)
        }
        
      }
    }
  }
}
