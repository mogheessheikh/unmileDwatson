//
//  UploadPrescriptionIpad.swift
//  UnMile
//
//  Created by user on 4/11/20.
//  Copyright © 2020 Moghees Sheikh. All rights reserved.
//

import UIKit

class UploadPrescriptionIpad: BaseViewController {

    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var btnGallery: UIButton!
    var imagePicker = UIImagePickerController()
    var img :UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnCamera.layer.cornerRadius = 8
        btnGallery.layer.cornerRadius = 8
        btnCamera.layer.borderWidth = 4
        btnGallery.layer.borderWidth = 4
        imagePicker.delegate = (self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate)
    }

@IBAction func openCamera(_ sender: Any) {
    
    if(UIImagePickerController .isSourceTypeAvailable(.camera)){
          imagePicker.sourceType = .camera
          imagePicker.allowsEditing = true
          self.present(imagePicker, animated: true, completion: nil)
       }
       else{
           showAlert(title: "Warning", message: "You don't have camera")
           }
    }
@IBAction func openGallery(_ sender: Any) {
    imagePicker.sourceType = .savedPhotosAlbum
    imagePicker.allowsEditing = true
                  
    present(imagePicker, animated: true, completion: nil)
        
    }
@IBAction func closeView(_ sender: Any) {
    
    self.dismiss(animated: true, completion: nil)
    }
    

}
extension UploadPrescriptionIpad : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            img = image
            
            let prescriptionVC = Storyboard.main.instantiateViewController(withIdentifier: PrescriptionVC.identifier)as! PrescriptionVC
            prescriptionVC.title = "Upload Prescription"
            prescriptionVC.img = img
            self.dismiss(animated: true, completion: nil)
            self.present(prescriptionVC, animated: true, completion: nil)
          
        }
        dismiss(animated: true, completion: nil)
    }
}
