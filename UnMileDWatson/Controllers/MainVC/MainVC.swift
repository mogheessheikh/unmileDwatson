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

    var city: CityObject?
    var area: AreaObject?

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var sliderCollection: UICollectionView!
    @IBOutlet weak var appIcon: UIImageView!
    @IBOutlet weak var orderNow: UIButton!
    
    @IBOutlet weak var popularCollectionView: UICollectionView!
    var companyDetails: CompanyDetails!
    var branch: BranchDetailsResponse?
    lazy var discoverMenu : UIButton = {
        let btn = UIButton(frame: CGRect.zero)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Discover Menu", for: .normal)
        btn.backgroundColor = Color.purple
        return btn
    }()
    var firstLabel: UILabel!
    var cityAreaView: CityAreaView!
    var deliveryZoneType = DeliveryZoneType.cityArea
    var imgArr: [UIImage]  = [  UIImage(named:"Order Steps")!,
                                UIImage(named:"sale")! ,
                                UIImage(named:"Free Delivery Services")! ,
                             ]
    var popularImg:[UIImage] = [ UIImage(named:"1")!,
                                  UIImage(named:"2")!,
                                   UIImage(named:"3")!,
                                    UIImage(named:"4")!,
                                     UIImage(named:"5")!,
                                      UIImage(named:"6")!,
                                       UIImage(named:"7")!,
                                        UIImage(named:"8")!,
                                         UIImage(named:"9")!,
                                          UIImage(named:"9")!,
                                           UIImage(named:"9")!
                                ]
        var timer = Timer()
        var counter = 0
    
        var catagoryId = 0
        var categoryLocationId = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        orderNow.layer.cornerRadius = 7
        orderNow.layer.borderWidth = 1
        sliderCollection.layer.cornerRadius = 7
        
        companyDetails = getCompanyObject(keyForSavedCompany)
        slideMenu()
        getBranchDetail()
        
        pageControl.numberOfPages = imgArr.count
        pageControl.currentPage = 0
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
      
        if let tabItems = tabBarController?.tabBar.items {
        
            let tabItem = tabItems[1]
            tabItem.badgeValue = "0"
            if let cartBag = UserDefaults.standard.object(forKey: "Bag"){
                
                tabItem.badgeValue = "\(cartBag)"
                print(cartBag)
            }
            else{
                
                tabItem.badgeValue = "0"
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mainTOmenu"{
             let vc = segue.destination as! RestaurantDetailVC
            if(catagoryId != 0){
               vc.catagoryId = self.catagoryId
                vc.categoryLocationId = categoryLocationId
            }
                vc.branchDetails = self.branch
        }
    }
    
    @objc func changeImage() {
        
        if counter < imgArr.count {
            let index = IndexPath.init(item: counter, section: 0)
            self.sliderCollection.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
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
  
    func getBranchDetail() {
        
        self.startActivityIndicator()
        let path = ProductionPath.menuUrl + "/active-category?branchId=\(branchId)&productName=a"
        print(path)
        
        NetworkManager.getDetails(path: path, params: nil, success: { (json, isError) in
            
            do {
                let jsonData =  try json.rawData()
               self.branch = try JSONDecoder().decode(BranchDetailsResponse.self, from: jsonData)
                
                self.saveBranchObject(Object: self.branch!, key: keyForSavedBranch)
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

    
    func slideMenu(){
        // Define the menus
     
        // UISideMenuNavigationController is a subclass of UINavigationController, so do any additional configuration
        // of it here like setting its viewControllers. If you're using storyboards, you'll want to do something like:
        let menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "UISideMenuNavigationController") as! UISideMenuNavigationController
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        
        // (Optional) Enable gestures. The left and/or right menus must be set up above for these to work.
        // Note that these continue to work on the Navigation Controller independent of the view controller it displays!
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        
        // (Optional) Prevent status bar area from turning black when menu appears:
        SideMenuManager.default.menuFadeStatusBar = false
        
    }
    @IBAction func sideMenuTapped(_ sender: Any) {
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
   

    @IBAction func orderNowPressed(_ sender: Any) {
        performSegue(withIdentifier: "mainTOmenu", sender: self)
    
    }
    

}
extension MainVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == sliderCollection {
       
            return imgArr.count
        }
        else{
            
            return branch?.categories.count ?? 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         if collectionView == sliderCollection {
            
        let cellA = collectionView.dequeueReusableCell(withReuseIdentifier: "cell1", for: indexPath) as! SliderCollectionViewCell
       
            cellA.layer.cornerRadius = 7
    
            cellA.sliderImg.layer.cornerRadius = 7
             cellA.sliderImg.image = imgArr[indexPath.row]
             return cellA
        }
            
        else
         {
            let cellB = collectionView.dequeueReusableCell(withReuseIdentifier: "cell2", for: indexPath) as! PopularCollectionViewCell
            
            cellB.popularLbl.text = branch?.categories[indexPath.row].name
            cellB.popularImg.image = popularImg[indexPath.row]
            return cellB
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView == popularCollectionView){
            catagoryId = (branch?.categories[indexPath.row].id)!
            categoryLocationId = indexPath.row
            performSegue(withIdentifier: "mainTOmenu", sender: self)
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
    let id, discount, status, archive: Int
    let createdDate, expiryDate: String
    let chargeMode: ChargeMode
}

// MARK: - ChargeMode
struct ChargeMode: Codable {
    let id: Int
    let name: String
}




