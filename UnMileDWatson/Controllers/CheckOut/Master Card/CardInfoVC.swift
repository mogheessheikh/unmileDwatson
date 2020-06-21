//
//  CardInfoVC.swift
//  UnMile
//
//  Created by user on 5/23/20.
//  Copyright © 2020 Moghees Sheikh. All rights reserved.
//

import UIKit
import MPGSDK
import PassKit


class CardInfoVC: UIViewController {

    @IBOutlet var segmentContol: UISegmentedControl!
    @IBOutlet var nameTxt: UITextField!
    @IBOutlet var cardNumberTxt: UITextField!
    @IBOutlet var expMMTxt: UITextField!
    @IBOutlet var expYYTxt: UITextField!
    @IBOutlet var cvvTxt: UITextField!
    @IBOutlet var subTotalLbl: UILabel!
    @IBOutlet var deliveryChargesLbl: UILabel!
    @IBOutlet var grandTotalLbl: UILabel!
    @IBOutlet var btnPay: UIButton!
    
    var applePayButton = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
     var customerOrder: CustomerOrder!
    
    var viewModel = CollectCardInfoViewModel() {
           didSet {
               renderViewModel()
           }
       }
       
       var completion: ((Transaction) -> Void)?
       var cancelled: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        renderViewModel()
        initView()
        view?.addSubview(applePayButton)

        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           applePayButton.addTarget(self, action: #selector(applePayAction), for: .touchUpInside)
       }
    func initView(){
        
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
           segmentContol.setTitleTextAttributes(titleTextAttributes, for: .normal)
           segmentContol.setTitleTextAttributes(titleTextAttributes, for: .selected)
        btnPay.layer.cornerRadius = 7
        btnPay.layer.borderWidth = 2
        
        deliveryChargesLbl.text = "RS.\(customerOrder.deliveryCharge)"
        subTotalLbl.text = "RS.\(customerOrder.subTotal)"
        grandTotalLbl.text = "RS.\(customerOrder.deliveryCharge + customerOrder.subTotal )"
    }
    @IBAction func payButtonPressed(_ sender: Any) {
    completion?(viewModel.transaction!)
    }
    
    @objc func applePayAction() {
    guard let request = viewModel.transaction?.pkPaymentRequest, let apvc = PKPaymentAuthorizationViewController(paymentRequest: request)
        else { return }
        apvc.delegate = self
        self.present(apvc, animated: true, completion: nil)
       }


func renderViewModel() {
      nameTxt?.text = viewModel.transaction?.nameOnCard
      nameTxt?.textColor = viewModel.nameValid ? UIColor.darkText : UIColor.red
      
      cardNumberTxt?.text = viewModel.transaction?.cardNumber
      cardNumberTxt?.textColor = viewModel.cardNumberValid ? UIColor.darkText : UIColor.red
      
      expMMTxt?.text = viewModel.transaction?.expiryMM
      expMMTxt?.textColor = viewModel.expirationMonthValid ? UIColor.darkText : UIColor.red
      
      expYYTxt?.text = viewModel.transaction?.expiryYY
      expYYTxt?.textColor = viewModel.expirationYearValid ? UIColor.darkText : UIColor.red
      
      cvvTxt?.text = viewModel.transaction?.cvv
      cvvTxt?.textColor = viewModel.cvvValid ? UIColor.darkText : UIColor.red
    
      btnPay?.isEnabled = viewModel.isValid
      
//      if viewModel.applePayCapable && PKPaymentAuthorizationViewController.canMakePayments() {
//          orView?.isHidden = false
//          applePayButton.isHidden = false
//      } else {
//          orView?.isHidden = true
//          applePayButton.isHidden = true
//      }
  }
}

extension CardInfoVC: PKPaymentAuthorizationViewControllerDelegate {
    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @available(iOS 11.0, *)
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        viewModel.transaction?.applePayPayment = payment
        self.completion?(viewModel.transaction!)
        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
    }
}

