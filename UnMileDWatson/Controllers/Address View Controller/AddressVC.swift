//
//  AddressVC.swift
//  UnMile
//
//  Created by iMac on 08/05/2019.
//  Copyright © 2019 Adnan Asghar. All rights reserved.
//

import UIKit


class AddressVC: BaseViewController {

    var totalAddress : [Address]!
    var selectedAddress: Address?
    var userAddressList : [Address]?
    var addressFields = [AddressField]()
    var addressField : CustomerOrderAddressField!
    var customerorderaddress : CustomerOrderAddress!
    var edit = false
    var addressId = 0
    var fieldId:[Int] = []
    
    @IBOutlet var tblAddress: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let savedAddress = UserDefaults.standard.object(forKey: keyForSavedCustomerAddress) as? Data  {
            let decoder = JSONDecoder()
            if let loadedAddress = try? decoder.decode(Address.self, from: savedAddress) {
                selectedAddress = loadedAddress
            }
        }
        // Do any additional setup after loading the view.]
        fieldId.reserveCapacity(4)
       getuserAddress()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        getuserAddress()

    }
    
    func getuserAddress() {
        self.startActivityIndicator()
        if let customerDetail = UserDefaults.standard.object(forKey: keyForSavedCustomer) as? Data{
            let decoder = JSONDecoder()
            let customer = try? decoder.decode(CustomerDetail.self, from: customerDetail)
            customerId = customer!.id
        }
        
        NetworkManager.getDetails(path: ProductionPath.customerUrl + "/\(customerId)", params: nil, success: { (json, isError) in
            
            self.view.endEditing(true)
            
            do {
                self.userAddressList?.removeAll()
                let jsonData =  try json.rawData()
                print(jsonData)
                let customer = try JSONDecoder().decode(CustomerDetail.self, from: jsonData)
                
                self.totalAddress = customer.addresses
                if self.totalAddress != nil{
                    
                    self.userAddressList = self.totalAddress.filter { $0.archive == 0 }
                    self.tblAddress.reloadData()
                    
                }
                else{
                    UserDefaults.standard.removeObject(forKey: keyForSavedCustomerAddress)
                    self.userAddressList = []
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() , execute: {
                    
                 
                    self.stopActivityIndicator()
                    
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
        if(segue.identifier == "address2addAddress"){
            if(edit == true)
            {
                let vc = segue.destination as? AddAddressVC
                vc?.edit = true
                vc?.editAddress = self.currentAddress
                vc?.addressId = self.addressId
                vc?.fieldId = self.fieldId
            }
            
        }
        else{
            _ = segue.destination as? CheckOutVC
        }
        
    }
    func deleteAddress(addressId: Int){
        
        let path = ProductionPath.addressUrl + "/delete/" + "\(addressId)"
        NetworkManager.getDetails(path: path, params: nil, success: { (json, isError) in
            do{
               print("response")
                self.tblAddress.reloadData()
            }
            catch let myJSONError {
                print(myJSONError)
                self.showAlert(title: Strings.error, message: Strings.somethingWentWrong)
            }
            
        }) { (error) in
            //self.dismissHUD()
            self.showAlert(title: Strings.error, message: error.localizedDescription)
        }
    }

    @IBAction func addNewAddress(_ sender: Any) {
      
        let userAddress = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddAddressVC")
        //let navi =  UINavigationController.init(rootViewController: initialVC)
        self.navigationController?.pushViewController(userAddress, animated: true)
    }
    
}
extension AddressVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userAddressList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AddressTableViewCell
            cell.delegate = self
        var customerAddress = ""
        var cityArea = ""
        
        for i in 0..<((userAddressList?[indexPath.row].addressFields.count)!)
            {
                if(userAddressList?[indexPath.row].addressFields[i].label == "addressLine1" || userAddressList![indexPath.row].addressFields[i].label == "addressLine2" || userAddressList?[indexPath.row].addressFields[i].label == "addressline1"){
                    customerAddress += (userAddressList?[indexPath.row].addressFields[i].fieldValue)!
                }
                else if(userAddressList?[indexPath.row].addressFields[i].label == "city" || userAddressList![indexPath.row].addressFields[i].label == "area"){
                    cityArea += (userAddressList?[indexPath.row].addressFields[i].fieldValue)!
                    
                }
           
        }
            cell.lblFullAddress.text = customerAddress
            cell.lblCityArea.text = cityArea
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        currentAddress = userAddressList![indexPath.row]
        saveSelectedAddress(obj: currentAddress, key: keyForSavedCustomerAddress)
        dismiss(animated: true, completion: nil)
       self.navigationController?.popViewController(animated: true)
    
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    }

extension AddressVC : editAddressDelegate {
    func deleteButtonTapped(cell: AddressTableViewCell) {
          let indexPath = self.tblAddress.indexPath(for: cell)
      
        if (userAddressList?.count != 0){
            deleteAddress(addressId: (userAddressList?[(indexPath?.row)!].id)!)
            if(userAddressList?[(indexPath?.row)!].id == selectedAddress?.id){
              UserDefaults.standard.removeObject(forKey: keyForSavedCustomerAddress)
            }
            userAddressList?.remove(at: indexPath!.row)
            self.totalAddress.remove(at: indexPath!.row)
            tblAddress.reloadData()
            getuserAddress()
    }
    }
    
    func didTappedEdit(cell: AddressTableViewCell) {
    let indexPath = self.tblAddress.indexPath(for: cell)
        currentAddress = userAddressList?[(indexPath?.row)!]
        edit = true
        fieldId.removeAll()
        for i in 0..<((userAddressList?[indexPath!.row].addressFields.count)!){
            fieldId.append((userAddressList?[(indexPath?.row)!].addressFields[i].id)!)
        }
        addressId = (userAddressList?[(indexPath?.row)!].id)!
        //performSegue(withIdentifier: "address2addAddress", sender: self)
        let userAddress = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddAddressVC") as! AddAddressVC
        //let navi =  UINavigationController.init(rootViewController: initialVC)
        userAddress.edit = true
        userAddress.editAddress = self.currentAddress
        userAddress.addressId = self.addressId
        userAddress.fieldId = self.fieldId
        self.navigationController?.pushViewController(userAddress, animated: true)
    }
    }



