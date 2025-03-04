//
//  UserRegistrationVC.swift
//  UnMile
//
//  Created by iMac on 13/03/2019.
//  Copyright © 2019 Adnan Asghar. All rights reserved.
//

import UIKit
import Alamofire

class UserRegistrationVC: BaseViewController {
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!

    var customerObj: CustomerDetail!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    @IBAction func registerButtonTapped(_ sender: Any) {
        if (firstName.text?.isEmpty)! {
            showAlert(title: Strings.error, message: "First name is required")
        return
        } else if (lastName.text?.isEmpty)! {
            showAlert(title: Strings.error, message: "Last name is required")
        return
        } else if (emailField.text?.isEmpty)! {
            showAlert(title: Strings.error, message: "Email is required")
        return
        } else if !(emailField.text?.isValidEmail())! {
            showAlert(title: Strings.error, message: "Email is invalid")
        return
        } else if (passwordField.text?.isEmpty)! {
            showAlert(title: Strings.error, message: "Password is required")
        return
        } else if (phoneNumber.text?.isEmpty)! {
            showAlert(title: Strings.error, message: "Phone number is required")
        return
        }
        else{
            
            var email = emailField.text
            
            checkEmail(email!)
    }
    }
    
    func checkEmail(_ email:String ){
        startActivityIndicator()
        
        let URL_USER_LOGIN = ProductionPath.customerUrl+"/find-customer-id-companyid"
       
        let parameters: Parameters=[
            "email":emailField.text!,
            "companyID": companyId,
            "customerType": "Member"
        ]

        // let postString = ["userName": name, "userPassword": password] as [String: String]
        //making a post request
        Alamofire.request(URL_USER_LOGIN, method: .get, parameters: parameters).responseJSON
            {
                response in
                //printing response
                print(response)
                
                //getting the json value from the server
                if response.result.value != nil {
                    self.stopActivityIndicator()
                
                    self.showAlert(title: "User Already Registered", message: "user is already registerd with this email \(email)")
                }
                    // if response.result.value found nil then registrationNewUser Called
                else{
                    self.stopActivityIndicator()
                    self.registerNewUser()
                }
                
        }
        
        
    }

    func registerNewUser() {

        let registrationDate = currentDateTime()
        let ipAddress = getDeviceIP()

        let myUrl = URL(string: ProductionPath.customerUrl + "/create")
        var request = URLRequest(url: myUrl!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let postString = ["companyId":companyId,
                          "customerType":"MEMBER",
                          "firstName": firstName.text!,
                          "internalInfo":"",
                          "ipAddress": ipAddress,
                          "lastName": lastName.text!,
                          "email": emailField.text!,
                          "password": passwordField.text!,
                          "phone": phoneNumber.text!,
                          "mobile": phoneNumber.text!,
                          "promotionEmail":"false",
                          "promotionSms":"false",
                          "registrationDate": registrationDate,
                          "salt":"",
                          "salutation":"",
                          "status":1,
                          ] as [String: Any]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postString , options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            showAlert(title: "Alert", message: "Something went wrong. Try again.")
            return
        }
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in

            if error != nil
            {
                self.showAlert(title: "Request Error", message: "Could not successfully perform this request. Please try again later")

                print("error=\(String(describing: error))")
                return
            }

            // Let's convert response sent from a server side code to a NSDictionary object:

            do {
                self.customerObj = try JSONDecoder().decode(CustomerDetail.self, from: data!)
                self.sendRejistrationDetailToSender(customerObj: self.customerObj)
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary

                if let parseJSON = json {

                    DispatchQueue.main.async {
                    let userId = parseJSON["firstName"] as? String
                    print("User id: \(String(describing: userId!))")

                    if (userId?.isEmpty)!
                    {
                        // Display an Alert dialog with a friendly error message
                        self.showAlert(title: "Request Error", message: "Could not successfully perform this request. Please try again later")
                        return
                    } else {
                        self.stopActivityIndicator()
                        self.firstName.text = ""
                        self.lastName.text = ""
                        self.emailField.text = ""
                        self.passwordField.text = ""
                        self.phoneNumber.text = ""
                        
                        //self.sendRejistrationDetailToSender(customer: self.customerObj)
                        
                        self.showAlert(title: "SignUP Successfully", message: "Successfully Registered a New Account. Please proceed to Sign in")
                    }

                    }

                }
              
            } catch {

                // self.removeActivityIndicator(activityIndicator: myActivityIndicator)

                // Display an Alert dialog with a friendly error message
                self.showAlert(title: "Request Error", message: "Could not successfully perform this request. Please try again later")

                print(error)
            }
        }

        task.resume()
    }
    
    
    
    func sendRejistrationDetailToSender(customerObj: CustomerDetail){
        
        let myUrl = URL(string: ProductionPath.sendEmailUrl+"/send-registrationdetails")
        var request = URLRequest(url: myUrl!)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let obj = customerObj
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(obj)
        
        let postString = String(data: data, encoding: .utf8)!
        do {
             request.httpBody = postString.data(using: .utf8)
        } catch let error {
            print(error.localizedDescription)
            showAlert(title: "Alert", message: "Something went wrong. Try again.")
            return
        }
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil
            {
                self.showAlert(title: "Request Error", message: "Could not successfully perform this request. Please try again later")
                
                print("error=\(String(describing: error))")
                return
            }
            
            // Let's convert response sent from a server side code to a NSDictionary object:
            
            do {
                print(response)
                
              
                        }
           catch {
                
                // self.removeActivityIndicator(activityIndicator: myActivityIndicator)
                
                // Display an Alert dialog with a friendly error message
                self.showAlert(title: "Request Error", message: "Could not successfully perform this request. Please try again later")
                
                print(error)
            }
        }
        
        task.resume()
        
    }
    
    
    
    @IBAction func signInPressed(_ sender: Any) {
        
    }
}
