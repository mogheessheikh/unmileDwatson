//
//  PromoCodeCell.swift
//  UnMile
//
//  Created by iMac on 10/04/2019.
//  Copyright © 2019 Adnan Asghar. All rights reserved.
//

import UIKit

protocol PromoCodeDelegate {
    func didTappedVerificationButton()
    func textField(editingChangedInTextField newText: String, in cell: PromoCodeCell)
}

class PromoCodeCell: UITableViewCell {
    
    
    @IBOutlet var verifyButton: UIButton!
    @IBOutlet var promoTextField: UITextField!
    
    var delegate: PromoCodeDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func didtextEnter(_ sender: UITextField) {
        if let text = sender.text { delegate?.textField(editingChangedInTextField: text, in: self) }
    
    }
    
    @IBAction func verifyButtonTapped(_ sender: Any) {
        delegate?.didTappedVerificationButton()
    }
    
}
extension PromoCodeCell {
    @objc func didSelectCell() { promoTextField?.becomeFirstResponder() }
    @objc func textFieldValueChanged(_ sender: UITextField) {
        if let text = sender.text { delegate?.textField(editingChangedInTextField: text, in: self) }
    }
}
