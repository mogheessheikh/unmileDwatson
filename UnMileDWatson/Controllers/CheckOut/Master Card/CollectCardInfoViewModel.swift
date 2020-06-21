//
//  CollectCardInfoViewModel.swift
//  UnMile
//
//  Created by user on 6/4/20.
//  Copyright © 2020 Moghees Sheikh. All rights reserved.
//


import Foundation
import PassKit

struct CollectCardInfoViewModel {
    var transaction: Transaction?
    
    var nameValid: Bool {
        return validate(transaction?.nameOnCard, min: 1, max: 256)
    }
    
    var cardNumberValid: Bool {
        return validate(transaction?.cardNumber, min: 1, max: 19)
    }
    
    var expirationMonthValid: Bool {
        return validate(transaction?.expiryMM, min: 2, max: 2)
    }
    
    var expirationYearValid: Bool {
        return validate(transaction?.expiryYY, min: 2, max: 2)
    }
    
    var cvvValid: Bool {
        return validate(transaction?.cvv, min: 3, max: 4)
    }
    
    var isValid: Bool {
        return (nameValid && cardNumberValid && expirationYearValid && expirationMonthValid && expirationYearValid && cvvValid) || transaction?.applePayPayment != nil
    }
    
    var applePayCapable: Bool {
        return transaction?.applePayMerchantIdentifier != nil && !transaction!.applePayMerchantIdentifier!.isEmpty
    }

    fileprivate func validate(_ value: String?, min: Int = 1, max: Int? = nil) -> Bool {
        guard let value = value, value.count >= min else { return false }
        if let max = max, value.count > max {
            return false
        } else {
            return true
        }
    }
}
