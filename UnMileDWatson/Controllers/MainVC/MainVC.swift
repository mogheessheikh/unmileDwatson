//
//  MainVC.swift
//  UnMile
//
//  Created by Adnan Asghar on 1/14/19.
//  Copyright © 2019 Adnan Asghar. All rights reserved.
//

import UIKit
import SideMenu
import Foundation


enum DeliveryZoneType {
    static let cityArea = "CITYAREA"
    static let postalCode = "POSTALCODE"
}

class MainVC: BaseViewController {
    
    @IBOutlet weak var cartButton: UIBarButtonItem!
    @IBOutlet weak var movingWebText: UIWebView!
    @IBOutlet weak var movingTextLable: UILabel!
    var city: CityObject?
    var area: AreaObject?
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var sliderCollection: UICollectionView!
    @IBOutlet weak var appIcon: UIImageView!
    @IBOutlet weak var orderNow: UIButton!
    let cartBag = SSBadgeButton()
    @IBOutlet weak var categorySearchBar: UISearchBar!
    @IBOutlet weak var popularCollectionView: UICollectionView!
    var companyDetails: CompanyDetails!
    var branchCategories: BranchDetailsResponse?
    lazy var discoverMenu : UIButton = {
        let btn = UIButton(frame: CGRect.zero)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Discover Menu", for: .normal)
        btn.backgroundColor = Color.purple
        return btn
    }()
    var firstLabel: UILabel!
    
    var deliveryZoneType = DeliveryZoneType.cityArea
    
    var companyBanner: [BranchBanner]?
    
    var timer = Timer()
    var counter = 0
    
