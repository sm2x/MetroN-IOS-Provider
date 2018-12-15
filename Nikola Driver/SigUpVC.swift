//
//  SigUpVC.swift
//  Nikola Driver
//
//  Created by sudharsan s on 02/12/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import UIKit
import SwiftyJSON
import AlamofireImage


class SigUpVC: UIViewController,UITextFieldDelegate,SSRadioButtonControllerDelegate {
    /**
     This function is called when a button is selected. If 'shouldLetDeSelect' is true, and a button is deselected, this function
     is called with a nil.
     
     */
    @objc func didSelectButton(selectedButton: UIButton?) {
        
        if selectedButton != nil {
            print(" \(selectedButton?.currentTitle)" )
            let genderString:String = (selectedButton?.currentTitle?.lowercased())!
            print(genderString)
            gender = genderString
        }
        
        
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var countryViewHeightConstrains: NSLayoutConstraint!
    @IBOutlet weak var txtFristName: UITextField!
    
    @IBOutlet weak var txtLastName: UITextField!
    
    @IBOutlet weak var txtEmail: UITextField!
    
    @IBOutlet weak var txtPassword: UITextField!
    var hud : MBProgressHUD = MBProgressHUD()
    
    @IBOutlet weak var btnFemale: SSRadioButton!
    @IBOutlet weak var btnMale: SSRadioButton!
    
    @IBOutlet weak var txtPhonenumber: UITextField!
    @IBOutlet weak var txtCountryCode: UITextField!
    
    @IBOutlet weak var car_image: UIImageView!
    
    @IBOutlet weak var txtCarPlateNumber: UITextField!
    
    @IBOutlet weak var txtCarBrand: UITextField!
    
    @IBOutlet weak var txtCarColor: UITextField!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var tableview: UITableView!
    
    fileprivate var phoneCode : String = ""
    
    fileprivate var isCarImageAdded: Bool = false
    
    
    fileprivate var radioButtonController: SSRadioButtonsController?
    fileprivate var gender : String = ""
    fileprivate var carTypeNameArray = [String]()
    fileprivate var carImageArray = [String]()
    fileprivate var carIdArray = [Int]()
    fileprivate var isSelected : Bool = false
    fileprivate var currentSelection : Int = -1
    fileprivate var serviceId : Int = -1
    
    var imageChanged: Bool = false
    
    @IBOutlet weak var courntryCodeView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var countryArray :[Any]! = []
    
    var picker = UIImagePickerController()
      var carPicker = UIImagePickerController()
    //MARK:- override method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegateFortxt()
        RadioButtonDelegate()
        getTaxiTypes()
        UIViewSetup()
        // Do any additional setup after loading the view.
    }
    
    //MARK:- UIViewSetup
    private func UIViewSetup() {
        self.title = "Registration".localized()
        txtCountryCode.text = "  IN +91"
        countryViewHeightConstrains.constant = 0
        tableview.tableFooterView = UIView()
        readJson()
    }
    
    //MARK:- SetUITextField Delegate
    private func setDelegateFortxt() {
        
        txtFristName.delegate = self
        txtFristName.tag = 0
        txtFristName.setBottomBorder()
        
        txtLastName.delegate = self
        txtLastName.tag = 1
        txtLastName.setBottomBorder()
        
        txtEmail.delegate = self
        txtEmail.tag = 2
        txtEmail.setBottomBorder()
        
        txtCarBrand.delegate = self
        txtCarBrand.tag = 6
        txtCarBrand.setBottomBorder()
        
        txtCarColor.delegate = self
        txtCarColor.tag = 7
        txtCarColor.setBottomBorder()
        
        txtPassword.delegate = self
        txtPassword.tag = 3
        txtPassword.setBottomBorder()
        
        txtPhonenumber.delegate = self
        txtPhonenumber.tag = 4
        txtPhonenumber.setBottomBorder()
        
        txtCarPlateNumber.delegate = self
        txtCarPlateNumber.tag = 5
        txtCarPlateNumber.setBottomBorder()
        
        txtPhonenumber.addDoneButtonOnKeyboard()
        txtFristName.addDoneButtonOnKeyboard()
        txtEmail.addDoneButtonOnKeyboard()
        txtCarBrand.addDoneButtonOnKeyboard()
        txtLastName.addDoneButtonOnKeyboard()
        txtCarPlateNumber.addDoneButtonOnKeyboard()
        txtCarColor.addDoneButtonOnKeyboard()
        txtPassword.addDoneButtonOnKeyboard()
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
        
    }
    
