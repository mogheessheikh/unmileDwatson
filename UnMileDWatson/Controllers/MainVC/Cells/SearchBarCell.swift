//
//  SearchBarCell.swift
//  UnMile
//
//  Created by user on 1/3/20.
//  Copyright © 2020 Moghees Sheikh. All rights reserved.
//

import UIKit

protocol SearchBarDelegate {
func didTappedSearchBar(cell:SearchBarCell)
}
class SearchBarCell: UITableViewCell{

    @IBOutlet weak var searchProductBtn: UIButton!

    var delegate: SearchBarDelegate!
    override func awakeFromNib() {
        super.awakeFromNib()
        searchProductBtn.layer.cornerRadius = 6
        searchProductBtn.layer.borderWidth = 2
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
    
    @IBAction func searchProductTapped(_ sender: Any) {
        delegate.didTappedSearchBar(cell: self)
    }
}

