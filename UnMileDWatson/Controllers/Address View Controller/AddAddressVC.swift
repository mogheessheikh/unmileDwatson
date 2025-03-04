//
//  AddAddressVC.swift
//  UnMile
//
//  Created by iMac on 08/05/2019.
//  Copyright © 2019 Adnan Asghar. All rights reserved.
//

import UIKit
import Alamofire

class AddAddressVC: BaseViewController {

    @IBOutlet var btnAddAddress: UIButton!
    @IBOutlet var addressView2: UIView!
    @IBOutlet var addressView1: UIView!
    @IBOutlet var txtAddress1: UITextField!
    var cities = [CityObject]()
    @IBOutlet var cityAreaPickerView: UIPickerView!
    @IBOutlet var btnArea: UIButton!
    @IBOutlet var btnCity: UIButton!
    var companyDetails: CompanyDetails!
    var customerAddress : Address?
    var addressFeilds = [AddressField]()
    var addressFeild: AddressField!
    var city: CityObject?
    var area: AreaObject?
    var edit = false
    var addressId:Int?
    var fieldId:[Int]!
    var editAddress : Address?
    var coustomerId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showNavigationBar()
       
        
        cityAreaPickerView.isHidden = true
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick))
       
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        cityAreaPickerView.addSubview(toolBar)
        
        btnCity.layer.cornerRadius = 7
        btnCity.layer.cornerRadius = 7
        btnArea.layer.cornerRadius = 7
        btnArea.layer.cornerRadius = 7
        getCities()
        let user = getUserDetail()
        
        customerCheck = user.1
        let BranchAddress = getCompanyObject(keyForSavedCompany)
        if(((BranchAddress.deliveryZoneType.name) == "CITYAREA")){
            
            btnArea.isHidden = false
        }
        else{
            
            
            btnArea.isHidden = true
            
        }
        if customerCheck != nil  {
           coustomerId = customerCheck.id
        }
        if(edit == true ){
            
           txtAddress1.text = editAddress?.addressFields[0].fieldValue
            btnAddAddress.setTitle("UPDATE", for: UIControl.State.normal)
            
        }
        else{
            btnAddAddress.setTitle("ADD", for: UIControl.State.normal)
        }
        self.navigationController?.isNavigationBarHidden = false
        //self.showNavigationBar()
    }
    override func viewWillAppear(_ animated: Bool) {
        
       
        
        
        if let savedArea = UserDefaults.standard.object(forKey: keyForSavedArea) as? Data  {
            let decoder = JSONDecoder()
            if let loadedArea = try? decoder.decode(AreaObject.self, from: savedArea) {
                area = loadedArea
               // btnArea.setTitle(loadedArea.area, for: .normal)
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        /// Getting Saved City and Area Values
        super.viewDidAppear(animated)
        if let savedCity = UserDefaults.standard.object(forKey: keyForSavedCity) as? Data  {
            let decoder = JSONDecoder()
            if let loadedCity = try? decoder.decode(CityObject.self, from: savedCity) {
               city = loadedCity
               btnCity.setTitle(loadedCity.city, for: .normal)
            }
           //self.showNavigationBar()
        }
        

        if let savedArea = UserDefaults.standard.object(forKey: keyForSavedArea) as? Data  {
            let decoder = JSONDecoder()
            if let loadedArea = try? decoder.decode(AreaObject.self, from: savedArea) {
                area = loadedArea
               // btnArea.setTitle(loadedArea.area, for: .normal)
            }
        }
    }
    
    @IBAction func addCityTapped(_ sender: Any) {
        //CityArea(sender: sender as! UIButton)
        cityAreaPickerView.isHidden = false
    }
    
    @objc func doneClick(){
        cityAreaPickerView.isHidden = true
    }
    
    func getCities() {
           
           let company = getCompanyObject(keyForSavedCompany)
           let id = company.country?.id
           let params: [String : Any] = ["countryId":"\(id!)"]
        
           NetworkManager.getDetails(path: ProductionPath.companyCityUrl, params: params, success: { (json, isError) in

               do {
                   let jsonData =  try json.rawData()
                   self.cities = try JSONDecoder().decode(CitiesResponse.self, from: jsonData)
                   self.cityAreaPickerView.reloadAllComponents()
                   self.stopActivityIndicator()
                   print(self.cities)

               } catch let myJSONError {
                   print(myJSONError)
                   self.showAlert(title: Strings.error, message: Strings.somethingWentWrong)
               }

           }) { (error) in
               //self.dismissHUD()
               self.stopActivityIndicator()
               self.showAlert(title: Strings.error, message: Strings.somethingWentWrong)
           }
       }

    @IBAction func addAreaTapped(_ sender: Any) {
          CityArea(sender: sender as! UIButton)
    }
    @IBAction func addAddressTapped(_ sender: Any) {
        
        if (txtAddress1.text == ""){
            showAlert(title: "Address Fields are Empty", message: "Must Enter One Address Feilds")
        }
        else
        {
           if (edit == true)
           {
            updateAddressToServer()
            
            }
           else {
              addAddressToServer()
            }
        }
    }

    func addAddressToServer(){
        startActivityIndicator()	
        if let savedCity = UserDefaults.standard.object(forKey: keyForSavedCity) as? Data  {
                   let decoder = JSONDecoder()
                   if let loadedCity = try? decoder.decode(CityObject.self, from: savedCity) {
                      city = loadedCity
                    
            }
                  //self.showNavigationBar()
               }
        let path = URL(string: ProductionPath.addressUrl + "/add-address")

        let parameters =     ["id":0,
                              "isDefault":0,
                              "archive":0,
                              "addressFields":[["id":0,"fieldName":"addressLine1","fieldValue":"\(txtAddress1!.text!)","label":"addressLine1"],["id":0,"fieldName":"addressLine2","fieldValue":"","label":"addressLine2"],["id":0,"fieldName":"city","fieldValue":"\(city!.city)","label":"city"],["id":0,"fieldName":"area","fieldValue":"","label":"area"]],
                              "customer": ["id":customerCheck.id]
            ]
                as [String: Any]
        
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
                   DispatchQueue.main.async {
                    if let httpResponse = response as? HTTPURLResponse {
                        print("error \(httpResponse.statusCode)")
                        
                        if httpResponse.statusCode == 200{
                            restResponse = true
                            self.stopActivityIndicator()
                            self.txtAddress1.text = ""
                           
                            //self.showAlert(title: "Request Completed", message: "")
                            _ = self.navigationController?.popViewController(animated: true)
                        }
                        else
                        {
                            self.showAlert(title: "Request Decline", message: "Something goes worng")
                        }
                    }
                    }
                    
                } catch {
                    print(error)
                    self.showAlert(title: "Request Decline", message: "Something goes worng")
                }
            }
            
            }.resume()
    }
    func updateAddressToServer(){
        startActivityIndicator()
        if let savedCity = UserDefaults.standard.object(forKey: keyForSavedCity) as? Data  {
                          let decoder = JSONDecoder()
                          if let loadedCity = try? decoder.decode(CityObject.self, from: savedCity) {
                             city = loadedCity
                            
                          }
                         //self.showNavigationBar()
                      }
        let path = URL(string: ProductionPath.addressUrl + "/update-address")
        let parameters = [
            
            "id": addressId!,
            "isDefault":0,
            "archive":0,
            "addressFields":[
                ["id": fieldId[0],
                              "fieldName":"addressLine1",
                              "fieldValue":"\(txtAddress1!.text!)",
                              "label":"addressLine1"],
                             ["id": fieldId[1],
                              "fieldName":"city",
                              "fieldValue":"\(city!.city)",
                                "label":"city"]],
            "customer": ["id":customerCheck.id]
            ] as [String: Any]
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
                    DispatchQueue.main.async {
                        if let httpResponse = response as? HTTPURLResponse {
                            print("error \(httpResponse.statusCode)")
                            
                            if httpResponse.statusCode == 200{
                                restResponse = true
                                self.stopActivityIndicator()
                                self.txtAddress1.text = ""
                               
                                //self.showAlert(title: "Request Completed", message: "")
                            _ = self.navigationController?.popViewController(animated: true)
                            }
                            else
                            {
                                self.showAlert(title: "Request Decline", message: "Something goes worng")
                            }
                        }
                    }
                    
                } catch {
                    print(error)
                }
            }
            
            }.resume()
        
       
    }
   
    
    func CityArea(sender: UIButton) {
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : SearchVC = storyboard.instantiateViewController(withIdentifier: SearchVC.identifier) as! SearchVC
        vc.isFor = SearchFor(rawValue: sender.tag)!
        if sender.tag == 0 {
            //searchVC.cityDelegate = self as! SearchVCCityDelegate
            vc.companyId = companyId
            vc.addressSelection = true
            
            UserDefaults.standard.removeObject(forKey: keyForSavedArea)
//            btnArea.setTitle("Area", for: .normal)
              self.navigationController?.pushViewController(vc, animated: true)
           // self.present(vc, animated: true, completion: nil)
            //self.navigationController?.pushViewController(vc, animated: true)
            
            
        } else {
            
            if let savedCity = UserDefaults.standard.object(forKey: keyForSavedCity) as? Data  {
                let decoder = JSONDecoder()
                if let loadedCity = try? decoder.decode(CityObject.self, from: savedCity) {
                    
                  //  searchVC.areaDelegate = self as! SearchVCAreaDelegate
                    vc.cityId = loadedCity.id
                    vc.companyId = companyId
                     vc.addressSelection = true
                    self.navigationController?.pushViewController(vc, animated: true)
                    //self.present(vc, animated: true, completion: nil)
                   // self.navigationController?.pushViewController(vc, animated: true)
                }
            }
                
                
            else{
                
                if let aCity = self.city {
                    vc.areaDelegate = self as! SearchVCAreaDelegate
                    vc.cityId = aCity.id
                    vc.companyId = self.companyDetails.id
                    self.navigationController?.pushViewController(vc, animated: true)
                    //self.present(vc, animated: true, completion: nil)
                   // self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    self.showAlert(title: "Select city!", message: "Please select city to continue")
                }
            }
        }
    }
}
extension AddAddressVC : UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cities.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return cities[row].city
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let city = cities[row]
        saveCityObject(Object: city, key: keyForSavedCity)
        btnCity.setTitle(city.city, for: .normal)
    }
    
}
