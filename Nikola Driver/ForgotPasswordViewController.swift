//
//  ForgotPasswordViewController.swift
//  Nikola
//
//  Created by Sutharshan on 5/23/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import SwiftyJSON


class ForgotPasswordViewController : UIViewController,UITextFieldDelegate {
    
    var hud : MBProgressHUD = MBProgressHUD()
    @IBOutlet weak var emailTextField: UITextField!
    
    var is_sentry: Bool! = false
    let loginAuto: Bool = false
    var tripStartTime: Date!
    
    @IBOutlet weak var requestpasswordbtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        self.title = "Forgot Password".localized()
        prepareEmailField()
        
        emailTextField.delegate = self
        emailTextField.tag = 0
        
        emailTextField.placeholder = "Email Id".localized()
        requestpasswordbtn.setTitle("Request Password".localized(), for: .normal)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func requestPasswordAction(_ sender: UIButton) {
        self.showLoader(str: "Requesting")
        API.forgotPassword(email: emailTextField.text!){ json, error in
            
            if (error != nil) {
                print(error.debugDescription)
                self.hideLoader()
                self.view.makeToast(message: (error?.localizedDescription)!)
            }else{
                do{
                    let status = json![Const.STATUS_CODE].boolValue
                    let statusMessage = json![Const.STATUS_MESSAGE].stringValue
                    if(status){
                        self.hideLoader()
                        print("Full Login JSON")
                        print(json ?? "json null")
                        self.view.makeToast(message: "Password Sent successfully to Registered Mail Id!")
                        print("forgot password SUCCESS GOING TO MAIN")
                        //self.goToDashboard()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                            self.goToSignIn()
                        })
                        
                    }else{
                        self.hideLoader()
                        print(statusMessage)
                        print(json ?? "json empty")
                        var msg = try json!["error"].stringValue
                        
                        self.view.makeToast(message: msg)
                    }
                }catch {
                    self.hideLoader()
                    self.view.makeToast(message: "Server Error")
                    print("json error")
                }
            }
        }
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
    
    
    
    func goToSignIn(){
        self.navigationController? .popViewController(animated: true)
    }
    
    func goToDashboard(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "SignInNewViewController") as? UIViewController
        self.present(secondViewController!, animated: true, completion: nil)
    }
    @IBAction func backBtn(_ sender: Any)
    {
        self.navigationController? .popViewController(animated: true)
    }
    
}


extension ForgotPasswordViewController{
    fileprivate func prepareEmailField() {
        
        // emailTextField.placeholder = "Email"
//        emailTextField.detail = "Error, incorrect email"
//        emailTextField.isClearIconButtonEnabled = true
        emailTextField.delegate = self
        
    }
}
extension ForgotPasswordViewController : MBProgressHUDDelegate {
    
    func showLoader(str: String) {
        hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = MBProgressHUDModeIndeterminate
        hud.labelText = str
    }
    
    func hideLoader() {
        hud.hide(true)
    }
    
    
}
