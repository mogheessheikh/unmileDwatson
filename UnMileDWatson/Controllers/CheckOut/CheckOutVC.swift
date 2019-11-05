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
    var paymentLogo: [UIImage] = [UIImage(named: "cash-1")! , UIImage(named: "credit-card")!]
    var branch : BranchDetailsResponse!
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
    var selectedArray : [IndexPath] = [IndexPath]()
    var selectedSingleRows = [String:IndexPath]()
    var reSizeOrderTypeCell = false
    var reSizePayementTypeCell = false
    var specialIstruction = ""
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        orderDate = currentDateTime()
        orderTime = currentTime()
        transId  = getTransId()
        customerOrderItem = getAlreadyCartItems()
        getUser()
        
       branch = getBranchObject(key: keyForSavedBranch)
        if let savedBranch = UserDefaults.standard.object(forKey: "branchAddress") as? Data  {
            let decoder = JSONDecoder()
            if let loadedBranchAddress = try? decoder.decode(Branch.self, from: savedBranch) {
             savedBranchId = loadedBranchAddress.id
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
        }
    }
    
    @IBAction func goToSummary(_ sender: Any) {

        if (selectedAddress == nil )
        {
            showAlert(title: "Address is empty", message: "Select Delivery Address")
        }
        else if (paymentType == "" || oderType == ""){
            
            showAlert(title: "Selection Missing", message: "Must select all selection")
        }
        else{
            do {
          
            
                customerOrder = CustomerOrder.init(id: 0, customerType: customer.customerType, transID: transId, ipAddress: customer.ipAddress, orderDate: orderDate, specialInstructions: specialIstruction , customerPhone: customer.phone, customerFirstName: customer.firstName, customerLastName: customer.lastName, orderStatus: "PENDING", billingStatus: "false", printingStatus: "false", creditStatus: "false", orderType: oderType, paymentType: paymentType, orderTime: "ASAP (Around 75 Minutes)", promoCode: "false", sitePreference: "false", paymentGateway: "false", paymentGatewayReference: "false", orderConfirmationStatus: "PENDING", orderConfirmationStatusMessage: "AUTOCONFIRMED", deliveryCharge: 0, surCharge: 0.0, amount: subTotal, subTotal: subTotal, orderDiscount: 0.0, promoCodeDiscount: 0.0, orderCredit: "false", customerID: customer.id, branchID: branchId, processedBySoftware: 0, phoneNotify: false, sendFax: false, sendSMS: false, firstCustomerOrder: false, preOrdered: 0, companyID: companyId, customerOrderAddress: selectedAddress! , customerOrderTaxes: [], customerOrderItem: customerOrderItem, invoiceOrderDetailID: "false", cardOption: "false")

               performSegue(withIdentifier: "checkout2Summary", sender: self)
            }
            catch{
                showAlert(title: "Can't Perform Action", message: "Can't perform Action")
            }
            
        }
        
    }
    func getTransId() -> String
    {
        
        let areaUrl = Path.transIdUrl + "/new"
        NetworkManager.getDetails(path: areaUrl , params: nil, success: { (json, isError) in
            
            do {
                self.transId = json.rawString()!
//                self.transId =  String(data:  jsonData, encoding: String.Encoding.utf8)!
               // let anArray = try JSONDecoder().decode(AreaResponse.self, from: jsonData)
                
            } catch let myJSONError {
                print(myJSONError)
                self.showAlert(title: Strings.error, message: Strings.somethingWentWrong)
            }
            
        }) { (error) in
           
            self.stopActivityIndicator()
            self.showAlert(title: Strings.error, message: Strings.somethingWentWrong)
        }
        
return transId
    }

    func currentDateTime () -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        return (formatter.string(from: Date()) as NSString) as String
    }
    func currentTime () -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm:ss"
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
            let path = URL(string: Path.customerUrl + "/\(customerId)")
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
    
    
}



extension CheckOutVC : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0)
        {
            return userArray.count
        }
       
        else {
            
            return 1
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if(indexPath.section == 0)
        {
            guard let  cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CheckOutTableViewCell else {fatalError("Unknown cell")}
            
            
       
                cell.lblUser.text = "\(userArray[indexPath.row])"
                cell.lblUserL.text = "\(userL[indexPath.row])"
            
            
            return cell
            
            
        }
        
        if (indexPath.section == 1){
            guard let orderTypeCell = tableView.dequeueReusableCell(withIdentifier: "odercell", for: indexPath) as? OrderType
                else {
                    fatalError("Unknown cell")
            }
            
            orderTypeCell.delegate = self
            var orderTypeArray = [String]()
            
            for (_,j) in branch.branch.services.enumerated(){
                orderTypeArray.append(j.orderType.name)
                
            }
            
            orderTypeCell.orderType = orderTypeArray


            return orderTypeCell
        }
         if (indexPath.section == 2){
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "deliverycell", for: indexPath) as? DeliveryAddress
                else {
                    fatalError("Unknown cell")
            }
            if let savedBranch = UserDefaults.standard.object(forKey: "selectedAddress") as? Data  {
                let decoder = JSONDecoder()
                if let loaded = try? decoder.decode(Address.self, from: savedBranch) {
                    
                    selectedAddress  =  CustomerOrderAddress.init(id: 0, addressID: loaded.id, customerOrderAddressFields: loaded.addressFields)

                }
                // Do any additional setup after loading the view.
            }
            if(selectedAddress != nil){
                cell.deliveryAddress.text = "\(selectedAddress.customerOrderAddressFields[1].fieldValue + " " + selectedAddress.customerOrderAddressFields[2].fieldValue + " " + selectedAddress.customerOrderAddressFields[3].fieldValue)"
            }
            

           
            cell.delegate = self
            return cell
        }
         if(indexPath.section == 3)
        {
            
            guard let paymentTypeCell = tableView.dequeueReusableCell(withIdentifier: "paymentcell", for: indexPath) as? PaymentMethodCell
                else {
                    fatalError("Unknown cell")
            }
            
            paymentTypeCell.delegate = self
            var paymentTypeArray = [String]()
            
            for (_,j) in branch.branch.paymentMethods!.enumerated(){
                paymentTypeArray.append(j.paymentType.name)
                
            }
            paymentTypeCell.paymentType = paymentTypeArray
            
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
      
        tblCheckOut.deselectRow(at: indexPath, animated: false)
    }


    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(section == 0)
        {
            let headerView = Bundle.main.loadNibNamed("PromoCodeCell", owner: self, options: nil)?.first as! PromoCodeCell
            headerView.frame = CGRect(x: 100, y: 0, width: 200, height: 200)
            return headerView
        }
        else {return nil}
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 1){
            if(reSizeOrderTypeCell){
                
                return 160
            }
            else{ return UITableView.automaticDimension}
            
        }
        else if(indexPath.section == 2){
            
            return 95
            
        }
        else if(indexPath.section == 3){
            
            if(reSizePayementTypeCell){
                
                return 160
            }
            else{ return UITableView.automaticDimension}
            
        }
        else if(indexPath.section == 4){
            return 100
            
        }
        else{ return UITableView.automaticDimension}
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 200
        }
        else{
        return 0
        }
        
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
    
    func didTappedVerificationButton()
    {
        self.showAlert(title: "Tapped", message: "Verification button tapped")
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



