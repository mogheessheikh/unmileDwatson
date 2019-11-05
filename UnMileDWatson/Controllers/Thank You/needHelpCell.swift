//
//  needHelpCell.swift
//  UnMile
//
//  Created by user on 11/3/19.
//  Copyright © 2019 Moghees Sheikh. All rights reserved.
//

import UIKit
protocol NeedSupportDelegate {
    func didToggleNeedSupport(cell: needHelpCell)
}
class needHelpCell: UITableViewCell {

    @IBOutlet weak var lblTotalPrice: UILabel!
    @IBOutlet weak var btnNeedSupport: UIButton!
    var delegate: NeedSupportDelegate!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func didPressNeedSupport(_ sender: Any) {
        delegate.didToggleNeedSupport(cell: self)
    }
}
