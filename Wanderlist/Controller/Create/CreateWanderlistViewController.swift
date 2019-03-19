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
  var results : [Result] = []
  var wanderspots : [Wanderspot] = [] {
    didSet {
      updateMap()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Create"
    
    setupMapUI()
    placeResultsCollection.register(UINib(nibName: "PlaceResultCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "PlaceResultCollectionViewCell")
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.results = []
    self.wanderspots = []
  }
  
  func updateMap() {
    nextButton.isEnabled = true
    if wanderspots.count == 1 {
      mapView.addWanderspotToMap(wanderspot: wanderspots.first!)
    } else if wanderspots.count == 0 {
      nextButton.isEnabled = false
    } else {
      fitMapToWanderspots()
    }
  }
  
  func fitMapToWanderspots() {
    var coordinates = [CLLocationCoordinate2D]()
    for spot in self.wanderspots {
      let latitude = spot.latitude
      let longitude = spot.longitude
      coordinates.append(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
      mapView.addWanderspotAsAnnotation(wanderspot: spot)
      mapView.setVisibleCoordinates(
        coordinates,
        count: UInt(coordinates.count),
        edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40),
        animated: true
      )
    }
  }
  
  func lookupAddress(_ address: String) {
  
    let options = ForwardGeocodeOptions(query: address)
    options.focalLocation = CLLocation(latitude: 40.792143, longitude: -73.974156)
    options.allowedScopes = [.address, .pointOfInterest]
    
    results = []
    
    let task = geocoder.geocode(options) { [unowned self] (placemarks, attribution, error) in
      guard let placemarks = placemarks else { return }
      for place in placemarks {
        self.results.append(Result(name: place.name, address: place.formattedName, coordinate: place.location?.coordinate))
      }

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

    let storyboard = UIStoryboard(name: "Create", bundle: nil)
    let controller = storyboard.instantiateViewController(withIdentifier: "EditWanderspotsViewController") as! EditWanderspotsViewController
    controller.wanderspots = wanderspots
    self.navigationController?.pushViewController(controller, animated: true)
  }
  
  func setupMapUI() {
    let center = CLLocationCoordinate2D(latitude: 40.792143, longitude: -73.974156)
    self.mapView?.setCenter(center, zoomLevel: 12, animated: true)
  }
}

extension CreateWanderlistViewController: UISearchBarDelegate {
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    performSearch()
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    print("Cancel clicked")
    results = []
    toggleSearchState()
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    performSearch()
  }
  
  func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
    performSearch()
  }
  
  func performSearch() {
    guard let query = searchBar.text else { return }
    lookupAddress(query)
    
    results = []
    searchBar.text = ""
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

    let wanderspot = Wanderspot(result: results[indexPath.row])
    self.wanderspots.append(wanderspot)
    
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
  
  func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
    if annotation is MGLUserLocation && mapView.userLocation != nil {
      
    }
    return nil
  }
  
  func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
    return UIButton(type: .detailDisclosure)
  }
  
  func mapViewDidStopLocatingUser(_ mapView: MGLMapView) {

  }
  
  func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
    
    return true
  }
  
  func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
    print("Annotation selected")
  }
}
