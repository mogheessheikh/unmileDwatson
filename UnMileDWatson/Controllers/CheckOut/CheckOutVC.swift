//
//  CheckOutVC.swift
//  UnMile
//
//  Created by iMac on 20/03/2019.
//  Copyright © 2019 Adnan Asghar. All rights reserved.
//

import UIKit


class CheckOutVC: BaseViewController {
 
    @IBOutlet var checkOutButton: UIButton!
    @IBOutlet var tblCheckOut: UITableView!
    var userName = ""
    var userEmail = ""
    var userPhone = ""
    var userL: [String] = ["Name*", "Email*", "Phone*"]
  
    var branch : Branch!
    var sectionTitle = [ "User","Order Type","Delivery Address","Payment Type","Special Instruction(optional)"]
    var oderType = ""
    var paymentType = ""
    var selectedAddress: CustomerOrderAddress!
    var userArray = [String]()
    var userKeyArray = [String]()
    var orderSelectedIndex:NSIndexPath?
    var paymentSelectedIndex : NSIndexPath?
    var firstOrderTypeIndex = 0
    var firstPaymentTypeIndex = 0
    var totalprice = 0.0
    var orderDate = ""
    var orderTime = ""
    var customerOrderItem : [CustomerOrderItem]!
    var customerOrder: CustomerOrder!
    var custorder = [CustomerOrder]()
    var customerOrderAddresss : CustomerOrderAddress?
    var alreadyAddress : [CustomerOrderAddress]!
    var transId = ""
    var subTotal = 0.0
    var savedBranchId = 0
    var radioControllerChoice : SSRadioButtonsController = SSRadioButtonsController()
    var radioControllerDip : SSRadioButtonsController = SSRadioButtonsController()
    var customer : CustomerDetail!
    var selectedIndex : NSIndexPath?
    var selectedArray : [IndexPath] = [IndexPath]()
    var selectedSingleRows = [String:IndexPath]()
    var reSizeOrderTypeCell = false
    var reSizePayementTypeCell = false
    var promoCodeText = ""
    var promoCodeMatch = false
    var specialIstruction = ""
    var services: [String] = []
    var userSectionImagesArray :[UIImage] = [UIImage(named: "Suser.png")!,UIImage(named: "mail.png")!,UIImage(named: "phone-1.png")!]
    var headerTitleArray :[String] = ["Customer Information", "Have a Coupn?", "Delivery Address","Order Type", "Payment Type","General Requst(Optional)" ]
   
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        orderDate = currentDateTime()
        orderTime = currentTime()
        transId  = getTransId()
        customerOrderItem = getAlreadyCartItems()
        getUser()
        
       branch = getBranchObject(key: keyForSavedBranch)
    
        
       
         for i in branch.services{
          if (i.archive == 0){
            services.append(i.orderType.name)
             }
        }
        
