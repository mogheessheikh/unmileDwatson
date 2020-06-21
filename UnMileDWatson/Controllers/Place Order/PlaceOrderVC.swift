//
//  PlaceOrderVC.swift
//  UnMile
//
//  Created by iMac on 20/04/2019.
//  Copyright © 2019 Adnan Asghar. All rights reserved.
//

import UIKit
import Alamofire
class PlaceOrderVC: BaseViewController {
    
    @IBOutlet weak var tblOrderSummery: UITableView!
    @IBOutlet weak var btnPlacedOrder: UIButton!
    
    var customerOrder: CustomerOrder!
    var customer: CustomerOrder!
    var OrderItem : [CustomerOrderItem]!
    var orderProduct : CustomerOrderItem!
    var instructions = ""
    var itemID = ""
    var finalsubTotal = 0.0
    var quantity = 0
    var selectedAddress : CustomerOrderAddress!
    var branch: Branch!
    var branchWrapper : BranchWrapperAppList!
    var surCharges = 0.0
    var sectionTitle = ["","Route","Order Summery","Detail","Contact Support"]
    
    
    var routeLogo: [UIImage] = [UIImage(named: "restaurant")! , UIImage(named: "location1")!]
    var routeArray:[String]!
    var restuarentAddress: String!
    var itemSummery : [CustomerOrderItem]!
    var paymentMethod : [PaymentMethod]!
    var customerOrderTax : [CustomerOrderTax]!
    var company: CompanyDetails!
    var orderDiscount = 0.0
    var taxAmount = 0.0
    var imagePath = ""
    var promoCodeMatch = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        btnPlacedOrder.layer.cornerRadius = 7
        tblOrderSummery.rowHeight = UITableView.automaticDimension
        tblOrderSummery.estimatedRowHeight = UITableView.automaticDimension
        print(customerOrder.branchID)
        company  = getCompanyObject("SavedCompany")
        
        itemSummery = getAlreadyCartItems()
        if let savedBranch = UserDefaults.standard.object(forKey: keyForSavedBranch) as? Data  {
            let decoder = JSONDecoder()
            self.branch = try? decoder.decode(Branch.self, from: savedBranch)
            
            restuarentAddress  = branch.addressLine1
            paymentMethod = branch.paymentMethods
            
        }
        
        
        selectedAddress = customerOrder.customerOrderAddress
        
        taxAmount = calculateTaxes(restbranch: branch, customerOrder: customerOrder)
        surCharges = chargeSurcharge(customerOrder:customerOrder, paymentMethod: paymentMethod)
        
        if promoCodeMatch == ""{
            orderDiscount = calculateDiscounts(branch: branch, customerOrder: customerOrder)
        }
        else{
            
            orderDiscount = calculatePromoCodeDiscount(branch: branch, customerOrder: customerOrder)
        }
        
        finalsubTotal = round(customerOrder.subTotal + customerOrder.deliveryCharge + taxAmount - orderDiscount)
        
        
        var customerAddress = ""
        
        for fields in selectedAddress!.customerOrderAddressFields{
            customerAddress += "  \(fields.fieldValue)"
        }
        
        routeArray = [restuarentAddress,"\(customerAddress)"]
        
        tblOrderSummery.register(UINib(nibName: "Route", bundle: Bundle.main), forCellReuseIdentifier: "routecell")
        tblOrderSummery.register(UINib(nibName: "InvoiceIpadCell", bundle: Bundle.main), forCellReuseIdentifier: "InvoiceIpadCell")
        
