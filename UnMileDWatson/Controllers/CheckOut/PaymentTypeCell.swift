//
//  PaymentTypeCell.swift
//  UnMile
//
//  Created by iMac on 09/04/2019.
//  Copyright © 2019 Adnan Asghar. All rights reserved.
//

import UIKit

class PaymentTypeCell: UITableViewCell {
    @IBOutlet var radioButton: UIButton!
    @IBOutlet var lblPayment: UILabel!
    @IBOutlet var paymentLogo: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
