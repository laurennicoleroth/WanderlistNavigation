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
  
  lazy var annotations : [WanderspotAnnotation] = []
  lazy var wanderspots : [Wanderspot] = []
  
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
  
  func setupMapUI() {
    mapView.showBlankCurrentLocation()
  }
}

extension CreateWanderlistViewController: GMSAutocompleteViewControllerDelegate {
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    
    let wanderspot = Wanderspot(place: place)
    wanderspot.addPhotoToWanderspot()
    mapView.addAnnotation(wanderspot.toAnnotation())
    
    dismiss(animated: true) {
      print("Add point to map")
    }
  }
  
  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    print("Error in gms autocomplete ", error)
  }
  
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    print("Autocomplet request was cancelled")
  }

}


