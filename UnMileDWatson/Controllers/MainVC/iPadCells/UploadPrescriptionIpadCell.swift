//
//  UploadPrescriptionIpadCell.swift
//  UnMile
//
//  Created by user on 4/3/20.
//  Copyright © 2020 Moghees Sheikh. All rights reserved.
//

import UIKit
protocol IPadPrscriptionDelegate {
    func uploadPricriptionTapped(cell: UploadPrescriptionIpadCell)
}
class UploadPrescriptionIpadCell: UITableViewCell {
var delegate :IPadPrscriptionDelegate!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func uploadPrescriptionTapped(_ sender: Any) {
        delegate.uploadPricriptionTapped(cell: self)
        
    }
}
