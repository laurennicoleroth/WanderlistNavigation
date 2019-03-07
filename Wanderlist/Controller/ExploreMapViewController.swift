//
//  ExploreMapViewController.swift
//  Wanderlist
//
//  Created by Lauren Nicole Roth on 3/5/19.
//  Copyright © 2019 Lauren Nicole Roth. All rights reserved.
//

import UIKit
import Mapbox
import InstantSearch
import MMBannerLayout
import SwiftLocation

class ExploreMapViewController: UIViewController {
  
  @IBOutlet var mapView: WanderlistMapboxMap!
  @IBOutlet var wanderlistCollectionView: UICollectionView!
  
  var wanderlists = [Wanderlist]()
  var currentLocation : CLLocation?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "WANDERLY"
    
    Locator.currentPosition(accuracy: .city, onSuccess: { (location) -> (Void) in
      self.currentLocation = location
    }) { (error, location) -> (Void) in
      print("Failed to get location: ", error)
    }
    
    setupMapUI()
    searchWanderlistsWithQueryAndCurrentLocation(query: "")
    setupCollectionUI()
  }
 
  private func setupMapUI() {
    mapView.showCurrentLocation()
    mapView.userTrackingMode = .followWithHeading
    mapView.showsUserHeadingIndicator = true
    mapView.delegate = self
  }
  
  private func setupCollectionUI() {
    searchWanderlistsWithQueryAndCurrentLocation(query: "")
    
    self.view.layoutIfNeeded()
    wanderlistCollectionView.showsHorizontalScrollIndicator = false
    if let layout = wanderlistCollectionView.collectionViewLayout as? MMBannerLayout {
      layout.itemSpace = 10
      layout.itemSize = self.wanderlistCollectionView.frame.insetBy(dx: 30, dy: 30).size
      layout.minimuAlpha = 0.4
      layout.angle = 30.0
    }
    
    wanderlistCollectionView.register(UINib(nibName: "WanderlistCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "WanderlistCollectionViewCell")
  }
  
  private func searchWanderlistsWithQueryAndCurrentLocation(query: String) {
    let client = Client(appID: ALGOLIA_APPLICATION_ID, apiKey: ALGOLIA_API_KEY)
    let index = client.index(withName: "wanderlist_search")
    
    Locator.currentPosition(accuracy: .city, onSuccess: { (location) -> (Void) in
      let latitude = location.coordinate.latitude
      let longitude = location.coordinate.longitude
      
      let query = Query(query: query)
      query.aroundLatLng = LatLng(lat: latitude, lng: longitude)
      query.attributesToRetrieve = ["title", "city", "about", "latitude", "longitude", "spots_count", "categories"]
      
      index.search(query, completionHandler: { (results, error) in
        guard let results = results else {
          return
        }
        
        guard let hits = results["hits"] as? [[String: AnyObject]] else { return }
        
        if hits.count < 1 {
          self.wanderlists = []
//          self.getWanderlistsNearCurrentLocation()
        }
        
        self.addHitsToCollection(hits: hits)
        self.mapView.addHitsToMap(hits: hits)
      })
    }) { (error, location) -> (Void) in
      print("location error: ", error)
    }
  }
  
  func addHitsToCollection(hits: [[String: Any]]) {
    wanderlists = []
    for hit in hits {
      let wanderlist = Wanderlist(json: hit)
      wanderlists.append(wanderlist)
    }
    wanderlistCollectionView.reloadData()
  }
}

extension ExploreMapViewController: MGLMapViewDelegate {
  
  func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
    if annotation is MGLUserLocation && mapView.userLocation != nil {
      print("View for annotation, y'all")
    }
    return nil
  }
  
  func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
    print("Did select annotation on map", annotation)
  }
  
  // Allow callout view to appear when an annotation is tapped.
  func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
    
    debugPrint("Annotation callout shown")
    return true
  }
  
}

extension ExploreMapViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    mapView.drawWanderlistPathForWanderlist(wanderlist: wanderlists[indexPath.row])
  }
}

extension ExploreMapViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return wanderlists.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let wanderlist = wanderlists[indexPath.row]
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WanderlistCollectionViewCell", for: indexPath) as! WanderlistCollectionViewCell
    cell.configureCellFrom(wanderlist: wanderlist)
    
    if let origin = currentLocation {
//      cell.categoriesLabel.text = "\(wanderlist.distanceFromUserAt(origin: origin)) away"
    }
    cell.backgroundColor = .white
    return cell
  }

}

extension ExploreMapViewController: BannerLayoutDelegate {
  func collectionView(_ collectionView: UICollectionView, focusAt indexPath: IndexPath) {
    let wanderlist = wanderlists[indexPath.row]
    
    mapView.zoomToWanderlistWithMapPreview(wanderlist: wanderlists[indexPath.row])
  }
}


