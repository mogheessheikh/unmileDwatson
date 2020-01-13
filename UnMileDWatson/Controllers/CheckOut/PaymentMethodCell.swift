//
//  PaymentMethodCell.swift
//  UnMile
//
//  Created by iMac on 09/04/2019.
//  Copyright © 2019 Adnan Asghar. All rights reserved.
//

import UIKit

protocol radioButtonDelelgate {
    func didCheckRadioButton(cell: PaymentMethodCell?, String: String)
   
}
class PaymentMethodCell: UITableViewCell {
    
    
    


    @IBOutlet var lblPaymentMethod: UILabel!
    @IBOutlet var radioButton: UIButton!
    var delegate: radioButtonDelelgate?
    var animate = false
    var paymentType:[String] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
   
}
