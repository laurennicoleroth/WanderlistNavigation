//
//  UIImage_Extensions.swift
//  Wanderlist
//
//  Created by Lauren Nicole Roth on 3/19/19.
//  Copyright © 2019 Lauren Nicole Roth. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
  
  func setRounded() {
    self.layer.cornerRadius = (self.frame.width / 2)
    self.layer.masksToBounds = true
  }
}