        tblOrderSummery.register(UINib(nibName: "OrderDetailIpadCell", bundle: Bundle.main), forCellReuseIdentifier: "OrderDetailIpadCell")
        tblOrderSummery.register(UINib(nibName: "OrderItemsSummery", bundle: Bundle.main), forCellReuseIdentifier: "itemcell")
        tblOrderSummery.register(UINib(nibName: "OrderDetail", bundle: Bundle.main), forCellReuseIdentifier: "detailcell")
        tblOrderSummery.register(UINib(nibName: "ContactSupport", bundle: Bundle.main), forCellReuseIdentifier: "contactcell")
        
    }
    
    
    
    
    @IBAction func tappedToPlaceOrder(_ sender: Any) {
        
        startActivityIndicator()
        
        if let filePath = UserDefaults.standard.string(forKey: keyForFilePath){
            imagePath = filePath
        }
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        // customerOrder.customerOrderItem conversion into json data
        
        let customerAddress = try! JSONEncoder().encode(selectedAddress.customerOrderAddressFields) //Data
        let customerAddressArray = try! JSONSerialization.jsonObject(with: customerAddress, options: []) as! Array<Dictionary<String, Any>>
               
               let adjustedCustomerAddressArray = NSMutableArray.init()
               
               for aDict in customerAddressArray{
                   let newObj = NSMutableDictionary.init()
                   
                   newObj["fieldName"] = aDict["fieldName"]
                   newObj["fieldValue"] = aDict["fieldValue"]
                   newObj["label"] = aDict["label"]
                   
                   adjustedCustomerAddressArray.add(newObj)
                   
               }
               print(adjustedCustomerAddressArray)
        
        
        
        let jsonData = try! JSONEncoder().encode(customerOrder.customerOrderItem) //Data
        let jsonArray = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! Array<Dictionary<String, Any>>
        
        let adjustedCustomerOrderItemArray = NSMutableArray.init()
        
        for aDict in jsonArray{
            let newObj = NSMutableDictionary.init()
            
            newObj["customerOrderItemOptions"] = aDict["customerOrderItemOptions"]
            newObj["instructions"] = aDict["instructions"]
            newObj["orderItemId"] = aDict["orderItemId"]
            newObj["forWho"] = aDict["forWho"]
            newObj["product"] = aDict["product"]
            newObj["purchaseSubTotal"] = aDict["purchaseSubTotal"]
            newObj["quantity"] = aDict["quantity"]
            newObj["productPrice"] = aDict["productPrice"]
            newObj["discount"] = aDict["discount"]
            
            adjustedCustomerOrderItemArray.add(newObj)
            
        }
        print(adjustedCustomerOrderItemArray)
        let jsontaxData = try! JSONEncoder().encode(customerOrderTax) //Data
        let jsontaxArray = try! JSONSerialization.jsonObject(with: jsontaxData, options: []) as! Array<Dictionary<String, Any>>
        
        let adjustedJsontaxArray = NSMutableArray.init()
        
        for aDict in jsontaxArray{
            let newObj = NSMutableDictionary.init()
            newObj["orderType"] = aDict["orderType"]
            newObj["taxRule"] = aDict["taxRule"]
            newObj["taxLabel"] = aDict["taxLabel"]
            newObj["rate"] = aDict["rate"]
            newObj["taxAmount"] = aDict["taxAmount"]
            newObj["chargeMode"] = aDict["chargeMode"]
            
            adjustedJsontaxArray.add(newObj)
            
        }
        print(adjustedJsontaxArray)
        let postString = [
            "ipAddress": customerOrder.ipAddress,
            "billingStatus":"\(customerOrder.billingStatus!)",
            "branchId":"\(customerOrder.branchID)",
            "creditStatus":"\(customerOrder.creditStatus)",
            "customerFirstName":"\(customerOrder.customerFirstName)",
            "customerId": "\(customerOrder.customerID)",
            "customerLastName":"\(customerOrder.customerLastName)",
            "customerOrderAddress":["customerOrderAddressFields": adjustedCustomerAddressArray],
            "customerOrderItem": adjustedCustomerOrderItemArray,
            "customerOrderTaxes": adjustedJsontaxArray,
            "customerPhone":"\(customerOrder.customerPhone)",
            "customerType":"\(customerOrder.customerType)",
            "deliveryCharge":"\(customerOrder.deliveryCharge)",
            "firstCustomerOrder":true,
            "orderConfirmationStatus":"PENDING",
            "orderConfirmationStatusMessage":"",
            "orderDate": customerOrder.orderDate,
            "orderDiscount": orderDiscount,
            "orderStatus":"PENDING",
            "orderTime":"ASAP (Around 75 Minutes)",
            "orderType": customerOrder.orderType,
            "paymentType": customerOrder.paymentType,
            "phoneNotify":false,
            "sendFax":false,
            "sendSms":true,
            "specialInstructions":"\(customerOrder.specialInstructions)",
            "subTotal": "\(finalsubTotal)",
            "amount": "\(customerOrder.subTotal)",
            "transId":"\(customerOrder.transID)",
            "surCharge": surCharges,
            "userAgent": "iPhone",
            "attachment1":"\(imagePath)",
            "attachment2":"",
            "bankDetail":"",
            "companyId": customerOrder.companyID
            ] as [String : Any]
        
        print(postString )
        
        guard let url = URL(string: ProductionPath.customerOrderUrl + "/create") else { return }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = postString as? [String : String]
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        do {
            
            let jsoncheck =  try JSONSerialization.data(withJSONObject: postString , options: .prettyPrinted)
            request.httpBody = try JSONSerialization.data(withJSONObject: postString , options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            showAlert(title: "Alert", message: "Something went wrong. Try again.")
            return
        }
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil
            {
                self.showAlert(title: "Request Error", message: "Could not successfully perform this request. Please try again later")
                
                print("error=\(String(describing: error))")
                return
            }
            
            // Let's convert response sent from a server side code to a NSDictionary object:
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                if let parseJSON = json {
                    
                    let jsonData = try JSONSerialization.data(withJSONObject: parseJSON, options: .prettyPrinted)
                    let encodedObjectJsonString = String(data: jsonData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
                    let jsonData1 = encodedObjectJsonString.data(using: .utf8)
                    let customerOrder = try JSONDecoder().decode(CustomerOrder.self, from: jsonData1!)
                    self.sendOrderDetailToSender(customerOrder: customerOrder)
                    DispatchQueue.main.async {
                        self.stopActivityIndicator()
                        UIApplication.shared.endIgnoringInteractionEvents()
                //self.orderPlaceAlert(title: "Order Placed", message: "Your Order is PLACED")
                        self.saveCustomerOrder(obj: customerOrder, key: "savedCustomerOrder" )
                    
//                    let alreadyItems = NSMutableArray.init(array: self.getAlreadyCartItems())
//                    if (alreadyItems.count != 0){
//                    alreadyItems.removeAllObjects()
//                    self.saveItems(allItems: alreadyItems as! [CustomerOrderItem])
//                    }
                        let vc : UIViewController = Storyboard.main.instantiateViewController(withIdentifier: "ThankYouVC") as! ThankYouVC
                        self.present(vc, animated: true, completion: nil)
                        
                        print(self.customerOrder.amount)
                    }
                    
                }
                else {
                    
                    //Display an Alert dialog with a friendly error message
                    self.showAlert(title: "Request Error", message: "Could not successfully perform this request. Please try again later")
                    
                }
            } catch {
                
                // self.removeActivityIndicator(activityIndicator: myActivityIndicator)
                
                // Display an Alert dialog with a friendly error message
                self.showAlert(title: "Request Error", message: "Could not successfully perform this request. Please try again later")
                
                print(error)
            }
        }
        
        task.resume()
    }
    
    func  chargeSurcharge(customerOrder: CustomerOrder,  paymentMethod: [PaymentMethod])-> Double {
        
        for paymentmethod:PaymentMethod in paymentMethod{
            
            if(customerOrder.paymentType ==  paymentmethod.paymentType.name) {
                
                if(paymentmethod.chargeMode!.id == 1) {
                    surCharges = paymentmethod.charge!
                }
                    
                else if (paymentmethod.chargeMode!.id == 2){
                    
                    surCharges = (customerOrder.subTotal * paymentmethod.charge!)
                }
                
            }
        }
        
        return surCharges
        
    }
    
    func calculateTaxes(restbranch: Branch, customerOrder: CustomerOrder) -> Double{
        
        if (!branch.taxes.isEmpty) {
            var taxRule = ""
            var taxLabel = ""
            var rate = 0.0
            var ChargeMode = 0
            
            
            for  tax:Tax  in restbranch.taxes {
                
                if (tax.orderType.name == customerOrder.orderType) || (tax.orderType.name == "\(OrderType.self)") {
                    
                    if (tax.taxRule ==  tax.taxRule) {
                        if (tax.chargeMode.id == 2 /** percentage */) {
                            taxAmount = (customerOrder.subTotal * tax.rate)
                        }
                    }
                        
                    else if  (tax.chargeMode.id == 1 /** fixed */) {
                        taxAmount = tax.rate
                    }
                    else {
                        
                        taxAmount = 0.0
                    }
                    taxRule = tax.taxRule
                    taxLabel = tax.taxLabel
                    rate = tax.rate
                    taxAmount += taxAmount
                    ChargeMode = tax.chargeMode.id
                }
            }
            customerOrderTax = [CustomerOrderTax.init(id: 1, orderType: customerOrder.orderType, taxRule: taxRule , taxLabel: taxLabel, rate: rate, taxAmount: taxAmount, chargeMode: ChargeMode)]
        }
        else {
            
            customerOrderTax = [CustomerOrderTax.init(id: 0, orderType: "", taxRule: "", taxLabel: "", rate: 0.0, taxAmount: 0, chargeMode: 0)]
        }
        
        return taxAmount
    }
    
    func calculatePromoCodeDiscount(branch: Branch,  customerOrder: CustomerOrder)-> Double{
        var discountAmount = 0.0
        for promo: PromoCodeDiscountRule in branch.promoCodeDiscountRules{
            
            if(promo.orderType.name == customerOrder.orderType && promo.status == 1 && promo.paymentType.name == customerOrder.paymentType ){
                
                discountAmount  = ((customerOrder.subTotal - customerOrder.deliveryCharge) * promo.discount)
            }
        }
        return   discountAmount
    }
    
    func calculateDiscounts(branch: Branch,  customerOrder: CustomerOrder)-> Double {
        
        var discountAmount = 0.0
        for  orderDiscountRule: OrderDiscountRule  in branch.orderDiscountRules {
            
            let  expiryDate = orderDiscountRule.expiryDate
            let  today = currentDateTime()
            if(orderDiscountRule.status == 1 && orderDiscountRule.orderType.name == customerOrder.orderType && orderDiscountRule.paymentType.name == customerOrder.paymentType && expiryDate > today)
                {
                
                
                if(orderDiscountRule.chargeMode.id == 1)
                {
                    discountAmount = orderDiscountRule.discount
                }
                else if(orderDiscountRule.chargeMode.id == 2)
                {
                    discountAmount = ((customerOrder.subTotal - customerOrder.deliveryCharge) * (orderDiscountRule.discount/100))
                }
                
            }
            else
            {
               discountAmount = 0.0
              
            }
            
        }
        
    
        
        return discountAmount
    }
    
    func sendOrderDetailToSender(customerOrder: CustomerOrder){
        
        let myUrl = URL(string: ProductionPath.sendEmailUrl+"/send-order")
        var request = URLRequest(url: myUrl!)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let obj = customerOrder
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(obj)
        
        let postString = String(data: data, encoding: .utf8)!
        do {
            request.httpBody = postString.data(using: .utf8)
        } catch let error {
            print(error.localizedDescription)
            showAlert(title: "Alert", message: "Something went wrong. Try again.")
            return
        }
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil
            {
                self.showAlert(title: "Request Error", message: "Could not successfully perform this request. Please try again later")
                
                print("error=\(String(describing: error))")
                return
            }
            
            // Let's convert response sent from a server side code to a NSDictionary object:
        }
        
        task.resume()
        
    }
    
}

