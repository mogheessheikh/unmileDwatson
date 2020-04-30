//
//  InvoiceIpadCell.swift
//  UnMile
//
//  Created by user on 4/10/20.
//  Copyright © 2020 Moghees Sheikh. All rights reserved.
//

import UIKit

class InvoiceIpadCell: UITableViewCell {

    
    @IBOutlet weak var lblDiscount: UILabel!
    @IBOutlet weak var lblSurCharge: UILabel!
    @IBOutlet weak var lblGST: UILabel!
    @IBOutlet weak var lblAmountValue: UILabel!
    
    @IBOutlet weak var lblSubTotal: UILabel!
    @IBOutlet weak var lblOrderTime: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
