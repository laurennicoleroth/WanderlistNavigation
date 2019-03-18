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
  
  let geocoder = Geocoder.shared
  var annotations : [WanderspotAnnotation]?
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
    
//    setupMapUI()

  }
  
  func lookupAddress(_ address: String) {
  
    let options = ForwardGeocodeOptions(query: address)
    options.focalLocation = CLLocation(latitude: 40.792143, longitude: -73.974156)
    options.allowedScopes = [.address, .pointOfInterest]
    
    let task = geocoder.geocode(options) { (placemarks, attribution, error) in
      guard let placemark = placemarks?.first else {
        return
      }
      
      let wanderspot = Wanderspot(placemark: placemark)
      print(wanderspot.toJSON())
    }
  }

  @IBAction func addButtonTouched(_ sender: Any) {
    print("Add button touched")
  }
  @IBAction func nextButtonTouched(_ sender: Any) {
    
  }
  
  func setupMapUI() {
    mapView.showCurrentLocation()
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
