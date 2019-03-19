//
//  WanderlistPreviewViewController.swift
//  Wanderlist
//
//  Created by Lauren Nicole Roth on 3/8/19.
//  Copyright © 2019 Lauren Nicole Roth. All rights reserved.
//

import UIKit
import Mapbox
import SwiftLocation
import MMBannerLayout

class WanderlistPreviewViewController: UIViewController {

  @IBOutlet var mapView: WanderlistDetailMapboxMap!
  @IBOutlet var wanderspotsCollectionView: UICollectionView!

  var currentLocation: CLLocation?
  var selectedWanderspot: Wanderspot?
  var wanderspots: [Wanderspot] = [] {
    didSet {
      wanderspots = wanderspots.sorted(by: { $0.distanceAway < $1.distanceAway})
      wanderspotsCollectionView.reloadData()
      addAnnotationsToMap()
    }
  }
  var wanderlist: Wanderlist?

  override func viewDidLoad() {
    super.viewDidLoad()

    print("Wanderlist in preview: ", wanderlist?.title)

    setupWanderlist()

    mapView.showCurrentLocation()

    self.view.layoutIfNeeded()
    wanderspotsCollectionView.showsHorizontalScrollIndicator = false
    if let layout = wanderspotsCollectionView.collectionViewLayout as? MMBannerLayout {
      layout.itemSpace = 10
      layout.itemSize = self.wanderspotsCollectionView.frame.insetBy(dx: 40, dy: 40).size
      layout.minimuAlpha = 0.4
      layout.angle = 30.0
    }

    wanderspotsCollectionView.register(UINib(nibName: "WanderspotCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "WanderspotCollectionViewCell")
  }

  func setupWanderlist() {
    self.title = wanderlist?.title
    mapView.setCenter(CLLocationCoordinate2D(latitude: wanderlist?.latitude ?? 0.0, longitude: wanderlist?.longitude ?? 0.0), animated: true)

  }

  func setupData() {
//    if let wanderspots = wanderlist?.wanderspots.enumerated() {
//      for (index, spot) in wanderspots {
//        self.wanderspots.append(spot)
//      }
//    }
//    wanderspots = wanderspots.sorted(by: { $0.distanceAway ?? 0.0 < $1.distanceAway ?? 0.0 })

    wanderspotsCollectionView.reloadData()
    //    if let id = wanderlist?.objectID {
    //      Wanderlist.get(id) { (wanderlist, error) in
    //        var annotations = [MGLPointAnnotation]()
    //        if let spots = wanderlist?.wanderspots.enumerated() {
    //
    //          for (index, spot) in spots {
    //            self.wanderspots.append(spot)
    //          }
    //        }
    //      }
    //    }

  }

  func addAnnotationsToMap() {
    var coordinates = [CLLocationCoordinate2D]()
    var annotations = [MGLPointAnnotation]()

    for spot in self.wanderspots {
      let latitude = spot.latitude
      let longitude = spot.longitude

      let annotation = MGLPointAnnotation()
      let coordinate = CLLocationCoordinate2D(latitude: spot.latitude, longitude: spot.longitude)
      annotation.coordinate = coordinate
      coordinates.append(coordinate)
      self.mapView.addAnnotation(annotation)
    }

    self.mapView.setVisibleCoordinates(
      coordinates,
      count: UInt(coordinates.count),
      edgePadding: UIEdgeInsets(top: 20, left: 40, bottom: 100, right: 40),
      animated: true
    )
  }

}

extension WanderlistPreviewViewController: MGLMapViewDelegate {

  func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
    if annotation is MGLUserLocation && mapView.userLocation != nil {
      //      return CustomUserLocationAnnotationView()
    }
    return nil
  }

  func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
    if mapView.userTrackingMode != .followWithHeading {
      mapView.userTrackingMode = .followWithHeading
    } else {
      mapView.resetNorth()
    }

    // We're borrowing this method as a gesture recognizer, so reset selection state.
    mapView.deselectAnnotation(annotation, animated: false)
  }

  // Allow callout view to appear when an annotation is tapped.
  func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {

    debugPrint("Annotation callout shown")
    return true
  }

  func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
    //    if let annotation = annotation as? CustomPolyline {
    //      // Return orange if the polyline does not have a custom color.
    //      return annotation.color ?? .orange
    //    }

    // Fallback to the default tint color.
    return mapView.tintColor
  }

}

extension WanderlistPreviewViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return wanderspots.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let wanderspot = wanderspots[indexPath.row]
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WanderspotCollectionViewCell", for: indexPath) as! WanderspotCollectionViewCell
    cell.configureCellFrom(index: indexPath.row, wanderspot: wanderspot)
//    setPhotoOnCellForWanderspotID(cell: cell, id: wanderspot.placeID)
    cell.backgroundColor = .white
    return cell
  }

}

extension WanderlistPreviewViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    selectedWanderspot = wanderspots[indexPath.row]
    let storyboard = UIStoryboard(name: "Home", bundle: nil)
    //    let controller = storyboard.instantiateViewController(withIdentifier: "WanderlistPreviewViewController") as! WanderlistPreviewViewController
    ////    controller.wanderlist = wanderspots[indexPath.row]
    //    self.navigationController?.pushViewController(controller, animated: true)
  }
}

extension WanderlistPreviewViewController: BannerLayoutDelegate {
  func collectionView(_ collectionView: UICollectionView, focusAt indexPath: IndexPath) {
    let wanderspot = wanderspots[indexPath.row]
  }
}
