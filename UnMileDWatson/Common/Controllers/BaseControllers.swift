//
//  BaseControllers.swift
//  UnMile
//
//  Created by Adnan Asghar on 1/5/19.
//  Copyright © 2019 Adnan Asghar. All rights reserved.
//

import UIKit
//import SVProgressHUD

class BaseViewController: UIViewController {

    var cityCheck: CityObject?
    var areaCheck: AreaObject?
    var branchCheck: Branch?
    var customerCheck: CustomerDetail!
    var companyCheck: CompanyDetails!
    var currentAddress : Address!
    var address: AddressField?
    var isBranchClose = "true"
   
    var saveCustomerAddress : [Address]!
    private var customerAddressDetails : [Address]!
    var companyObject: CompanyDetails!
    let activityIndicatorView:UIActivityIndicatorView = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
        if let _ = UserDefaults.standard.object(forKey: keyForSavedCompany) as? Data{
        companyObject = getCompanyObject(keyForSavedCompany)
        }
    }
    func currentDateTime () -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        return (formatter.string(from: Date()) as NSString) as String
    }
    
    func getDeviceIP() -> String{
        
        var temp = [CChar](repeating: 0, count: 255)
        enum SocketType: Int32 {
            case  SOCK_STREAM = 0, SOCK_DGRAM, SOCK_RAW
        }
        gethostname(&temp, temp.count)
        
        var port: UInt16 = 0;let hosts = ["localhost", String(cString: temp)]
        var hints = addrinfo();hints.ai_flags = 0;hints.ai_family = PF_UNSPEC
        
        for host in hosts {
            print("\n\(host)")
            print()
            var info: UnsafeMutablePointer<addrinfo>?
            defer {
                if info != nil
                {
                    freeaddrinfo(info)
                }
            }
            let status: Int32 = getaddrinfo(host, String(port), nil, &info)
            guard status == 0 else {
                print(errno, String(cString: gai_strerror(errno)))
                continue
            }
            var p = info;var i = 0;var ipFamily = "";_ = ""
            
            while p != nil {
                i += 1
                let _info = p!.pointee
                p = _info.ai_next
                
                switch _info.ai_family {
                case PF_INET:
                    _info.ai_addr.withMemoryRebound(to: sockaddr_in.self, capacity: 1, { p in
                        inet_ntop(AF_INET, &p.pointee.sin_addr, &temp, socklen_t(temp.count))
                        ipFamily = "IPv4"
                    })
                case PF_INET6:
                    _info.ai_addr.withMemoryRebound(to: sockaddr_in6.self, capacity: 1, { p in
                        inet_ntop(AF_INET6, &p.pointee.sin6_addr, &temp, socklen_t(temp.count))
                        ipFamily = "IPv6"
                    })
                default:
                    continue
                }
                
                print(i,"\(ipFamily)\t\(String(cString: temp))", SocketType(rawValue: _info.ai_socktype)!)
                
            }
            
            
        }
        
        return String(cString: temp)
        
    }

    func makeAPhoneCall()  {
        
        
        guard let number = URL(string: "tel://" + companyObject.companyEmailDetails.phone) else { return }
        UIApplication.shared.open(number)
        
    }
    func showToast(controller: UIViewController , message: String , seconds: Double){
        
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = UIColor.black
        alert.view.alpha = 0.6
        alert.view.layer.cornerRadius = 16
        DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + seconds){
            alert.dismiss(animated: true)
        }
    }
    func showError() {
        showAlert(title: Strings.error, message: Strings.somethingWentWrong)
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        alert.addAction(okButton)

        present(alert, animated: true, completion: nil)
    }
    
    func startActivityIndicator(){
        activityIndicatorView.center = self.view.center
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.style = UIActivityIndicatorView.Style.whiteLarge
        activityIndicatorView.color = Color.purple
        activityIndicatorView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
    }
    
    func stopActivityIndicator(){
        
        activityIndicatorView.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        
    }
    
    
    func deleteFromCartAlert(title: String , message: String){
        
        let deleteAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        deleteAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            let alreadyItems = NSMutableArray.init(array: self.getAlreadyCartItems())
            if (alreadyItems.count != 0){
            alreadyItems.removeAllObjects()
            self.saveItems(allItems: alreadyItems as! [CustomerOrderItem])
            UserDefaults.standard.removeObject(forKey: "SavedBranch")
            
                self.dismiss(animated: true, completion: nil)
            
            }
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        present(deleteAlert, animated: true, completion: nil)
    }
    
    func logOutAlert(title: String , message: String, dataTable: UITableView ){
        
            
            let deleteAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            
            deleteAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
               
                    UserDefaults.standard.removeObject(forKey: keyForSavedCustomer)//(forKey: "savedCustomer")
                    UserDefaults.standard.removeObject(forKey: "customerName")
                
                    dataTable.reloadData()
            }))
            
            deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                self.dismiss(animated: true, completion: nil)
            }))
            
            present(deleteAlert, animated: true, completion: nil)
        
    }
    
    func orderPlaceAlert(title: String , message: String){
        
        
        let orderAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        orderAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc : UIViewController = storyboard.instantiateViewController(withIdentifier: "ThankYouVC") as! ThankYouVC
                self.present(vc, animated: true, completion: nil)
        }))
        
        present(orderAlert, animated: true, completion: nil)
        
    }
    
    
    
    func hideNavigationBar(){
        self.navigationController?.setNavigationBarHidden(true, animated: true)

    }

    func showNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func getAlreadyCartItems() -> [CustomerOrderItem]  {
        
        let docsURL = FileManager.documentsURL
        let docsFileURL = docsURL.appendingPathComponent("cart.json")
        
        let data = try! Data(contentsOf: docsFileURL, options: [])
        if JSONSerialization.isValidJSONObject(data) {
            print("Valid Json")
        } else {
            print("InValid Json")
        }
        let jsonResult = try? JSONSerialization.jsonObject(with: data, options: [])
        let jsonArray = jsonResult as! [NSDictionary]
        var prodsArray = NSMutableArray.init() as! [CustomerOrderItem]
        
        for anItem in jsonArray{
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: anItem, options: .prettyPrinted)
                // here "jsonData" is the dictionary encoded in JSON data
                let encodedObjectJsonString = String(data: jsonData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
                let jsonData1 = encodedObjectJsonString.data(using: .utf8)
                
                let itemBac = try? JSONDecoder().decode(CustomerOrderItem.self, from: jsonData1!)
                
                //totalPrice += (itemBac?.totalPrice) ?? (itemBac?.price)!
                
                
                prodsArray.append(itemBac!)
                
                
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return prodsArray
    }
    func getAlreadyAddress() -> [Address]  {

        let docsURL = FileManager.documentsURL
        let docsFileURL = docsURL.appendingPathComponent("Address.json")

        let data = try! Data(contentsOf: docsFileURL, options: [])
        if JSONSerialization.isValidJSONObject(data) {
            print("Valid Json")
        } else {
            print("InValid Json")
        }
        let jsonResult = try? JSONSerialization.jsonObject(with: data, options: [])
        let jsonArray = jsonResult as! [NSDictionary]
        var addressArray = NSMutableArray.init() as! [Address]

        for anItem in jsonArray{

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: anItem, options: .prettyPrinted)
                // here "jsonData" is the dictionary encoded in JSON data
                let encodedObjectJsonString = String(data: jsonData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
                let jsonData1 = encodedObjectJsonString.data(using: .utf8)

                let itemBac = try? JSONDecoder().decode(Address.self, from: jsonData1!)

                //totalPrice += (itemBac?.totalPrice) ?? (itemBac?.price)!


                addressArray.append(itemBac!)


            } catch {
                print(error.localizedDescription)
            }
        }

        return addressArray
    }
    
    
    func getUserDetail() -> ([Address]?,CustomerDetail?){
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
                        self.customerCheck = try JSONDecoder().decode(CustomerDetail.self, from: jsonData1!)
                        self.saveCustomerObj(obj: self.customerCheck, key: "SavedCustomer")
                        print(self.customerCheck)
                        self.customerAddressDetails = self.customerCheck.addresses
                        self.saveCustomerAddress(obj: self.customerAddressDetails, key: "SavedAddress")
                        
                        DispatchQueue.main.async {
                           
                            self.stopActivityIndicator()
                        }
                        
                    }
                
            } catch let parseError as NSError {
                print("JSON Error \(parseError.localizedDescription)")
            }
        }
        
        task.resume()
        }
        else{
            
            let loginVC = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: LoginViewController.identifier)
            loginVC.title = "Signin"
            self.navigationController?.pushViewController(loginVC, animated: true)
            
        }
    return (customerAddressDetails,customerCheck)
    }
