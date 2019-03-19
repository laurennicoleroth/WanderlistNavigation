//
//  WanderspotCollectionViewCell.swift
//  Wanderly
//
//  Created by Lauren Nicole Roth on 1/15/19.
//  Copyright © 2019 Lauren Nicole Roth. All rights reserved.
//

import UIKit

class WanderspotCollectionViewCell: UICollectionViewCell {

  @IBOutlet var titleLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  
  @IBOutlet weak var imageView: UIImageView!
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    imageView.setRounded()
  }

  func configureCellFrom(index: Int, wanderspot: Wanderspot) {
    titleLabel.text = "\(index + 1). \(wanderspot.name)"
    addressLabel.text = wanderspot.address
//    let distance = String(format: "%.2f miles first first stop.", wanderspot.distanceAway)
//
//    if wanderspot.distanceAway == 0.0 {
//      self.distanceLabel.text = "First stop"
//    } else {
//      self.distanceLabel.text = distance
//    }
//
//    let hours = wanderspot.getHoursForTodayFor(wanderspot)
//    self.hoursLabel.text = hours
  }

}
