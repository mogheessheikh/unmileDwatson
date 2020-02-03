//
//  BranchCategorylistVC.swift
//  UnMile
//
//  Created by user on 2/1/20.
//  Copyright © 2020 Moghees Sheikh. All rights reserved.
//

import UIKit

class BranchCategorylistVC: BaseViewController {

    
       
    
    @IBOutlet weak var categoryCollection: UICollectionView!
         var branchCategories: BranchDetailsResponse?
         var category:Category?
         var catagoryId = 0
         var categoryLocationId = 0
         var categoryName = ""
       
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getBranchCategories()
        // Do any additional setup after loading the view.
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
                      self.categoryCollection.reloadData()
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
    func getbranchDetail(){
              
              //self.startActivityIndicator()
              let path = ProductionPath.branchUrl + "/\(branchId)"
              print(path)
              
              NetworkManager.getDetails(path: path, params: nil, success: { (json, isError) in
                  
                  do {
                      let jsonData =  try json.rawData()
                      let branch = try JSONDecoder().decode(Branch.self, from: jsonData)
                      self.saveBranchObject(Object: branch, key: keyForSavedBranch)
                      self.categoryCollection.reloadData()
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
          
}

extension BranchCategorylistVC: UICollectionViewDelegate,UICollectionViewDataSource{
    
      func numberOfSections(in collectionView: UICollectionView) -> Int {
              return 1
          }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return branchCategories?.categories.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionCell", for: indexPath) as! CategoryCollectionCell
        
        cell.layer.borderWidth = 2.0
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.categoryLabel.text = branchCategories?.categories[indexPath.row].name
        
        if let urlString = branchCategories?.categories[indexPath.row].imageURL,
            let url = URL(string: urlString)  {
            cell.popularImg.af_setImage(withURL: url, placeholderImage: UIImage(), imageTransition: .crossDissolve(1), runImageTransitionIfCached: true)
            cell.delegate = self as? CategoryCellDelegate
        }
        return cell
    }
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
        
            category = branchCategories?.categories[indexPath.row]
            let ProductList = Storyboard.main.instantiateViewController(withIdentifier: BranchCategoryProductsVC.identifier) as! BranchCategoryProductsVC
        ProductList.title = "Products"
            ProductList.catagoryId = branchCategories?.categories[indexPath.row].id ?? 0
        self.navigationController?.pushViewController(ProductList, animated: true)
            
        }
         func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
              
                    return CGSize(width: 70, height: 70)
                
            }
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 0
        }
            

}
