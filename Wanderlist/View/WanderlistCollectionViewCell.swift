//
//  WanderlistCollectionViewCell.swift
//  Wanderly
//
//  Created by Lauren Nicole Roth on 2/21/19.
//  Copyright © 2019 Lauren Nicole Roth. All rights reserved.
//

import UIKit

protocol WanderlistCollectionViewCellDelegate {
  func favoriteButtonTouched(indexPath: IndexPath)
}

class WanderlistCollectionViewCell: UICollectionViewCell {

  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var statsLabel: UILabel!
  @IBOutlet var aboutLabel: UILabel!
  @IBOutlet var imageView: UIImageView!
  @IBOutlet var favoriteButton: UIButton!

  var delegate : WanderlistCollectionViewCellDelegate?
  var wanderlist : Wanderlist?
  public var indexPath: IndexPath!
  
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
    self.wanderlist = wanderlist
    titleLabel.text = wanderlist.title.uppercased()
    aboutLabel.text = wanderlist.about
    let count = wanderlist.spotsCount

    
    if count == 1 {
      
    } else {
 
    }


  }
  
  @IBAction func favoriteButtonTouched(_ sender: UIButton) {
    if let wanderlist = self.wanderlist {
      print("Favorite button touched ", wanderlist)
      delegate?.favoriteButtonTouched(indexPath: indexPath)
    }
    
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
