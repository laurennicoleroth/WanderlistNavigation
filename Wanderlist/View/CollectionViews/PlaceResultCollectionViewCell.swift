//
//  PlaceResultCollectionViewCell.swift
//  Wanderlist
//
//  Created by Lauren Nicole Roth on 3/18/19.
//  Copyright © 2019 Lauren Nicole Roth. All rights reserved.
//

import UIKit
import Mapbox
import MapboxGeocoder

class PlaceResultCollectionViewCell: UICollectionViewCell {

  @IBOutlet weak var addressLabel: UILabel!
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
  
  func configureCellFrom(result: Placemark) {
    print("Configuring from ", result.qualifiedName )
    print(addressLabel)
    addressLabel.text = result.qualifiedName
  }


}
