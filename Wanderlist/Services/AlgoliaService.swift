//
//  AlgoliaService.swift
//  Wanderlist
//
//  Created by Lauren Nicole Roth on 3/11/19.
//  Copyright © 2019 Lauren Nicole Roth. All rights reserved.
//

import Foundation
import InstantSearchClient
import SwiftLocation

class AlgoliaService {
  
  class func searchWanderlistsWithQueryAndCurrentLocation(query: String, completion: @escaping ([Wanderlist]) -> ()) {
    let client = Client(appID: ALGOLIA_APPLICATION_ID, apiKey: ALGOLIA_API_KEY)
    let index = client.index(withName: "wanderlist_search")
    
    Locator.currentPosition(accuracy: .city, onSuccess: { (location) -> (Void) in
      let latitude = location.coordinate.latitude
      let longitude = location.coordinate.longitude
      
      var wanderlists = [Wanderlist]()
      
      let query = Query(query: query)
      query.aroundLatLng = LatLng(lat: latitude, lng: longitude)
      query.attributesToRetrieve = ["title", "city", "about", "latitude", "longitude", "spots_count", "categories"]
      
      index.search(query, completionHandler: {(results, error) in
        guard let results = results else {
          return
        }
        
        guard let hits = results["hits"] as? [[String: AnyObject]] else { return }
        
        for hit in hits {

          wanderlists.append(Wanderlist(json: hit))
        }
        completion(wanderlists)
      })
    }) { (error, location) -> (Void) in
      print("location error: ", error)
    }
  }
}