        tblCheckOut.register(UINib(nibName: "OrderType", bundle: Bundle.main), forCellReuseIdentifier: "odercell")
        tblCheckOut.register(UINib(nibName: "DeliveryAddress", bundle: Bundle.main), forCellReuseIdentifier: "deliverycell")
        tblCheckOut.register(UINib(nibName: "SpecialInstruction", bundle: nil), forCellReuseIdentifier: "instructioncell")
        tblCheckOut.register(UINib(nibName: "PaymentMethodCell", bundle: Bundle.main), forCellReuseIdentifier: "paymentcell")
        tblCheckOut.register(UINib(nibName: "PromoCodeCell", bundle: Bundle.main), forCellReuseIdentifier: "promocell")
       
    }
    override func viewWillAppear(_ animated: Bool) {
        tblCheckOut.reloadData()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "checkout2Summary"
    {
        let vc = segue.destination as? PlaceOrderVC
        vc?.customerOrder = customerOrder
        vc?.promoCodeMatch = self.promoCodeMatch
        }
    }
    
    @IBAction func goToSummary(_ sender: Any) {
        
       let area = getSavedAreaObject(key: keyForSavedArea)
        let deliveryCharges = deliverCharges()
        
        if (selectedAddress == nil )
        {
            showAlert(title: "Address is empty", message: "Select Delivery Address")
        }
        else if (paymentType == "" || oderType == ""){
            
            showAlert(title: "Selection Missing", message: "Must select all selection")
        }
        else if(userPhone == ""){
            
           showAlert(title: "Phone Number Field Can't be Empty", message: "Update your phone number in 'MyProfile'" )
            return
        }
            
        else{
            
            if(paymentType == "CARD"){
                showAlert(title: "no card", message: "cant select card")
            }
            else{
                customerOrder = CustomerOrder.init(id: 0, customerType: customer.customerType, transID: transId, ipAddress: customer.ipAddress, orderDate: orderDate, specialInstructions: specialIstruction , customerPhone: customer.phone, customerFirstName: customer.firstName, customerLastName: customer.lastName, orderStatus: "PENDING", billingStatus: "false", printingStatus: "false", creditStatus: "false", orderType: oderType, paymentType: paymentType, orderTime: "ASAP (Around 75 Minutes)", promoCode: "false", sitePreference: "false", paymentGateway: "false", paymentGatewayReference: "false", orderConfirmationStatus: "PENDING", orderConfirmationStatusMessage: "PENDING", deliveryCharge: deliveryCharges, surCharge: 0.0, amount: subTotal, subTotal: totalprice, orderDiscount: 0.0, promoCodeDiscount: 0.0, orderCredit: "false", customerID: customer.id, branchID: branchId, processedBySoftware: 0, phoneNotify: false, sendFax: false, sendSMS: false, firstCustomerOrder: false, preOrdered: 0, companyID: companyId, customerOrderAddress: selectedAddress! , customerOrderTaxes: [], customerOrderItem: customerOrderItem, invoiceOrderDetailID: "false", cardOption: "false")
                    performSegue(withIdentifier: "checkout2Summary", sender: self)
        }
        }
        
    }
    func getTransId() -> String
    {
        
        let areaUrl = ProductionPath.transIdUrl + "/new"
        NetworkManager.getDetails(path: areaUrl , params: nil, success: { (json, isError) in
            do {
                self.transId = json.rawString()!

            } catch let myJSONError {
                print(myJSONError)
                self.showAlert(title: Strings.error, message: Strings.somethingWentWrong)
            }
        })
        { (error) in
           
            self.stopActivityIndicator()
            self.showAlert(title: Strings.error, message: Strings.somethingWentWrong)
        }
        return transId
    }

    
    func currentTime () -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return (formatter.string(from: Date()) as NSString) as String
    }
    func addSelectedCellWithSection(_ indexPath:IndexPath) ->IndexPath?
    {
        let existingIndexPath = selectedSingleRows["\(indexPath.section)"]
        selectedSingleRows["\(indexPath.section)"]=indexPath;
        return existingIndexPath
    }
    func indexPathIsSelected(_ indexPath:IndexPath) ->Bool {
        if let selectedIndexPathInSection = selectedSingleRows["\(indexPath.section)"] {
            if(selectedIndexPathInSection.row == indexPath.row) { return true }
        }
        
        return false
    }
    func getUser() {
        self.startActivityIndicator()
        if let customerDetail = UserDefaults.standard.object(forKey: keyForSavedCustomer) as? Data{
            let decoder = JSONDecoder()
            let customer = try? decoder.decode(CustomerDetail.self, from: customerDetail)
            customerId = customer!.id
            let path = URL(string: ProductionPath.customerUrl + "/\(customerId)")
            print(path!)
            let session = URLSession.shared
            let task = session.dataTask(with: path!) { data, response, error in
                print("Task completed")
                
                guard data != nil && error == nil else {
                    print(error?.localizedDescription)
                    return
                }
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                    if let parseJSON = json {
                        
                        let jsonData = try JSONSerialization.data(withJSONObject: parseJSON, options: .prettyPrinted)
                        let encodedObjectJsonString = String(data: jsonData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
                        let jsonData1 = encodedObjectJsonString.data(using: .utf8)
                        self.customer = try JSONDecoder().decode(CustomerDetail.self, from: jsonData1!)
                        DispatchQueue.main.async {
                            self.userName = self.customer.firstName
                            self.userEmail = self.customer.email
                            self.userPhone = self.customer.phone
                            self.userArray.append(self.userName)
                            self.userArray.append(self.userEmail)
                            self.userArray.append(self.userPhone)
                            self.tblCheckOut.reloadData()
                            self.stopActivityIndicator()
                        }
                        
                    }
                    
                } catch let parseError as NSError {
                    print("JSON Error \(parseError.localizedDescription)")
                }
            }
            
            task.resume()
        }
    }
    
    
    func deliverCharges()-> Double{
        
        let company = getCompanyObject(keyForSavedCompany)
        let city = getSavedCityObject(key: keyForSavedCity)
        let branch = getBranchObject(key: keyForSavedBranch)
        var deliverCharge = 0.0
        
            if(company.deliveryZoneType.name == "CITY"){
            
                for (i,j) in (branch?.deliveryZones.enumerated())!{
                
                    if(j.city.city == city.city){
                    
                    deliverCharge = branch?.deliveryZones[i].deliveryFee ?? 0.0
                }
            }
        }
        
            else if(company.deliveryZoneType.name == "CITYAREA"){
                
                deliverCharge = 0.0
        }
       return deliverCharge
            
    }
    
    
}



