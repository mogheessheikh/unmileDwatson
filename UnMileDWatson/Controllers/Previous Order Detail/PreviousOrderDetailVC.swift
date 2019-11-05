//
//  PreviousOrderDetailVC.swift
//  UnMile
//
//  Created by user on 10/18/19.
//  Copyright © 2019 Moghees Sheikh. All rights reserved.
//

import UIKit

class PreviousOrderDetailVC: BaseViewController {

    @IBOutlet weak var tblpreviousOrder: UITableView!
    var fetchingMore = false
    var customerObj: CustomerDetail!
    var preOrder: CustomerPreviousOrder!
    var singlePreOrder : CustomerOrder!
    var customerOrders: [CustomerOrder]?
    var customerOrderItems : [CustomerOrderItem]!
    var items : CustomerOrderItem?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let _ = getCustomerObject(keyForSavedCustomer){
             customerObj = getCustomerObject(keyForSavedCustomer)
        }
        else{
            showAlert(title: "Error", message: "You are not login")
        }
       
        getCustomerPreviousOrder(pageNo: "0", pageSize: "5", customerId: "\(3194)") //customerObj.id
        
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "orderDetail"){
            
            let vc = segue.destination as! OrderDetailVC
            vc.preOrder = self.singlePreOrder
            
        }
    }
    
    func getCustomerPreviousOrder(pageNo: String, pageSize: String , productName: String = "", customerId: String) {
        self.startActivityIndicator()
         UIApplication.shared.beginIgnoringInteractionEvents()
        let parameters: [String : Any] = ["pageNo":pageNo,
                                          "pageSize": pageSize,
                                          "customerId": customerId,
                                          "productName":productName]
        print(parameters)
        
        NetworkManager.getDetails(path: ProductionPath.customerOrderUrl + "/pagination", params: parameters, success: { (json, isError) in
            
            self.view.endEditing(true)
            
            do {
                let jsonData =  try json.rawData()
                print(jsonData)
                 self.preOrder = try JSONDecoder().decode(CustomerPreviousOrder.self, from: jsonData)
             
                
                if self.preOrder?.number == 0 {
                    self.customerOrders = self.preOrder.customerOrders
                } else {
                    self.customerOrders =  self.customerOrders! + self.preOrder.customerOrders
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                    self.tblpreviousOrder.reloadData()
                    
                    self.stopActivityIndicator()
                     UIApplication.shared.beginReceivingRemoteControlEvents()
                })
            } catch let myJSONError {
                print(myJSONError)
                self.showAlert(title: Strings.error, message: Strings.somethingWentWrong)
            }
            
        }) { (error) in
            //self.dismissHUD()
            self.showAlert(title: Strings.error, message: Strings.somethingWentWrong)
        }
    }
}


extension PreviousOrderDetailVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customerOrders?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! preOrderDetailCell
        cell.lblOrderDate.text = customerOrders?[indexPath.row].orderDate
        cell.lblOrderPrice.text = "RS: \(customerOrders?[indexPath.row].amount ?? 0.0)"
        cell.detailDelegate = self as? orderDetailDelegate
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.height {
            if !fetchingMore{
                if self.preOrder.hasNext {
                    getCustomerPreviousOrder(pageNo:"\((preOrder?.number)! + 1)", pageSize: "10", productName: "", customerId: "\(3194)")
                    
                }
                fetchingMore = true
            }
        }
    }
}


extension PreviousOrderDetailVC: orderDetailDelegate{
    func orderDetailPressed(cell: preOrderDetailCell) {
        let indexPath = self.tblpreviousOrder.indexPath(for: cell)
        singlePreOrder = customerOrders?[(indexPath?.row)!]
        performSegue(withIdentifier: "orderDetail", sender: self)
    }
    
    func repeatOrderPressed(cell: preOrderDetailCell) {
         let indexPath = self.tblpreviousOrder.indexPath(for: cell)
        var alreadyItems = getAlreadyCartItems()
       customerOrderItems = preOrder.customerOrders[(indexPath?.row)!].customerOrderItem
        for (_,j) in (customerOrderItems?.enumerated())!{
            
          items = CustomerOrderItem.init(id: 0, orderItemID: "" , forWho: "", instructions: j.instructions, quantity: j.quantity, purchaseSubTotal: j.purchaseSubTotal, product: j.product, customerOrderItemOptions: j.customerOrderItemOptions )
              alreadyItems.append(items!)
              saveItems(allItems: alreadyItems)
        }
    }
    
    
    
    
}


struct CustomerPreviousOrder: Codable{
    
    let  hasNext: Bool
    let  numberOfRecord: Int?
    let  totalRecord: Int?
    let  totalOrders: Int?
    let  totalPages: Int?
    let  number: Int?
    let  customerOrderWrapperList: CustomerOrderWrapper?
    let  customerOrders: [CustomerOrder]
}
enum CodingKeys: String, CodingKey {
    case hasNext,numberOfRecord,totalRecord,totalOrders,totalPages,number,customerOrderWrapperList,customerOrders
    
}
struct CustomerOrderWrapper: Codable {
    let     company: String
    let     branch: String
    let     customerOrder: CustomerOrder
}
