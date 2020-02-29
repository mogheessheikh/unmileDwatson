//
//  PrescriptionVC.swift
//  UnMile
//
//  Created by user on 1/14/20.
//  Copyright © 2020 Moghees Sheikh. All rights reserved.
//

import UIKit

class PrescriptionVC: BaseViewController {

    
    @IBOutlet weak var prescriptionImg: UIImageView!
    
    @IBOutlet weak var btnSubmit: UIButton!
    var img:UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        prescriptionImg.image = img
        // Do any additional setup after loading the view.
    }
    
    
   
        
        func imageTobase64(image: UIImage) -> String {
            var base64String = ""
            let  cim = CIImage(image: image)
            if (cim != nil) {
                let imageData = image.jpegData(compressionQuality: 0.5)
                base64String = (imageData?.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters))!
            }
            return base64String
        }


    func make64BitToPathFile(Bit64String: String){
        startActivityIndicator()
        let path = URL(string: ProductionPath.imageUrl + "/upload")
        let parameters =     Bit64String //["encodedFile": Bit64String] as [String: Any]
        
        var request = URLRequest(url: path!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        
        request.httpBody = parameters.data(using: .utf8)
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
                        
            if let data = data {
                do {
                   // let json = try JSONSerialization.jsonObject(with: data, options: [])as? NSDictionary
                    //let jsonData = try JSONSerialization.data(withJSONObject: json as Any, options: .prettyPrinted)
                    let encodedObjectJsonString = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
                    
                    print(encodedObjectJsonString)
                    DispatchQueue.main.async {
                        if let httpResponse = response as? HTTPURLResponse {
                            print("error \(httpResponse.statusCode)")
                            
                            if httpResponse.statusCode == 200{
                                restResponse = true
                                self.stopActivityIndicator()
                             UserDefaults.standard.set(encodedObjectJsonString, forKey: keyForFilePath)
//                            self.showAlert(title: "Prescription is Uploaded. Now you can proceed to your Order", message: "")
//
                                let item = Storyboard.main.instantiateViewController(withIdentifier: BranchCategoryProductsVC.identifier) as! BranchCategoryProductsVC
                                item.categoryName = "Medicine"
                                item.catagoryId = 4547
                                self.navigationController?.pushViewController(item, animated: true)
                            }
                            else
                            {
                                self.showAlert(title: "Request Decline", message: "Something goes worng")
                            }
                        }
                    }
                    
                } catch {
                    print(error)
                }
            }
            
            }.resume()
    
        
    }
    
    func  convertImageToBase64String(image : UIImage ) -> String
    {
        let strBase64 =  image.pngData()?.base64EncodedString()
        return strBase64!
    }
    
    func resizeImageWithAspect(image: UIImage,scaledToMaxWidth width:CGFloat,maxHeight height :CGFloat)->UIImage? {
        let oldWidth = image.size.width;
        let oldHeight = image.size.height;

        let scaleFactor = (oldWidth > oldHeight) ? width / oldWidth : height / oldHeight;

        let newHeight = oldHeight * scaleFactor;
        let newWidth = oldWidth * scaleFactor;
        let newSize = CGSize(width: newWidth, height: newHeight)

        UIGraphicsBeginImageContextWithOptions(newSize,false,UIScreen.main.scale);

        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height));
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage
    }
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
         let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        img.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    @IBAction func submitTapped(_ sender: Any) {
       var string64Bit = ""
        let imge = img
        let reSizedImg = resizeImageWithAspect(image: img, scaledToMaxWidth: 500, maxHeight: 500)//self.resizeImage(image: img, targetSize: CGSize(width: 300,height: 300))
        string64Bit = convertImageToBase64String(image: reSizedImg!)
        make64BitToPathFile(Bit64String: string64Bit)
       self.dismiss(animated: true, completion: nil)
    }
}
