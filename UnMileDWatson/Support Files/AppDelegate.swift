//
//  AppDelegate.swift
//  UnMile
//
//  Created by Adnan Asghar on 1/5/19.
//  Copyright © 2019 Adnan Asghar. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import ScrollableSegmentedControl
import ZDCChat
import Firebase
import GoogleSignIn
//import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{
        var window: UIWindow?
    
   
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
       
        ZDCChat.initialize(withAccountKey: "Q4tc8dF2Gec8k0SUZ3TAm3xLlWPokWdp")
        //GMSServices.provideAPIKey("AIzaSyDHsxs_5WO9L4fEj6hFsgG-nT78hcYDSXU")
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self as? GIDSignInDelegate
     
        let docsURL = FileManager.documentsURL
        let docsFileURL = docsURL.appendingPathComponent("cart.json")
        let  docsFileURL2 = docsURL.appendingPathComponent("Address.json")
        let userDefaults = UserDefaults.standard
        if((userDefaults.object(forKey: "installed")) == nil){
            userDefaults.set("1", forKey: "installed")
            
            let bundlePath = Bundle.main.url(forResource: "cart", withExtension: "json")
             let bundlePath2 = Bundle.main.url(forResource: "Address", withExtension: "json")
            FileManager.default.copyItemFromURL(urlPath: bundlePath!, toURL: docsFileURL)
            FileManager.default.copyItemFromURL(urlPath: bundlePath2!, toURL: docsFileURL2)
            
        }
        
        
        print(docsFileURL)
        
        userDefaults.synchronize()
        
        let segmentedControlAppearance = ScrollableSegmentedControl.appearance()
        segmentedControlAppearance.segmentContentColor  = UIColor.white
        segmentedControlAppearance.selectedSegmentContentColor = UIColor.yellow
        segmentedControlAppearance.backgroundColor = UIColor.black

        IQKeyboardManager.shared.enable = true
        
      
        return true
    }
    
    
    @available(iOS 9.0, *)
   func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
     -> Bool {
        
        
     return GIDSignIn.sharedInstance().handle(url)
     
   }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

