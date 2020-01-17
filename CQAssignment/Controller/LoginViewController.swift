//
//  ViewController.swift
//  CQAssignment
//
//  Created by Neel Nishant on 12/01/20.
//  Copyright © 2020 Neel Nishant. All rights reserved.
//

import UIKit
import GoogleSignIn
import LocalAuthentication
class LoginViewController: UIViewController {

    @IBOutlet var contentView: UIView!
    let context = LAContext()
    var loginReason = "Logging in with Biometrics"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        authenticateUserWithBiometrics()
        addGradientToView(view: contentView)
        
        //to get notification if error occurs while signing in
        NotificationCenter.default.addObserver(self, selector: #selector(createAlert), name: NSNotification.Name("ErrorSigningIn"), object: nil)
    }
    
    
    func checkIfUserExists(){
        let user = UserDefaults.standard.value(forKey: "user")
        if (user != nil){
            performSegue(withIdentifier: "loginSegue", sender: nil)
        }
    }
    
    
    
}

//UIView gradient, biometrics authetication and
extension LoginViewController{
    func addGradientToView(view: UIView)
    {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(red: 148 / 255, green: 33 / 255, blue: 147 / 255, alpha: 1.0).cgColor, UIColor(red: 41 / 255, green: 128 / 255, blue: 183 / 255, alpha: 1.0).cgColor, UIColor.white.cgColor]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @objc func createAlert(notification: Notification){
        let message = notification.userInfo!["message"] as! String
        showAlert(title: "Error", message: message, isAuth: false)
    }
    
    func showAlert(title: String, message: String, isAuth: Bool){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            if(!isAuth){
                let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(action)
            }
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    func authenticateUserWithBiometrics(){
        authenticateUser { (message) in
            if message != nil{
                self.showAlert(title: "Not you?", message: "The app is not able to autheticate your identity", isAuth: true)
            }
            else{
                self.checkIfUserExists()
            }
        }
    }
    //reference from raywenderlich.com
    
    func canEvaluatePolicy()-> Bool{
        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }
    func authenticateUser(completion: @escaping (String?) -> Void) {
        
      guard canEvaluatePolicy() else {
        completion("Touch ID not available")
        return
      }
        
      context.evaluatePolicy(.deviceOwnerAuthentication,
        localizedReason: loginReason) { (success, evaluateError) in
          if success {
            DispatchQueue.main.async {
              completion(nil)
            }
          } else {
                                  
            let message: String
                                  
            switch evaluateError {
            case LAError.authenticationFailed?:
              message = "There was a problem verifying your identity."
            case LAError.userCancel?:
              message = "You pressed cancel."
            case LAError.userFallback?:
              message = "You pressed password."
            case LAError.biometryNotAvailable?:
              message = "Face ID/Touch ID is not available."
            case LAError.biometryNotEnrolled?:
              message = "Face ID/Touch ID is not set up."
            case LAError.biometryLockout?:
              message = "Face ID/Touch ID is locked."
            default:
              message = "Face ID/Touch ID may not be configured"
            }
              
            completion(message)
          }
      }
    }
}

