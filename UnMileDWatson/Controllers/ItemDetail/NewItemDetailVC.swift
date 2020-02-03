////
////  NewItemDetailVC.swift
////  UnMile
////
////  Created by user on 9/2/19.
////  Copyright © 2019 Moghees Sheikh. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class NewItemDetailVC: BaseViewController {
    
    @IBOutlet weak var tblOptionGroup: UITableView!
    var product: Product!
    var optionGroup : [String] = []
    var oG :CustomerOptionGroup!
    var optionGroupOptions : Option!
    let mustArray = NSMutableArray.init()
    var optionalArray = NSMutableArray.init()
    var mustCount = 0
    var optionalCount = 0
    var selectedIndex : NSIndexPath?
    var cProduct : CustomerProduct!
    var customerOrderItemOptionObj : CustomerOrderItemOption!
    var customerOrderItemOptionArray : [CustomerOrderItemOption] = []
    var items : CustomerOrderItem?
    let cartBag = SSBadgeButton()
    var bag = 0
    var qNumber = 1
    var itemPurchaseSubTotal = 0.0
    var selectedSingleRows = [String:IndexPath]()
    var rowsWhichAreChecked = [NSIndexPath]()
    var radioWhichAreChecked = [NSIndexPath.init(row: 0, section: 0)]
    var customerOptionGroupArray : [CustomerOptionGroup] = []
    var selectedElement = [Int : String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        let alreadyItems = getAlreadyCartItems()
        tblOptionGroup.rowHeight = 44
        // Do any additional setup after loading the view.
        tblOptionGroup.register(UINib(nibName: "productImgCell", bundle: Bundle.main), forCellReuseIdentifier: "cell1")
        tblOptionGroup.register(UINib(nibName: "productNameCategoryCell", bundle: Bundle.main), forCellReuseIdentifier: "cell2")
        tblOptionGroup.register(UINib(nibName: "productOptionGroupCell", bundle: Bundle.main), forCellReuseIdentifier: "cell3")
        tblOptionGroup.register(UINib(nibName: "section4Cell", bundle: Bundle.main), forCellReuseIdentifier: "cell4")
        tblOptionGroup.register(UINib(nibName: "productSpecialInstructionCell", bundle: Bundle.main), forCellReuseIdentifier: "cell5")
        tblOptionGroup.register(UINib(nibName: "addToCartButtonCell", bundle: Bundle.main), forCellReuseIdentifier: "cell6")
        
        if  !(product.optionGroups.isEmpty){
        for index in product.optionGroups.indices{
            optionGroup.append(product.optionGroups[index].name)
        }
  }
        
        cartBag.frame = CGRect(x: 0, y: 0, width: 25, height: 30)
        cartBag.setImage(UIImage(named: "add to cart")?.withRenderingMode(.automatic), for: .normal)
        cartBag.badgeEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 15)
        cartBag.addTarget(self, action: #selector(cartBagTapped), for: .touchUpInside)
        bag = alreadyItems.count
        UserDefaults.standard.set(bag, forKey: "bag")
        cartBag.badge = String(bag)
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: cartBag)]
        
        for group in product!.optionGroups{
            if (group.maxChoice <= 1){
                mustCount += 1
            }
            else{
                optionalCount += 1
            }
        }
        
        
        for _ in 0..<mustCount{
            
            mustArray.add("")
        }
        for _ in 0..<optionalCount{
            
            optionalArray.add("")
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        let alreadyItems = getAlreadyCartItems()
        bag = alreadyItems.count
        UserDefaults.standard.set(bag, forKey: "bag")
        cartBag.badge = String(bag)
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

    func getSubOptionGroup(optionId: Int){
        startActivityIndicator()
        let path = URL(string: ProductionPath.optionGroupUrl + "/option/\(optionId)")
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
                    let option = try JSONDecoder().decode(OptionGroup.self, from: jsonData1!)
                    DispatchQueue.main.async {
 
                        self.stopActivityIndicator()
                    }
                    
                }
                
            } catch let parseError as NSError {
                print("JSON Error \(parseError.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    
    @IBAction func cartBagTapped (_ sender: Any){
        
        performSegue(withIdentifier: "addtoCart", sender: nil)
    }
   
}

extension NewItemDetailVC :  UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section <= 1){
            return 0
        }
        else {
            
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      return ""
    }
    
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 3 && !product.optionGroups.isEmpty){
            return product.optionGroups[section-3].options?.count ?? 0
        }
        else{
            return 1
        }
    }
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            
            return 300
        }
        else{
            return UITableView.automaticDimension
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if(!product.optionGroups.isEmpty){
            return 6
        }
        else{
         return 5
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 3 && !product.optionGroups.isEmpty){
            return 40
        }
        else
        {
            return UITableView.automaticDimension
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if indexPath.section == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! productImgCell
                Alamofire.request(product.productPhotoURL ?? "").responseImage { response in
                    if let image = response.result.value {
                        cell.productImg.image = image
                    } else {
                        cell.productImg.image  = UIImage(named: "logo")
                    }
                    
                }
                
                return cell
            }
              
            else if (indexPath.section == 1){
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! productNameCategoryCell
                cell.subview1.layer.cornerRadius = 5
                cell.descriptionLbl.text = product.description
                cell.productName.text = product.name
                return cell
            }
                
            else if (indexPath.section == 2){
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell6", for: indexPath) as! addToCartButtonCell
                cell.addItemButton.layer.cornerRadius = 7
                if(product.price == 0.0){
                    cell.productPrice.text = "\(product.optionGroups[indexPath.row].options![indexPath.row].price ?? 0.0)"
                }
                else{
                    cell.productPrice.text = "\(product.price ?? 0.0)"
                }
                cell.delegate = self
                return cell
  
            }
            else if(indexPath.section == 3 && !product.optionGroups.isEmpty){
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell3") as! productOptionGroupCell
                cell.optionName.text = product.optionGroups[indexPath.section-3].options?[indexPath.row].name
                
                cell.optionPrice.text = "\(product.optionGroups[indexPath.section-3].options![indexPath.row].price!)"
                if(product.optionGroups[indexPath.section-3].maxChoice ?? 0 <= 1)
                {
                    if(self.indexPathIsSelected(indexPath)) {
                        cell.radio_check_button.setImage(UIImage(named: "radiobutton"),for:UIControl.State.normal)
                        
                    } else {
                        cell.radio_check_button.setImage(UIImage(named: "uncheckradiobutton"),for:UIControl.State.normal)
                    }
                }
                else{
                    
                    if(self.indexPathIsSelected(indexPath)) {
                        
                        cell.radio_check_button.setImage(UIImage(named: "check"),for:UIControl.State.normal)
                    }
                    else {
                        cell.radio_check_button.setImage(UIImage(named: "uncheck"),for:UIControl.State.normal)
                    }
                    
                }
                return cell
            }
                
            else if (indexPath.section == 4){
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell4", for: indexPath) as! section4Cell
                cell.subview1.layer.cornerRadius = 5
                cell.delegate = self
                
                return cell
            }

                else{

                let cell = tableView.dequeueReusableCell(withIdentifier: "cell5", for: indexPath) as!productSpecialInstructionCell


                return cell

        }
       
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section >= 3 && !product.optionGroups.isEmpty){
            let previusSelectedCellIndexPath = self.addSelectedCellWithSection(indexPath)
            
            let cell = self.tblOptionGroup.cellForRow(at: indexPath) as! productOptionGroupCell
            if(product.optionGroups[indexPath.section-3].maxChoice ?? 0 <= 1)
            {
                oG  =  CustomerOptionGroup.init(id: product.optionGroups[indexPath.section-3].id, name: product.optionGroups[indexPath.section-3].name, identifierName: product.optionGroups[indexPath.section-3].identifierName, listQuantity: product.optionGroups[indexPath.section-3].listQuantity, minChoice: product.optionGroups[indexPath.section-3].minChoice, maxChoice: product.optionGroups[indexPath.section-3].maxChoice, status: product.optionGroups[indexPath.section-3].status, archive: product.optionGroups[indexPath.section-3].archive, optID: product.optionGroups[indexPath.section-3].optID, options: [product.optionGroups[indexPath.section-3].options![indexPath.row]])
                optionGroupOptions =  product.optionGroups[indexPath.section-3].options?[indexPath.row]
                
                customerOrderItemOptionObj  = CustomerOrderItemOption.init(quantity: customerOptionGroupArray.count, purchaseSubTotal: Int(product.optionGroups[indexPath.section-3].options![indexPath.row].price!), option: optionGroupOptions, parentOptionGroup: product?.optionGroups[indexPath.section-3], customerOrderItem: items)
                
                if(previusSelectedCellIndexPath != nil)
                {
                    let previusSelectedCell = self.tblOptionGroup.cellForRow(at: previusSelectedCellIndexPath!) as! productOptionGroupCell
                    previusSelectedCell.radio_check_button.setImage(UIImage(named: "uncheckradiobutton"),for:UIControl.State.normal)
                    selectedIndex = indexPath as NSIndexPath
                    customerOrderItemOptionArray.append(customerOrderItemOptionObj)
                    mustArray.replaceObject(at: indexPath.section-3, with:oG)
                    tblOptionGroup.deselectRow(at: previusSelectedCellIndexPath!, animated: true)
                    
                    tblOptionGroup.reloadData()
                }
                else{
                    cell.radio_check_button.setImage(UIImage(named: "radiobutton"),for:UIControl.State.normal)
                    mustArray.replaceObject(at: indexPath.section-3, with:oG)
                    customerOrderItemOptionArray.append(customerOrderItemOptionObj)
                }
            }
            else {
                let oG  =  CustomerOptionGroup.init(id: product.optionGroups[indexPath.section-3].id, name: product.optionGroups[indexPath.section-3].name, identifierName: product.optionGroups[indexPath.section-3].identifierName, listQuantity: product.optionGroups[indexPath.section-3].listQuantity, minChoice: product.optionGroups[indexPath.section-3].minChoice, maxChoice: product.optionGroups[indexPath.section-3].maxChoice, status: product.optionGroups[indexPath.section-3].status, archive: product.optionGroups[indexPath.section-3].archive, optID: product.optionGroups[indexPath.section-3].optID, options: [product.optionGroups[indexPath.section-3].options![indexPath.row]])
                
                optionGroupOptions =  product.optionGroups[indexPath.section-3].options?[indexPath.row]
                
                customerOrderItemOptionObj  = CustomerOrderItemOption.init(quantity: customerOptionGroupArray.count, purchaseSubTotal: Int(product.optionGroups[indexPath.section-3].options![indexPath.row].price!), option: optionGroupOptions,  parentOptionGroup:product?.optionGroups[indexPath.section-2],customerOrderItem: items)
                
                customerOrderItemOptionArray.append(customerOrderItemOptionObj)
                
                if(rowsWhichAreChecked.contains(indexPath as NSIndexPath) == false){
                    
                    cell.radio_check_button.setImage(UIImage(named: "check"),for:UIControl.State.normal)
                    
                    if((optionalArray[indexPath.section - 3 - mustCount]) is String)
                    {
                        
                        optionalArray[indexPath.section - 3 - mustCount ] = [oG]
                        customerOptionGroupArray += [oG]
                    }
                    else{
                        customerOptionGroupArray[indexPath.section - 3 - mustCount].options.append(contentsOf: oG.options)
                    }
                    rowsWhichAreChecked.append(indexPath as NSIndexPath)
                    tblOptionGroup.deselectRow(at: indexPath, animated: true)
                }
                else{
                    if let checkedItemIndex = rowsWhichAreChecked.index(of: indexPath as NSIndexPath){
                        cell.radio_check_button.setImage(UIImage(named: "uncheck"),for:UIControl.State.normal)
                        if let index = customerOptionGroupArray[indexPath.section - 3 - mustCount].options.index(where: {$0.name == optionGroupOptions.name})
                        {
                            customerOptionGroupArray[indexPath.section - 3 - mustCount].options.remove(at: index)
                        }
                        customerOrderItemOptionArray.remove(at: checkedItemIndex)
                        rowsWhichAreChecked.remove(at: checkedItemIndex)
                        tblOptionGroup.deselectRow(at: indexPath, animated: true)
                    }
                }
                
            }
        }
        else{
            tblOptionGroup.allowsSelection = false
        }
    }
}
extension NewItemDetailVC: radio_checkDelegate{
    func didCheck_Radio_CheckButton(cell: productOptionGroupCell) {
        let indexPath = self.tblOptionGroup.indexPath(for: cell)
        
        //let indexPath = self.tblCheckOut.indexPathForSelectedRow //optional, to get from any UIButton for example
        
        let currentCell = tblOptionGroup.cellForRow(at: indexPath!) as! productOptionGroupCell
        currentCell.radio_check_button.setImage(UIImage(named: "radiobutton"),for:UIControl.State.normal)
      
    }

}

