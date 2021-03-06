//
//  SearchViewController.swift
//  Wanderlist
//
//  Created by Lauren Nicole Roth on 3/12/19.
//  Copyright © 2019 Lauren Nicole Roth. All rights reserved.
//

import UIKit
import Mapbox
import InstantSearch
import InstantSearchCore
import InstantSearchClient
import MMBannerLayout
import SwiftLocation
import Kingfisher

class SearchViewController: UIViewController {
  @IBOutlet var mapView: WanderlistMapboxMap!
  @IBOutlet var wanderlistHitsCollectionView: HitsCollectionWidget!
  @IBOutlet var searchBar: UISearchBar!

  var searchController = UISearchController()

  var originIsLocal: Bool = false
  var currentUser: User?
  var wanderlists = [Wanderlist]()
  var currentLocation: CLLocation?
  var isExpanded = [Bool]()
  var query = Query()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Search"
    setupMapUI()
    setupCollectionUI()
    Locator.currentPosition(accuracy: .city, onSuccess: { (location) -> Void in
      self.searchQueryNearby(queryString: "", lat: location.coordinate.latitude, lon: location.coordinate.longitude)
    }) { (error, location) -> Void in
      print("Error getting location: ", error)
    }
  }

  func searchQueryNearby(queryString: String, lat: CLLocationDegrees, lon: CLLocationDegrees) {
    InstantSearch.shared.configure(appID: ALGOLIA_APPLICATION_ID, apiKey: ALGOLIA_API_KEY, index: "wanderlist_search")
    InstantSearch.shared.params.attributesToRetrieve = ["title", "city", "about", "latitude", "longitude", "spots_count", "categories"]
    InstantSearch.shared.params.attributesToHighlight = ["title"]

    InstantSearch.shared.registerAllWidgets(in: self.view, doSearch: true)
    query.aroundLatLng = LatLng(lat: lat, lng: lon)
    query.query = queryString
    query.attributesToRetrieve = ["title", "city", "about", "latitude", "longitude", "spots_count", "categories"]
    let client = Client(appID: ALGOLIA_APPLICATION_ID, apiKey: ALGOLIA_API_KEY)
    let index = client.index(withName: "wanderlist_search")

    index.search(query, completionHandler: { [unowned self] (results, error) in
      guard let results = results else {
        return
      }

      guard let hits = results["hits"] as? [[String: AnyObject]] else { return }

      self.wanderlists = hits.map({Wanderlist(json: $0)})

      self.wanderlistHitsCollectionView.reloadHits()
      self.mapView.fitHitsToMap(hits: hits)
    })
  }

  private func setupMapUI() {
    mapView.showCurrentLocation()
    mapView.userTrackingMode = .followWithHeading
    mapView.showsUserHeadingIndicator = true
    mapView.delegate = self
  }

  private func setupCollectionUI() {
    self.view.layoutIfNeeded()
    wanderlistHitsCollectionView.showsHorizontalScrollIndicator = false
    if let layout = wanderlistHitsCollectionView.collectionViewLayout as? MMBannerLayout {
      layout.itemSpace = 10
      layout.itemSize = self.wanderlistHitsCollectionView.frame.insetBy(dx: 30, dy: 30).size
      layout.minimuAlpha = 0.4
      layout.angle = 30.0
    }

    wanderlistHitsCollectionView.register(UINib(nibName: "WanderlistCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "WanderlistCollectionViewCell")
  }
}

extension SearchViewController: UISearchBarDelegate {

  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    print("Cancel clicked")
  }

  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    print("Search began")
  }

  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    if let query = searchBar.text {
      print("Search query:", query)
    }

    searchBar.resignFirstResponder()
  }

  func updateCollectionWithHits(hits: [[String: Any]]) {

  }

  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    print("textDidChange", searchText)

  }

  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    if let queryString = searchBar.text {
      Locator.currentPosition(accuracy: .city, onSuccess: { (location) -> Void in
        self.searchQueryNearby(queryString: queryString, lat: location.coordinate.latitude, lon: location.coordinate.longitude)
      }) { (error, location) -> Void in
        print("Error getting location: ", error)
      }
    }

  }
}

extension SearchViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    print("Update them results")
  }

}

extension SearchViewController: MGLMapViewDelegate {

  func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
    if annotation is MGLUserLocation && mapView.userLocation != nil {

    }
    return nil
  }

  func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {

    var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "map-pin-purple")

    if annotationImage == nil {
      var image = UIImage(named: "map-pin-purple")!

      image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/4, right: 0))

      // Initialize the ‘pisa’ annotation image with the UIImage we just loaded.
      annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "map-pin-purple")
    }

    return annotationImage
  }

//  func mapView(_ mapView: MGLMapView, leftCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
//    if (annotation.title! == "Kinkaku-ji") {
//      // Callout height is fixed; width expands to fit its content.
//      let label = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 50))
//      label.textAlignment = .right
//      label.textColor = UIColor(red: 0.81, green: 0.71, blue: 0.23, alpha: 1)
//      label.text = "金閣寺"
//      
//      return label
//    }
//    
//    return nil
//  }

  func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
    return UIButton(type: .detailDisclosure)
  }

  func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
    print("Did select annotation on map", annotation.title)
    if let index = wanderlists.firstIndex(where: { $0.title == annotation.title }) {
      wanderlistHitsCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
      wanderlistHitsCollectionView.layoutSubviews()
      mapView.setCenter(CLLocationCoordinate2D(latitude: wanderlists[index].latitude, longitude: wanderlists[index].longitude), animated: true)
    }
  }

  // Allow callout view to appear when an annotation is tapped.
  func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {

    debugPrint("Annotation callout shown")
    return true
  }

  func zoomToWanderlist() {

  }

}

extension SearchViewController: UICollectionViewDelegate, HitsCollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath, containing hit: [String : Any]) {
    print("hit \(String(describing: hit["name"]!)) has been clicked")

  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    print("Selected item", wanderlists[indexPath.row].title)
    let wanderlist = wanderlists[indexPath.row]
    mapView.zoomToWanderlistWithMapPreview(wanderlist: wanderlist)
  }
}

extension SearchViewController: UICollectionViewDataSource, HitsCollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WanderlistCollectionViewCell", for: indexPath) as! WanderlistCollectionViewCell
    let wanderlist = wanderlists[indexPath.row]
//    cell.configureCellFrom(wanderlist: wanderlist)
    return cell
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return wanderlists.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, containing hit: [String : Any]) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WanderlistCollectionViewCell", for: indexPath) as! WanderlistCollectionViewCell
    let wanderlist = Wanderlist(json: hit)
//    cell.configureCellFrom(wanderlist: wanderlist)
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

extension SearchViewController: BannerLayoutDelegate {
  func collectionView(_ collectionView: UICollectionView, focusAt indexPath: IndexPath) {
    let wanderlist = wanderlists[indexPath.row]
    mapView.zoomToWanderlistWithMapPreview(wanderlist: wanderlist)
  }
}
