//
//  Terms&Conditions.swift
//  UnMile
//
//  Created by iMac  on 22/06/2019.
//  Copyright © 2019 Adnan Asghar. All rights reserved.
//

import UIKit

class Terms_Conditions: BaseViewController {

    @IBOutlet weak var textview: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        getTANDC()
    }
    
    func getTANDC() {
        self.startActivityIndicator()
        let path = ProductionPath.pageContentUrl + "/\(companyId)/TANDC"
        print(path)
        
        NetworkManager.getDetails(path: path, params: nil, success: { (json, isError) in
            
            do {
                let jsonData =  try json.rawData()
               let term = try JSONDecoder().decode(TANDC.self, from: jsonData)
                
                self.textview.attributedText = self.stringFromHtml(string: term.content)
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
            self.showAlert(title: Strings.error, message: Strings.somethingWentWrong)
        }
    }
    
    
private func stringFromHtml(string: String) -> NSAttributedString? {
        do {
            let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
            if let d = data {
                let str = try NSAttributedString(data: d,
                                                 options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
                                                 documentAttributes: .none)
                return str
            }
        } catch {
        }
        return nil
    }

}
struct TANDC: Codable {
    let id, isDefault: Int
    let createdDate, updatedDate, pageType, content: String
}
