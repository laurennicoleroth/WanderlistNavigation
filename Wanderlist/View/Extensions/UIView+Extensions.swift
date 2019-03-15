//
//  UIView+Extensions.swift
//  Wanderlist
//
//  Created by Lauren Nicole Roth on 3/13/19.
//  Copyright © 2019 Lauren Nicole Roth. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedView: UIView {

  @IBInspectable var borderColor: UIColor = UIColor.white {
    didSet {
      self.layer.borderColor = borderColor.cgColor
    }
  }

  @IBInspectable var borderWidth: CGFloat = 2.0 {
    didSet {
      self.layer.borderWidth = borderWidth
    }
  }

  @IBInspectable var cornerRadius: CGFloat = 0.0 {
    didSet {
      self.layer.cornerRadius = cornerRadius
    }
  }

}
