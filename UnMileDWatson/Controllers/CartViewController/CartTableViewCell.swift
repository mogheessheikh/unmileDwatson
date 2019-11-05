//
//  CartTableViewCell.swift
//  UnMile
//
//  Created by iMac on 04/03/2019.
//  Copyright © 2019 Adnan Asghar. All rights reserved.
//

import UIKit

protocol CartDelegate {
    func didTappedAddButton(cell: CartTableViewCell)
    func didTappedMinusButton(cell: CartTableViewCell)
    func didTappedDeleteButton(cell: CartTableViewCell)
}
class CartTableViewCell: UITableViewCell {

   
    @IBOutlet var ProductName: UILabel!
    @IBOutlet var Quantity: UILabel!
    @IBOutlet var ItemPrice: UILabel!
    @IBOutlet var TotalPrice: UILabel!
    @IBOutlet var SpecialInstruction: UILabel!
    @IBOutlet var ProductImage: UIImageView!
    
    @IBOutlet weak var btnDelete: UIButton!
    var delegate: CartDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func addQuantityTapped(_ sender: Any) {
        delegate?.didTappedAddButton(cell: self)
    }
    @IBAction func minusQuantityTapped(_ sender: Any) {
        
        delegate?.didTappedMinusButton(cell: self)
    }
    
    @IBAction func btnDeleteTapped(_ sender: Any) {
        delegate?.didTappedDeleteButton(cell: self)
    }
}
