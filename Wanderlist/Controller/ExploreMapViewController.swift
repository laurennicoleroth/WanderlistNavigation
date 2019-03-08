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
import GooglePlaces
import Kingfisher
import Pring

class ExploreMapViewController: UIViewController {
  
  @IBOutlet var mapView: WanderlistMapboxMap!
  @IBOutlet var wanderlistCollectionView: UICollectionView!
  @IBOutlet var collectionViewHeightConstraint: NSLayoutConstraint!
  
  var wanderlistsWithState = [(Wanderlist, Bool)]() {
    didSet {
      if wanderlistsWithState.count == 2 {
        self.wanderlistCollectionView.reloadData()
      }
      
    }
  }
  
  var currentLocation : CLLocation?
  var expandedHeight : CGFloat = 600
  var notExpandedHeight : CGFloat = 200
  var isExpanded = [Bool]()
 
  override func viewWillAppear(_ animated: Bool) {
    searchWanderlistsWithQueryAndCurrentLocation(query: "")
  }
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    self.title = "WANDERLY"
    
    setupMapUI()
    setupCollectionUI()
  }
  
  private func setupMapUI() {
    mapView.showCurrentLocation()
    mapView.userTrackingMode = .followWithHeading
    mapView.showsUserHeadingIndicator = true
    mapView.delegate = self
  }
  
  private func setupCollectionUI() {
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
  }
  
  func getWanderlistsFromHits(hits: [[String: Any]]) {
    for hit in hits {
      if let id = hit["objectID"] as? String {
        Wanderlist.get(id) { [unowned self] (wanderlist, error) in
          if let wanderlist = wanderlist {
            self.wanderlistsWithState.insert((wanderlist, false), at: 0)
          }
        }
      }
    }
    self.wanderlistCollectionView.reloadData()
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
    mapView.drawWanderlistPathForWanderlist(wanderlist: wanderlistsWithState[indexPath.row].0)
  }
  
 
}

extension ExploreMapViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return wanderlistsWithState.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WanderlistCollectionViewCell", for: indexPath) as! WanderlistCollectionViewCell
    let wanderlist = wanderlistsWithState[indexPath.row].0
    cell.configureCellFrom(wanderlist: wanderlist)
    
    if let origin = currentLocation {
      let distance = wanderlist.distanceFromUserAt(origin: origin)
      cell.distanceAwayButton.setTitle("\(distance) miles away", for: .normal)
    }
    cell.delegate = self
    cell.indexPath = indexPath
 
    if let placeID = wanderlist.wanderspots.first?.placeID {
      setPhotoOnCell(cell: cell, id: placeID)
    }
    
    cell.backgroundColor = .white
    return cell
  }
  
  func setPhotoOnCell(cell: WanderlistCollectionViewCell, id: String) {
    let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.photos.rawValue))!
    let placesClient = GMSPlacesClient()
    placesClient.fetchPlace(fromPlaceID: id,
                            placeFields: fields,
                            sessionToken: nil, callback: {
                              (place: GMSPlace?, error: Error?) in
                              if let error = error {
                                print("An error occurred: \(error.localizedDescription)")
                                return
                              }
                              if let place = place {
                                // Get the metadata for the first photo in the place photo metadata list.
                                if let photoMetadata: GMSPlacePhotoMetadata = place.photos?[0] {
                                  // Call loadPlacePhoto to display the bitmap and attribution.
                                  placesClient.loadPlacePhoto(photoMetadata, callback: { (photo, error) -> Void in
                                    if let error = error {
                                      // TODO: Handle the error.
                                      print("Error loading photo metadata: \(error.localizedDescription)")
                                      return
                                    } else {
                                      // Display the first image and its attributions.
                                      cell.imageView.image = photo
                                    }
                                  })
                                }
                                
                                
                              }
    })
  }
  
  private func setImage(cell: WanderlistCollectionViewCell, placeID: String) {
    let imageURL = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(placeID)&key=\(GOOGLE_PLACES_KEY)"
    
    let url = URL(string: imageURL)
    cell.imageView.kf.indicatorType = .activity
    let processor = DownsamplingImageProcessor(size: cell.imageView.frame.size)
    cell.imageView.kf.setImage(
      with: url,
      placeholder: UIImage(named: "times-square"),
      options: [
        .processor(processor),
        .scaleFactor(UIScreen.main.scale),
        .transition(.fade(1)),
        .cacheOriginalImage
      ])
    {
      result in
      switch result {
      case .success(let value):
        print("Task done for: \(value.source.url?.absoluteString ?? "")")
      case .failure(let error):
        print("Job failed: \(error.localizedDescription)")
      }
    }
  }
  
}

extension ExploreMapViewController: UICollectionViewDelegateFlowLayout{
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    if wanderlistsWithState[indexPath.row].1 == true{
      return CGSize(width: self.view.frame.width, height: expandedHeight)
      
    }else{

      return CGSize(width: self.view.frame.width, height: notExpandedHeight)
    }
    
  }
  
}

extension ExploreMapViewController: BannerLayoutDelegate {
  func collectionView(_ collectionView: UICollectionView, focusAt indexPath: IndexPath) {
    let wanderlist = wanderlistsWithState[indexPath.row].0
    mapView.zoomToWanderlistWithMapPreview(wanderlist: wanderlist)
  }
  
  
}

extension ExploreMapViewController: WanderlistCollectionViewCellDelegate {
  func expandButtonTouched(indexPath: IndexPath) {
  
    wanderlistsWithState[indexPath.row].1 = !wanderlistsWithState[indexPath.row].1
 
    UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9,
                   options: UIView.AnimationOptions.curveEaseInOut, animations: {
      self.wanderlistCollectionView.reloadItems(at: [indexPath])
    }, completion: { success in
      print("success")
    })
  }
  
 
 
}