extension NewItemDetailVC: itemDelegate{
    func didPressAddItem(cell: addToCartButtonCell) {
        
        if(mustArray.contains("") && optionGroup.count > 0 ){
            showAlert(title: "Selection is missing", message: "Must choose required selection")
        }
        else{
//            let indexPath = NSIndexPath(row: 0, section: product.optionGroups?.count ?? 0 + 5)
//            let cell = tblOptionGroup.cellForRow(at: indexPath as IndexPath) as! productSpecialInstructionCell
            let specialIstruction = "" //cell.specialInstructions.text!
            
            if (optionGroup.count > 0){
                customerOptionGroupArray += mustArray as! Array<CustomerOptionGroup>
                for (j,i) in customerOptionGroupArray.enumerated(){
                    itemPurchaseSubTotal += Double(i.options[j].price ?? 0.0)
                }
            }
            else{
                
                itemPurchaseSubTotal = ((product.price  ?? 0.0) * Double(qNumber))
            }
            var productPrice = 0.0
            if(product.price != 0.0){
                productPrice = product.price ?? 0.0
                
            }
            else{
                productPrice = itemPurchaseSubTotal
            }
            
            cProduct = CustomerProduct.init(id: product.id, code: product.code, name: product.name, description: product.description, productPhotoURL: product.productPhotoURL ?? "logo", price: productPrice, position: product.position, status: product.status, archive: product.archive, optionGroups: customerOptionGroupArray)
            
            var alreadyItems = getAlreadyCartItems()
            // update existing item in cart
            if alreadyItems.contains(where: { $0.product.name == product.name }) {
                
                for i in alreadyItems.indices {
                    if(alreadyItems[i].product.name == product.name){
                        if(alreadyItems[i].quantity == qNumber || alreadyItems[i].quantity! > qNumber ){
                            qNumber = alreadyItems[i].quantity! + 1
                            itemPurchaseSubTotal = itemPurchaseSubTotal * Double(qNumber)
                            // alreadyItems[i].quantity = qNumber
                        }
                        
                        alreadyItems[i].quantity = qNumber
                        alreadyItems[i].purchaseSubTotal = itemPurchaseSubTotal
                        alreadyItems[i].instructions = specialIstruction
                        alreadyItems[i].customerOrderItemOptions = customerOrderItemOptionArray
                    }
                }
                saveItems(allItems: alreadyItems)
            }
                // add new item in cart
            else{
                items?.quantity = qNumber
                items?.purchaseSubTotal = itemPurchaseSubTotal
                items?.instructions = specialIstruction
                print(String.init(format: "count before adding item is %i", alreadyItems.count))
                
                items =  CustomerOrderItem.init(id: 0, orderItemID: "v1px5bld" , forWho: "", instructions: specialIstruction, quantity: qNumber, purchaseSubTotal: itemPurchaseSubTotal, product: cProduct, customerOrderItemOptions: customerOrderItemOptionArray )
                alreadyItems.append(items!)
                
                saveItems(allItems: alreadyItems)
                
            }
            
            bag = alreadyItems.count
            UserDefaults.standard.set(bag, forKey: "bag")
            cartBag.badge = String(bag)
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: cartBag)]
            showAlert(title: "item is Added in cart", message: "")
        }
        
    }
}

