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
import InstantSearchCore
import InstantSearchClient
import SwiftLocation
import Kingfisher
import MMBannerLayout
import GEOSwift

class ExploreMapViewController: UIViewController {

  @IBOutlet weak var mapView: WanderlistMapboxMap!
  @IBOutlet weak var wanderlistsHitsCollectionView: HitsCollectionWidget!

  var wanderlists = [Wanderlist]()
  var query = Query()
  var selectedWanderlist: Wanderlist?
  var currentLocation : CLLocationCoordinate2D? {
    didSet {
//      searchQueryNearby(queryString: "")
    }
  }
  var haveResults = false {
    didSet {
      if haveResults {
        wanderlistsHitsCollectionView.reloadData()
      }
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    Locator.currentPosition(accuracy: .city, onSuccess: { [unowned self] (location) in
      self.currentLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }) { (error, location) in
      print("Error \(error)")
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    InstantSearch.shared.configure(appID: ALGOLIA_APPLICATION_ID, apiKey: ALGOLIA_API_KEY, index: "wanderlist_search")
    InstantSearch.shared.params.attributesToRetrieve = ["title", "city", "about", "latitude", "longitude", "spots_count", "categories"]
    
    setupMapUI()
    setupCollectionUI()
    addPolygonsToMap()
  }
  
  func addPolygonsToMap() {
    if let geoJSONURL = Bundle.main.url(forResource: "nyc_neighborhoods", withExtension: "geojson") {
      let features = try! Features.fromGeoJSON(geoJSONURL)
      let firstNeighborhood = features?.first?.geometries?.first as? MGLMultiPolygon
      print(firstNeighborhood)
    }
  }

  func searchQueryNearby(queryString: String) {
    let client = Client(appID: ALGOLIA_APPLICATION_ID, apiKey: ALGOLIA_API_KEY)
    let index = client.index(withName: "wanderlist_search")
    let query = Query(query: queryString)
    
    if let location = currentLocation {
      query.aroundLatLng = LatLng(lat: location.latitude, lng: location.longitude)
      
      index.search(query, completionHandler: { [unowned self] (results, error) in
        guard let results = results else {
          return
        }
        guard let hits = results["hits"] as? [[String: AnyObject]] else { return }
        
        self.wanderlists = hits.map({ Wanderlist(json: $0) })
        self.haveResults = true
        
      })
    }
  }

  private func setupMapUI() {
    mapView.showCurrentLocation()
    mapView.delegate = self
  }

  private func setupCollectionUI() {
    self.view.layoutIfNeeded()
    wanderlistsHitsCollectionView.showsHorizontalScrollIndicator = true
    wanderlistsHitsCollectionView.register(UINib(nibName: "WanderlistCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "WanderlistCollectionViewCell")

    if let layout = wanderlistsHitsCollectionView.collectionViewLayout as? MMBannerLayout {
      layout.itemSpace = 10
      layout.itemSize = self.wanderlistsHitsCollectionView.frame.insetBy(dx: 20, dy: 20).size
      layout.minimuAlpha = 0.7
      layout.angle = 30.0
    }
  }

//  private func findWanderlistFromAnnotation(annotation: MGLAnnotation) -> Wanderlist? {
//    var wanderlist: Wanderlist?
//    if let index = wanderlists?.firstIndex(where: { $0.title == annotation.title }) {
//      print("The first index = \(index)")
//      wanderlist = wanderlists?[index]
//      wanderlistsHitsCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
//      wanderlistsHitsCollectionView.layoutSubviews()
//      mapView.setCenter(CLLocationCoordinate2D(latitude: wanderlists?[index].latitude ?? 0.0, longitude: wanderlists?[index].longitude ?? 0.0), animated: true)
//    }
//    return wanderlist
//  }
}

extension ExploreMapViewController: MGLMapViewDelegate {

  func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
    if annotation is MGLUserLocation && mapView.userLocation != nil {
      print("Have annotation ", annotation)
    }
    return nil
  }

//  func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
//    // Optionally handle taps on the callout.
//
//    var wanderlist = findWanderlistFromAnnotation(annotation: annotation)
//    print("Tapped the callout. Let's go see \(wanderlist?.title)")
//    wanderlist = nil
//    mapView.deselectAnnotation(annotation, animated: true)
//  }

  func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {

    var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "map-pin-purple")

    if annotationImage == nil {
      var image = UIImage(named: "map-pin-purple")!
      image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/4, right: 0))
      annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "map-pin-purple")
    }

    return annotationImage
  }

  func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
    return UIButton(type: .detailDisclosure)
  }

  func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
//    findWanderlistFromAnnotation(annotation: annotation)
  }

  // Allow callout view to appear when an annotation is tapped.
  func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {

    return true
  }

}

extension ExploreMapViewController: UICollectionViewDelegate {

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let storyboard = UIStoryboard(name: "Explore", bundle: nil)
    let controller = storyboard.instantiateViewController(withIdentifier: "WanderlistPreviewViewController") as! WanderlistPreviewViewController
    controller.wanderlist = wanderlists[indexPath.row]
    self.navigationController?.pushViewController(controller, animated: true)
  }
}

extension ExploreMapViewController: UICollectionViewDataSource, HitsCollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WanderlistCollectionViewCell", for: indexPath) as! WanderlistCollectionViewCell
    cell.configureCellFrom(wanderlist: wanderlists[indexPath.row])
    return cell
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return wanderlists.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, containing hit: [String : Any]) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WanderlistCollectionViewCell", for: indexPath) as! WanderlistCollectionViewCell
    cell.configureCellFrom(wanderlist: wanderlists[indexPath.row])
    
    return cell
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
      ]) {
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

    print("Focus is at ", indexPath.row)
  }
}
