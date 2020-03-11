//
//  ContainerVC.swift
//  UnMile
//
//  Created by iMac  on 18/06/2019.
//  Copyright © 2019 Adnan Asghar. All rights reserved.
//

import UIKit

class ContainerVC: BaseViewController {
    
    
    @IBOutlet weak var sideMenuConstraints: NSLayoutConstraint!
    
    
    var sideMenuOpen = false
    var menuItems = ["Previous Order","My Profile", "My Address","Update Password","Share with Friends" ,"Contact Us","Live Chat", "More*","LogOut"]
    var menuLogOut = ["Settings","Share with friends","Contact Us","More*","Login/Registration"]
    
    
    var registeredUser = ""
    var myCustomView: UIImageView!
    
    @IBOutlet weak var tblSlideMenu: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        tblSlideMenu.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        tblSlideMenu.reloadData()
    }
    
}
extension ContainerVC : UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if UserDefaults.standard.object(forKey: "customerName") != nil
        {
            return menuItems.count
        }
        else{
            return menuLogOut.count
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? SideMenuCell else {
            fatalError("Unknown cell")
        }
        
        if UserDefaults.standard.object(forKey: keyForSavedCustomerName) != nil{
            
            cell.lblSideMenu.text = menuItems[indexPath.row]
          
            }
            else {
                cell.lblSideMenu.text =  menuLogOut[indexPath.row]
            
            }
        
    
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        
        return 165
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        // ****************checking if user is logIn**************************
       
        if UserDefaults.standard.object(forKey: keyForSavedCustomer) != nil{
            
        // \\\\\\\\\\\\\\\\^^^^^^^^^^^^^^^^^^^^^^^^^\\\\\\\\\\\\\\\\\\\\\\\\\\\
            
            if(indexPath.row == 0){
                
                performSegue(withIdentifier: "sideMenuToPreviousOrder", sender: self)
            }
            else if(indexPath.row == 1){
                performSegue(withIdentifier: "sideMenuToUserProfile", sender: self)
            }
            else if(indexPath.row == 2){
                performSegue(withIdentifier: "sideMenuToAddress", sender: self)
            }
            else if(indexPath.row == 3){
                
                let userUpdatePassword = Storyboard.login.instantiateViewController(withIdentifier: ForgotPasswordViewController.identifier)
                userUpdatePassword.title = "Update Password"
                self.navigationController?.pushViewController(userUpdatePassword, animated: true)
            }
            
            else if (indexPath.row == 4){
                
                let text = "Share D.Watson"
                let myWebsite : NSURL = NSURL(string: "https://apps.apple.com/us/app/eat-craze/id1444723136")!
                // If you want to put an image
                let image : UIImage = UIImage(named: "login-logo.png")!
                
                let shareAll : [Any] = [text , image , myWebsite]
                
                let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                
                present(activityViewController, animated: true, completion: nil)
            }
            else if(indexPath.row == 5){
                
               self.makeAPhoneCall()
            }
            else if(indexPath.row == 6){
                
                 performSegue(withIdentifier: "SidetoChatRoom", sender: self)
            }
            else if(indexPath.row == 7){
                performSegue(withIdentifier: "sideMenuToMore" , sender: self)
            }
            else if(indexPath.row == 8){
                 logOutAlert(title: "Do You Want to LogOut?", message: "You will not able to place any order",dataTable: tblSlideMenu )
            }
            
        }
            
           // *********************if user is Not logIn **************************
        else{
            
            if (indexPath.row == 0){
                
                performSegue(withIdentifier: "sideMenuToSettings", sender: self)
            }
            else if (indexPath.row == 1){
                
                let text = "Share D.Watson"
                let myWebsite : NSURL = NSURL(string: "https://apps.apple.com/us/app/eat-craze/id1444723136")!
                // If you want to put an image
                let image : UIImage = UIImage(named: "login-logo.png")!
                
                let shareAll : [Any] = [text , image , myWebsite]
                
                let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                
                present(activityViewController, animated: true, completion: nil)
            }
            else if(indexPath.row == 2){
                
                self.makeAPhoneCall()
            }
            else if(indexPath.row == 3){
                performSegue(withIdentifier: "sideMenuToMore" , sender: self)
            }
            else {
                
                let registrationVC = Storyboard.login.instantiateViewController(withIdentifier: UserRegistrationVC.identifier)
                registrationVC.title = "Registration"
                self.navigationController?.pushViewController(registrationVC, animated: true)
                
            }
            
        }
        tblSlideMenu.deselectRow(at: indexPath, animated: true)
        
        }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = Bundle.main.loadNibNamed("SideMenuHeaderViewCell", owner: self, options: nil)?.first as! SideMenuHeaderViewCell
        headerView.backgroundColor = Color.blue

        if UserDefaults.standard.object(forKey: keyForSavedCustomerName) != nil{
            customerCheck = getCustomerObject(keyForSavedCustomer)
            if customerCheck != nil  {
                headerView.imgHeader.image = UIImage(named: "client-img")!
                headerView.lblUserName.text = customerCheck.firstName
                headerView.lblUserEmail.text = customerCheck.email
            }
        }
        
        else{
            headerView.lblUserName.text = "User is Not LogIn"
            headerView.lblUserEmail.text = ""
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.frame = CGRect(x: 100, y: 100, width: 200, height: 50)
        let label = UILabel()
        label.frame = CGRect(x: 14  , y: 0, width: tableView.bounds.size.width - 10, height: 24)
        label.text = "legal"
        footerView.addSubview(label)
       
        let label2 = UILabel()
        label2.frame = CGRect(x: (tableView.bounds.size.width) - 24 , y: 0, width: tableView.bounds.size.width - 10, height: 24)
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        label2.text = appVersion
        label2.textColor = Color.blue
        footerView.addSubview(label2)
        
        return footerView
    }
}
