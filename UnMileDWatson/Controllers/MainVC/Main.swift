//
//  Main.swift
//  UnMile
//
//  Created by user on 1/2/20.
//  Copyright © 2020 Moghees Sheikh. All rights reserved.
//

import UIKit
import SideMenu



class Main: BaseViewController,UIPopoverPresentationControllerDelegate {

    
    
    
    @IBOutlet weak var mainTableView: UITableView!
    var pageController = UIPageControl()
    var bag = 0
    let cartBag = SSBadgeButton()
    var catagoryId = 0
    var categoryLocationId = 0
    var categoryName = ""
    var branchCategories: BranchDetailsResponse?
    var companyDetails: CompanyDetails!
    
    override func viewDidLoad() {
       
        // Do any additional setup after loading the view.
        
        // ******************START-POPUPVIEW**********************
             
               
               
//               popUpView.btnCamera.layer.cornerRadius = 7
//               popUpView.btnGallery.layer.cornerRadius = 7
//
//
//               popUpView.btnCloseView.addTarget(self, action: #selector(closePopUp(with:)), for: .touchUpInside)
//               popUpView.btnCamera.addTarget(self, action: #selector(openCamera(with:)), for: .touchUpInside)
//               popUpView.btnGallery.addTarget(self, action: #selector(openGallery(with:)), for: .touchUpInside)
               
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
                    self.stopActivityIndicator()
                      UIApplication.shared.endIgnoringInteractionEvents()
                      self.showAlert(title: Strings.error, message: Strings.somethingWentWrong)
                  }
                  
              }) { (error) in
                 // self.dismissHUD()
                self.stopActivityIndicator()
                UIApplication.shared.endIgnoringInteractionEvents()
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
                    self.stopActivityIndicator()
                      #endif
                      
                      print(myJSONError)
                    self.stopActivityIndicator()
                     self.showAlert(title: Strings.error, message: Strings.somethingWentWrong)
                  }
                  
              }) { (error) in
                  //self.dismissHUD()
                self.stopActivityIndicator()
                  self.showAlert(title: Strings.error, message: Strings.somethingWentWrong)
              }
          }
          
    func registerTableViewCells(){
        mainTableView.register(UINib(nibName: "WebViewCell", bundle: Bundle.main), forCellReuseIdentifier: "WebViewCell")
        mainTableView.register(UINib(nibName: "UploadPrescriptionCell", bundle: Bundle.main), forCellReuseIdentifier: "UploadPrescriptionCell")
         mainTableView.register(UINib(nibName: "UploadPrescriptionIpadCell", bundle: Bundle.main), forCellReuseIdentifier: "UploadPrescriptionIpadCell")
        mainTableView.register(UINib(nibName: "OrderNowTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "OrderNowTableViewCell")
        mainTableView.register(UINib(nibName: "OrderNowIpadCell", bundle: Bundle.main), forCellReuseIdentifier: "OrderNowIpadCell")
        mainTableView.register(UINib(nibName: "SearchBarIpadCell", bundle: Bundle.main), forCellReuseIdentifier: "SearchBarIpadCell")
        mainTableView.register(UINib(nibName: "SearchBarCell", bundle: Bundle.main), forCellReuseIdentifier: "SearchBarCell")
         mainTableView.register(UINib(nibName: "SliderViewIpadCell", bundle: Bundle.main), forCellReuseIdentifier: "SliderViewIpadCell")
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
        
    if UIDevice.current.userInterfaceIdiom == .pad{
    let popVC = UploadPrescriptionIpad (nibName: "UploadPrescriptionIpad", bundle: nil)

        popVC.modalPresentationStyle = .popover

        let popOverVC = popVC.popoverPresentationController
        popOverVC?.delegate = self
        popOverVC?.sourceView = self.view
        popOverVC?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.minY, width: 0, height: 0)
        popVC.preferredContentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)

        self.present(popVC, animated: true)

        }
    else{
      let popVC = UploadPrescription (nibName: "UploadPrescription", bundle: nil)

        popVC.modalPresentationStyle = .popover

        let popOverVC = popVC.popoverPresentationController
        popOverVC?.delegate = self
        popOverVC?.sourceView = self.view
        popOverVC?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.minY, width: 0, height: 0)
        popVC.preferredContentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)

        self.present(popVC, animated: true)
        }

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
        if UIDevice.current.userInterfaceIdiom == .pad{
            if(section == 0){
                       
                       let cell = tableView.dequeueReusableCell(withIdentifier: "SliderViewIpadCell", for: indexPath) as! SliderViewIpadCell
                       view.addSubview(pageController)
                       return cell
                       
                   }
                   else if (section == 1){
                          let message =  companyDetails.companyAlertNotification[0].message
                       let cell = tableView.dequeueReusableCell(withIdentifier: "WebViewCell", for: indexPath) as! WebViewCell
                       cell.movingTextWebView.loadHTMLString("<html><body><font face='Bodoni 72' size='3'><b><marquee style='color:red' scrollamount= '10'>\(message ?? "")</b></marquee></font></body></html>", baseURL: nil)
                       return cell
                       
                       
                   }
                    else if (section == 2){
                        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchBarIpadCell", for: indexPath) as! SearchBarIpadCell
                        cell.delegate = self as? IpadSearchBarDelegate
                        return cell
                        }
                   else if (section == 3)
                   {
                       
                    let cell = tableView.dequeueReusableCell(withIdentifier: "UploadPrescriptionIpadCell", for: indexPath) as! UploadPrescriptionIpadCell
                    cell.layer.cornerRadius = 10
                    cell.delegate = self as? IPadPrscriptionDelegate
                    
                    return cell
                       
                   }
                   else if (section == 4){
                       
                   let cell = tableView.dequeueReusableCell(withIdentifier: "OrderNowIpadCell", for: indexPath) as! OrderNowIpadCell
                       cell.delegate = self as? IpadOrderCellDelegate
                       cell.orderBtn.layer.cornerRadius = 10
                       cell.orderBtn.layer.borderWidth = 6
                       cell.orderBtn.layer.borderColor = UIColor.lightGray.cgColor
                       
                       return cell
                   }
                   else {
                              
                   let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableViewCell", for: indexPath) as! CategoryTableViewCell
                       cell.delegate = self
                              return cell
                          }
        }
        else{
        
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
            cell.orderBtn.layer.cornerRadius = 7
            cell.orderBtn.layer.borderWidth = 2
            cell.orderBtn.layer.borderColor = UIColor.lightGray.cgColor
            
            return cell
        }
        else {
                   
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableViewCell", for: indexPath) as! CategoryTableViewCell
            cell.delegate = self
                   return cell
               }
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
        if UIDevice.current.userInterfaceIdiom == .pad{
            
            if(indexPath.section == 0){
            return 408
            }
                       
            else if(indexPath.section == 1){
            return 90
            }
            else if(indexPath.section == 2){
            return 150
            }
            else if(indexPath.section == 3){
            return 240
            }
            else{
            return 140
            }
            }
        
    
    else{
        
        if(indexPath.section == 0){
            return 250
        }
        else if(indexPath.section == 1){
         return 40
        }
        else if(indexPath.section == 2){
         return 60
         }
        else if(indexPath.section == 3){
        return 120
        }
        else{
        return 70
        }
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
    
extension Main: IpadOrderCellDelegate{
    func orderNowCell(cell: OrderNowIpadCell) {
        let CategoryListVC = Storyboard.main.instantiateViewController(withIdentifier: BranchCategorylistVC.identifier)
        CategoryListVC.title = "Categorylist"
        self.navigationController?.pushViewController(CategoryListVC, animated: true)
        }
    }
   
    
extension Main: SearchBarDelegate{
    func didTappedSearchBar(cell: SearchBarCell) {
        performSegue(withIdentifier: "MainToSearch", sender: self)
    }
    
    
}
extension Main: IpadSearchBarDelegate{
    func didTappedSearchBar(cell: SearchBarIpadCell) {
        performSegue(withIdentifier: "MainToSearch", sender: self)
    }
    
    
}

extension Main: PrscriptionDelegate{
    func uploadPricriptionTapped(cell: UploadPrescriptionCell) {
          uploadPrescriptionViewLoad()

    }
    
    
}
extension Main: IPadPrscriptionDelegate{
    func uploadPricriptionTapped(cell: UploadPrescriptionIpadCell) {
        uploadPrescriptionViewLoad()
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
