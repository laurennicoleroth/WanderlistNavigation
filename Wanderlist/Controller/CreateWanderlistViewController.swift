//
//  CreateWanderlistViewController.swift
//  Wanderlist
//
//  Created by Lauren Nicole Roth on 3/14/19.
//  Copyright © 2019 Lauren Nicole Roth. All rights reserved.
//

import UIKit
import GooglePlaces
import Mapbox

class CreateWanderlistViewController: UIViewController {
  @IBOutlet var mapView: WanderlistMapboxMap!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.showCurrentLocation()
    
  }
  
  
}


