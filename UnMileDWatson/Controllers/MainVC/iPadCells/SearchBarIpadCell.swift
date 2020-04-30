//
//  SearchBarIpadCell.swift
//  UnMile
//
//  Created by user on 4/3/20.
//  Copyright © 2020 Moghees Sheikh. All rights reserved.
//

import UIKit
protocol IpadSearchBarDelegate {
func didTappedSearchBar(cell:SearchBarIpadCell)
}
class SearchBarIpadCell: UITableViewCell {

    @IBOutlet weak var searchBtn: UIButton!
     var delegate: IpadSearchBarDelegate!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        searchBtn.layer.cornerRadius = 10
        searchBtn.layer.borderWidth = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func searchTapped(_ sender: Any) {
         delegate.didTappedSearchBar(cell: self)
    }
}
