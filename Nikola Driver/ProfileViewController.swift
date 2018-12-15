//
//  ProfileViewController.swift
//  Nikola
//
//  Created by Sutharshan Ram on 02/08/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import SwiftyJSON
import Localize_Swift

class ProfileViewController: UIViewController, UITextFieldDelegate, SSRadioButtonControllerDelegate {
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var editBtn: UIBarButtonItem!
    
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var phoneNumberField: UITextField!
    
    @IBOutlet weak var countryCodeBtn: UIButton!
    
    @IBOutlet weak var maleRadioBtn: SSRadioButton!
    
    @IBOutlet weak var femaleRadioBtn: SSRadioButton!
    
    var radioButtonController: SSRadioButtonsController?
    
    var picker = UIImagePickerController()
    
    var gender: String = "male"
    var editStatus: Bool = false
    var imageChanged: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        
        firstNameField.delegate = self
        firstNameField.tag = 0
        // firstNameField.textAlignment = NSTextAlignment.right
        lastNameField.delegate = self
        lastNameField.tag = 1
        emailField.delegate = self
        emailField.tag = 2
        phoneNumberField.delegate = self
        phoneNumberField.tag = 3
        
        firstNameField.placeholder = "First Name".localized()
        lastNameField.placeholder = "Last Name".localized()
        emailField.placeholder = "Email Id".localized()
        phoneNumberField.placeholder = "Phone Number".localized()
        
        firstNameField.setBottomBorder()
        lastNameField.setBottomBorder()
        emailField.setBottomBorder()
        phoneNumberField.setBottomBorder()
        picker.delegate = self
        
        phoneNumberField.addDoneButtonOnKeyboard()
        
        
        if defaults.object(forKey: Const.Params.FIRSTNAME) != nil {
            
            //            let trimmedString : String =  defaults.string(forKey: Const.Params.FIRSTNAME)!.trimmingCharacters(in: .whitespaces)
            
            firstNameField.text = defaults.string(forKey: Const.Params.FIRSTNAME)!
        }else {
            firstNameField.text = ""
        }
        if defaults.object(forKey: Const.Params.LAST_NAME) != nil {
            lastNameField.text = defaults.string(forKey: Const.Params.LAST_NAME)!
        }else {
            lastNameField.text = ""
        }
        if defaults.object(forKey: Const.Params.EMAIL) != nil {
            emailField.text = defaults.string(forKey: Const.Params.EMAIL)!
        }else {
            emailField.text = ""
        }
        if defaults.object(forKey: Const.Params.PHONE) != nil {
            phoneNumberField.text = defaults.string(forKey: Const.Params.PHONE)!
        }else {
            phoneNumberField.text = ""
        }
        if defaults.object(forKey: Const.Params.GENDER) != nil {
            gender = defaults.string(forKey: Const.Params.GENDER)!
            if (gender ?? "").isEmpty {
                gender = "male"
            }
        }else {
            gender = "male"
        }
        
        if gender == "male" {
            maleRadioBtn.isSelected = true
        }else{
            femaleRadioBtn.isSelected = true
        }
        
        radioButtonController = SSRadioButtonsController(buttons: maleRadioBtn, femaleRadioBtn)
        radioButtonController!.delegate = self
        radioButtonController!.shouldLetDeSelect = true
        
        changeStateTo(state: false)
        
        var pic: String = defaults.string(forKey: Const.Params.PICTURE)!
        
        if !pic.isEmpty{
            pic = pic.decodeUrl()
            
            let url = URL(string: pic)!
            let placeholderImage = UIImage(named: "ellipse_contacting")!
            
            profileImage?.af_setImage(
                withURL: url,
                placeholderImage: placeholderImage//,
                //filter: filter
            )
        }else{
            profileImage.image = UIImage(named: "driver")!
        }
        
        
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func didSelectButton(selectedButton: UIButton?)
    {
        if selectedButton != nil {
            print(" \(selectedButton?.currentTitle)" )
            let genderString:String = (selectedButton?.currentTitle?.lowercased())!
            print(genderString)
            gender = genderString
        }
    }
    
    
    @IBAction func editBtnAction(_ sender: UIBarButtonItem) {
        editStatus = !editStatus
        let item = self.navigationItem.rightBarButtonItem
        //let button = item!.customView as! UIButton
        
        if editStatus {
            sender.title  = "SAVE".localized()
        }else{
            updateProfile()
            sender.title  = "EDIT".localized()
        }
        
        changeStateTo(state: editStatus)
        
    }
    
    @IBAction func countryCodeAction(_ sender: UIButton) {
        showCountrySelector()
    }
    
    @IBAction func backBtnAction(_ sender: UIBarButtonItem) {
        goToDashboard()
    }
    
