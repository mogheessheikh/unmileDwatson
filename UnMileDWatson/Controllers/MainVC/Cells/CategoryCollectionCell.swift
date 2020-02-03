//
//  CategoryCollectionCell.swift
//  UnMile
//
//  Created by user on 1/3/20.
//  Copyright © 2020 Moghees Sheikh. All rights reserved.
//

import UIKit
protocol CategoryCellDelegate {
    func callSegueFromCell(cell:CategoryTableViewCell, id: Int)
}
class CategoryCollectionCell: UICollectionViewCell {
    @IBOutlet weak var categoryLabel: UILabel!
      @IBOutlet weak var popularImg: UIImageView!
    
    var delegate:CategoryCellDelegate!
}
