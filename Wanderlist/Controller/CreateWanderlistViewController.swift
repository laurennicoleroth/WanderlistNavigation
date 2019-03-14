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
  
  @IBAction func addButtonTouched(_ sender: Any) {
    let autocompleteController = GMSAutocompleteViewController()
    autocompleteController.delegate = self

    let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
      UInt(GMSPlaceField.placeID.rawValue))!
    autocompleteController.placeFields = fields

    let filter = GMSAutocompleteFilter()
    filter.type = .address
    autocompleteController.autocompleteFilter = filter

    present(autocompleteController, animated: true, completion: nil)
  }
}

extension CreateWanderlistViewController: GMSAutocompleteViewControllerDelegate {
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    print("Autocompleted place ", place)
  }
  
  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    print("Error in gms autocomplete ", error)
  }
  
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    print("Autocomplet request was cancelled")
  }

}