    func goToDashboard(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "SWRevealViewController") as? UIViewController
        self.present(secondViewController!, animated: true, completion: nil)
    }
    
    func changeStateTo(state: Bool){
        firstNameField.isEnabled = state
        lastNameField.isEnabled = state
        emailField.isEnabled = state
        maleRadioBtn.isEnabled = state
        femaleRadioBtn.isEnabled = state
        phoneNumberField.isEnabled = state
        //countryCodeBtn.isEnabled = state
    }
    
    @IBAction func imageTapped(_ sender: Any) {
        
        if !editStatus {
            return
        }
        print("hello")
        
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
//        let pickerController = DKImagePickerController()
//
//        pickerController.singleSelect = true
//        pickerController.didSelectAssets = { (assets: [DKAsset]) in
//            print("didSelectAssets")
//            print(assets)
//            if assets.count > 0 {
//                let asset = assets[0]
//                //asset.fetchImageWithSize(layout.itemSize.toPixel(), completeBlock: { image, info in
//                asset.fetchImageWithSize(CGSize(width: 200.0, height:200.0), completeBlock: { image, info in
//                    //if cell.tag == tag {
//                    self.profileImage.image = image
//                    self.imageChanged = true
//                    //}
//                })
//
//            }
//        }
//
//        self.present(pickerController, animated: true) {}
        
    }
    
    func updateProfile(){
        
        let firstName: String = firstNameField.text!
        let lastName: String = lastNameField.text!
        let email: String = emailField.text!
        let phone: String = phoneNumberField.text!
        //        let countryCode: String = (countryCodeBtn.titleLabel?.text)!
        let fullPhone: String = "\(phone)"
        
        var image: UIImage? = nil
        if imageChanged {
            image = self.profileImage.image
            
            let sizedImage : UIImage = self.resizeImage(image: image!, targetSize: CGSize(width: 200.0, height:200.0))
            
            API.updateProfileWithImage(firstName: firstName, lastName: lastName, gender: gender, phone: phone, email: email, image: sizedImage, completionHandler: { json, error in
                if error != nil {
                    print(error!.localizedDescription)
                }else{
                    let status = json![Const.STATUS_CODE].boolValue
                    let statusMessage = json![Const.STATUS_MESSAGE].stringValue
                    if(status){
                        
                        print("Full updateProfile JSON")
                        print(json ?? "json null")
                        
                        self.view.makeToast(message: "Profile Updated")
                        print("updateProfile  success.")
                        
                        let defaults = UserDefaults.standard
                        defaults.set(json![Const.Params.ID].stringValue, forKey: Const.Params.ID)
                        defaults.set(json![Const.Params.TOKEN].stringValue, forKey: Const.Params.TOKEN)
                        defaults.set(json![Const.Params.FIRSTNAME].stringValue, forKey: Const.Params.FIRSTNAME)
                        defaults.set(json![Const.Params.LAST_NAME].stringValue, forKey: Const.Params.LAST_NAME)
                        defaults.set(json![Const.Params.GENDER].stringValue, forKey: Const.Params.GENDER)
                        defaults.set(json![Const.Params.EMAIL].stringValue, forKey: Const.Params.EMAIL)
                        defaults.set(json![Const.Params.PHONE].stringValue, forKey: Const.Params.PHONE)
                        defaults.set(json![Const.Params.PICTURE].stringValue, forKey: Const.Params.PICTURE)
                        defaults.set(json![Const.Params.LOGIN_BY].stringValue, forKey: Const.Params.LOGIN_BY)
                        
                    }else{
                        print(statusMessage)
                        print(json ?? "json empty")
                        let msg = json![Const.ERROR].rawString()!
                        self.view.makeToast(message: msg)
                    }
                }
            })
        }else{
            API.updateProfile(firstName: firstName, lastName: lastName, gender: gender, phone: phone, email: email, completionHandler: { json, error in
                if error != nil {
                    print(error!.localizedDescription)
                }else{
                    let status = json![Const.STATUS_CODE].boolValue
                    let statusMessage = json![Const.STATUS_MESSAGE].stringValue
                    if(status){
                        
                        print("Full updateProfile JSON")
                        print(json ?? "json null")
                        
                        self.view.makeToast(message: "Profile Updated")
                        print("updateProfile  success.")
                        
                        let defaults = UserDefaults.standard
                        defaults.set(json![Const.Params.ID].stringValue, forKey: Const.Params.ID)
                        defaults.set(json![Const.Params.TOKEN].stringValue, forKey: Const.Params.TOKEN)
                        defaults.set(json![Const.Params.FIRSTNAME].stringValue, forKey: Const.Params.FIRSTNAME)
                        defaults.set(json![Const.Params.LAST_NAME].stringValue, forKey: Const.Params.LAST_NAME)
                        defaults.set(json![Const.Params.GENDER].stringValue, forKey: Const.Params.GENDER)
                        defaults.set(json![Const.Params.EMAIL].stringValue, forKey: Const.Params.EMAIL)
                        defaults.set(json![Const.Params.PHONE].stringValue, forKey: Const.Params.PHONE)
                        defaults.set(json![Const.Params.PICTURE].stringValue, forKey: Const.Params.PICTURE)
                        defaults.set(json![Const.Params.LOGIN_BY].stringValue, forKey: Const.Params.LOGIN_BY)
                        //                    defaults.set(json![Const.Params.PAYMENT_MODE_STATUS].stringValue, forKey: Const.Params.PAYMENT_MODE_STATUS)
                    }else{
                        print(statusMessage)
                        print(json ?? "json empty")
                        var msg = json![Const.ERROR].rawString()!
                        self.view.makeToast(message: msg)
                    }
                }
            })
        }
        
    }
    
    func showCountrySelector(){
        guard let countryPopupVC = UIStoryboard(name: "Main", bundle: nil ).instantiateViewController(withIdentifier: "CountryPopupController") as? CountryPopupController else {
            return
        }
        
        countryPopupVC.didSelectCountry = { [weak self](item) in
            if let countryPopupVC = self {
                // Do something with the item.
                let btnTxt: String = "" + item
                //                self?.countryCodeBtn.setTitle(btnTxt, for: UIControlState.normal)
            }
        }
        
        self.addChildViewController(countryPopupVC)
        countryPopupVC.view.frame = self.view.frame
        self.view.addSubview(countryPopupVC.view)
        countryPopupVC.didMove(toParentViewController: self)
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
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
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}
extension ProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        // use the image
        
        
        self.profileImage.image = chosenImage
        self.imageChanged = true
        
        
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
}
