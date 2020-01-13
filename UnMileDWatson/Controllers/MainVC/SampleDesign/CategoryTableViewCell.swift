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

class CategoryTableViewCell: UITableViewCell,UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
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
        
         catagoryId = (branchCategories?.categories[indexPath.row].id)!
                   categoryName = (branchCategories?.categories[indexPath.row].name)!
                   categoryLocationId = indexPath.row
       
        delegate.didTappedCollectionCell(cell: self, catId: catagoryId,name:categoryName,locationId:categoryLocationId,catagory: branchCategories!)
        
    }
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
          
                return CGSize(width: 70, height: 70)
            
        }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    	


  
    @IBOutlet weak var categoryCollection: UICollectionView!
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
        self.categoryCollection.delegate = self
        self.categoryCollection.dataSource = self
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
