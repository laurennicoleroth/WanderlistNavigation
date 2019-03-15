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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupMapUI()
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


