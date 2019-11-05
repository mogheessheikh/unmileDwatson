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
    //var items : OrderItem!
    var branch: BranchDetailsResponse!
    var allItems : [CustomerOrderItem]!
    var addMoreItems : [CustomerOrderItem]!
    @IBOutlet var lblTotalPrice: UILabel!
    @IBOutlet var addItems: UIButton!
    @IBOutlet var tblCart: UITableView!
    @IBOutlet var checkOut: UIButton!
    
    //var items: ItemsDetailVC = ItemsDetailVC(nibName: nil, bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allItems = getAlreadyCartItems()
        for (_,j) in allItems.enumerated(){
          subTotal  += j.purchaseSubTotal
        }
      
        lblTotalPrice.text = "Grand Total : \(subTotal)"

        branch = getBranchObject(key: keyForSavedBranch)
        
        isBranchOpenClose = isBranchClose()
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
        tblCart.reloadData()
        if(allItems.count == 0){
            //            checkOut.isEnabled = false
            //            checkOut.isUserInteractionEnabled = false
            checkOut.isHidden = true
        }
        else{
            checkOut.isHidden =  false
        }
    }
    func isBranchClose() -> String
    {
        startActivityIndicator()
        let url = ProductionPath.branchUrl + "/is-branch-close/\(branchId)"
        print(url)
        NetworkManager.getDetails(path: url , params: nil, success: { (json, isError) in
            
            do {
                self.isBranchOpenClose = json.rawString()!
                //                self.transId =  String(data:  jsonData, encoding: String.Encoding.utf8)!
                // let anArray = try JSONDecoder().decode(AreaResponse.self, from: jsonData)
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
        
        return isBranchOpenClose
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cart2checkout"{
 
            let checkOut = segue.destination as? CheckOutVC
            checkOut?.totalprice = totalPrice
        }
        else if (segue.identifier == "cartToBranchCategories"){
            let vc = segue.destination as! BranchCategoryProductsVC
            vc.branchDetails = self.branch
            
        }
        
    }
    @IBAction func addMoreItems(_ sender: Any) {
        
        performSegue(withIdentifier: "cartToBranchCategories", sender: nil)
    }
    
    @IBAction func checkOut(_ sender: Any) {
       
       if tblCart.visibleCells.isEmpty {
        showAlert(title: "Cart is empty", message: "Add Items in card to continue")
        }
       else{
      
        if isBranchOpenClose == "false"//"true" //"false"//"true"
        {
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
//            showAlert(title: "Dwatson is Close Now", message: "You cant place your order when branch is close")
            if UserDefaults.standard.object(forKey: keyForSavedCustomer) != nil{
                let urlArray = allItems.map({ $0.id })
                let urlSet = Set(urlArray)
                print(urlSet)
                performSegue(withIdentifier: "cart2checkout", sender: nil)
                
        }
        }
       
       
        
     
    }
}
}

extension CartVC: CartDelegate{
    
    func didTappedDeleteButton(cell: CartTableViewCell) {
         var indexPath = self.tblCart.indexPath(for: cell)
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
        var indexPath = self.tblCart.indexPath(for: cell)
        
        itemPrice = Double(addMoreItems[(indexPath?.row)!].product.price)
        quantity = addMoreItems[(indexPath?.row)!].quantity!
           quantity += 1
            itemTotalPrice = itemPrice * Double(quantity)
            totalPrice = totalPrice + itemPrice
        cell.Quantity.text = "Quantity \(quantity)"
        cell.TotalPrice.text = "Total Pkr : \(itemTotalPrice)"
        lblTotalPrice.text = "Grand Total : \(totalPrice)"
        addMoreItems[(indexPath?.row)!].quantity = quantity
        addMoreItems[(indexPath?.row)!].purchaseSubTotal = totalPrice
        
        saveItems(allItems: addMoreItems )
    
    }
    
    func didTappedMinusButton(cell: CartTableViewCell) {
        var indexPath = self.tblCart.indexPath(for: cell)
        addMoreItems = getAlreadyCartItems()
       
        quantity = addMoreItems[indexPath!.row].quantity!
        itemPrice = Double(addMoreItems[indexPath!.row].product.price)
        
        if quantity  > 1 {
            quantity -= 1
          itemTotalPrice = itemPrice * Double(quantity)
            totalPrice = totalPrice - itemPrice
        cell.Quantity.text = "Quantity \(quantity)"
        cell.TotalPrice.text = "Total Pkr: \(itemTotalPrice)"
        lblTotalPrice.text = "Grand Total : \(totalPrice)"
            addMoreItems[(indexPath?.row)!].quantity = quantity
            addMoreItems[(indexPath?.row)!].purchaseSubTotal = totalPrice
            saveItems(allItems: addMoreItems )
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
        
        cell.ItemPrice.text = "Price:\(items.product.price )"//String(items.itemPrice)//
        
       // totalPrice += items.price
        
        Alamofire.request(items.product.productPhotoURL ?? "").responseImage { response in
            if let image = response.result.value {
                cell.ProductImage.image = image
                
            } else {
                cell.ProductImage.image = UIImage(named: "logo")
            }
        }
        cell.ProductName.text = items.product.name//itemName
        cell.TotalPrice.text = "Total Pkr\(Int(items.purchaseSubTotal ) * (items.quantity!))"//String(items.subTotal)//
//        cell.SpecialInstruction.text = "Special Instructions:\(items.instructions ?? "No Instruction")"//items.instruction//
        cell.Quantity.text = " Quantity \(items.quantity ?? 1)"
        
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
            let alreadyItems = NSMutableArray.init(array: getAlreadyCartItems())
            if (alreadyItems.count != 0){
                alreadyItems.removeObject(at: indexPath.row)
                allItems.remove(at: indexPath.row)
                self.tblCart.deleteRows(at: [indexPath] , with: .fade)
                //tblCart.beginUpdates()

                saveItems(allItems: alreadyItems as! [CustomerOrderItem])
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
    }
}
