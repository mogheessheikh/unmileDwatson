//
//  SpecialInstruction.swift
//  UnMile
//
//  Created by iMac on 08/04/2019.
//  Copyright © 2019 Adnan Asghar. All rights reserved.
//

import UIKit
protocol TextFieldInSpecialInstructionDelegate{
    func textField(editingDidBeginIn cell:SpecialInstruction)
    func textField(editingChangedInTextField newText: String, in cell: SpecialInstruction)
}
class SpecialInstruction: UITableViewCell,UITextFieldDelegate {

    @IBOutlet var textField: UITextView!
      var delegate: TextFieldInSpecialInstructionDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
     
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func textDidEnd(_ sender: UITextField) {
        if let text = sender.text { delegate?.textField(editingChangedInTextField: text, in: self) }
    }
    
}
extension SpecialInstruction {
    @objc func didSelectCell() { textField?.becomeFirstResponder() }
    @objc func editingDidBegin() { delegate?.textField(editingDidBeginIn: self) }
    @objc func textFieldValueChanged(_ sender: UITextField) {
        if let text = sender.text { delegate?.textField(editingChangedInTextField: text, in: self) }
    }
}
