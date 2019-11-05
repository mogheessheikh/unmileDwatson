//
//  OrderCompleteCell.swift
//  UnMile
//
//  Created by iMac  on 06/07/2019.
//  Copyright © 2019 Moghees Sheikh. All rights reserved.
//

import UIKit

class OrderCompleteCell: UITableViewCell {

    @IBOutlet weak var lblSurCharge: UILabel!
    @IBOutlet weak var lblOrderTime: UILabel!
    @IBOutlet weak var lblSubTotal: UILabel!
    @IBOutlet weak var lblDiscount: UILabel!
    @IBOutlet weak var lblGST: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblAmountValue: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
