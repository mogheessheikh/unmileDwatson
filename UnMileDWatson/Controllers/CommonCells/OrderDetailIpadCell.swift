//
//  OrderDetailIpadCell.swift
//  UnMile
//
//  Created by user on 4/10/20.
//  Copyright © 2020 Moghees Sheikh. All rights reserved.
//

import UIKit

class OrderDetailIpadCell: UITableViewCell {

    @IBOutlet weak var lblInstructions: UILabel!
    @IBOutlet weak var lblDeliveryTime: UILabel!
    @IBOutlet weak var lblPaymentType: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
