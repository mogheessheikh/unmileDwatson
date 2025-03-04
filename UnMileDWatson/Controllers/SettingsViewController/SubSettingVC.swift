//
//  SubSettingVC.swift
//  UnMile
//
//  Created by iMac on 12/04/2019.
//  Copyright © 2019 Adnan Asghar. All rights reserved.
//

import UIKit

protocol RefreshDataDelegate: class {
  func refreshData()
}
class SubSettingVC: BaseViewController {
    
    @IBOutlet var btnClose: UIButton!
    @IBOutlet var tblSubSettings: UITableView!
    var userArray: [String] = ["First Name", "Last Name", "Email", "Phone"]
    var userData : CustomerDetail?
    var userDataArray: [String]?
     weak var  viewDelegate: RefreshDataDelegate!
    @IBOutlet weak var subview: UIView!
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var phoneNumberView: UIView!
    @IBOutlet weak var mobilenumberView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var lastnameView: UIView!
    @IBOutlet weak var firstnameView: UIView!
    @IBOutlet weak var tfMobile: UITextField!
    @IBOutlet weak var tfPhone: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    var isCloseHidden = true;
    var checkoutVC = CheckOutVC()
    var company: CompanyDetails!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        getUser()
       company = getCompanyObject("SavedCompany")
    
        if isCloseHidden{
            
            btnClose.isHidden = true
            
        }
        else{
              btnClose.isHidden = false
        }
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        viewDelegate?.refreshData()
    }
    
    @IBAction func closePressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    @IBAction func updateDidPressed(_ sender: Any) {
      
        let firstName = tfFirstName.text
        let lastName = tfLastName.text
        let email = tfEmail.text
        let phone = tfPhone.text
        let mobile = tfMobile.text
        
        if(phone!.isEmpty || mobile!.isEmpty){
            self.showAlert(title: "Contact number is not entered", message: "Must enter your contact number")
            return
        }
        else{
            
            self.startActivityIndicator()
             let path = URL(string: ProductionPath.customerUrl + "/update")
            let parameters =   ["id":userData!.id,
                            "customerType": "\(userData!.customerType)",
                            "ipAddress": "\(userData!.ipAddress)",
                            "internalInfo": "",
                            "salutation": "",
                            "phone": "\(phone!)",
                            "mobile": "\(mobile!)",
                            "firstName": "\(firstName!)",
                            "lastName": "\(lastName!)",
                            "email": "\(email!)",
                            "salt": "",
                            "promotionSMS": false,
                            "promotionEmail":  false,
                            "registrationDate": "\(userData!.registrationDate)",
                            "status": userData!.status,
                            "password": userData!.password,
                            "branchId": userData?.branchID,
                            "addresses": [],
                            "companyId": userData!.companyID
                        ] as [String:Any]
        
        var request = URLRequest(url: path!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])as? NSDictionary
                    let jsonData = try JSONSerialization.data(withJSONObject: json as Any, options: .prettyPrinted)
                    let encodedObjectJsonString = String(data: jsonData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
                    let jsonData1 = encodedObjectJsonString.data(using: .utf8)
                    if let httpResponse = response as? HTTPURLResponse {
                        print("error \(httpResponse.statusCode)")
                        if httpResponse.statusCode == 200{
                            restResponse = true
                            self.stopActivityIndicator()
                             //self.showAlert(title: "Request Completed", message: "Your Profile is updated now")
                             self.getUser()
//
                            
                           
                        }
                        else
                        {
                            self.showAlert(title: "Request Decline", message: "Something goes worng")
                        }
                    }
                    
                } catch {
                    print(error)
                }
            }
            
            }.resume()
        }
        
    }

    
    func getUser() {
        self.startActivityIndicator()
        if let customerDetail = UserDefaults.standard.object(forKey: keyForSavedCustomer) as? Data{
            let decoder = JSONDecoder()
            let customer = try? decoder.decode(CustomerDetail.self, from: customerDetail)
            customerId = customer!.id
            let path = URL(string: ProductionPath.customerUrl + "/\(customerId)")
            let session = URLSession.shared
            let task = session.dataTask(with: path!) { data, response, error in
                print("Task completed")
                
                guard data != nil && error == nil else {
                    print(error?.localizedDescription)
                    return
                }
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                    if let parseJSON = json {
                        
                        let jsonData = try JSONSerialization.data(withJSONObject: parseJSON, options: .prettyPrinted)
                        let encodedObjectJsonString = String(data: jsonData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
                        let jsonData1 = encodedObjectJsonString.data(using: .utf8)
                        self.userData = try JSONDecoder().decode(CustomerDetail.self, from: jsonData1!)
                        DispatchQueue.main.async {
                            self.tfFirstName.text  = self.userData?.firstName
                            self.tfLastName.text =  self.userData?.lastName
                            self.tfEmail.text =  self.userData?.email
                            self.tfMobile.text = self.userData?.mobile
                            self.tfPhone.text = self.userData?.phone
                            self.stopActivityIndicator()
                        }
                        
                    }
                    
                } catch let parseError as NSError {
                    print("JSON Error \(parseError.localizedDescription)")
                }
            }
            
            task.resume()
        }
    }
    
}

