//
//  orderDetailCell.swift
//  UnMile
//
//  Created by user on 11/3/19.
//  Copyright © 2019 Moghees Sheikh. All rights reserved.
//

import UIKit

class orderDetailCell: UITableViewCell {

    @IBOutlet weak var lblCustomerAddress: UILabel!
    @IBOutlet weak var lblOrderNumber: UILabel!
    @IBOutlet weak var lblBranchAddress: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
