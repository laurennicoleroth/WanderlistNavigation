//
//  Errors.swift
//  Wanderlist
//
//  Created by Lauren Nicole Roth on 3/15/19.
//  Copyright © 2019 Lauren Nicole Roth. All rights reserved.
//

enum Errors: Error {
  case unKnowError
  case geocodingManagerDictionary
  case noMatchingLocation
}

class URLGenerator {
  
  static let geocodingbaseUrl: String = "https://maps.googleapis.com/maps/api/geocode"
  
  class func geocodingApiUrlForPathString(path: String) -> String {
    
    return URLGenerator.geocodingbaseUrl + "/" + path
    
  }
  
}
