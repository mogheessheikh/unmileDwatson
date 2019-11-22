//
//  AddressTableViewCell.swift
//  UnMile
//
//  Created by iMac on 10/05/2019.
//  Copyright © 2019 Adnan Asghar. All rights reserved.
//

import UIKit
protocol editAddressDelegate {
    func didTappedEdit(cell:AddressTableViewCell)
    func deleteButtonTapped(cell:AddressTableViewCell)
    
}
class AddressTableViewCell: UITableViewCell {

    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet var lblCityArea: UILabel!
    @IBOutlet var lblFullAddress: UILabel!
    @IBOutlet var btnAddEdit: UIButton!
    
    var delegate : editAddressDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func AddEditTapped(_ sender: Any) {
    delegate?.didTappedEdit(cell: self)
    }
    @IBAction func didTappedDelete(_ sender: Any) {
        delegate?.deleteButtonTapped(cell: self)
    }
    
}
