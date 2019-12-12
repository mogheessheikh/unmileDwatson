//
//  SplashVC.swift
//  UnMile
//
//  Created by Adnan Asghar on 1/5/19.
//  Copyright © 2019 Adnan Asghar. All rights reserved.
//

import UIKit
import AlamofireImage

class SplashVC: BaseViewController {

    @IBOutlet weak var verticalCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    public var companyDetailObject: CompanyDetails!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getUserDetail()
        getCompanyDetails()
    }

    // MARK: - API Calls
    func getCompanyDetails() {

        let path = ProductionPath.companyUrl + "/\(companyId)"
        print(path)
        NetworkManager.getDetails(path: path, params: nil, success: { (json, isError) in

            do {
                let jsonData =  try json.rawData()
                let companyDetails = try JSONDecoder().decode(CompanyDetails.self, from: jsonData)
                
                print(companyDetails)
                self.saveCompanyObject(Object: companyDetails, key: keyForSavedCompany)
                self.companyDetailObject = companyDetails
                UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
                    //self.verticalCenterConstraint.constant = (UIScreen.main.bounds.height/2 - 100) - (180+216)
                    self.view.layoutIfNeeded()
                    self.activityIndicatorView.isHidden = true
                }, completion: nil)
                if let _ = UserDefaults.standard.object(forKey: keyForSavedCustomer) as? Data{
                    if let tabbarVC = Storyboard.main.instantiateViewController(withIdentifier: "TabbarController") as? UITabBarController,
                        let nvc = tabbarVC.viewControllers?[0] as? UINavigationController,
                        let mainVC = nvc.viewControllers[0] as? MainVC {
                        mainVC.companyDetails = companyDetails
                        mainVC.deliveryZoneType = companyDetails.deliveryZoneType.name //"POSTALCODE"
                        
                        UIApplication.shared.keyWindow!.replaceRootViewControllerWith(tabbarVC, animated: true, completion: nil)
                    }
                    
                    
                }
                else{
                    if let loginVC = Storyboard.login.instantiateViewController(withIdentifier: LoginViewController.identifier) as? UIViewController{
                    loginVC.title = "Signin"
                    UIApplication.shared.keyWindow!.replaceRootViewControllerWith(loginVC, animated: true, completion: nil)
                
                    }
                }
            } catch let myJSONError {
                print(myJSONError)
                self.showAlert(title: Strings.error, message: Strings.somethingWentWrong)
            }

        }) { (error) in
            //self.dismissHUD()
            self.showAlert(title: Strings.error, message: error.localizedDescription)
        }
    }
    
    
  
    }
    

struct CompanyDetails: Codable {
    let id: Int
    let name, companyDetailsDescription, locationWebLogoURL, androidAppURL: String
    let status, archive, clientSendPushNotification: Int
    let salesCompanyName, salesCompanyWebsite: String
    let homeURL: String
    let chatScript, facebookPixel, googleAnalytics: String
    let showGuestCheckout: Int
    let companyEmailDetails: CompanyEmailDetails
    let country: Country
    let companyType, deliveryZoneType: CompanyTypeClass
    let companyTemplate: CompanyTemplate
    let widgetTheme: TTheme
    let widgetSetting: WidgetSetting
    let listingRedirection: String
    let companyLocales: [CompanyLocale]
    let addressFieldRules: [AddressFieldRule]
    let companyIntegrations: [CompanyIntegration]
    let emailTemplates: String?
    //let paymentGateway: [PaymentGateway]
    let companyAlertNotification: [CompanyAlertNotification]
    let iosappURL: String
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case companyDetailsDescription = "description"
        case locationWebLogoURL = "locationWebLogoUrl"
        case androidAppURL, status, archive, clientSendPushNotification, salesCompanyName, salesCompanyWebsite, homeURL, chatScript, facebookPixel, googleAnalytics, showGuestCheckout, companyEmailDetails, country, companyType, deliveryZoneType, companyTemplate, widgetTheme, widgetSetting, listingRedirection, companyLocales, addressFieldRules, companyIntegrations, emailTemplates, companyAlertNotification, iosappURL
    }
}

