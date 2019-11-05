//
//  BranchCategoryProductsVC.swift
//  UnMile
//
//  Created by Adnan Asghar on 1/31/19.
//  Copyright © 2019 Adnan Asghar. All rights reserved.
//

import UIKit
import AlamofireImage
import Foundation
import ScrollableSegmentedControl

class BranchCategoryProductsVC: BaseViewController {

    @IBOutlet weak var collectionViewProduct: UICollectionView!
    @IBOutlet weak var restaurantImage: UIImageView!
    @IBOutlet weak var isOpen: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cuisineLabel: UILabel!
    @IBOutlet weak var minimumOrderLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var serviceImage1: UIImageView!
    @IBOutlet weak var serviceImage2: UIImageView!
    @IBOutlet weak var serviceImage3: UIImageView!
    
    @IBOutlet weak var segmentscrollview: UIScrollView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var segementView: UIView!
    @IBOutlet weak var productSearchBar: UISearchBar!
    
    var product : Product!
    var fetchingMore = false
    var branchDetails: BranchDetailsResponse!
    var productWrapperlist: [ProductWrapperList]?
    var productWraper: ProductWraper!
    var catagoryId = 0
    var categoryLocationId = 0
    var categoryName = ""
    var isSearching = false
    var isSearchingMore = false
    var categoryNameArray:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        if(categoryName != ""){
           title = categoryName
            
        }
        else{
            title = branchDetails.categories[0].name
        }
        
        print(branchDetails)
        print("Number of Cat\(branchDetails.categories.count)")
        

        if(catagoryId != 0){
            getProductsBy(pageNo: "0" , pageSize: "10", productName: "", categoryId: "\(catagoryId)")

        }
        else{
          //  let segment = segmentControl.selectedSegmentIndex
              getProductsBy(pageNo: "0" , pageSize: "10", productName: "", categoryId: "\(branchDetails.categories[0].id)")
        }
//
    }
    override func viewDidAppear(_ animated: Bool) {
        productSearchBar.becomeFirstResponder()
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
   
    func getProductsBy(pageNo: String, pageSize: String , productName: String = "", categoryId: String) {
         UIApplication.shared.beginIgnoringInteractionEvents()
        self.startActivityIndicator()
         
        let parameters: [String : Any] = ["pageNo":pageNo,
                                          "pageSize": pageSize,
                                          "categoryId": categoryId,
                                          "productName":productName]
        print(parameters)

        NetworkManager.getDetails(path: Path.productUrl + "/get-active-bycategoryId/", params: parameters, success: { (json, isError) in
            
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
                    
                self.fetchingMore = false
                self.collectionViewProduct.reloadData()
                UIApplication.shared.endIgnoringInteractionEvents()
                 self.stopActivityIndicator()
                    
                    if (self.isSearchingMore){ self.productSearchBar.becomeFirstResponder() }
                    
                    self.isSearchingMore = true
                  
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

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "newItem"){
            let vc = segue.destination as? NewItemDetailVC
            vc?.product = self.product
        }
        
    }
    
    
}

extension BranchCategoryProductsVC:UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        isSearching = text.isEmpty
        
        return true
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if(catagoryId != 0){
            getProductsBy(pageNo: "0" , pageSize: "10", productName: searchText, categoryId: "\(catagoryId)")
            
        }
        else{
            //  let segment = segmentControl.selectedSegmentIndex
            getProductsBy(pageNo: "0" , pageSize: "10", productName: searchText, categoryId: "\(branchDetails.categories[0].id)")
        }
      
        
    }
    func didPresentSearchController(searchController: UISearchController) {
        productSearchBar.becomeFirstResponder()
    }
}

extension BranchCategoryProductsVC: UICollectionViewDataSource,UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return category[section].products?.count ?? 0
        return productWrapperlist?.count ?? 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! branchCategoriesCellCollectionViewCell
        cell.layer.borderWidth = 2.0
        cell.layer.borderColor = UIColor.gray.cgColor
        if let urlString = productWrapperlist?[indexPath.row].product?.productPhotoURL,
            let url = URL(string: urlString) {
            cell.productImg.af_setImage(withURL: url, placeholderImage: UIImage(), imageTransition: .crossDissolve(1), runImageTransitionIfCached: true)
        }

        cell.productName.text = productWrapperlist?[indexPath.row].product?.name
        cell.productPrice.text = "\(productWrapperlist?[indexPath.row].product?.price ?? 0.0)"
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        product = productWrapperlist?[indexPath.row].product
        performSegue(withIdentifier: "newItem", sender: self)
    }
   
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.height {
            if !fetchingMore{
                if self.productWraper.hasNext {
                    if(catagoryId != 0){
                        getProductsBy(pageNo: "\(self.productWraper.number! + 1)" , pageSize: "10", productName: "", categoryId: "\(catagoryId)")
                        
                    }
                    else{
                        //  let segment = segmentControl.selectedSegmentIndex
                        getProductsBy(pageNo: "\(self.productWraper.number! + 1)", pageSize: "10", productName: "", categoryId: "\(branchDetails.categories[0].id)")
                    }
                
            }
                fetchingMore = true
            }
    }
}
}
extension BranchCategoryProductsVC : addItemDelegate{
    
    func didTappedAddButton(cell: RestaurantDetailCell) {
   
    }
}

struct BranchDetailsResponse: Codable {
    let id: Int
    let name, optiongroupDescription: String
    let code: String?
    let imageURL: String?
    let status, archive: Int
    let branch: Branch
    let categories: [Category]
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case optiongroupDescription = "description"
        case code
        case imageURL = "imageUrl"
        case status, archive, branch, categories
    }
}

