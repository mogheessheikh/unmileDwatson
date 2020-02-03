//
//  GernalSearchVC.swift
//  UnMile
//
//  Created by user on 1/18/20.
//  Copyright © 2020 Moghees Sheikh. All rights reserved.
//

import UIKit

class GernalSearchVC: BaseViewController {

    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var searchBarTable: UITableView!
    var isSearching = false
    var productWraper:ProductWraper!
    var productWrapperlist: [ProductWrapperList]?
    var product : Product!
    override func viewDidLoad() {
        super.viewDidLoad()
      
        searchbar.becomeFirstResponder()
        navigationController?.navigationBar.isHidden = true
        // Do any additional setup after loading the view.
    }
    func getCategoryByProduct(productName: String) {
        self.startActivityIndicator()
        let path =  ProductionPath.menuUrl+"/active-category/?branchId=\(branchId)" + "&productName=\(productName)"
      
        print(path)
        
        NetworkManager.getDetails(path: path, params: nil, success: { (json, isError) in
            
            do {
                let jsonData =  try json.rawData()
                let branch = try JSONDecoder().decode(BranchDetailsResponse.self, from: jsonData)
                for i in branch.categories{
                    
                     self.getProductByCategory(pageNo: "0", pageSize: "15", productName: productName, categoryId: "\(i.id)")
                }
             
               
                self.stopActivityIndicator()
            } catch let myJSONError {
                
                #if DEBUG
                self.showAlert(title: "Error", message: myJSONError.localizedDescription)
                #endif
                
                print(myJSONError)
                self.showAlert(title: Strings.error, message: Strings.somethingWentWrong)
            }
            
        }) { (error) in
            //self.dismissHUD()
            self.showAlert(title: Strings.error, message: Strings.somethingWentWrong)
        }
    }
    func getProductByCategory(pageNo: String, pageSize: String , productName: String , categoryId: String){
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.startActivityIndicator()
        
        let parameters: [String : Any] = ["pageNo":pageNo,
                                          "pageSize": pageSize,
                                          "categoryId": categoryId,
                                          "productName":productName]
        print(parameters)
        
        NetworkManager.getDetails(path: ProductionPath.productUrl + "/get-active-bycategoryId/", params: parameters, success: { (json, isError) in
            
            self.view.endEditing(true)
            
            do {
                let jsonData =  try json.rawData()
                print(jsonData)
                self.productWraper = try JSONDecoder().decode(ProductWraper.self, from: jsonData)
                print(self.productWraper)
                
                if self.productWraper.number == 0 {
                    self.productWrapperlist = self.productWraper.productWrapperList
                } else {
                    self.productWrapperlist =  self.productWrapperlist! + self.productWraper.productWrapperList
                }
                DispatchQueue.main.asyncAfter(deadline: .now() , execute: {
                    // self.productSearchBar.becomeFirstResponder()
                    self.searchbar.becomeFirstResponder()
                    self.searchBarTable.reloadData()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.stopActivityIndicator()
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

extension GernalSearchVC : UISearchBarDelegate{
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText != ""){
            getCategoryByProduct(productName: searchText)
            self.searchBarTable.reloadData()
        }
        else{
            return
        }
        searchBar.showsCancelButton = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        if let tabbarVC = Storyboard.main.instantiateViewController(withIdentifier: "TabbarController") as? UITabBarController,
        let nvc = tabbarVC.viewControllers?[0] as? UINavigationController,
            let _ = nvc.viewControllers[0] as? Main {
                UIApplication.shared.keyWindow!.replaceRootViewControllerWith(tabbarVC, animated: true, completion: nil)
                       }
    }
   
}

extension GernalSearchVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  productWrapperlist?.count ??  0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "cells", for: indexPath) as! GernalSearchCellTableViewCell
        if indexPath.row >= 0 && indexPath.row < productWrapperlist?.count ??  0 {
            cell.lblProduct.text = productWrapperlist?[indexPath.row].product?.name
        }
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         if indexPath.row >= 0 {
        product = productWrapperlist?[indexPath.row].product
        let item = Storyboard.main.instantiateViewController(withIdentifier: NewItemDetailVC.identifier) as! NewItemDetailVC
        item.product = product
        searchBarTable.deselectRow(at: indexPath, animated: false)
        self.navigationController?.pushViewController(item, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
