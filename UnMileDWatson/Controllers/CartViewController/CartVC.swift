//
//  CartVC.swift
//  UnMile
//
//  Created by iMac on 04/03/2019.
//  Copyright © 2019 Adnan Asghar. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

class CartVC: BaseViewController{
    
    var itemPrice = 0.0
    var itemTotalPrice = 0.0
    var logoUrl = ""
    var itemName = ""
    var subTotal = 0.0
    var instruction = ""
    var quantity = 1
    var items: Product!
    var branch: Branch!
    var allItems : [CustomerOrderItem]!
    var addMoreItems : [CustomerOrderItem]!
    @IBOutlet var lblTotalPrice: UILabel!
    @IBOutlet var addItems: UIButton!
    @IBOutlet var tblCart: UITableView!
    @IBOutlet var checkOut: UIButton!
    
    //var items: ItemsDetailVC = ItemsDetailVC(nibName: nil, bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.current.userInterfaceIdiom == .pad{
            lblTotalPrice.font =  lblTotalPrice.font.withSize(35)
            checkOut.titleLabel?.font = checkOut.titleLabel?.font.withSize(30)
        }
        
        allItems = getAlreadyCartItems()
        for (_,j) in allItems.enumerated(){
          self.subTotal  += j.purchaseSubTotal
        }
      
        
        lblTotalPrice.text = "Grand Total : \(self.subTotal)"

        branch = getBranchObject(key: keyForSavedBranch)
    
        isBranchClose = isBranchClose()
    }
    override func viewWillAppear(_ animated: Bool) {
        
        if allItems.count != 0
        {
            UserDefaults.standard.set(allItems.count , forKey: "Bag")
            
        }
        else{
            UserDefaults.standard.removeObject(forKey: "Bag")
            allItems = getAlreadyCartItems()
        }
         //allItems = getAlreadyCartItems()
        
        if(allItems.count == 0){
            //            checkOut.isEnabled = false
            //            checkOut.isUserInteractionEnabled = false
            checkOut.isHidden = true
        }
        else{
            checkOut.isHidden =  false
        }
        tblCart.reloadData()
    }
    func isBranchClose() -> String
    {
        startActivityIndicator()
        UIApplication.shared.beginIgnoringInteractionEvents()
        let url = ProductionPath.branchUrl + "/is-branch-close/\(branchId)"
        print(url)
        NetworkManager.getDetails(path: url , params: nil, success: { (json, isError) in
            
            do {
                self.isBranchClose = json.rawString()!
                UIApplication.shared.endIgnoringInteractionEvents()
                self.stopActivityIndicator()
                
            }
            catch let myJSONError {
                print(myJSONError)
                self.showAlert(title: Strings.error, message: Strings.somethingWentWrong)
            }
            
        }) { (error) in
            
            self.stopActivityIndicator()
            self.showAlert(title: Strings.error, message: Strings.somethingWentWrong)
        }
        
        return isBranchClose
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cart2checkout"{
            allItems = getAlreadyCartItems()
            var total = 0.0
            for (_,j) in allItems.enumerated(){
                total  += j.purchaseSubTotal
            }
            let checkOut = segue.destination as? CheckOutVC
            checkOut?.totalprice = total
        }
        else if (segue.identifier == "cartToBranchCategories"){
         }
        
    }
    @IBAction func addMoreItems(_ sender: Any) {
        
        performSegue(withIdentifier: "cartToBranchCategories", sender: nil)
    }
    
    @IBAction func checkOut(_ sender: Any) {
        allItems = getAlreadyCartItems()
        var total = 0.0
        for (_,j) in allItems.enumerated(){
            total  += j.purchaseSubTotal
        }
       if tblCart.visibleCells.isEmpty {
        showAlert(title: "Cart is empty", message: "Add Items in card to continue")
        }
       else if(total < 500){
        
         showAlert(title: "Add More Items", message: "Your amount is less then the minimum order amount")
       }
       else{
      
        if (isBranchClose == "false")//"false"
        {
            subTotal = 0.0
            allItems = getAlreadyCartItems()
            for (_,j) in allItems.enumerated(){
                subTotal += j.purchaseSubTotal
            }
            if UserDefaults.standard.object(forKey: keyForSavedCustomer) != nil{
                let urlArray = allItems.map({ $0.id })
                let urlSet = Set(urlArray)
                print(urlSet)
                performSegue(withIdentifier: "cart2checkout", sender: nil)
                
            }
            else{
                
                let loginVC = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: LoginViewController.identifier)
                loginVC.title = "Signin"
                self.navigationController?.pushViewController(loginVC, animated: true)
            }
            
        }
        else{
            showAlert(title: "D.Watson is close now", message: "You cant place your order when branch is close")
        }
    }
}
}

extension CartVC: CartDelegate{
    
