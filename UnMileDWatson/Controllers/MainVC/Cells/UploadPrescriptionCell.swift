//
//  UploadPrescriptionCell.swift
//  UnMile
//
//  Created by user on 1/3/20.
//  Copyright © 2020 Moghees Sheikh. All rights reserved.
//

import UIKit
protocol PrscriptionDelegate {
    func uploadPricriptionTapped(cell: UploadPrescriptionCell)
}
class UploadPrescriptionCell: UITableViewCell {

    var delegate :PrscriptionDelegate!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func didSelect(indexPath: NSIndexPath) {
        delegate.uploadPricriptionTapped(cell: self)
       }
    
    @IBAction func didTappedUploadPrescription(_ sender: Any) {
        delegate.uploadPricriptionTapped(cell: self)
    }
}
