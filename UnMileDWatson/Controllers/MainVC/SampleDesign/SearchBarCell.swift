//
//  SearchBarCell.swift
//  UnMile
//
//  Created by user on 1/3/20.
//  Copyright © 2020 Moghees Sheikh. All rights reserved.
//

import UIKit
protocol SearchBarDelegate {
    func didTappedSearchBar(cell:SearchBarCell )
}
class SearchBarCell: UITableViewCell,UISearchBarDelegate {

    @IBOutlet weak var productSearch: UISearchBar!
    var delegate: SearchBarDelegate!
    override func awakeFromNib() {
        super.awakeFromNib()
        productSearch.delegate = self
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
         delegate.didTappedSearchBar(cell: self)
        return true
    }
}

