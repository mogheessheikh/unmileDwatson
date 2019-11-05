//
//  preOrderDetailCell.swift
//  UnMile
//
//  Created by user on 10/18/19.
//  Copyright © 2019 Moghees Sheikh. All rights reserved.
//

import UIKit

protocol orderDetailDelegate {
    func orderDetailPressed(cell: preOrderDetailCell)
    func repeatOrderPressed(cell: preOrderDetailCell)
}

class preOrderDetailCell: UITableViewCell {

    @IBOutlet weak var btnRepeatOrder: UIButton!
    @IBOutlet weak var repeatOrderView: UIView!
    @IBOutlet weak var btnOrderDetail: UIButton!
    @IBOutlet weak var orderDetailView: UIView!
    @IBOutlet weak var lblOrderDate: UILabel!
    @IBOutlet weak var lblOrderPrice: UILabel!
    var detailDelegate: orderDetailDelegate?
 
    override func awakeFromNib() {
        super.awakeFromNib()
        
        btnRepeatOrder.layer.cornerRadius = 7
        repeatOrderView.layer.cornerRadius = 7
        btnOrderDetail.layer.cornerRadius = 7
        orderDetailView.layer.cornerRadius = 7
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func didPressRepeatOrder(_ sender: Any) {
        detailDelegate?.repeatOrderPressed(cell: self)
    }
    @IBAction func didPressOrderDetail(_ sender: Any) {
        detailDelegate?.orderDetailPressed(cell: self)
    }
}
