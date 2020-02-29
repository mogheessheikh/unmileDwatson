//
//  productNameCategoryCell.swift
//  UnMile
//
//  Created by user on 9/3/19.
//  Copyright © 2019 Moghees Sheikh. All rights reserved.
//

import UIKit

protocol detailDescriptionDelegate {
    func didPressedDetailDescription(cell: productNameCategoryCell)
}

class productNameCategoryCell: UITableViewCell {

    @IBOutlet weak var detailDescriptionBtn: UIButton!
    @IBOutlet weak var subview1: UIView!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var subview2: UIView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var productName: UILabel!
    var delegate : detailDescriptionDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func detailDescriptionPressed(_ sender: Any) {
        delegate?.didPressedDetailDescription(cell: self)
        
    }
}
