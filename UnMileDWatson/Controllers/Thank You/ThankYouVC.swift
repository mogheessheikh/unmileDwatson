//
//  CompleteSummeryVC.swift
//  UnMile
//
//  Created by iMac  on 27/06/2019.
//  Copyright © 2019 Adnan Asghar. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ThankYouVC: BaseViewController {

    
    
    
   
    @IBOutlet weak var maps: MKMapView!
    var restuarentAddress: String!
    var itemSummery : [CustomerOrderItem]!
    @IBOutlet weak var tblCompleteSummery: UITableView!
    var orderSummery: CustomerOrder!
    var branch: Branch!
    var company: CompanyDetails!
    let locationManager = CLLocationManager()
    var customerOrder: CustomerOrder!
    let regionInMeters:Double = 10000
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
       
        checkLocationServices()
        
       hideNavigationBar()
        company  = getCompanyObject("SavedCompany")
         itemSummery = getAlreadyCartItems()
        
        tblCompleteSummery.register(UINib(nibName: "thankYouCell", bundle: Bundle.main), forCellReuseIdentifier: "thankyoucell")
        tblCompleteSummery.register(UINib(nibName: "OrderItemsSummery", bundle: Bundle.main), forCellReuseIdentifier: "itemcell")
        tblCompleteSummery.register(UINib(nibName: "orderDetailCell", bundle: Bundle.main), forCellReuseIdentifier: "orderdetailcell")
        tblCompleteSummery.register(UINib(nibName: "needHelpCell", bundle: Bundle.main), forCellReuseIdentifier: "needhelpcell")
       
        
        
        if let customerOrderSummery = UserDefaults.standard.object(forKey: "savedCustomerOrder") as? Data  {
            let decoder = JSONDecoder()
            customerOrder = try? decoder.decode(CustomerOrder.self, from: customerOrderSummery)
               orderSummery = customerOrder
            
        }
        
        if let savedBranch = UserDefaults.standard.object(forKey: keyForSavedBranch) as? Data  {
            let decoder = JSONDecoder()
           let branch = try! decoder.decode(Branch.self, from: savedBranch)
               restuarentAddress  = branch.addressLine1
        }
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        disMiss()
    }
    
    
    @IBAction func goToMain(_ sender: Any) {
        
    disMiss()
    
}
    
    func disMiss()  {
    UserDefaults.standard.removeObject(forKey:"savedCustomerOrder")
    UserDefaults.standard.removeObject(forKey:"branchAddress")
    UserDefaults.standard.removeObject(forKey:"SavedBranch")
    if let tabbarVC = Storyboard.main.instantiateViewController(withIdentifier: "TabbarController") as? UITabBarController,
    let nvc = tabbarVC.viewControllers?[0] as? UINavigationController,
    let _ = nvc.viewControllers[0] as? Main{
    UIApplication.shared.keyWindow!.replaceRootViewControllerWith(tabbarVC, animated: true, completion: nil)
         
        }
          
    }
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    func centerViewOnUserLocation(){
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            //maps.setRegion(region, animated: true)
        }
        
    }
    
    func checkLocationServices(){
        
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            checkLocationAutherization()
            
        }
        else{
            showAlert(title: "Dwatson don't have permission to access location ", message: "")
        }
    }
    
    func checkLocationAutherization(){
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            //maps.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
        case .denied:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            break
        }
    }
}
extension ThankYouVC : UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return 1
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 1){
            return 344
        }
        else if (indexPath.section == 4){return 95}
        else{return 200}
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0
        {

           guard let cell = tableView.dequeueReusableCell(withIdentifier: "thankyoucell", for: indexPath) as? thankYouCell
            else {
                fatalError("Unknown cell")
            }
           
          return cell
        }
        
        else if(indexPath.section == 1) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "orderdetailcell", for: indexPath) as? orderDetailCell
                else {
                    fatalError("Unknown cell")
            }
            cell.lblOrderNumber.text = "\(orderSummery.id)"
            cell.lblBranchAddress.text = "Dwatson Group of Company, Islamabad Capital Territory"
            cell.lblCustomerAddress.text = "\(orderSummery.customerOrderAddress.customerOrderAddressFields[0].fieldValue + orderSummery.customerOrderAddress.customerOrderAddressFields[1].fieldValue + orderSummery.customerOrderAddress.customerOrderAddressFields[2].fieldValue + orderSummery.customerOrderAddress.customerOrderAddressFields[3].fieldValue)"
           
        return cell
        }
        else if (indexPath.section == 2){
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemcell", for: indexPath) as? OrderItemsSummery
                else {
                    fatalError("Unknown cell")
            }
            cell.customerOrderItems = itemSummery
            
          return cell
        }
       
        else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "needhelpcell", for: indexPath) as? needHelpCell
                else {
                    fatalError("Unknown cell")
            }
            cell.lblTotalPrice.text = "\(customerOrder.subTotal)"
           cell.delegate = self
            
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
   
}

extension ThankYouVC : NeedSupportDelegate{
    func didToggleNeedSupport(cell: needHelpCell) {
        makeAPhoneCall()
    }
    
    
}
extension ThankYouVC: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Update user location
        guard let location = locations.last else {return}
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        //maps.setRegion(region, animated: true)
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAutherization()
        
    }
}