//    func getUserDetail() -> ([Address]?,CustomerDetail?){
//
//        if let  Id = UserDefaults.standard.object(forKey: "customerId") as? Int{
//            customerId = Id
//            let path = Path.customerUrl + "/\(customerId)"
//
//            NetworkManager.getDetails(path: path, params: nil, success: { (json, isError) in
//
//                do {
//                    let jsonData =  try json.rawData()
//                    self.customerCheck = try JSONDecoder().decode(CustomerDetail.self, from: jsonData)
//                    self.saveCustomerObj(obj: self.customerCheck, key: "SavedCustomer")
//                    print(self.customerCheck)
//                    self.customerAddressDetails = self.customerCheck.addresses
//                    self.saveCustomerAddress(obj: self.customerAddressDetails, key: "SavedAddress")
//                } catch let myJSONError {
//                    print(myJSONError)
//                    self.showAlert(title: Strings.error, message: Strings.somethingWentWrong)
//                }
//
//            }) { (error) in
//                //self.dismissHUD()
//                self.showAlert(title: Strings.error, message: error.localizedDescription)
//            }
//        }
//        else{
//
//            print ("user is not logedin")
//        }
//
//        return (customerAddressDetails,customerCheck)
//    }
    func saveItems(allItems : [CustomerOrderItem])  {

        let docsURL = FileManager.documentsURL
        let docsFileURL = docsURL.appendingPathComponent("cart.json")

        let encodedObject = try? JSONEncoder().encode(allItems)
        let encodedObjectJsonString = String(data: encodedObject!, encoding: .utf8)
        let jsonData = encodedObjectJsonString!.data(using: .utf8)


        do {
            try FileManager.default.removeItem(at: docsFileURL)
        } catch let error as NSError {
            print("Error: \(error.domain)")
        }

        let bundlePath = Bundle.main.url(forResource: "cart", withExtension: "json")
        FileManager.default.copyItemFromURL(urlPath: bundlePath!, toURL: docsFileURL)




        if let file = FileHandle(forWritingAtPath:docsFileURL.path) {
            file.write(jsonData!)
            print("wrote")
        }

        let test = getAlreadyCartItems()
        print(String.init(format: "count after adding item is %i", test.count))


        //  let itemBac = try? JSONDecoder().decode(Product.self, from: jsonData)


    }
    func saveAddress(allAddress : [Address])  {

        let docsURL = FileManager.documentsURL
        let docsFileURL = docsURL.appendingPathComponent("Address.json")

        let encodedObject = try? JSONEncoder().encode(allAddress)
        let encodedObjectJsonString = String(data: encodedObject!, encoding: .utf8)
        let jsonData = encodedObjectJsonString!.data(using: .utf8)


        do {
            try FileManager.default.removeItem(at: docsFileURL)
        } catch let error as NSError {
            print("Error: \(error.domain)")
        }

        let bundlePath = Bundle.main.url(forResource: "Address", withExtension: "json")
        FileManager.default.copyItemFromURL(urlPath: bundlePath!, toURL: docsFileURL)




        if let file = FileHandle(forWritingAtPath:docsFileURL.path) {
            file.write(jsonData!)
            print("wrote")
        }

        let test = getAlreadyAddress()
        print(String.init(format: "count after adding item is %i", test.count))


        //  let itemBac = try? JSONDecoder().decode(Product.self, from: jsonData)


    }
    
   
    
    func setDict(dict: NSDictionary) {
        let data = NSKeyedArchiver.archivedData(withRootObject: dict)
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey:"keyHere")
    }
    
    
        func getDict() -> NSDictionary {
        let data = UserDefaults.standard.object(forKey: "keyHere") as! NSData
        let object = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! NSDictionary
        return object;
    }
    
    func saveCustomerObj(obj: CustomerDetail, key: String) {
       
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(obj) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: key)
        }
    }
    func saveCustomerAddress(obj: [Address], key: String) {
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(obj) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: key)
        }
    }
    func saveCustomerOrder(obj: CustomerOrder, key: String) {
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(obj) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: key)
        }
    }
    
    func saveBranchWrapper(Object: [BranchWrapperAppList], key: String) {
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(Object) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: key)
        }
        
    }
    
    func saveCityObject(Object : CityObject , key: String){
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(Object) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: key)
        }
    }
    
    func saveAreaObject(Object : AreaObject , key: String){
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(Object) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: key)
        }
    }
    
    func getSavedCityObject(key: String) -> CityObject {
       
        if let savedCity = UserDefaults.standard.object(forKey: key) as? Data  {
            let decoder = JSONDecoder()
            if let loadedCity = try? decoder.decode(CityObject.self, from: savedCity) {
                cityCheck = loadedCity
            }
            
        }
        return cityCheck!
    }
    func getSavedCustomerAddress(key: String) -> [Address]? {
        
        if let savedCity = UserDefaults.standard.object(forKey: key) as? Data  {
            let decoder = JSONDecoder()
            if let loadedCity = try? decoder.decode([Address].self, from: savedCity) {
                self.saveCustomerAddress = loadedCity
            }
            return self.saveCustomerAddress
        }
        else { return nil }
    }
    
    func getSavedAreaObject(key: String) -> AreaObject? {
        
        if let savedArea = UserDefaults.standard.object(forKey: key) as? Data  {
            let decoder = JSONDecoder()
            if let loadedArea = try? decoder.decode(AreaObject.self, from: savedArea) {
                areaCheck = loadedArea
            }
             return areaCheck!
        }
        else{
            return nil
        }
       
    }
    
    func saveCompanyObject(Object : CompanyDetails , key: String){
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(Object) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: key)
        }
    }
    
    func saveBranchObject(Object : Branch , key: String){
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(Object) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: key)
        }
    }
    
    func saveBranchCategories(Object : BranchDetailsResponse , key: String){
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(Object) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: key)
        }
    }
    func saveBranchAddress(Object : Branch , key: String){
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(Object) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: key)
        }
    }
    
   
    func saveSelectedAddress(obj: Address, key: String) {
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(obj) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: key)
        }
    }
    func getBranchObject(key: String)-> Branch?
    {
        
        if let savedBranch = UserDefaults.standard.object(forKey: key) as? Data  {
            let decoder = JSONDecoder()
            if let loadedBranch = try? decoder.decode(Branch.self, from: savedBranch) {
                branchCheck = loadedBranch
            }
    }
        return branchCheck
    }
    
     func getCustomerObject(_ key:String)-> CustomerDetail?
    {
        
        if let savedCustomer = UserDefaults.standard.object(forKey: key) as? Data  {
            let decoder = JSONDecoder()
            if let loadedCustomer = try? decoder.decode(CustomerDetail.self, from: savedCustomer) {
                customerCheck = loadedCustomer
            }
        }
        return customerCheck
    }
    func getCompanyObject(_ key:String)-> CompanyDetails
    {
        
        if let savedCustomer = UserDefaults.standard.object(forKey: key) as? Data  {
            let decoder = JSONDecoder()
            if let loadedCompany = try? decoder.decode(CompanyDetails.self, from: savedCustomer) {
                companyCheck = loadedCompany
            }
        }
        return companyCheck
    }
}

