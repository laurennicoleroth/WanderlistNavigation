//
//  EditWanderspotsViewController.swift
//  Wanderlist
//
//  Created by Lauren Nicole Roth on 3/15/19.
//  Copyright © 2019 Lauren Nicole Roth. All rights reserved.
//

import UIKit

class EditWanderspotsViewController: UIViewController {
  
  var wanderlist : Wanderlist?
  var wanderspots : [Wanderspot] = []
  
  @IBOutlet var wanderspotsCollection: UICollectionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if wanderspots.count > 0 {
       wanderspotsCollection.reloadData()
    }
   
    wanderspotsCollection.register(UINib(nibName: "WanderspotCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "WanderspotCollectionViewCell")
  }
  
  func nextButtonTouched() {
    let storyboard = UIStoryboard(name: "Create", bundle: nil)
    let controller = storyboard.instantiateViewController(withIdentifier: "EditWanderspotsViewController") as! EditWanderspotsViewController
    controller.wanderspots = wanderspots
    self.navigationController?.pushViewController(controller, animated: true)
  }
}

extension EditWanderspotsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return wanderspots.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WanderspotCollectionViewCell", for: indexPath) as! WanderspotCollectionViewCell
//    cell.configureCellFrom(index: indexPath.row, wanderspot: wanderspots[indexPath.row])
    return cell
  }

}