    func didTappedDeleteButton(cell: CartTableViewCell) {
        let indexPath = self.tblCart.indexPath(for: cell)
         var subTotal = 0.0
        let alreadyItems = NSMutableArray.init(array: getAlreadyCartItems())
        if (alreadyItems.count != 0){
            alreadyItems.removeObject(at: indexPath!.row)
            allItems.remove(at: indexPath!.row)
            self.tblCart.deleteRows(at: [indexPath!] , with: .fade)
            //tblCart.beginUpdates()
            saveItems(allItems: alreadyItems as! [CustomerOrderItem])
            allItems = getAlreadyCartItems()
            for (_,j) in allItems.enumerated(){
                subTotal  += j.purchaseSubTotal
            }
            
            lblTotalPrice.text = "Grand Total : \(subTotal)"
            tblCart.reloadData()
            
            // tblCart.endUpdates()
            if let tabItems = tabBarController?.tabBar.items {
                
                let tabItem = tabItems[1]
                tabItem.badgeValue = "0"
                
                UserDefaults.standard.set(allItems.count , forKey: "Bag")
                if let cartBag = UserDefaults.standard.object(forKey: "Bag"){
                    
                    tabItem.badgeValue = "\(cartBag)"
                    print(cartBag)
                }
                else{
                    
                    tabItem.badgeValue = "0"
                }
            }
        }
    }

    func didTappedAddButton(cell: CartTableViewCell) {
        addMoreItems = getAlreadyCartItems()
        let indexPath = self.tblCart.indexPath(for: cell)
        if(addMoreItems[(indexPath?.row)!].product.optionGroups.count >= 1){
            itemPrice = Double(addMoreItems[(indexPath?.row)!].product.optionGroups[0].options[0].price ?? 0.0)
        }
        else {
            itemPrice = Double(addMoreItems[(indexPath?.row)!].product.price)
        }
        quantity = addMoreItems[(indexPath?.row)!].quantity!
        
            quantity += 1
            itemTotalPrice = itemPrice * Double(quantity)
            var subTotal = 0.0
        addMoreItems[(indexPath?.row)!].quantity = quantity
        addMoreItems[(indexPath?.row)!].purchaseSubTotal = itemTotalPrice
        saveItems(allItems: addMoreItems )
        
         addMoreItems = getAlreadyCartItems()
        for (_,j) in addMoreItems.enumerated(){
            subTotal += j.purchaseSubTotal
        }
        
        cell.Quantity.text = "\(quantity)"
        cell.TotalPrice.text = "Total Pkr : \(itemTotalPrice)"
        lblTotalPrice.text = "Grand Total : \(subTotal)"
        
    
    }
    
    func didTappedMinusButton(cell: CartTableViewCell) {
        let indexPath = self.tblCart.indexPath(for: cell)
        addMoreItems = getAlreadyCartItems()
        quantity = addMoreItems[indexPath!.row].quantity!
        if(addMoreItems[(indexPath?.row)!].product.optionGroups.count >= 1){
            itemPrice = Double(addMoreItems[(indexPath?.row)!].product.optionGroups[0].options[0].price ?? 0.0)
        }
        else {
            itemPrice = Double(addMoreItems[(indexPath?.row)!].product.price)
        }
        
        if quantity  > 1 {
            quantity -= 1
          itemTotalPrice = itemPrice * Double(quantity)
             var subTotal = 0.0
            addMoreItems[(indexPath?.row)!].quantity = quantity
            addMoreItems[(indexPath?.row)!].purchaseSubTotal = itemTotalPrice
            saveItems(allItems: addMoreItems )
            addMoreItems = getAlreadyCartItems()
            for (_,j) in addMoreItems.enumerated(){
                subTotal  += j.purchaseSubTotal
            }
        cell.Quantity.text = "\(quantity)"
        cell.TotalPrice.text = "Total Pkr: \(itemTotalPrice)"
        lblTotalPrice.text = "Grand Total : \(subTotal)"
            
        }
       
    }
    
    
    
}
extension CartVC : UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return items.quantity ?? 1
        return allItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CartTableViewCell
        cell.delegate = self
        let items = allItems[indexPath.row]
        
        if UIDevice.current.userInterfaceIdiom == .pad{
            cell.ItemPrice.font =  cell.ItemPrice.font.withSize(17)
            cell.ProductName.font =  cell.ProductName.font.withSize(25)
            cell.TotalPrice.font =  cell.TotalPrice.font.withSize(17)
            cell.Discount.font =  cell.Discount.font.withSize(17)
            cell.btnDelete.layer.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        }
        
        cell.ItemPrice.text = "Price:\(items.product.price )"//String(items.itemPrice)//
        
       // totalPrice += items.price
        
        Alamofire.request(items.product.productPhotoURL).responseImage { response in
            if let image = response.result.value {
                cell.ProductImage.image = image
                
            } else {
                cell.ProductImage.image = UIImage(named: "logo")
            }
        }
        cell.ProductName.text = items.product.name//itemName
        cell.TotalPrice.text = "RS.\(Double(items.purchaseSubTotal ))"
        if(items.customerOrderItemOptions.count != 0){
            var optionGroupName = ""
            var optionGroupPrice = ""
            for i in items.customerOrderItemOptions.indices {
                optionGroupName += ""//items.customerOrderItemOptions[i].option?.name ?? ""
                optionGroupPrice += "" //"RS.\(Double((items.customerOrderItemOptions[i].option?.price)!))"
            }
            cell.optionName.text = optionGroupName//items.customerOrderItemOptions[indexPath.row].option?.name
            cell.optionPrice.text = optionGroupPrice //"RS.\(Double((items.customerOrderItemOptions[indexPath.row].option?.price)!))"
            cell.Discount.text = "0%"
        }
        else{
            cell.optionName.text = ""
            cell.optionPrice.text = ""
        }
        
        cell.Quantity.text = " \(items.quantity ?? 1)"
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220;
    }
}