extension CheckOutVC : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0)
        {
            return userArray.count
        }
        else if (section == 3){
            
            return services.count
        }
            
        else if(section == 4){
            
            return branch.paymentMethods!.count
        }
            
        else {
            
            return 1
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.section == 1){
            guard let  cell = tableView.dequeueReusableCell(withIdentifier: "promocell", for: indexPath) as? PromoCodeCell else {fatalError("Unknown cell")}
            cell.verifyButton.layer.cornerRadius = 5
            cell.delegate = self
            return cell
        }
      else if(indexPath.section == 0)
        {
            guard let  cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CheckOutTableViewCell else {fatalError("Unknown cell")}
       
                cell.lblUser.text = "\(userArray[indexPath.row])"
                cell.lblUserL.text = "\(userL[indexPath.row])"
                cell.icons.image = userSectionImagesArray[indexPath.row]
            
            
            return cell
            
            
        }
       else if (indexPath.section == 2){
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "deliverycell", for: indexPath) as? DeliveryAddress
                else {
                    fatalError("Unknown cell")
            }
            if let savedAddress = UserDefaults.standard.object(forKey: keyForSavedCustomerAddress) as? Data  {
                let decoder = JSONDecoder()
                if let loaded = try? decoder.decode(Address.self, from: savedAddress) {
                    selectedAddress  =  CustomerOrderAddress.init(id: 0, addressID: loaded.id, customerOrderAddressFields: loaded.addressFields)
                    
                }
                // Do any additional setup after loading the view.
            }
            if(selectedAddress != nil){
            cell.deliveryAddress.text = "\(selectedAddress.customerOrderAddressFields[0].fieldValue + " " + selectedAddress.customerOrderAddressFields[1].fieldValue + " " + selectedAddress.customerOrderAddressFields[2].fieldValue + " " + selectedAddress.customerOrderAddressFields[3].fieldValue)"
            }
            cell.delegate = self
            return cell
        }
       else if (indexPath.section == 3){
            guard let orderTypeCell = tableView.dequeueReusableCell(withIdentifier: "odercell", for: indexPath) as? OrderType
                else {
                    fatalError("Unknown cell")
            }
            orderTypeCell.orderTypelbl.text =  branch.paymentMethods?[indexPath.row].branchDetailService.orderType.name
                if(self.indexPathIsSelected(indexPath)) {
                                     orderTypeCell.orderTypeRadioButton.setImage(UIImage(named: "radiobutton"),for:UIControl.State.normal)
                                  } else {
                                      orderTypeCell.orderTypeRadioButton    .setImage(UIImage(named: "uncheckradiobutton"),for:UIControl.State.normal)
                                  }
            return orderTypeCell
        }
       
        else if(indexPath.section == 4)
        {
            guard let paymentTypeCell = tableView.dequeueReusableCell(withIdentifier: "paymentcell", for: indexPath) as? PaymentMethodCell
                else {
                    fatalError("Unknown cell")
            }
            
            
            paymentTypeCell.lblPaymentMethod.text = branch.paymentMethods![indexPath.row].paymentType.name
            if(self.indexPathIsSelected(indexPath)) {
                                                paymentTypeCell.radioButton.setImage(UIImage(named: "radiobutton"),for:UIControl.State.normal)
                                                 
                                             } else {
                                                 paymentTypeCell.radioButton    .setImage(UIImage(named: "uncheckradiobutton"),for:UIControl.State.normal)
                                             }
            
            return paymentTypeCell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "instructioncell", for: indexPath) as? SpecialInstruction
                else {
                    fatalError("Unknown cell")
            }
            cell.delegate = self
            
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        
        if(indexPath.section == 3){
            let previusSelectedCellIndexPath = self.addSelectedCellWithSection(indexPath)
            let cell = self.tblCheckOut.cellForRow(at: indexPath) as! OrderType
            if(previusSelectedCellIndexPath != nil)
                          {
                              let previusSelectedCell = self.tblCheckOut.cellForRow(at: previusSelectedCellIndexPath!) as! OrderType
                              previusSelectedCell.orderTypeRadioButton.setImage(UIImage(named: "uncheckradiobutton"),for:UIControl.State.normal)
                              selectedIndex = indexPath as NSIndexPath
                              
                              tblCheckOut.deselectRow(at: previusSelectedCellIndexPath!, animated: true)
                              
                              tblCheckOut.reloadData()
                          }
            else{
                oderType = branch.services[indexPath.row].orderType.name
                cell.orderTypeRadioButton.setImage(UIImage(named: "radiobutton"),for:UIControl.State.normal)
            }
        }
        else if (indexPath.section == 4){
            
            let previusSelectedCellIndexPath = self.addSelectedCellWithSection(indexPath)
                       let cell = self.tblCheckOut.cellForRow(at: indexPath) as! PaymentMethodCell
                       if(previusSelectedCellIndexPath != nil)
                                     {
                                         let previusSelectedCell = self.tblCheckOut.cellForRow(at: previusSelectedCellIndexPath!) as! PaymentMethodCell
                                        previusSelectedCell.radioButton.setImage(UIImage(named: "uncheckradiobutton"),for:UIControl.State.normal)
                                         selectedIndex = indexPath as NSIndexPath
                                         
                                         tblCheckOut.deselectRow(at: previusSelectedCellIndexPath!, animated: true)
                                         paymentType = branch.paymentMethods![indexPath.row].paymentType.name   
                                         tblCheckOut.reloadData()
                                     }
                       else{
                        paymentType = branch.paymentMethods![indexPath.row].paymentType.name
                           cell.radioButton.setImage(UIImage(named: "radiobutton"),for:UIControl.State.normal)
                       }
        }
        tblCheckOut.deselectRow(at: indexPath, animated: false)
    }


    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0){
            
            return 50
            
        }
            else if(indexPath.section == 1){
                
                return 81
                
                
            }
       else if(indexPath.section == 2){
            
            return 81
        }
        else if (indexPath.section == 3){
          return 54
        }
        else if(indexPath.section == 4){
            
           return 54
		  
        }
        else if(indexPath.section == 5){
            return 100
            
        }
        else{ return UITableView.automaticDimension
            
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 5, width: 200, height: 90))//set these values as necessary
        headerView.backgroundColor = UIColor.white
        
        let label = UILabel(frame: CGRect(x:10  , y: 0, width: tableView.bounds.size.width - 10, height: 24))
        label.text = headerTitleArray[section]
        headerView.addSubview(label)

        return headerView
    }
    
    
}
extension CheckOutVC: radioButtonDelelgate{
    func didCheckRadioButton(cell: PaymentMethodCell?, String: String) {
        if (!cell!.animate){
            
            reSizePayementTypeCell = true
            tblCheckOut.reloadData()
        }
        else{
            reSizePayementTypeCell = false
            tblCheckOut.reloadData()
        }
         paymentType = String
    }
    
}

