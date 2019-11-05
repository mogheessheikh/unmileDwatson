//
//  ContactSupport.swift
//  UnMile
//
//  Created by iMac  on 02/07/2019.
//  Copyright © 2019 Adnan Asghar. All rights reserved.
//

import UIKit
protocol contactStaffDelegate {
    func didpressContactStaff(cell: ContactSupport)
}
class ContactSupport: UITableViewCell {

    @IBOutlet weak var lblSupport: UILabel!
    @IBOutlet weak var btnInfo: UIButton!
    var delegate:contactStaffDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func contactSupport(_ sender: Any) {
        delegate?.didpressContactStaff(cell: self)
    }
    
}
