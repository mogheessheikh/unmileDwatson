//
//  CategoryTableViewCell.swift
//  UnMile
//
//  Created by user on 1/3/20.
//  Copyright © 2020 Moghees Sheikh. All rights reserved.
//

import UIKit
protocol delegateCategory {
    func didTappedCollectionCell(cell: CategoryTableViewCell, catId: Int,name:String,locationId:Int,catagory:BranchDetailsResponse)
}

class CategoryTableViewCell: UITableViewCell{
  

  
    
    var companyDetails: CompanyDetails!
    var branchCategories: BranchDetailsResponse?
    var catagoryId = 0
     let activityIndicatorView:UIActivityIndicatorView = UIActivityIndicatorView()
    
  var delegate: delegateCategory!
       var categoryLocationId = 0
       var categoryName = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
     
        getBranchCategories()
        getbranchDetail()
    }
    func getbranchDetail(){
           
           //self.startActivityIndicator()
           let path = ProductionPath.branchUrl + "/\(branchId)"
           print(path)
           
           NetworkManager.getDetails(path: path, params: nil, success: { (json, isError) in
               
               do {
                   let jsonData =  try json.rawData()
                   let branch = try JSONDecoder().decode(Branch.self, from: jsonData)
                   self.saveBranchObject(Object: branch, key: keyForSavedBranch)
                   //self.categoryCollection.reloadData()
                  // self.stopActivityIndicator()
               } catch let myJSONError {
                   
                   #if DEBUG
                  // self.showAlert(title: "Error", message: myJSONError.localizedDescription)
                   #endif
                   
                   print(myJSONError)
                  // self.showAlert(title: Strings.error, message: Strings.somethingWentWrong)
               }
               
           }) { (error) in
               //self.dismissHUD()
               //self.showAlert(title: Strings.error, message: Strings.somethingWentWrong)
           }
       }
       
       func getBranchCategories() {
           
           self.startActivityIndicator()
           let path = ProductionPath.menuUrlV2 + "/?branchId=\(branchId)&productName="
           print(path)
           
           NetworkManager.getDetails(path: path, params: nil, success: { (json, isError) in
               
               do {
                   let jsonData =  try json.rawData()
                   self.branchCategories = try JSONDecoder().decode(BranchDetailsResponse.self, from: jsonData)
                   self.saveBranchCategories(Object: self.branchCategories!, key: keyForSavedCategory)
//                   self.categoryCollection.reloadData()
                   //self.stopActivityIndicator()
               } catch let myJSONError {
                   
                   #if DEBUG
                  // self.showAlert(title: "Error", message: myJSONError.localizedDescription)
                   #endif
                   
                   print(myJSONError)
                  // self.showAlert(title: Strings.error, message: Strings.somethingWentWrong)
               }
               
           }) { (error) in
               //self.dismissHUD()
               //self.showAlert(title: Strings.error, message: Strings.somethingWentWrong)
           }
       }
       

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func saveBranchObject(Object : Branch , key: String){
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(Object) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: key)
        }
    }
    func saveBranchCategories(Object : BranchDetailsResponse , key: String){
           
           let encoder = JSONEncoder()
           if let encoded = try? encoder.encode(Object) {
               let defaults = UserDefaults.standard
               defaults.set(encoded, forKey: key)
           }
       }
    func startActivityIndicator(){
        activityIndicatorView.center = self.center
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.style = UIActivityIndicatorView.Style.whiteLarge
        activityIndicatorView.color = Color.purple
        activityIndicatorView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        self.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
    }
    
    func stopActivityIndicator(){
        
        activityIndicatorView.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        
    }
}
