//
//  MainViewSearch.swift
//  UnMile
//
//  Created by user on 3/28/20.
//  Copyright © 2020 Moghees Sheikh. All rights reserved.
//

import UIKit

class MainViewSearch: BaseViewController {

    @IBOutlet weak var searchbar: UISearchBar!
        @IBOutlet weak var searchBarTable: UITableView!
        var isSearching = false
        var productWraper:ProductWrapperSearchList!
        var productWrapperlist: [ProductWrapperList]?
        var product : Product!
        var timer : Timer?
    
        override func viewDidLoad() {
            super.viewDidLoad()
            searchbar.showsCancelButton = true
            searchbar.becomeFirstResponder()
            self.searchBarTable.keyboardDismissMode = .onDrag
        }
        func getCategoryByProduct(productName: String) {
            self.startActivityIndicator()
           
            
            var path =  ProductionPath.menuUrl+"/active-category/?branchId=\(branchId)" + "&productName=\(productName)"
            path = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            print(path)
            
            NetworkManager.getDetails(path: path, params: nil, success: { (json, isError) in
                
                do {
                    let jsonData =  try json.rawData()
                    let branch = try JSONDecoder().decode(BranchDetailsResponse.self, from: jsonData)
                    for i in branch.categories{
                        if branch.categories.count != 0 {
                        self.getProductByCategory(pageNo: "0", pageSize: "10", productName: productName, categoryId: "\(i.id)")
                        }
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
            
             self.startActivityIndicator()
             UIApplication.shared.beginIgnoringInteractionEvents()
            
            let parameters: [String : Any] = ["pageNo":pageNo,
                                              "pageSize": pageSize,
                                              "categoryId": "",
                                              "nameParam":productName,
                                              "menuId": 511]
    
            
            NetworkManager.getDetails(path: ProductionPathV2.productUrl + "/all", params: parameters, success: { (json, isError) in
                
               
                
                do {
                                let jsonData =  try json.rawData()
                                self.productWraper = try JSONDecoder().decode(ProductWrapperSearchList.self, from: jsonData)
                                print(self.productWraper)
                
                               
                                DispatchQueue.main.asyncAfter(deadline: .now() , execute: {
                                if self.productWraper.number == 0 {
                                    self.productWrapperlist = self.productWraper.productWrapperList
                                   self.productWrapperlist =  self.productWrapperlist?.sorted { $0.product!.name < $1.product!.name}
                                } else {
                                    self.productWrapperlist =  self.productWrapperlist ?? [] + self.productWraper.productWrapperList
                                       self.productWrapperlist =  self.productWrapperlist?.sorted { $0.product!.name < $1.product!.name}
                                }
                                    
//                                    self.productWrapperlist = self.productWraper.productWrapperList
                                      self.searchBarTable.reloadData()
                            
                                    UIApplication.shared.endIgnoringInteractionEvents()
                                    self.stopActivityIndicator()
                                })
                    
                } catch let myJSONError {
                    print(myJSONError)
                       UIApplication.shared.endIgnoringInteractionEvents()
                    self.showAlert(title: Strings.error, message: Strings.somethingWentWrong)
                }
                
            }) { (error) in
                //self.dismissHUD()
                   UIApplication.shared.endIgnoringInteractionEvents()
                self.showAlert(title: Strings.error, message: Strings.somethingWentWrong)
            }
        }
    }

    extension MainViewSearch : UISearchBarDelegate{
    
    
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if(searchText != ""){
                //getCategoryByProduct(productName: searchText)
                timer?.invalidate() //cancels out previous Timers
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (Timer) in
//                    self.getCategoryByProduct(productName: searchText)
                    self.getProductByCategory(pageNo: "0", pageSize: "10", productName: searchText, categoryId: "")
                    
                })
                
                }
               
            
            else{
                productWrapperlist?.removeAll()
                searchBarTable.reloadData()
                return
            }
         
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
        
       
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            self.view.endEditing(true)
        }
    
    }

    extension MainViewSearch: UITableViewDelegate,UITableViewDataSource{
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return  productWrapperlist?.count ??  0
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell  = tableView.dequeueReusableCell(withIdentifier: "cells", for: indexPath) as! GernalSearchCellTableViewCell
//            if indexPath.row >= 0 && indexPath.row < productWrapperlist?.count ??  0 {
            cell.lblProduct.text = (productWrapperlist?[indexPath.row].product?.name ?? "") + "  (\(  productWrapperlist?[indexPath.row].categoryName ?? ""))"
//            }
            
            
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
            return 70
        }
}
struct ProductWrapperSearchList: Codable {
    let hasNext: Bool?
    let numberOfRecord, totalRecord: Int?
    let totalStores: Int?
    let totalPages, number: Int?
    let productWrapperList: [ProductWrapperList]
}
