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
class PaymentMethodCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentType.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UITableViewCell
        cell.textLabel!.text = paymentType[indexPath.row]
        cell.textLabel?.font = UIFont(name: "Bodoni 72", size: 15)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didCheckRadioButton(cell: self, String: "\(paymentType[indexPath.row])")
        radioButton.setTitle("\(paymentType[indexPath.row])", for: .normal)
        animate(toogle: false)
        animate = false
    }


    @IBOutlet weak var paymentTypeTable: UITableView!
    @IBOutlet var logo: UIImageView!
    @IBOutlet var lblPaymentMethod: UILabel!
    @IBOutlet var radioButton: UIButton!
    var delegate: radioButtonDelelgate?
    var animate = false
    var paymentType:[String] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        radioButton.layer.cornerRadius = 7
        paymentTypeTable.delegate = self
        paymentTypeTable.dataSource = self
        paymentTypeTable.isScrollEnabled = true
        paymentTypeTable.isHidden = true
        paymentTypeTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func radioButtonPressed(_ sender: Any) {
        delegate?.didCheckRadioButton(cell: self, String: "")
        if (paymentTypeTable.isHidden){
            animate(toogle: true)
            animate = true
        }
        else{
            animate(toogle: false)
            animate = false
        }
    }
    
    func animate(toogle: Bool) {
        if (toogle){
            UIView.animate(withDuration: 0.3) {
                self.paymentTypeTable.isHidden = false
            }
        }
        else{
            UIView.animate(withDuration: 0.3) {
                self.paymentTypeTable.isHidden = true
            }
        }
    }
}