extension NewItemDetailVC : itemPlusMinusDelegate{
    func didTappedAddButton(cell: section4Cell) {
        qNumber += 1
       cell.quantity.text = String(qNumber)
    }
    
    func didTappedMinusButton(cell: section4Cell) {
        if qNumber  > 1 {
            qNumber -= 1
            cell.quantity.text = String(qNumber)
          
        }
    }
}
struct CustomerOrder: Codable {
    let id: Int
    let customerType: String
    let transID: String
    let ipAddress, orderDate: String
    let specialInstructions, customerPhone, customerFirstName, customerLastName: String
    let orderStatus: String
    let billingStatus, printingStatus, creditStatus: String?
    let orderType, paymentType, orderTime: String
    let promoCode: String?
    let sitePreference: String?
    let paymentGateway, paymentGatewayReference: String?
    let orderConfirmationStatus: String
    let orderConfirmationStatusMessage: String?
    let deliveryCharge: Double
    let surCharge: Double?
    let amount: Double
    let subTotal: Double
    let orderDiscount, promoCodeDiscount: Double?
    let orderCredit: String?
    let customerID, branchID: Int
    let processedBySoftware: Int?
    let phoneNotify, sendFax, sendSMS, firstCustomerOrder: Bool
    let preOrdered, companyID: Int
    let customerOrderAddress: CustomerOrderAddress
    let customerOrderTaxes: [CustomerOrderTax]
    let customerOrderItem: [CustomerOrderItem]
    let invoiceOrderDetailID, cardOption: String?
    
