//
//  SignInViewController.swift

//  Alicia
//
//  Created by Sutharshan on 5/4/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import SwiftyJSON
import Localize_Swift

class SignInViewController:UIViewController, UITextFieldDelegate {
    
    var hud : MBProgressHUD = MBProgressHUD()
    @IBOutlet weak var mobileNumber: UITextField!
    @IBOutlet weak var password: UITextField!
    var is_sentry: Bool! = false
    let loginAuto: Bool = true
    let availableLanguages = Localize.availableLanguages()
    var actionSheet: UIAlertController!
    
    @IBOutlet weak var signinbtn: UIButton!
    @IBOutlet weak var forgotPassbtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setText()
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: mobileNumber.frame.origin.x-20, y: mobileNumber.frame.size.height - 1, width:  mobileNumber.frame.size.width, height: 1)
        bottomLine.backgroundColor = #colorLiteral(red: 1, green: 0.4980392157, blue: 0, alpha: 1).cgColor
        mobileNumber.borderStyle = UITextBorderStyle.none
        mobileNumber.layer.addSublayer(bottomLine)
        mobileNumber.layer.masksToBounds = true
        
        let bottomLine1 = CALayer()
        bottomLine1.frame = CGRect(x: password.frame.origin.x-20, y: password.frame.size.height - 1, width:  password.frame.size.width, height: 1)
        bottomLine1.backgroundColor = #colorLiteral(red: 1, green: 0.4980392157, blue: 0, alpha: 1).cgColor
        password.borderStyle = UITextBorderStyle.none
        password.layer.addSublayer(bottomLine1)
        password.layer.masksToBounds = true
        
        
        mobileNumber.delegate = self
        mobileNumber.tag = 0
        password.delegate = self
        password.tag = 1
        
        if loginAuto {
//            mobileNumber.text = "shanthakumar@provenlogic.net"
//            password.text = "43082d73"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name( LCLLanguageChangeNotification), object: nil)
    }
    
    @objc func setText(){
        self.title = "Sign In".localized()
        mobileNumber.placeholder = "Email Id".localized()
        password.placeholder = "Password".localized()
        forgotPassbtn.setTitle("Forgot Password?".localized(), for: .normal)
        signinbtn.setTitle("Sign In".localized(), for: .normal)
        
    }
    
    
    // Remove the LCLLanguageChangeNotification on viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //MARK:- Button Action Methods
    @IBAction func changeLanguageButtonAction(_ sender: Any) {
        actionSheet = UIAlertController(title: nil, message: "Switch Language", preferredStyle: UIAlertControllerStyle.actionSheet)
        for language in availableLanguages {
            let displayName = Localize.displayNameForLanguage(language)
            if language == "Base" {
                
            }else {
                let languageAction = UIAlertAction(title: displayName, style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    Localize.setCurrentLanguage(language)
                })
                actionSheet.addAction(languageAction)
            }
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {
            (alert: UIAlertAction) -> Void in
        })
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    
    
    @IBAction func backBtn(_ sender: Any)
    {
        self.navigationController? .popViewController(animated: true)
    }
    @IBAction func forgotPassWord(_sender: Any)
    {
        self .performSegue(withIdentifier: "forgotPassword", sender: nil)
    }
    
    @IBAction func SignInBtn(_ sender: Any) {
        
        //self.view.makeToast(message: "Signing In")
        self.showLoader( str: "Signing In")
        API.signIn( email: mobileNumber.text!, password: password.text!){ json, error in
            
            if let error = error {
                self.hideLoader()
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status){
                        self.hideLoader()
                        print("Full Login JSON")
                        print(json ?? "json null")
                        print(json["response"]["_id"].stringValue)
                        print(json["response"]["name"].stringValue)
                        print(json["response"]["mobile"].stringValue)
                        print(json["response"]["token"].stringValue)
                        
                        let defaults = UserDefaults.standard
                        defaults.set(json[Const.Params.ID].stringValue, forKey: Const.Params.ID)
                        
                        print("user id \(DATA().getUserId())")
                        DATA().putSessionToken(token: json[Const.Params.TOKEN].stringValue)
                        //defaults.set(json![Const.Params.TOKEN].stringValue, forKey: Const.Params.TOKEN)
                        defaults.set(json[Const.Params.FIRSTNAME].stringValue, forKey: Const.Params.FIRSTNAME)
                        defaults.set(json[Const.Params.LAST_NAME].stringValue, forKey: Const.Params.LAST_NAME)
                        defaults.set(json[Const.Params.CURRENCY].stringValue, forKey: Const.Params.CURRENCY)
                        defaults.set(json[Const.Params.GENDER].stringValue, forKey: Const.Params.GENDER)
                        defaults.set(json[Const.Params.EMAIL].stringValue, forKey: Const.Params.EMAIL)
                        defaults.set(json[Const.Params.TIMEZONE].stringValue, forKey: Const.Params.TIMEZONE)
                        defaults.set(json[Const.Params.PICTURE].stringValue, forKey: Const.Params.PICTURE)
                        defaults.set(json[Const.Params.LOGIN_BY].stringValue, forKey: Const.Params.LOGIN_BY)
                        defaults.set(json[Const.Params.COUNTRY].stringValue, forKey: Const.Params.COUNTRY)
                        defaults.set(json[Const.Params.ACTIVE].stringValue, forKey: Const.Params.ACTIVE)
                        defaults.set(json[Const.Params.SERVICE_TYPE].stringValue, forKey: Const.Params.SERVICE_TYPE)
                        defaults.set(json[Const.Params.SERVICE_TYPE_NAME].stringValue, forKey: Const.Params.SERVICE_TYPE_NAME)
                        print(Const.Params.PHONE)
                        defaults.set(json[Const.Params.PHONE].stringValue, forKey: Const.Params.PHONE)
                        
                        print("LOGIN SUCCESS GOING TO MAIN")
                        self.goToDashboard()
                        //self.view.makeToast(message: "Logged In")
                    }else{
                        print(statusMessage)
                        self.hideLoader()
                        print(json ?? "json empty")
                        var msg = json[Const.ERROR].rawString()!
                        msg = msg.replacingOccurrences( of:"[{}\",]", with: "", options: .regularExpression)
                        
                        self.view.makeToast(message: msg)
                    }
                    
                    
                    
                }else {
                    self.hideLoader()
                    debugPrint("Invalid JSON :(")
                }
                
                
                
            }
            
            
            
        }
    }
    
    func goToDashboard(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "SWRevealViewController") as? UIViewController
        self.present(secondViewController!, animated: true, completion: nil)
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
    
}
extension SignInViewController : MBProgressHUDDelegate {
    
    func showLoader(str: String) {
        hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = MBProgressHUDModeIndeterminate
        hud.labelText = str
    }
    
    func hideLoader() {
        hud.hide(true)
    }
    
    
}

