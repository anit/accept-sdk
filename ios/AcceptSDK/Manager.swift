//
//  Manager.swift
//  AcceptSDK
//
//  Created by Madhavi  Solanki on 26/06/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

import Foundation
import UIKit
import PassKit

@objc(Manager)
class Manager: UIViewController,PKPaymentAuthorizationViewControllerDelegate {
  
  @objc let SupportedPaymentNetworks = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.amex]

  @objc func methodQueue() ->  DispatchQueue {
    return DispatchQueue.main
  }
  
  @objc func getAPI() {
    let supportedNetworks = [ PKPaymentNetwork.amex, PKPaymentNetwork.masterCard, PKPaymentNetwork.visa ]
    
    if PKPaymentAuthorizationViewController.canMakePayments() == false {
      let alert = UIAlertController(title: "Apple Pay is not available", message: nil, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
      //return self.present(alert, animated: true, completion: nil)
    }
    
    if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: supportedNetworks) == false {
      let alert = UIAlertController(title: "No Apple Pay payment methods available", message: nil, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
     // return self.present(alert, animated: true, completion: nil)
    }
    
    let request = PKPaymentRequest()
    request.currencyCode = "USD"
    request.countryCode = "US"
    request.merchantIdentifier = "merchant.authorize.net.test.dev15"
    request.supportedNetworks = SupportedPaymentNetworks
    // DO NOT INCLUDE PKMerchantCapability.capabilityEMV
    request.merchantCapabilities = PKMerchantCapability.capability3DS
    
    request.paymentSummaryItems = [
      PKPaymentSummaryItem(label: "Total", amount: 254.00)
    ]
    
    let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
    applePayController?.delegate = self

    self.present(applePayController!, animated: true, completion: nil)
  // implement you method
  }
  
   func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: (@escaping (PKPaymentAuthorizationStatus) -> Void)) {
    print("paymentAuthorizationViewController delegates called")
    
    if payment.token.paymentData.count > 0 {
      let base64str = self.base64forData(payment.token.paymentData)
      let messsage = String(format: "Data Value: %@", base64str)
      let alert = UIAlertController(title: "Authorization Success", message: messsage, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
      return self.performApplePayCompletion(controller, alert: alert)
    } else {
      let alert = UIAlertController(title: "Authorization Failed!", message: nil, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
      return self.performApplePayCompletion(controller, alert: alert)
    }
  }
  
  @objc func performApplePayCompletion(_ controller: PKPaymentAuthorizationViewController, alert: UIAlertController) {
    controller.dismiss(animated: true, completion: {() -> Void in
      self.present(alert, animated: false, completion: nil)
    })
  }
  
  func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
    controller.dismiss(animated: true, completion: nil)
    print("paymentAuthorizationViewControllerDidFinish called")
  }
  
  @objc func base64forData(_ theData: Data) -> String {
    let charSet = CharacterSet.urlQueryAllowed
    
    let paymentString = NSString(data: theData, encoding: String.Encoding.utf8.rawValue)!.addingPercentEncoding(withAllowedCharacters: charSet)
    
    return paymentString!
  }
  
}