    enum CodingKeys: String, CodingKey {
        case id, customerType
        case transID = "transId"
        case ipAddress, orderDate, specialInstructions, customerPhone, customerFirstName, customerLastName, orderStatus, billingStatus, printingStatus, creditStatus, orderType, paymentType, orderTime, promoCode, sitePreference, paymentGateway, paymentGatewayReference, orderConfirmationStatus, orderConfirmationStatusMessage, deliveryCharge, surCharge, amount, subTotal, orderDiscount, promoCodeDiscount, orderCredit
        case customerID = "customerId"
        case branchID = "branchId"
        case processedBySoftware, phoneNotify, sendFax
        case sendSMS = "sendSms"
        case firstCustomerOrder, preOrdered
        case companyID = "companyId"
        case customerOrderAddress, customerOrderTaxes, customerOrderItem, invoiceOrderDetailID, cardOption
    }
}

struct CustomerOrderAddress: Codable {
    let id, addressID: Int?
    let customerOrderAddressFields: [AddressField]
    
    enum CodingKeys: String, CodingKey {
        case id
        case addressID = "addressId"
        case customerOrderAddressFields
    }
}

struct CustomerOrderAddressField: Codable {
    let id: Int
    let fieldName, label, fieldValue: String
}

struct CustomerOrderItem: Codable {
    let id: Int
    var orderItemID: String?
    var forWho: String?
    var instructions: String?
    var quantity: Int?
    var purchaseSubTotal: Double
    var product: CustomerProduct
    var customerOrderItemOptions: [CustomerOrderItemOption]
    