extension PlaceOrderVC: UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitle.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0)
        {
            return 1
            
        }
        else if(section == 3)
        {
            return routeArray.count
        }
        else if(section == 0)
        {
            return itemSummery.count
        }
        else{return 1}
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 2
        {
            if UIDevice.current.userInterfaceIdiom == .pad {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "InvoiceIpadCell", for: indexPath) as? InvoiceIpadCell
                else {
                fatalError("Unknown cell")
                }
               cell.lblAmountValue.text = "\(customerOrder.amount)"
               cell.lblOrderTime.text = "\(currentDateTime())"
               cell.lblGST.text = "\(round(taxAmount))"
               cell.lblSurCharge.text = "\(customerOrder.deliveryCharge)"
               cell.lblDiscount.text = "\(round(orderDiscount))"
               cell.lblSubTotal.text = "\(finalsubTotal) PKR"
               return cell
            }
            else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ordercell", for: indexPath) as? OrderCompleteCell
                else {
                    fatalError("Unknown cell")
            }
            cell.lblAmountValue.text = "\(customerOrder.subTotal)"
            cell.lblOrderTime.text = "\(currentDateTime())"
            cell.lblGST.text = "\(round(taxAmount))"
            cell.lblSurCharge.text = "\(customerOrder.deliveryCharge)"
            cell.lblDiscount.text = "\(round(orderDiscount))"
            cell.lblSubTotal.text = "\(finalsubTotal) PKR"
            return cell
            }
        }
        else if(indexPath.section == 3) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "routecell", for: indexPath) as? Route
                else {
                    fatalError("Unknown cell")
            }
            if(UIDevice.current.userInterfaceIdiom == .pad){
                cell.lblRoute.font =   cell.lblRoute.font.withSize(25)
            }
            cell.imgRoute.image = routeLogo[indexPath.row]
            cell.lblRoute.text = routeArray[indexPath.row]
            return cell
        }
        else if (indexPath.section == 0){
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemcell", for: indexPath) as? OrderItemsSummery
                else {
                    fatalError("Unknown cell")
            }
            cell.customerOrderItems = itemSummery
            return cell
        }
        else if (indexPath.section == 1) {
            
            if(UIDevice.current.userInterfaceIdiom == .pad){
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "OrderDetailIpadCell", for: indexPath) as? OrderDetailIpadCell
                    else {
                    fatalError("Unknown cell")
                    }
                if(customerOrder.paymentType == "BANK"){
                cell.lblPaymentType.text =  "\(branch.paymentMethods?[1].bankDetail ?? "")"
                }
                else{
                cell.lblPaymentType.text =  "\(customerOrder.paymentType)"
                }
                           
                cell.lblInstructions.text = "\(customerOrder.specialInstructions)"
                cell.lblDeliveryTime.text = "Delivery Time is minimum 3 hours and Max 24 hours ( For islamabad & Rawalpindi) Outside (4-5) working days "
                return cell
            }
            else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "detailcell", for: indexPath) as? OrderDetail
                else {
                    fatalError("Unknown cell")
            }
            if(customerOrder.paymentType == "BANK"){
                cell.lblPaymentType.text =  "\(branch.paymentMethods?[1].bankDetail ?? "")"
            }
            else{
               cell.lblPaymentType.text =  "\(customerOrder.paymentType)"
            }
            
            cell.lblInstruction.text = "\(customerOrder.specialInstructions)"
            cell.lblDeliveryTime.text =  "Minimum Delivery Time is 3 hours & Max-24 Hours (Islamabad/Rawalpindi) Outside (2-3 days)"
            return cell
            }
        }
        else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "contactcell", for: indexPath) as? ContactSupport
                else {
                    fatalError("Unknown cell")
            }
            cell.delegate = self
            cell.lblSupport.text = "For Any Qurrey or complain contact to our support Staff"
            
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 4) {
            
            makeAPhoneCall()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if UIDevice.current.userInterfaceIdiom == .pad{
            if(indexPath.section == 2 )
            {
                return 800
            }
            else if (indexPath.section == 0){
                
                return 250
            }
                else if (indexPath.section == 1){
                    
                    return 400
                }
            else {return UITableView.automaticDimension}
        }
        else{
        if(indexPath.section == 2 )
        {
            return 434
        }
        else if (indexPath.section == 0){
            
            return 150
        }
            else if (indexPath.section == 1){
                
                return 200
            }
        else {return UITableView.automaticDimension}
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.frame = CGRect(x: 100, y: 5, width: 200, height: 30)
        headerView.backgroundColor = Color.red
        let label = UILabel()
        label.frame = CGRect(x: tableView.bounds.size.width / 3  , y: 13, width: tableView.bounds.size.width - 10, height: 24)
        label.textColor = Color.blue
        label.font = UIFont(name: "Bodoni 72", size: 15)
        if section == 0{
            label.font = UIFont.boldSystemFont(ofSize: 12.0)
            let imageView = UIImageView(frame: CGRect(x: 5, y: 8, width: 30, height: 30))
            
            if let savedBranch = UserDefaults.standard.object(forKey: keyForSavedBranch) as? Data  {
                let decoder = JSONDecoder()
                if let loadedBranch = try? decoder.decode(BranchDetailsResponse.self, from: savedBranch) {
                    if let urlString = loadedBranch.branch.locationWebLogoURL,
                        let url = URL(string: urlString) {
                        imageView.af_setImage(withURL: url, placeholderImage: UIImage(), imageTransition: .crossDissolve(1), runImageTransitionIfCached: false)
                        label.text = "Billing Detail"
                        label.textColor = Color.whitesmoke
                    }
                    
                    headerView.addSubview(imageView)
                    headerView.addSubview(label)
                }
            }
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 0){
            return 50
        }
        else {return 0}
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section == 4{
            let footerView = UIView()
            footerView.frame = CGRect(x: 100, y: 100, width: 200, height: 50)
            let label = UILabel()
            label.frame = CGRect(x: 14  , y: 0, width: tableView.bounds.size.width - 10, height: 24)
            label.font = UIFont(name: "Bodoni 72", size: 15)
            label.text = "Delivery Time"
            footerView.addSubview(label)
            let imageView = UIImageView(frame: CGRect(x: tableView.bounds.size.width / 3 , y: 0, width: 25, height: 25))
            let image = UIImage(named: "scooter")
            imageView.image = image
            let label2 = UILabel()
            label2.frame = CGRect(x: (tableView.bounds.size.width / 3) + 30  , y: 0, width: tableView.bounds.size.width - 10, height: 24)
            label2.text = "Minimum Delivery Time is 3 hours"
            label2.font = UIFont(name: "Bodoni 72", size: 15)
            label2.textColor = Color.red
            footerView.addSubview(label2)
            footerView.addSubview(imageView)
            return footerView
        }
        else {return nil}
        
    }
    
}
extension PlaceOrderVC : contactStaffDelegate{
    