    //MARK:- RadioButtonDelegate
    private func RadioButtonDelegate() {
        radioButtonController = SSRadioButtonsController(buttons: btnMale, btnFemale)
        radioButtonController!.delegate = self
        radioButtonController!.shouldLetDeSelect = true
    }
    
    //MARK:- ReadJson file
    private func readJson() {
        do {
            if let file = Bundle.main.url(forResource: "countryCodes", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [String: Any] {
                    // json is a dictionary
                    print(object)
                } else if let object = json as?  [[String:Any]] {
                    // json is an array
                    print(object)
                    
                    
                    self.countryArray = object
                    
                    self.tableview.delegate = self
                    self.tableview.dataSource = self
                    
                    self.tableview.reloadData()
                    
                } else {
                    print("JSON is invalid")
                }
            } else {
                print("no file")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //MARK:- ResizeImage
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
    
    
    //MARK:- GetTaxiTypes
    private func getTaxiTypes() {
        self.showLoader(str: "Please wait")
        API.getTaxiTypes() { json, error in
            
            if let error = error {
                self.hideLoader()
                debugPrint(error.localizedDescription)
            }else {
                if let json = json {
                    print(json)
                    let status = json[Const.STATUS_CODE].boolValue
                    if(status){
                        let services = json["services"].arrayValue
                        for array : JSON in services {
                            print(array["name"])
                            self.carTypeNameArray.append(array["name"].stringValue)
                            self.carImageArray.append(array["picture"].stringValue)
                            self.carIdArray.append(array["id"].intValue)
                        }
                        self.hideLoader()
                        self.collectionView.delegate = self
                        self.collectionView.dataSource = self
                        self.collectionView.reloadData()
                        
                    }else {
                        
                        self.hideLoader()
                    }
                    
                }else {
                    self.hideLoader()
                    debugPrint("invalid json :(")
                }
                
            }
            
        }
        
    }
    
    //MARK:- Textfield Delegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            
            if nextField.tag > 1 {
                if nextField.tag > 4 {
                    scrollView.contentOffset = CGPoint(x:0, y: txtPhonenumber.frame.origin.y + 30)
                    
                }else {
                    scrollView.contentOffset = CGPoint(x:0, y: scrollView.frame.origin.y + 20)
                }
                
                
            }
            
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func btnDOBAction(_ sender: Any) {
    }
    
    
    //MARK:- profileImageSetButtonAction
    @IBAction func profileImageSetButtonAction(_ sender: Any) {
        
        picker.allowsEditing = false
        picker.delegate = self
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
    @IBAction func countryCodeButtonAction(_ sender: Any) {
        
        countryViewHeightConstrains.constant = 100
        
        
    }
    
    //MARK:- Resgister User Action Method
    @IBAction func registerButtonAction(_ sender: Any) {
        
        
        if (txtFristName.text?.isEmpty)! || (txtLastName.text?.isEmpty)! || (txtEmail.text?.isEmpty)! || (txtPassword.text?.isEmpty)! || (txtPhonenumber.text?.isEmpty)! || (txtCarPlateNumber.text?.isEmpty)! || (txtCarBrand.text?.isEmpty)! || (txtCarColor.text?.isEmpty)!{
            let alert = UIAlertController(title: "Message", message: "PLEASE FILL ALL REQURIED DETAILS", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            
            
            
        }
        else if (serviceId == -1) {
            
            let alert = UIAlertController(title: "Message", message: "PLEASE SELECT THE SERVICE", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
//        else if (gender.isEmpty) {
//
//            let alert = UIAlertController(title: "Message", message: "PLEASE SELECT THE GENDER", preferredStyle: UIAlertControllerStyle.alert)
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//
//        }
        else if (txtEmail.text?.isEmpty)! || !isValidEmailAddress(emailAddressString: txtEmail.text!){
            
            let alert = UIAlertController(title: "Message", message: "PLEASE ENTER VALID EMAIL ID", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        else if isCarImageAdded == false {
            let alert = UIAlertController(title: "Message", message: "PLEASE ADD CAR IMAGE", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            
            self.showLoader(str: "Please wait")
            
            var image: UIImage? = nil
            var carimage: UIImage? = nil
            if imageChanged {
                
                image = self.profileImage.image
                carimage = self.car_image.image
                
                let sizedImage : UIImage = self.resizeImage(image: image!, targetSize: CGSize(width: 200.0, height:200.0))
                
                let carsizedImage: UIImage = self.resizeImage(image: carimage!, targetSize: CGSize(width: 200.0, height:200.0))
                
                let svid : String = String(serviceId)
                
                let phone : String = phoneCode + txtPhonenumber.text!
                
                API.register(frist_name: txtFristName.text!, timezone: TimeZone.current.identifier, service_type: svid, color: txtCarColor.text!, brand: txtCarBrand.text!, plate_no: txtCarPlateNumber.text!, gender: gender, last_name: txtLastName.text!, email: txtEmail.text!, phonenumber: phone, password: txtPassword.text!,image:sizedImage,car_image: carsizedImage, imagestatus: imageChanged) { json , error in
                    
                    print(error ?? "")
                    print(json ?? "")
                    
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
                                print(json)
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
                                
                                if var error_code : Int = json["error_code"].intValue {
                                    
                                    if error_code == 101 {
                                        
                                        var msg = json["error_messages"].stringValue
                                        
                                        let alert = UIAlertController(title: "Message", message: msg, preferredStyle: UIAlertControllerStyle.alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                        self.present(alert, animated: true, completion: nil)
                                        
                                    }else {
                                        
                                        var msg = json[Const.ERROR].rawString()
                                        let alert = UIAlertController(title: "Message", message: msg, preferredStyle: UIAlertControllerStyle.alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                    
                                }
                                
                                //                                var msg = json[Const.ERROR].rawString()!
                                //                                msg = msg.replacingOccurrences( of:"[{}\",]", with: "", options: .regularExpression)
                                //
                                //                                self.view.makeToast(message: msg)
                            }
                            
                            
                            
                        }else {
                            self.hideLoader()
                            debugPrint("Invalid JSON :(")
                        }
                        
                        
                        
                    }
                }
                
                
            }
            else {
                let svid : String = String(serviceId)
                
                let phone : String = phoneCode + txtPhonenumber.text!
                
                API.register(frist_name: txtFristName.text!, timezone: TimeZone.current.identifier, service_type: svid, color: txtCarColor.text!, brand: txtCarBrand.text!, plate_no: txtCarPlateNumber.text!, gender: gender, last_name: txtLastName.text!, email: txtEmail.text!, phonenumber: phone, password: txtPassword.text!,imagestatus: imageChanged) { json , error in
                    
                    print(error ?? "")
                    print(json ?? "")
                    
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
                                
                                if var error_code : Int = json["error_code"].intValue {
                                    
                                    if error_code == 101 {
                                        
                                        var msg = json["error_messages"].stringValue
                                        
                                        let alert = UIAlertController(title: "Message", message: msg, preferredStyle: UIAlertControllerStyle.alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                        self.present(alert, animated: true, completion: nil)
                                        
                                    }else {
                                        
                                        var msg = json[Const.ERROR].rawString()
                                        let alert = UIAlertController(title: "Message", message: msg, preferredStyle: UIAlertControllerStyle.alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                    
                                }
                                //                                var msg = json[Const.ERROR].rawString()!
                                //                                msg = msg.replacingOccurrences( of:"[{}\",]", with: "", options: .regularExpression)
                                //
                                //                                self.view.makeToast(message: msg)
                            }
                            
                            
                            
                        }else {
                            self.hideLoader()
                            debugPrint("Invalid JSON :(")
                        }
                        
                        
                        
                    }
                }
                
                
            }
        }
    }
    
    
    @IBAction func addCarImageActionMethod(_ sender: Any) {
        
        carPicker.allowsEditing = false
        carPicker.delegate = self
        carPicker.sourceType = .photoLibrary
        self.present(carPicker, animated: true, completion: nil)
        
        
    }
    
    func isValidEmailAddress(emailAddressString: String) -> Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
    
    
    
    func goToDashboard(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "SWRevealViewController") as? UIViewController
        self.present(secondViewController!, animated: true, completion: nil)
    }
    
    
    
    
}

//MARK:- UICollectionView Delegate
extension SigUpVC : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.carTypeNameArray.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        
        
        
        if currentSelection == indexPath.row {
            currentSelection = -1
            serviceId = -1
            collectionView.reloadItems(at: [indexPath as IndexPath])
        }else {
            serviceId = carIdArray[indexPath.row]
            currentSelection = indexPath.row
            collectionView.reloadItems(at: [indexPath as IndexPath])
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CartypeCell", for: indexPath) as! CartypeCell
        
        cell.lblCarType.text = carTypeNameArray[indexPath.row]
        
        let imgURL : String = carImageArray[indexPath.row]
        
        
        //number_seat
        if !((imgURL).isEmpty)
        {
            let url = URL(string: imgURL.decodeUrl())!
            cell.carImg?.af_setImage(
                withURL: url,
                placeholderImage: nil//,
                //filter: filter
            )
            
        }else{
            //           cell.carImg.image = Toucan(image: UIImage(named: "taxi")!).maskWithEllipse().image
        }
        
        if currentSelection == indexPath.row {
            
            cell.selectedImg.isHidden = false
        }else {
            cell.selectedImg.isHidden = true
            
        }
        
        
        return cell
    }
    
}

//MARK:- UITableViewDelegate
extension SigUpVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return self.total
        return self.countryArray.count
    }
    
    //    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    //        cell.selectionStyle = UITableViewCellSelectionStyle.none
    //
    //    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:CountryCodeCell = tableView.dequeueReusableCell(withIdentifier: "CountryCodeCell", for: indexPath) as! CountryCodeCell
        
        
        let dic : [String: String] = self.countryArray[indexPath.row] as! [String : String]
        
        
        
        let name : String = dic["code"]!
        
        let cd : String = "\(name ) " + dic["dial_code"]!
        
        //cell.lblCountryName.text = dic["name"]
        cell.lblCountryCode.text = cd
        //cell.mapImg.image = UIImage(named: dic["code"]!)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath){
        
        let dic : [String: String] = self.countryArray[indexPath.row] as! [String : String]
        print(dic)
        
        countryViewHeightConstrains.constant = 0
        
        let name : String = dic["code"]!
        
        let cd : String = "\(name )" + dic["dial_code"]!
        
        phoneCode = dic["dial_code"]!
        
        txtCountryCode.text = "  \(cd)"
        
        
        
    }
    
    
    
}

//MARK:- MBProgressHUDDelegate
extension SigUpVC : MBProgressHUDDelegate {
    
    func showLoader(str: String) {
        hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = MBProgressHUDModeIndeterminate
        hud.labelText = str
    }
    
    func hideLoader() {
        hud.hide(true)
    }
    
    
}

//MARK:- UIImage extension
extension UIImage {
    var isPortrait:  Bool    { return size.height > size.width }
    var isLandscape: Bool    { return size.width > size.height }
    var breadth:     CGFloat { return min(size.width, size.height) }
    var breadthSize: CGSize  { return CGSize(width: breadth, height: breadth) }
    var breadthRect: CGRect  { return CGRect(origin: .zero, size: breadthSize) }
    var circleMasked: UIImage? {
        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait  ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }
        UIBezierPath(ovalIn: breadthRect).addClip()
        UIImage(cgImage: cgImage).draw(in: breadthRect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
extension SigUpVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        // use the image
        
        if picker == carPicker {
            self.car_image.image = chosenImage
            self.isCarImageAdded = true
        }
        else{
            self.profileImage.image = chosenImage
            self.imageChanged = true
        }
    
//        if imageChanged {
//            
//        }else {
//           
//        }
        
       
        
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

