//
//  CategoryCollection.swift
//  UnMile
//
//  Created by user on 1/3/20.
//  Copyright © 2020 Moghees Sheikh. All rights reserved.
//

import UIKit

class CategoryCollection: UICollectionView,UICollectionViewDelegate, UICollectionViewDataSource {
    override func awakeFromNib() {
        self.delegate = self
        self.dataSource = self
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionCell", for: indexPath) as! CategoryCollectionCell
        return cell
    }
    

}