    func didpressContactStaff(cell: ContactSupport) {
        makeAPhoneCall()
    }
}


struct CustomerType: Codable {
    let id: Int
    let customerType, transID: String
    let customerEmail,customerPassword: String
    let ipAddress: String?
    let orderDate, specialInstructions, customerPhone, customerFirstName: String
    let customerLastName, orderStatus, billingStatus: String
    let printingStatus: String
    let creditStatus, orderType, paymentType, orderTime: String
    let promoCode, sitePreference, paymentGateway, paymentGatewayReference: String?
    let orderConfirmationStatus, orderConfirmationStatusMessage: String
    let deliveryCharge: Int
    let surCharge: String?
    let amount, subTotal: Double
    let orderDiscount: Int
    let promoCodeDiscount, orderCredit: Bool?
    let customerID, branchID, processedBySoftware: Int
    let phoneNotify, sendFax, sendSMS, firstCustomerOrder: Bool
    let preOrdered, companyID: Int
    let customerOrderAddress: String?
    let customerOrderTaxes: [CustomerOrderTax]
    let customerOrderItem: [CustomerOrderItem]
    let invoiceOrderDetailID, cardOption: String
    
    enum CodingKeys: String, CodingKey {
        case id, customerType
        case transID = "transId"
        case customerEmail,customerPassword,ipAddress, orderDate, specialInstructions, customerPhone, customerFirstName, customerLastName, orderStatus, billingStatus, printingStatus, creditStatus, orderType, paymentType, orderTime, promoCode, sitePreference, paymentGateway, paymentGatewayReference, orderConfirmationStatus, orderConfirmationStatusMessage, deliveryCharge, surCharge, amount, subTotal, orderDiscount, promoCodeDiscount, orderCredit
        case customerID = "customerId"
        case branchID = "branchId"
        case processedBySoftware, phoneNotify, sendFax
        case sendSMS = "sendSms"
        case firstCustomerOrder, preOrdered
        case companyID = "companyId"
        case customerOrderAddress, customerOrderTaxes, customerOrderItem, invoiceOrderDetailID, cardOption
    }
}
