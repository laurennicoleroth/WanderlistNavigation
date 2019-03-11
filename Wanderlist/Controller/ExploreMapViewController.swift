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
  @IBOutlet var wanderlistsHitsCollectionView: HitsCollectionWidget!
  @IBOutlet var searchBarWidget: SearchBarWidget!
  
  var currentUser : User?
  var wanderlists = [Wanderlist]()
  var currentLocation : CLLocation?
  var expandedHeight : CGFloat = 600
  var notExpandedHeight : CGFloat = 200
  var isExpanded = [Bool]()
  
  override func viewWillAppear(_ animated: Bool) {
    setupSearch()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "EXPLORE"
    
    setupMapUI()
    setupCollectionUI()
  }
  
  func setupSearch() {
    InstantSearch.shared.configure(appID: ALGOLIA_APPLICATION_ID, apiKey: ALGOLIA_API_KEY, index: "wanderlist_search")
    InstantSearch.shared.params.attributesToRetrieve = ["title", "city", "about", "latitude", "longitude", "spots_count", "categories"]
    InstantSearch.shared.params.attributesToHighlight = ["title"]
    InstantSearch.shared.register(searchBar: searchBarWidget)
  }
  
  private func setupMapUI() {
    mapView.showCurrentLocation()
    mapView.userTrackingMode = .followWithHeading
    mapView.showsUserHeadingIndicator = true
    mapView.delegate = self
  }
  
  private func setupCollectionUI() {
    self.view.layoutIfNeeded()
    wanderlistsHitsCollectionView.showsHorizontalScrollIndicator = false
    if let layout = wanderlistsHitsCollectionView.collectionViewLayout as? MMBannerLayout {
      layout.itemSpace = 10
      layout.itemSize = self.wanderlistsHitsCollectionView.frame.insetBy(dx: 30, dy: 30).size
      layout.minimuAlpha = 0.4
      layout.angle = 30.0
    }
    
    wanderlistsHitsCollectionView.register(UINib(nibName: "WanderlistCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "WanderlistCollectionViewCell")
  }
 
  func setupDataNear(location: CLLocation) {
    let client = Client(appID: ALGOLIA_APPLICATION_ID, apiKey: ALGOLIA_API_KEY)
    let index = client.index(withName: "wanderlist_search")
    
    let query = Query(query: "")
    query.aroundLatLng = LatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
    query.attributesToRetrieve = ["title", "city", "about", "latitude", "longitude", "spots_count", "categories"]
    
    index.search(query, completionHandler: { [unowned self] (results, error) in
      guard let results = results else {
        return
      }
      
      guard let hits = results["hits"] as? [[String: AnyObject]] else { return }
      
      for hit in hits {
        self.wanderlists.append(Wanderlist(json: hit))
      }
     
    })
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

extension ExploreMapViewController: HitsCollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath, containing hit: [String : Any]) {
    print("hit \(String(describing: hit["name"]!)) has been clicked")
  }
}

extension ExploreMapViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let wanderlist = wanderlists[indexPath.row]
    let storyboard = UIStoryboard(name: "Explore", bundle: nil)
    let controller = storyboard.instantiateViewController(withIdentifier: "WanderlistPreviewViewController") as! WanderlistPreviewViewController
    controller.wanderlist = wanderlist
    self.navigationController?.pushViewController(controller, animated: true)
  }
  
}

extension ExploreMapViewController: HitsCollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, containing hit: [String : Any]) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WanderlistCollectionViewCell", for: indexPath) as! WanderlistCollectionViewCell
    let wanderlist = Wanderlist(json: hit)
    cell.configureCellFrom(wanderlist: wanderlist)
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

extension ExploreMapViewController: BannerLayoutDelegate {
  func collectionView(_ collectionView: UICollectionView, focusAt indexPath: IndexPath) {
    let wanderlist = wanderlists[indexPath.row]
    //    mapView.zoomToWanderlistWithMapPreview(wanderlist: wanderlist)
  }
}

