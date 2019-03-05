//
//  ExploreMapViewController.swift
//  Wanderlist
//
//  Created by Lauren Nicole Roth on 3/5/19.
//  Copyright © 2019 Lauren Nicole Roth. All rights reserved.
//

import UIKit
import Mapbox

class ExploreMapViewController: UIViewController {
  
  @IBOutlet var mapView: WanderlistMapboxMap!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "WANDERLY"
    setupMapUI()
  }
 
  func setupMapUI() {
    mapView.showCurrentLocation()
    mapView.userTrackingMode = .followWithHeading
    mapView.showsUserHeadingIndicator = true
    mapView.delegate = self
  }
  
}

extension ExploreMapViewController: MGLMapViewDelegate {
  
  func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
    if annotation is MGLUserLocation && mapView.userLocation != nil {
//      return CustomUserLocationAnnotationView()
    }
    return nil
  }
  
  func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
    print("Did select annotation on map", annotation)
  }
  
  // Allow callout view to appear when an annotation is tapped.
  func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
    
    debugPrint("Annotation callout shown")
    return true
  }
 
  
}
