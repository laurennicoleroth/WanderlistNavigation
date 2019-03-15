//
//  WanderspotAnnotation.swift
//  Wanderlist
//
//  Created by Lauren Nicole Roth on 3/14/19.
//  Copyright © 2019 Lauren Nicole Roth. All rights reserved.
//

import Foundation
import Mapbox

class WanderspotAnnotation: NSObject, MGLAnnotation {
  var coordinate: CLLocationCoordinate2D
  var title: String?
  var subtitle: String?
  
  var image: UIImage?
  var reuseIdentifier: String?
  
  init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
    self.coordinate = coordinate
    self.title = title
    self.subtitle = subtitle
  }
}
