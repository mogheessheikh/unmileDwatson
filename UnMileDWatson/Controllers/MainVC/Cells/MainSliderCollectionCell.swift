//
//  MainSliderCollectionCell.swift
//  UnMile
//
//  Created by user on 1/3/20.
//  Copyright © 2020 Moghees Sheikh. All rights reserved.
//

import UIKit

class MainSliderCollectionCell: UICollectionViewCell {
    @IBOutlet weak var sliderImg: UIImageView!
    override func awakeFromNib() {
         super.awakeFromNib()
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
         
         NSLayoutConstraint.activate([
             contentView.leftAnchor.constraint(equalTo: leftAnchor),
             contentView.rightAnchor.constraint(equalTo: rightAnchor),
             contentView.topAnchor.constraint(equalTo: topAnchor),
             contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
         ])
     } 
}