// MARK: - AddressFieldRule
struct AddressFieldRule: Codable {
    let id: Int
    let fieldName, label: String
    let display, addressFieldRuleRequired, minLength, maxLength: Int
    let userInterfaceClass, userInterfaceType: String
    let position, parent, status, archive: Int
    
    enum CodingKeys: String, CodingKey {
        case id, fieldName, label, display
        case addressFieldRuleRequired = "required"
        case minLength, maxLength, userInterfaceClass, userInterfaceType, position, parent, status, archive
    }
}

// MARK: - CompanyAlertNotification
struct CompanyAlertNotification: Codable {
    let id, alertType: Int
    let message: String?
    let bannerURL: String?
    let status: Int
    let createdDate, createdBy, updatedDate, updatedBy: String
    
    enum CodingKeys: String, CodingKey {
        case id, alertType, message
        case bannerURL = "bannerUrl"
        case status, createdDate, createdBy, updatedDate, updatedBy
    }
}

// MARK: - CompanyEmailDetails
struct CompanyEmailDetails: Codable {
    let id, defaultDetails: Int
    let emailHost, emailPort, donotReplyEmail, donotReplyUserName: String
    let donotReplyPassword, customerCareEmail, infoEmail, supportEmail: String
    let adminEmail, phone: String
    let facebookURL: String
    let instagramURL, twitterURL, adminCellNumber, customercarecellnumber: String
    
    enum CodingKeys: String, CodingKey {
        case id, defaultDetails, emailHost, emailPort, donotReplyEmail, donotReplyUserName, donotReplyPassword, customerCareEmail, infoEmail, supportEmail, adminEmail, phone
        case facebookURL = "facebookUrl"
        case instagramURL = "instagramUrl"
        case twitterURL = "twitterUrl"
        case adminCellNumber, customercarecellnumber
    }
}

// MARK: - CompanyIntegration
struct CompanyIntegration: Codable {
    let id: Int
    let vendorName: String
    let status, archive: Int
    let companyIntegrationParams: [CompanyIntegrationParam]
}

// MARK: - CompanyIntegrationParam
struct CompanyIntegrationParam: Codable {
    let id: Int
    let dataType: String?
    let key, value: String
}

// MARK: - CompanyLocale
struct CompanyLocale: Codable {
    let id: Int
    let country, language: String
    let isdefault, status, archive: Int
}

// MARK: - CompanyTemplate
struct CompanyTemplate: Codable {
    let id: Int
    let name, standardFolderPath: String
    let mobileFolderPath: String?
    let rootStaticURL: String
    let rootStaticMobileURL: String?
    let status, archive: Int
    let defaultTheme: TTheme
    
    enum CodingKeys: String, CodingKey {
        case id, name, standardFolderPath, mobileFolderPath
        case rootStaticURL = "rootStaticUrl"
        case rootStaticMobileURL = "rootStaticMobileUrl"
        case status, archive, defaultTheme
    }
}

// MARK: - TTheme
struct TTheme: Codable {
    let id: Int
    let headerBg, footerBg, btnBg, btnHoverBg: String
    let btnFontColor: String
}

// MARK: - CompanyTypeClass
struct CompanyTypeClass: Codable {
    let id: Int
    let name: String
    let createdate: String?
    let status, archive: Int
}

// MARK: - Country
struct Country: Codable {
    let id: Int
    let country: String
    let status, archive: Int
}

// MARK: - PaymentGateway
//struct PaymentGateway: Codable {
//    let id: Int
//    let name, param1, param2, param3: String
//    let status: Int
//}

// MARK: - WidgetSetting
struct WidgetSetting: Codable {
    let id: Int
    let showPoweredBy: String
}
