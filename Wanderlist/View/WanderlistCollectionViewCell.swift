//
//  WanderlistCollectionViewCell.swift
//  Wanderly
//
//  Created by Lauren Nicole Roth on 2/21/19.
//  Copyright © 2019 Lauren Nicole Roth. All rights reserved.
//

import UIKit

class WanderlistCollectionViewCell: UICollectionViewCell {

  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var aboutLabel: UILabel!
  @IBOutlet var countLabel: UILabel!
  @IBOutlet var categoriesLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    let shadowPath = UIBezierPath(rect: self.bounds)
    self.layer.masksToBounds = false
    self.layer.shadowColor = UIColor.black.cgColor
    self.layer.shadowOffset = CGSize(width: 0, height: 0.1)
    self.layer.shadowOpacity = 0.2
    self.layer.shadowPath = shadowPath.cgPath
  }
  
  func configureCellFrom(wanderlist: Wanderlist) {

    titleLabel.text = wanderlist.title
    let count = wanderlist.spotsCount
//    countLabel.text = "\(count) spots"
    aboutLabel.text = wanderlist.about
//    categoriesLabel.text = wanderlist.categories?.joined(separator: ", ")

  }

  
  func prepareView() {
    self.contentView.layer.cornerRadius = 2.0
    self.contentView.layer.borderWidth = 1.0
    self.contentView.layer.borderColor = UIColor.clear.cgColor
    self.contentView.layer.masksToBounds = true
    
    self.layer.shadowColor = UIColor.black.cgColor
    self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
    self.layer.shadowRadius = 2.0
    self.layer.shadowOpacity = 0.5
    self.layer.masksToBounds = false
    self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
  }
  
  func addDropShadow() {
    self.contentView.layer.cornerRadius = 2.0
    self.contentView.layer.borderWidth = 1.0
    self.contentView.layer.borderColor = UIColor.clear.cgColor
    self.contentView.layer.masksToBounds = true
    self.layer.shadowColor = UIColor.black.cgColor
    self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
    self.layer.shadowRadius = 2.0
    self.layer.shadowOpacity = 1.0
    self.layer.masksToBounds = false
    self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
  }

}
