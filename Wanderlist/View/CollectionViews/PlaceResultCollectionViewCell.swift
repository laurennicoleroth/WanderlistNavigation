//
//  PlaceResultCollectionViewCell.swift
//  Wanderlist
//
//  Created by Lauren Nicole Roth on 3/18/19.
//  Copyright © 2019 Lauren Nicole Roth. All rights reserved.
//

import UIKit

class PlaceResultCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet var addressLabel: UILabel!
  

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
  
  func configureCellFrom(result: String) {
    print("Configuring from ", result)
    addressLabel.text = result
  }

}
