//
//  OrderNowTableViewCell.swift
//  UnMile
//
//  Created by user on 1/3/20.
//  Copyright © 2020 Moghees Sheikh. All rights reserved.
//

import UIKit
protocol orderCellDelegate {
    func orderNowCell(cell: OrderNowTableViewCell, category: BranchDetailsResponse)
}

class OrderNowTableViewCell: UITableViewCell {

    var delegate :  orderCellDelegate!
    @IBOutlet weak var orderBtn: UIButton!
    var branchCategories: BranchDetailsResponse?
    
    override func awakeFromNib() {
        super.awakeFromNib()
         getBranchCategories()
        // Initialization code
    }
    func getBranchCategories() {
        
        //self.startActivityIndicator()
        let path = ProductionPath.menuUrlV2 + "/?branchId=\(branchId)&productName="
        print(path)
        
        NetworkManager.getDetails(path: path, params: nil, success: { (json, isError) in
            
            do {
                let jsonData =  try json.rawData()
                self.branchCategories = try JSONDecoder().decode(BranchDetailsResponse.self, from: jsonData)
                //self.saveBranchCategories(Object: self.branchCategories!, key: keyForSavedCategory)
                //self.popularCollectionView.reloadData()
                //self.stopActivityIndicator()
            } catch let myJSONError {
                
                #if DEBUG
                //self.showAlert(title: "Error", message: myJSONError.localizedDescription)
                #endif
                
                print(myJSONError)
                //self.showAlert(title: Strings.error, message: Strings.somethingWentWrong)
            }
            
        }) { (error) in
            //self.dismissHUD()
            //self.showAlert(title: Strings.error, message: Strings.somethingWentWrong)
        }
    }
    @IBAction func orderNowPressed(_ sender: Any) {
        delegate.orderNowCell(cell: self, category: branchCategories!)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
