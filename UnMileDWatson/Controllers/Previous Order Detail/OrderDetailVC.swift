//
//  OrderDetailVC.swift
//  UnMile
//
//  Created by user on 10/19/19.
//  Copyright © 2019 Moghees Sheikh. All rights reserved.
//

import UIKit


class OrderDetailVC: BaseViewController {

    @IBOutlet weak var tblOrderDetail: UITableView!
    var sectionTitle = ["PREVIOUS ORDER","Route","Order Summery","Detail","Contact Support"]
    var sectionOneArrayTitle:[String?] = ["Sub Total","Sur Charge","GST","Discount","Order Number", "Order Time"]
    var routeLogo: UIImage =  UIImage(named: "location1")!
    var route: String!
    var itemSummery : [CustomerOrderItem]!
     var sectionOneArrayValue:[String]!
    var preOrder : CustomerOrder!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tblOrderDetail.register(UINib(nibName: "Route", bundle: Bundle.main), forCellReuseIdentifier: "routecell")
        tblOrderDetail.register(UINib(nibName: "OrderItemsSummery", bundle: Bundle.main), forCellReuseIdentifier: "itemcell")
        tblOrderDetail.register(UINib(nibName: "OrderDetail", bundle: Bundle.main), forCellReuseIdentifier: "detailcell")
        tblOrderDetail.register(UINib(nibName: "ContactSupport", bundle: Bundle.main), forCellReuseIdentifier: "contactcell")
        
//         ["10", "10", "10","10","10","10"]
        
        sectionOneArrayValue = ["\(preOrder.subTotal)","\(round(preOrder.surCharge!))","\(round(0.0))","\(round(preOrder.orderDiscount! ))","\(preOrder.id)","\(preOrder.orderDate)"]
        route = "\(preOrder.customerOrderAddress.customerOrderAddressFields[0].fieldValue + preOrder.customerOrderAddress.customerOrderAddressFields[1].fieldValue + preOrder.customerOrderAddress.customerOrderAddressFields[2].fieldValue + preOrder.customerOrderAddress.customerOrderAddressFields[3].fieldValue)"
    
        itemSummery = preOrder.customerOrderItem
    }
    


}
extension OrderDetailVC : UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitle.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0)
        {
            return sectionOneArrayTitle.count
            
        }
        else if(section == 1)
        {
            return 1
        }
        else if(section == 2)
        {
           return 1
        }
        else{return 1}
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 2 && indexPath.row == 1 || indexPath.section == 3)
        {
            return 100
        }
        else {return 60}
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0
        {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as? detailOrderCell
                else {
                    fatalError("Unknown cell")
            }
            cell.lblName.text = sectionOneArrayTitle[indexPath.row]
            cell.lblAmount.text = sectionOneArrayValue[indexPath.row]
            return cell
        }
            
        else if(indexPath.section == 1) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "routecell", for: indexPath) as? Route
                else {
                    fatalError("Unknown cell")
            }
            cell.imgRoute.image = routeLogo
            cell.lblRoute.text = route
            return cell
        }
        else if (indexPath.section == 2){
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemcell", for: indexPath) as? OrderItemsSummery
                else {
                    fatalError("Unknown cell")
            }
           
            cell.customerOrderItems = itemSummery
            
            return cell
        }
        else if (indexPath.section == 3) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "detailcell", for: indexPath) as? OrderDetail
                else {
                    fatalError("Unknown cell")
            }
            
            cell.lblPaymentType.text =  preOrder.paymentType
            cell.lblInstruction.text = "\(preOrder.specialInstructions)"
            cell.lblDeliveryTime.text = "minimum 50-75 mints"
            return cell
        }
        else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "contactcell", for: indexPath) as? ContactSupport
                else {
                    fatalError("Unknown cell")
            }
            cell.lblSupport.text = "For Any Qurrey or complain contact to our support Staff"
            
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 4) {
            
            makeAPhoneCall()
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.frame = CGRect(x: 100, y: 5, width: 200, height: 50)
        headerView.backgroundColor =  UIColor.initWithHex(hex: "87cefa")
        let label = UILabel()
        label.frame = CGRect(x: tableView.bounds.size.width / 3  , y: 13, width: tableView.bounds.size.width - 10, height: 24)
        if section == 0 {
            label.font = UIFont.boldSystemFont(ofSize: 12.0)
        }
        
        
        if section == 0{
            let imageView = UIImageView(frame: CGRect(x: 5, y: 8, width: 40, height: 40))
            if let savedBranch = UserDefaults.standard.object(forKey: "SavedBranch") as? Data  {
                let decoder = JSONDecoder()
                if let loadedBranch = try? decoder.decode(BranchWrapperAppList.self, from: savedBranch) {
                    if let urlString = loadedBranch.locationWebLogoURL,
                        
                        let url = URL(string: urlString) {
                        imageView.af_setImage(withURL: url, placeholderImage: UIImage(), imageTransition: .crossDissolve(1), runImageTransitionIfCached: false)
                        label.text = loadedBranch.name
                    }
                    
                    headerView.addSubview(imageView)
                    headerView.addSubview(label)
                }
            }
        }
        else{
            label.text = sectionTitle[section]
            headerView.addSubview(label)
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0{
            
            let footerView = UIView()
            footerView.frame = CGRect(x: 100, y: 150, width: 200, height: 50)
            let label = UILabel()
            label.frame = CGRect(x: 14  , y: 0, width: tableView.bounds.size.width - 10, height: 24)
            label.text = "Delivery Time"
            footerView.addSubview(label)
            let imageView = UIImageView(frame: CGRect(x: tableView.bounds.size.width / 3 , y: 0, width: 25, height: 25))
            let image = UIImage(named: "scooter")
            imageView.image = image
            let label2 = UILabel()
            label2.frame = CGRect(x: (tableView.bounds.size.width / 3) + 30  , y: 0, width: tableView.bounds.size.width - 10, height: 24)
            label2.text = "ASAP 55 Mints"
            label2.textColor = UIColor.orange
            footerView.addSubview(label2)
            footerView.addSubview(imageView)
            return footerView
        }
        else {return nil}
        
}
}
