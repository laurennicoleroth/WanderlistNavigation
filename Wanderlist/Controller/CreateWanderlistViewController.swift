//
//  CreateWanderlistViewController.swift
//  Wanderlist
//
//  Created by Lauren Nicole Roth on 3/14/19.
//  Copyright © 2019 Lauren Nicole Roth. All rights reserved.
//

import UIKit
import Mapbox
import PromiseKit

class CreateWanderlistViewController: UIViewController {

  @IBOutlet var mapView: WanderlistDetailMapboxMap!
  @IBOutlet var nextButton: UIButton!
  
  var geocodingResults = [GeocodingResult]()
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
    
    setupMapUI()
    testAddresses()
  }
  
  func testAddresses() {
    for address in getAddresses() {
      
      var geocodingResult = GeocodingResult(address)
      print("Geocoding result: ", geocodingResult)
      
      //initialize a NativeGeocoding Obj
      let nativeGeocoding = NativeGeocoding(address)
      
      //configure Geocoding
      let geocodingRequest = GeocodingRequest(address: address)
      let geocodingService = GeocodingService(geocodingRequest)
      
      firstly {
        //use native geocoding
        nativeGeocoding.geocode()
        }.then { (geocoding) -> Void in
          geocodingResult.native = geocoding
        }.then {() -> Promise<Geocoding> in
          //use google maps geocoding
          geocodingService.getGeoCoding()
        }.then {(geocoding) -> Void in
          geocodingResult.googleMaps = geocoding
        }.always {() -> Void in
          self.addGeocodingResult(geocodingResult)
        }.catch { (error) in
          //manage error here!
      }
    }
  }
  
  private func addGeocodingResult(_ geocodingResult: GeocodingResult) {
    self.geocodingResults.append(geocodingResult)
    
    print(geocodingResult.googleMaps?.coordinates)
    if geocodingResults.count == getAddresses().count {
//      tableView.reloadData()
//      tableView.tableHeaderView = UIView()
    }
  }
  
  private func getAddresses() -> [String] {
    return [
      "700 West End Ave, New York, NY",
      "18 w 18th St., New York, NY",
      "New York, NY",
      "Empire State Building, New York, NY",
      "Guggenheim, New York",
      "Central Park Tennis Center, NY",
      "Flatiron Building, NY"
    ]
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


