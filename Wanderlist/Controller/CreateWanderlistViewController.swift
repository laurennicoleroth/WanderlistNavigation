//
//  CreateWanderlistViewController.swift
//  Wanderlist
//
//  Created by Lauren Nicole Roth on 3/14/19.
//  Copyright © 2019 Lauren Nicole Roth. All rights reserved.
//

import UIKit
import Mapbox

class CreateWanderlistViewController: UIViewController {

  @IBOutlet var mapView: WanderlistDetailMapboxMap!
  @IBOutlet var nextButton: UIButton!
  
  var annotations : [WanderspotAnnotation]?
  var places : [GMSPlace] = [] {
    didSet {
      print("Place added: ", places.last?.coordinate)
    }
  }
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
  }

  @IBAction func addButtonTouched(_ sender: Any) {
    let autocompleteController = GMSAutocompleteViewController()
    autocompleteController.delegate = self

    let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
      UInt(GMSPlaceField.placeID.rawValue))!
    autocompleteController.placeFields = fields

    present(autocompleteController, animated: true, completion: nil)
  }
  @IBAction func nextButtonTouched(_ sender: Any) {
    
  }
  
  func setupMapUI() {
    mapView.showCurrentLocation()
  }
}


