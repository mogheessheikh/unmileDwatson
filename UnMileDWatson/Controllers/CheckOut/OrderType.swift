//
//  OrderType.swift
//  UnMile
//
//  Created by iMac on 01/04/2019.
//  Copyright © 2019 Adnan Asghar. All rights reserved.
//

import UIKit

protocol resizeOrderTypeDelegate {
    func didToggleOrderType(cell: OrderType?, String:String)
    
}

class OrderType: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderType.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) 
        cell.textLabel!.text = orderType[indexPath.row]
        cell.textLabel?.font = UIFont(name: "Bodoni 72", size: 15)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didToggleOrderType(cell: self, String: "\(orderType[indexPath.row])")
        selectOrderType.setTitle("\(orderType[indexPath.row])", for: .normal)
        animate(toogle: false)
        animate = false
    }

   
    @IBAction func selectOrderType(_ sender: Any) {
    }
    @IBOutlet weak var orderTypeTable: UITableView!
    @IBOutlet var selectOrderType: UIButton!
    var orderType : [String] = []
    var animate = false
    @IBOutlet var orderTypelbl: UILabel!
    var delegate: resizeOrderTypeDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectOrderType.layer.cornerRadius = 7
        orderTypeTable.delegate = self
        orderTypeTable.dataSource = self
        orderTypeTable.isScrollEnabled = true
        orderTypeTable.isHidden = true
        orderTypeTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func didPressOrderTypeRadioButton(_ sender: Any) {
        
        delegate?.didToggleOrderType(cell: self, String: "")
        if (orderTypeTable.isHidden){
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
            self.orderTypeTable.isHidden = false
        }
        }
        else{
            UIView.animate(withDuration: 0.3) {
                self.orderTypeTable.isHidden = true
            }
        }
    }
}

