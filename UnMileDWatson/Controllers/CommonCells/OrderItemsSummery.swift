//
//  OrderItemsSummery.swift
//  UnMile
//
//  Created by iMac  on 02/07/2019.
//  Copyright © 2019 Adnan Asghar. All rights reserved.
//

import UIKit

class OrderItemsSummery: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customerOrderItems?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : OrderSummery = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! OrderSummery
        
        if (UIDevice.current.userInterfaceIdiom == .pad){
            cell.lblItemName.font = cell.lblItemName.font.withSize(25)
            cell.lblItemQuantity.font = cell.lblItemName.font.withSize(25)
            cell.lblItemPrice.font = cell.lblItemName.font.withSize(25)
        }
        
        if let urlString = customerOrderItems?[indexPath.row].product.productPhotoURL,
            let url = URL(string: urlString) {
            cell.productImg.af_setImage(withURL: url, placeholderImage: UIImage(), imageTransition: .crossDissolve(1), runImageTransitionIfCached: false)}
    
        cell.lblItemName.text = customerOrderItems?[indexPath.row].product.name
        cell.lblItemQuantity.text = "\(customerOrderItems?[indexPath.row].quantity ?? 0)"
        cell.lblItemPrice.text = "\(customerOrderItems![indexPath.row].purchaseSubTotal)"
        return cell
    }
   
    @IBOutlet weak var productImg: UIImageView!
    @IBOutlet weak var customerProductTable: UITableView!
    @IBOutlet weak var lblSummeryItemName: UILabel!
    @IBOutlet weak var lblSummeryItemQuantity: UILabel!
    @IBOutlet weak var lblSummeryItemPrice: UILabel!
    var customerOrderItems : [CustomerOrderItem]?
    override func awakeFromNib() {
        super.awakeFromNib()
        customerProductTable.delegate = self
        customerProductTable.dataSource = self
        customerProductTable.isScrollEnabled = true
        customerProductTable.isHidden = false
       customerProductTable.register(UINib(nibName: "OrderSummery", bundle: Bundle.main), forCellReuseIdentifier: "cell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
