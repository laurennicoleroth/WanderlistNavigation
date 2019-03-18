//
//  CreateWanderlistViewController.swift
//  Wanderlist
//
//  Created by Lauren Nicole Roth on 3/14/19.
//  Copyright © 2019 Lauren Nicole Roth. All rights reserved.
//

import UIKit
import Mapbox
import MapboxGeocoder

class CreateWanderlistViewController: UIViewController {

  @IBOutlet var mapView: WanderlistDetailMapboxMap!
  @IBOutlet var nextButton: UIButton!
  @IBOutlet var searchView: UIView!
  @IBOutlet var searchBar: UISearchBar!
  @IBOutlet var addButton: UIButton!
  @IBOutlet var placeResultsCollection: UICollectionView!
  
  let geocoder = Geocoder.shared
  var annotations : [WanderspotAnnotation]?
  var results : [Placemark] = []
  var wanderspots : [Wanderspot] = [] {
    didSet {
      print("Wanderspot added", wanderspots.last?.latitude, wanderspots.last?.longitude)
      if wanderspots.count > 0 {
        nextButton.isEnabled = true
      } else {
        nextButton.isEnabled = false
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupMapUI()
    placeResultsCollection.register(UINib(nibName: "PlaceResultCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "PlaceResultCollectionViewCell")
  }
  
  func lookupAddress(_ address: String) {
  
    let options = ForwardGeocodeOptions(query: address)
    options.focalLocation = CLLocation(latitude: 40.792143, longitude: -73.974156)
    options.allowedScopes = [.address, .pointOfInterest]
    
    let task = geocoder.geocode(options) { [unowned self] (placemarks, attribution, error) in
      guard let placemarks = placemarks else { return }

      self.results = placemarks
      self.placeResultsCollection.reloadData()
      self.toggleResultsState()
    }
  }
  
  private func toggleSearchState() {
    searchView.isHidden = !searchView.isHidden
    addButton.isHidden = !addButton.isHidden
  }
  
  private func toggleResultsState() {
    placeResultsCollection.isHidden = !placeResultsCollection.isHidden
  }

  @IBAction func addButtonTouched(_ sender: Any) {
    toggleSearchState()
  }
  @IBAction func nextButtonTouched(_ sender: Any) {
    
  }
  
  func setupMapUI() {
    
    let center = CLLocationCoordinate2D(latitude: 40.792143, longitude: -73.974156)
    self.mapView?.setCenter(center, zoomLevel: 12, animated: true)
  }
}

extension CreateWanderlistViewController: UISearchBarDelegate {
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    print("search bar text did end editing")
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    print("Cancel clicked")
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
  
    print("Text to search:", searchBar.text)
    guard let query = searchBar.text else { return }
    lookupAddress(query)
  }
  
  func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
    print("Results list button clicked")
  }
}

extension CreateWanderlistViewController : UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return results.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaceResultCollectionViewCell", for: indexPath) as! PlaceResultCollectionViewCell
    cell.configureCellFrom(result: results[indexPath.row])
    return cell
  }
  
}

extension CreateWanderlistViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    print("Did select address: ", results[indexPath.row])
    guard let placemark : Placemark? = results[indexPath.row] else { return }
    mapView.addPlacemarkToMap(placemark: placemark!)
    toggleResultsState()
  }
}

extension CreateWanderlistViewController: MGLMapViewDelegate {
  func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
    
    var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "map-pin-purple")
    
    if annotationImage == nil {
      var image = UIImage(named: "map-pin-purple")!
      image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/4, right: 0))
      annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "map-pin-purple")
    }
    
    return annotationImage
  }
}
