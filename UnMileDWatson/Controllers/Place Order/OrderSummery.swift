//
//  OrderSummery.swift
//  UnMile
//
//  Created by iMac  on 06/07/2019.
//  Copyright © 2019 Moghees Sheikh. All rights reserved.
//

import UIKit

class OrderSummery: UITableViewCell {

    @IBOutlet weak var productImg: UIImageView!
    @IBOutlet weak var lblItemName: UILabel!
    @IBOutlet weak var lblItemQuantity: UILabel!
    @IBOutlet weak var lblItemPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