extension CheckOutVC: resizeOrderTypeDelegate{
    func didToggleOrderType(cell: OrderType?, String: String) {
        if(!cell!.animate){
            reSizeOrderTypeCell = true
            tblCheckOut.reloadData()
        }
        else{
            reSizeOrderTypeCell = false
            tblCheckOut.reloadData()
        }
        oderType = String
    }
    
}

extension CheckOutVC: PromoCodeDelegate {
    func textField(editingChangedInTextField newText: String, in cell: PromoCodeCell) {
        promoCodeText = newText
        
    }
    
    
    func didTappedVerificationButton()
    {
        for promoCode: PromoCodeDiscountRule in branch.promoCodeDiscountRules{
            
            if promoCode.promoCode == promoCodeText{
                if(Int(totalprice) < promoCode.subTotal){
                    
                showAlert(title: "", message: "Add more items in your cart to avail discount on this promo Code")
                promoCodeMatch = false
                }
                else{
                    showAlert(title: "Promocode Matched", message: "")
                    promoCodeMatch = true
                }
            }
            else{
                
                  showAlert(title: "'Promocode DoesNot Exist'", message: "")
            }
            
            
        }
        
       
    }
    
    
}
extension CheckOutVC: addAddressDelegate{
    func didTappedAddressButton(cell: DeliveryAddress) {
        let userAddress = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddressVC")
        userAddress.title = "User Address"
        self.navigationController?.pushViewController(userAddress, animated: true)
    }
    
}
extension CheckOutVC: TextFieldInSpecialInstructionDelegate{
    func textField(editingDidBeginIn cell: SpecialInstruction) {
        if let indexPath = tblCheckOut.indexPath(for: cell) {
            print("textfield selected in cell at \(indexPath)")
        }
    }
    func textField(editingChangedInTextField newText: String, in cell: SpecialInstruction) {
        if let indexPath = tblCheckOut?.indexPath(for: cell) {
            print("updated text in textfield in cell as \(indexPath), value = \"\(newText)\"")
            specialIstruction = newText
        }
    }
}