struct Branch: Codable {
    let id: Int
    let name, urlPath, phone, fax: String
    let postCode, addressLine1, addressLine2, town: String
    let city, county, country: String
    let locationWebLogoURL: String?
    let emailOrder, emailClient1, emailClient2, emailClient3: String
    //    let emailClientCC, smsClient: String
    let orderConfirmation, clientSendSMS, clientSendMail, clientSendFax: Int
    let clientPhoneNotify, encryptPassword, automaticPrinting, defaultBranch: Int
    let featureBranch: Int
    let timeZone: String
    let score, status, archive: Int
    let orderConfirmationSetting: String
    let outsourcedDelivery: Int
    let branchType: BranchType
    let paymentMethods: [PaymentMethod]?
    let services: [BranchDetailService]
    let taxes: [Tax]
    let orderDiscountRules: [OrderDiscountRule]
    let promoCodeDiscountRules: [PromoCodeDiscountRule]
    let dayOpeningTimes: [DayOpeningTime]
    let deliveryZones: [DeliveryZone]
    let cuisineTypes: [CuisineType]

    enum CodingKeys: String, CodingKey {
        case id, name, urlPath, phone, fax, postCode, addressLine1, addressLine2, town, city, county, country
        case locationWebLogoURL = "locationWebLogoUrl"
        case emailOrder, emailClient1, emailClient2, emailClient3
        //        case emailClientCC, smsClient
        case orderConfirmation
        case clientSendSMS = "clientSendSms"
        case clientSendMail, clientSendFax, clientPhoneNotify, encryptPassword, automaticPrinting, defaultBranch, featureBranch, timeZone, score, status, archive, orderConfirmationSetting, outsourcedDelivery, branchType, paymentMethods, services, taxes, dayOpeningTimes, deliveryZones, cuisineTypes,orderDiscountRules,promoCodeDiscountRules     
    }
}

struct BranchType: Codable {
    let id: Int
    let name: String
}

struct CuisineType: Codable {
    let id: Int
    let name: String
    let status, archive: Int
    let createdate: String?
    let price: Double?
}

struct DayOpeningTime: Codable {
    let id: Int
    let orderType: BranchType
    let day, status, archive: Int
    let dayTimeSlots: [DayTimeSlot]
}

struct DayTimeSlot: Codable {
    let id, startHour, startMinute, closingHour: Int
    let closingMinute, status, archive: Int
}

struct DeliveryZone: Codable {
    let id, minimumDelivery, minimumFreeDelivery: Int
    let lessThanFreeDeliveryCharge, deliveryFee: Double
    //    let firstPartZipCode, secondPartZipCode: String
    let city: CityClass
    let area: AreaStruct
    let status, archive: Int
    let type: CuisineType
}

struct CityClass: Codable {
    let id: Int
    let city: String
    let status, archive: Int
}

struct AreaStruct: Codable {
    let id: Int
    let status, archive: Int
    let area: String
}

struct PaymentMethod: Codable {
    let id: Int
    let charge: Double?
    let minimumAmount, freeAmount: Int
    let status, archive: Int
    let chargeMode: BranchType?
    let branchDetailService: BranchDetailService
    let paymentType: BranchType
    let paymentGateway: PaymentGateway?

    enum CodingKeys: String, CodingKey {
        case id, charge, minimumAmount, freeAmount, status, archive, chargeMode
        case paymentType, paymentGateway
        case branchDetailService = "service"

    }
}

struct BranchDetailService: Codable {
    let id, orderTime, minsBeforeClose, status: Int
    let archive: Int
    let orderType: BranchType
    let hasPreOrdering: Int
    //    let preOrderingNumOfDays: Int
}

struct PaymentGateway: Codable {
    let id: Int
    let name: String
    let companyID: Int?
    let param1, param2, param3: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case companyID = "companyId"
        case param1, param2, param3
    }
}
struct OrderDiscountRule: Codable {
    let id : Int
    let subTotal: Double
    let discount: Double
    let useOnceOnly, status, archive: Int
    let createdDate, expiryDate: String
    let chargeMode, paymentType, orderType: BranchType
}
struct PromoCodeDiscountRule: Codable {
    let id, subTotal: Int
    let discount: Double
    let promoCode: String
    let status, archive: Int
    let chargeMode, paymentType, orderType: BranchType
}
struct Tax: Codable {
    let id: Int
    let taxRule, taxLabel: String
    let rate: Double
    let status, archive: Int
    let chargeMode, orderType: BranchType
}

struct Category: Codable {
    let id: Int
    let name: String
    let description: String
    let position, status, archive: Int
    let products: [Product]?
}

struct Product: Codable {
    let id: Int
    var code, name, description: String
    let productPhotoURL: String?
    let promotionCode: String?
    var price: Double?
    var totalPrice: Double?
    var specialInstruction: String?
    var quantity: Int?
    let position, status, archive: Int
    let optionGroups: [OptionGroup]?

    enum CodingKeys: String, CodingKey {
        case id, code, name, description
        case productPhotoURL = "productPhotoUrl"
        case promotionCode
        case price, totalPrice, specialInstruction, quantity, position, status, archive, optionGroups
    }
}

struct OptionGroup: Codable {
    let id: Int
    let name, identifierName: String
    let listQuantity, minChoice, maxChoice, status: Int
    let archive, optID: Int
    let options: [Option]?

    enum CodingKeys: String, CodingKey {
        case id, name, identifierName, listQuantity, minChoice, maxChoice, status, archive
        case optID = "optId"
        case options
    }
    
}

