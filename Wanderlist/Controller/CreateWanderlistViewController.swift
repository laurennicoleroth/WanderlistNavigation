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