    var catagoryId = 0
    var categoryLocationId = 0
    var categoryName = ""
    var popUpView: UploadPrescriptionView!
    var imagePicker = UIImagePickerController()
    var img :UIImage!
    var bag = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let alreadyItems = getAlreadyCartItems()
        cartBag.frame = CGRect(x: 0, y: 0, width: 25, height: 30)
        cartBag.setImage(UIImage(named: "add to cart")?.withRenderingMode(.automatic), for: .normal)
        cartBag.badgeEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 15)
        cartBag.addTarget(self, action: #selector(cartButtonTapped), for: .touchUpInside)
        bag = alreadyItems.count
        UserDefaults.standard.set(bag, forKey: "bag")
        cartBag.badge = String(bag)
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: cartBag)]
        
        
        
        // ******************START-POPUPVIEW**********************
        popUpView = Bundle.main.loadNibNamed("UploadPrescriptionPopUP", owner: nil, options: [:])?.first as? UploadPrescriptionView
        
        
        popUpView.btnCamera.layer.cornerRadius = 7
        popUpView.btnGallery.layer.cornerRadius = 7
        
        imagePicker.delegate = self
        popUpView.btnCloseView.addTarget(self, action: #selector(closePopUp(with:)), for: .touchUpInside)
        popUpView.btnCamera.addTarget(self, action: #selector(openCamera(with:)), for: .touchUpInside)
        popUpView.btnGallery.addTarget(self, action: #selector(openGallery(with:)), for: .touchUpInside)
        
        // ******************END-POPUPVIEW***************************
        
        
        
        // ******************START-MARQUEE-TEXT*********************
        companyDetails = getCompanyObject(keyForSavedCompany)
        let message =  companyDetails.companyAlertNotification[0].message
        
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Bodoni 72", size: 20)!]
        
        orderNow.layer.borderWidth = 1
        movingWebText.backgroundColor = Color.blue
        movingWebText.tintColor = Color.blue
        
        movingWebText.loadHTMLString("<html><body><font face='Bodoni 72 Bold' size='10'><b><marquee style='color:red' scrollamount= '10'>\(message!)</b></marquee></font></body></html>", baseURL: nil)
        
        // ******************END-MARQUEE-TEXT*********************
        
        
        
        slideMenu()
        getBranchCategories()
        getbranchDetail()
        getBranchBanners()
        pageControl.numberOfPages = companyBanner?.count ?? 0
        pageControl.currentPage = 0
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 6.0, target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let alreadyItems = getAlreadyCartItems()
        bag = alreadyItems.count
        UserDefaults.standard.set(bag, forKey: "bag")
        cartBag.badge = String(bag)
        
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
    
    @objc func changeImage() {
        
        if counter < companyBanner?.count ?? 0 {
            let index = IndexPath.init(item: counter, section: 0)
            self.sliderCollection.scrollToItem(at: index , at: .centeredHorizontally, animated: true)
            pageControl.currentPage = counter
            counter += 1
        } else {
            counter = 0
            let index = IndexPath.init(item: counter, section: 0)
            self.sliderCollection.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
            pageControl.currentPage = counter
            counter = 1
        }
        
    }
    func getbranchDetail(){
        
        self.startActivityIndicator()
        let path = ProductionPath.branchUrl + "/\(branchId)"
        print(path)
        
        NetworkManager.getDetails(path: path, params: nil, success: { (json, isError) in
            
            do {
                let jsonData =  try json.rawData()
                let branch = try JSONDecoder().decode(Branch.self, from: jsonData)
                self.saveBranchObject(Object: branch, key: keyForSavedBranch)
                self.popularCollectionView.reloadData()
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
    
    func getBranchCategories() {
        
        self.startActivityIndicator()
        let path = ProductionPath.menuUrl + "/active-category?branchId=\(branchId)&productName="
        print(path)
        
        NetworkManager.getDetails(path: path, params: nil, success: { (json, isError) in
            
            do {
                let jsonData =  try json.rawData()
                self.branchCategories = try JSONDecoder().decode(BranchDetailsResponse.self, from: jsonData)
                self.saveBranchCategories(Object: self.branchCategories!, key: keyForSavedCategory)
                self.popularCollectionView.reloadData()
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
    
    func getBranchBanners(){
        
        self.startActivityIndicator()
        let path = ProductionPath.companyBannerUrl + "/all"
        print(path)
        let params = ["companyId": companyId] as [String : Any]
        NetworkManager.getDetails(path: path, params: params, success: { (json, isError) in
            
            do {
                let jsonData =  try json.rawData()
                self.companyBanner = try JSONDecoder().decode([BranchBanner].self, from: jsonData)
                
                self.sliderCollection.reloadData()
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
    
    @IBAction func cartButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "mainTocart", sender: self)
    }
    
    @IBAction func orderNowPressed(_ sender: Any) {
        performSegue(withIdentifier: "mainTOmenu", sender: self)
        
    }
    
    @IBAction func uploadPrescriptionTapped(_ sender: Any) {
        view.addSubview(popUpView)
        view.addConstraint(NSLayoutConstraint(item: popUpView as Any, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: popUpView as Any, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: popUpView as Any, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: popUpView as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,multiplier: 1, constant: 667))
        
        
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
extension MainVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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

extension MainVC: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        categorySearchBar.text = ""
        categorySearchBar.endEditing(true)
        
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let searchBar = Storyboard.main.instantiateViewController(withIdentifier: GernalSearchVC.identifier)
        categorySearchBar.endEditing(true)
        self.navigationController?.pushViewController(searchBar, animated: true)
    }
}
extension MainVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == sliderCollection {
            
            return companyBanner?.count ?? 0
        }
        else{
            
            return branchCategories?.categories.count ?? 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == sliderCollection {
            
            let cellA = collectionView.dequeueReusableCell(withReuseIdentifier: "cell1", for: indexPath) as! SliderCollectionViewCell
            
            
            
            if let urlSliderString =  companyBanner?[indexPath.row].bannerURL,
                let url = URL(string: urlSliderString)  {
                cellA.sliderImg.af_setImage(withURL: url, placeholderImage: UIImage(), imageTransition: .crossDissolve(1), runImageTransitionIfCached: true)
            }
            return cellA
        }
            
        else
        {
            let cellB = collectionView.dequeueReusableCell(withReuseIdentifier: "cell2", for: indexPath) as! PopularCollectionViewCell
            cellB.layer.borderWidth = 2.0
            cellB.layer.borderColor = UIColor.gray.cgColor
            cellB.popularLbl.text = branchCategories?.categories[indexPath.row].name
            
            if let urlString = branchCategories?.categories[indexPath.row].imageURL,
                let url = URL(string: urlString)  {
                cellB.popularImg.af_setImage(withURL: url, placeholderImage: UIImage(), imageTransition: .crossDissolve(1), runImageTransitionIfCached: true)
            }
            
            return cellB
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView == popularCollectionView){
            catagoryId = (branchCategories?.categories[indexPath.row].id)!
            categoryName = (branchCategories?.categories[indexPath.row].name)!
            categoryLocationId = indexPath.row
            performSegue(withIdentifier: "mainTOmenu", sender: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (collectionView == sliderCollection){
            return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
        }
        else{
            return CGSize(width: 40, height: 40)
        }
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
    let status: Int
    let createdDate, createdBy, updatedDate, updatedBy: String
    let company: String?
    
    enum CodingKeys: String, CodingKey {
        case id, label, displayType, position
        case bannerURL = "bannerUrl"
        case status, createdDate, createdBy, updatedDate, updatedBy, company
    }
}

