//
//  AlgoliaService.swift
//  Wanderlist
//
//  Created by Lauren Nicole Roth on 3/11/19.
//  Copyright © 2019 Lauren Nicole Roth. All rights reserved.
//

import Foundation
import InstantSearchClient

class AlgoliaService {
  
  let instance = AlgoliaService()
  
  
  func searchWanderlistsWithQueryAndCurrentLocation(query: String) {
    let client = Client(appID: ALGOLIA_APPLICATION_ID, apiKey: ALGOLIA_API_KEY)
    let index = client.index(withName: "wanderlist_search")
    
    Locator.currentPosition(accuracy: .city, onSuccess: { (location) -> (Void) in
      let latitude = location.coordinate.latitude
      let longitude = location.coordinate.longitude
      self.currentLocation = location
      
      let query = Query(query: query)
      query.aroundLatLng = LatLng(lat: latitude, lng: longitude)
      query.attributesToRetrieve = ["title", "city", "about", "latitude", "longitude", "spots_count", "categories"]
      
      index.search(query, completionHandler: { [unowned self] (results, error) in
        guard let results = results else {
          return
        }
        
        guard let hits = results["hits"] as? [[String: AnyObject]] else { return }
        
        if hits.count < 1 {
          self.wanderlistsWithState = []
          
        } else {
          self.getWanderlistsFromHits(hits: hits)
        }
      })
    }) { (error, location) -> (Void) in
      print("location error: ", error)
    }
    
    func getWanderlistsFromHits(hits: [[String: Any]]) {
      for hit in hits {
        print(hit)
      }
      self.wanderlistCollectionView.reloadData()
    }
  }
}


