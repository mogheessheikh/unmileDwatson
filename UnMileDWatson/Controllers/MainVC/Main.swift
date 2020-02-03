//
//  Main.swift
//  UnMile
//
//  Created by user on 1/2/20.
//  Copyright © 2020 Moghees Sheikh. All rights reserved.
//

import UIKit
import SideMenu


class Main: BaseViewController {

    
    
    
    @IBOutlet weak var mainTableView: UITableView!
    var pageController = UIPageControl()
    var bag = 0
    let cartBag = SSBadgeButton()
    var catagoryId = 0
    var categoryLocationId = 0
    var categoryName = ""
    var branchCategories: BranchDetailsResponse?
     var companyDetails: CompanyDetails!
    var popUpView: UploadPrescriptionView!
    var imagePicker = UIImagePickerController()
    var img :UIImage!
    override func viewDidLoad() {
       
        // Do any additional setup after loading the view.
        
        // ******************START-POPUPVIEW**********************
               popUpView = Bundle.main.loadNibNamed("UploadPrescriptionPopUP", owner: nil, options: [:])?.first as? UploadPrescriptionView
               
               
               popUpView.btnCamera.layer.cornerRadius = 7
               popUpView.btnGallery.layer.cornerRadius = 7
               
     imagePicker.delegate = (self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate)
               popUpView.btnCloseView.addTarget(self, action: #selector(closePopUp(with:)), for: .touchUpInside)
               popUpView.btnCamera.addTarget(self, action: #selector(openCamera(with:)), for: .touchUpInside)
               popUpView.btnGallery.addTarget(self, action: #selector(openGallery(with:)), for: .touchUpInside)
               
               // ******************END-POPUPVIEW***************************

        companyDetails = getCompanyObject(keyForSavedCompany)
     
       initiateCartButton()
       registerTableViewCells()
       slideMenu()
//        categotyCollection.delegate = self as! UICollectionViewDelegate
//        categotyCollection.dataSource = self
           getBranchCategories()
           getbranchDetail()
    
    }
     override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          let alreadyItems = getAlreadyCartItems()
          bag = alreadyItems.count
          UserDefaults.standard.set(bag, forKey: "bag")
          cartBag.badge = String(bag)
          
      }
    func getbranchDetail(){
              
              self.startActivityIndicator()
        UIApplication.shared.beginIgnoringInteractionEvents()
              let path = ProductionPath.branchUrl + "/\(branchId)"
              print(path)
              
              NetworkManager.getDetails(path: path, params: nil, success: { (json, isError) in
                  
                  do {
                      let jsonData =  try json.rawData()
                      let branch = try JSONDecoder().decode(Branch.self, from: jsonData)
                      self.saveBranchObject(Object: branch, key: keyForSavedBranch)
                     
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.stopActivityIndicator()
                  } catch let myJSONError {
                      
                      #if DEBUG
                     // self.showAlert(title: "Error", message: myJSONError.localizedDescription)
                      #endif
                      
                      print(myJSONError)
                      self.showAlert(title: Strings.error, message: Strings.somethingWentWrong)
                  }
                  
              }) { (error) in
                 // self.dismissHUD()
                  self.showAlert(title: Strings.error, message: Strings.somethingWentWrong)
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
                      //self.categoryCollection.reloadData()
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
          
    func registerTableViewCells(){
        mainTableView.register(UINib(nibName: "WebViewCell", bundle: Bundle.main), forCellReuseIdentifier: "WebViewCell")
        mainTableView.register(UINib(nibName: "UploadPrescriptionCell", bundle: Bundle.main), forCellReuseIdentifier: "UploadPrescriptionCell")
        mainTableView.register(UINib(nibName: "OrderNowTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "OrderNowTableViewCell")
        mainTableView.register(UINib(nibName: "SearchBarCell", bundle: Bundle.main), forCellReuseIdentifier: "SearchBarCell")
    }
    func initiateCartButton(){
        let alreadyItems = getAlreadyCartItems()
        cartBag.frame = CGRect(x: 0, y: 0, width: 25, height: 30)
        cartBag.setImage(UIImage(named: "add to cart")?.withRenderingMode(.automatic), for: .normal)
        cartBag.badgeEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 15)
        cartBag.addTarget(self, action: #selector(cartButtonTapped), for: .touchUpInside)
        bag = alreadyItems.count
        UserDefaults.standard.set(bag, forKey: "bag")
        cartBag.badge = String(bag)
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: cartBag)]
    }
    
    func uploadPrescriptionViewLoad()  {
            view.addSubview(popUpView)
                  view.addConstraint(NSLayoutConstraint(item: popUpView as Any, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
                  view.addConstraint(NSLayoutConstraint(item: popUpView as Any, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
                  
                  view.addConstraint(NSLayoutConstraint(item: popUpView as Any, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0))
                  view.addConstraint(NSLayoutConstraint(item: popUpView as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,multiplier: 1, constant: 667))
    }
   @IBAction func cartButtonTapped(_ sender: Any) {
          performSegue(withIdentifier: "mainTocart", sender: self)
      }
    
    func slideMenu(){
         // Define the menus
         
         // UISideMenuNavigationController is a subclass of UINavigationController, so do any additional configuration
         // of it here like setting its viewControllers. If you're using storyboards, you'll want to do something like:
         let menuLeftNavigationController = Storyboard.main.instantiateViewController(withIdentifier: "UISideMenuNavigationController") as! SideMenuNavigationController
         SideMenuManager.default.leftMenuNavigationController = menuLeftNavigationController
         
         // (Optional) Enable gestures. The left and/or right menus must be set up above for these to work.
         // Note that these continue to work on the Navigation Controller independent of the view controller it displays!
         SideMenuManager.default.addPanGestureToPresent(toView: self.navigationController!.navigationBar)
         SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
         
         // (Optional) Prevent status bar area from turning black when menu appears:
         SideMenuManager.default.menuFadeStatusBar = false
         
     }
    
     @IBAction func sideMenuTapped(_ sender: Any) {
         present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
     }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "mainTOmenu"{
              let vc = segue.destination as! BranchCategoryProductsVC
              if(catagoryId != 0){
                  vc.catagoryId = self.catagoryId
                  vc.categoryLocationId = categoryLocationId
                  vc.categoryName = self.categoryName

              }
              vc.branchCategoryDetails = self.branchCategories
          }
      }
    
    
    @objc func closePopUp(with sender: UIButton){
           
           popUpView.removeFromSuperview()
       }
       @objc func openCamera(with sender:UIButton){
           
           if(UIImagePickerController .isSourceTypeAvailable(.camera)){
               imagePicker.sourceType = .camera
               imagePicker.allowsEditing = true
               self.present(imagePicker, animated: true, completion: nil)
           } else {
               showAlert(title: "Warning", message:  "You don't have camera")
           }
       }
       @objc func openGallery(with sender: UIButton){
           
           imagePicker.sourceType = .savedPhotosAlbum
           imagePicker.allowsEditing = true
           
           present(imagePicker, animated: true, completion: nil)
       }
}
extension Main: UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
       return 6
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        if(section == 0){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MainSliderTableviewCell", for: indexPath) as! MainSliderTableviewCell
            view.addSubview(pageController)
            return cell
            
        }
        else if (section == 1){
               let message =  companyDetails.companyAlertNotification[0].message
            let cell = tableView.dequeueReusableCell(withIdentifier: "WebViewCell", for: indexPath) as! WebViewCell
            cell.movingTextWebView.loadHTMLString("<html><body><font face='Bodoni 72' size='3'><b><marquee style='color:red' scrollamount= '10'>\(message ?? "")</b></marquee></font></body></html>", baseURL: nil)
            return cell
            
            
        }
            else if (section == 2)
                   {
                       let cell = tableView.dequeueReusableCell(withIdentifier: "SearchBarCell", for: indexPath) as! SearchBarCell
                    
                    cell.delegate = self
                                 
                        return cell
                       
                   }
        else if (section == 3)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UploadPrescriptionCell", for: indexPath) as! UploadPrescriptionCell
            cell.layer.cornerRadius = 7
            cell.delegate = self
                      return cell
            
        }
        else if (section == 4){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderNowTableViewCell", for: indexPath) as! OrderNowTableViewCell
            cell.delegate = self
            return cell
        }
        else {
                   
                   let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableViewCell", for: indexPath) as! CategoryTableViewCell
            cell.delegate = self
                   return cell
               }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let cell = mainTableView.cellForRow(at: indexPath) as? UploadPrescriptionCell
        {
            cell.didSelect(indexPath: indexPath as NSIndexPath)
            
        }
            mainTableView.deselectRow(at: indexPath, animated: false)
       
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(indexPath.section == 0)
        {
            
            return 250
            
        }
            
        else if(indexPath.section == 1){
            
         return 40

        }

        else if(indexPath.section == 2){
             
             return 60
             
         }
            
        else if(indexPath.section == 3){
            
            return 70
            
        }
        else if(indexPath.section == 5){
            
            return 200
            
        }
        else
        {
            return 70
        }
    }
 
}

extension Main: delegateCategory{
    func didTappedCollectionCell(cell: CategoryTableViewCell, catId: Int, name: String, locationId: Int, catagory: BranchDetailsResponse) {
          categoryLocationId = locationId
              categoryName = name
              catagoryId = catId
            branchCategories = catagory
              performSegue(withIdentifier: "mainTOmenu", sender: self)
    }

}

extension Main: orderCellDelegate{
    func orderNowCell(cell: OrderNowTableViewCell) {
         let CategoryListVC = Storyboard.main.instantiateViewController(withIdentifier: BranchCategorylistVC.identifier)
               CategoryListVC.title = "Categorylist"
               self.navigationController?.pushViewController(CategoryListVC, animated: true)
               }
}
    
    
   
    
extension Main: SearchBarDelegate{
    func didTappedSearchBar(cell: SearchBarCell) {
          
                      let genralSearch = Storyboard.main.instantiateViewController(withIdentifier: GernalSearchVC.identifier)
                      genralSearch.title = "Search Products"
                      self.navigationController?.pushViewController(genralSearch, animated: true)
    }
    
    
}
extension Main: PrscriptionDelegate{
    func uploadPricriptionTapped(cell: UploadPrescriptionCell) {
          uploadPrescriptionViewLoad()

    }
    
    
}
extension Main : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            img = image
            
            let prescriptionVC = Storyboard.main.instantiateViewController(withIdentifier: PrescriptionVC.identifier)as! PrescriptionVC
            prescriptionVC.title = "Upload Prescription"
            prescriptionVC.img = img
            popUpView.removeFromSuperview()
            self.navigationController?.pushViewController(prescriptionVC, animated: true)
        }
        dismiss(animated: true, completion: nil)
    }
}

struct ProductWraper: Codable {
    let hasNext: Bool
    let numberOfRecord, totalRecord: Int?
    let totalStores, totalPages, number: Int?
    let productWrapperList: [ProductWrapperList]
}

// MARK: - ProductWrapperList
struct ProductWrapperList: Codable {
    let product: Product?
    let categoryName: String
    let categoryID: Int
    
    enum CodingKeys: String, CodingKey {
        case product, categoryName
        case categoryID = "categoryId"
    }
}

// MARK: - ProductDiscountRule
struct ProductDiscountRule: Codable {
    let id, discount, status: Int
    let archive: Int?
    let createdDate, expiryDate: String
    let chargeMode: ChargeMode
}

// MARK: - ChargeMode
struct ChargeMode: Codable {
    let id: Int
    let name: String
}


struct BranchBanner: Codable {
    let id: Int
    let label, displayType: String
    let position: Int
    let bannerURL: String?
    let mobileBannerUrl: String?
    let status: Int
    let createdDate, createdBy, updatedDate, updatedBy: String
    let company: String?
    
    enum CodingKeys: String, CodingKey {
        case id, label, displayType, position,mobileBannerUrl
        case bannerURL = "bannerUrl"
        case status, createdDate, createdBy, updatedDate, updatedBy, company
    }
}
