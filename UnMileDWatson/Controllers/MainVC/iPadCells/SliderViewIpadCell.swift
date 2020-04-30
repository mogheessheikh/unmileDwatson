//
//  SliderViewIpadCell.swift
//  UnMile
//
//  Created by user on 4/4/20.
//  Copyright © 2020 Moghees Sheikh. All rights reserved.
//

import UIKit

class SliderViewIpadCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout  {
   func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  companyBanner?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SliderImageCell", for: indexPath) as! SliderImageCell
//          cell.layer.borderWidth = Constants.borderWidth
        if(companyBanner?[indexPath.row].status == 1){
        if let urlSliderString =  companyBanner?[indexPath.row].mobileBannerUrl,
        let url = URL(string: urlSliderString)  {
        cell.sliderImg.af_setImage(withURL: url, placeholderImage: UIImage(), imageTransition: .crossDissolve(1), runImageTransitionIfCached: true)
                   }
        }
        
        
        return cell
    }
    
     
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{

        if UIDevice.current.userInterfaceIdiom == .pad{
        return CGSize(width: 1024, height: 800)
        }
        else{
        return CGSize(width: 375, height: 250)
        }


    }
    @IBOutlet weak var sliderCollection: UICollectionView!
    var companyBanner: [BranchBanner]?
    var timer = Timer()
    var counter = 0
    override func awakeFromNib() {
    self.sliderCollection.dataSource = self
    self.sliderCollection.delegate = self
    sliderCollection.register(UINib(nibName: "SliderImageCell", bundle: Bundle.main), forCellWithReuseIdentifier: "SliderImageCell")
      getBranchBanners()
            
            DispatchQueue.main.async{
                      self.timer = Timer.scheduledTimer(timeInterval: 6.0, target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
                  }
            
        }
        @objc func changeImage() {
              
              if counter < companyBanner?.count ?? 0 {
                  let index = IndexPath.init(item: counter, section: 0)
                  self.sliderCollection.scrollToItem(at: index , at: .centeredHorizontally, animated: true)
                  //self.pageControl.currentPage = counter
                  counter += 1
              } else {
                  counter = 0
                  let index = IndexPath.init(item: counter, section: 0)
                  self.sliderCollection.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
//                  pageControl.currentPage = counter
                  counter = 1
              }
        }
        func getBranchBanners(){
            
            //self.startActivityIndicator()
            let path = ProductionPath.companyBannerUrl + "/all"
            print(path)
            let params = ["companyId": companyId] as [String : Any]
            NetworkManager.getDetails(path: path, params: params, success: { (json, isError) in
                
                do {
                    let jsonData =  try json.rawData()
                    self.companyBanner = try JSONDecoder().decode([BranchBanner].self, from: jsonData)
                    
                    self.sliderCollection.reloadData()
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
                
                //showAlert(title: Strings.error, message: Strings.somethingWentWrong)
            }
        }
        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)

            // Configure the view for the selected state
        }

    
}