    enum CodingKeys: String, CodingKey {
        case id
        case orderItemID = "orderItemId"
        case forWho, instructions, quantity, purchaseSubTotal, product, customerOrderItemOptions
    }
}

struct CustomerOrderItemOption: Codable {
    //let id : Int
    let quantity, purchaseSubTotal: Int
    let option: Option?
   // let parentOption: Option?
    var parentOptionGroup: OptionGroup?
    var customerOrderItem : CustomerOrderItem?
}

struct Option: Codable {
    let id: Int
    let name: String
    let price: Double?
    let status, archive: Int
}

struct CustomerOptionGroup: Codable {
    let id: Int
    let name, identifierName: String
    let listQuantity, minChoice, maxChoice, status: Int
    let archive, optID: Int
    var options: [Option]
    
    enum CodingKeys: String, CodingKey {
        case id, name, identifierName, listQuantity, minChoice, maxChoice, status, archive
        case optID = "optId"
        case options
    }
}

struct CustomerProduct: Codable {
    let id: Int
    var code, name, description: String
    let productPhotoURL: String
    //let promotionCode: JSONNull?
    let price : Double
    let position, status, archive: Int
    let optionGroups: [CustomerOptionGroup]
    
    enum CodingKeys: String, CodingKey {
        case id, code, name, description
        case productPhotoURL = "productPhotoUrl"
        case price, position, status, archive, optionGroups
    }
}

struct CustomerOrderTax: Codable {
    let id: Int
    let orderType, taxRule, taxLabel: String
    let rate, taxAmount: Double
    let chargeMode: Int
}



//
//
//    
//
