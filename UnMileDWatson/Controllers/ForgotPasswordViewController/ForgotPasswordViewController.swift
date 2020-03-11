//
//  ForgotPasswordViewController.swift
//  Eduhkmit
//
//  Created by Adnan Asghar on 10/8/18.
//  Copyright © 2018 Adnan. All rights reserved.
//

import UIKit
import Alamofire
class ForgotPasswordViewController: BaseViewController {

   
    @IBOutlet weak var txtEmail: UITextField!
    var userData: CustomerDetail!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       // getUser()
    }
    
    @IBAction func resetDidPress(_ sender: UIButton) {
        
                if (txtEmail.text!.isEmpty ){
                    showAlert(title: Strings.error, message: "Enter Your Email first")
                }
                    else {
                    let email = txtEmail.text
            let path =  ProductionPath.customerUrl + "/find-customer-id-companyid"
            
            let parameters =   ["email": "\(email!)" ,
                                "companyID": companyId] as [String:Any]

                    NetworkManager.getDetails(path: path, params: parameters, success: { (json, isError) in
                        
                        do {
                            let jsonData =  try json.rawData()
                            let customer = try JSONDecoder().decode(CustomerDetail.self, from: jsonData)
                            sendPasswordDetailToSender(customerDetail: customer)
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
                        self.showAlert(title: Strings.error, message: Strings.emailError)
                    }
        
    }
    
    
    func sendPasswordDetailToSender(customerDetail: CustomerDetail){
           self.startActivityIndicator()
        let myUrl = URL(string: ProductionPath.sendEmailUrl+"/send-password")
        var request = URLRequest(url: myUrl!)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let obj = customerDetail
        
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
                DispatchQueue.main.async {
                    self.stopActivityIndicator()
                    self.showAlert(title: "Check Your MailBox", message: "Recovery Email is send to Your Email Address")
                    self.txtEmail.text = ""
            
                print(response)
                
                }
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
    
}

}
