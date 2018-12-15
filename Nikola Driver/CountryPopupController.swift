//
//  CountryPopupController.swift
//  Alicia
//
//  Created by Sutharshan on 5/10/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import MRCountryPicker

class CountryPopupController: UIViewController , MRCountryPickerDelegate {
    
    @IBOutlet weak var countryPicker: MRCountryPicker!
    
    //    @IBOutlet weak var countryPicker: MRCountryPicker!
    //    @IBOutlet weak var countryName: UILabel!
    //    @IBOutlet weak var countryCode: UILabel!
    //    @IBOutlet weak var countryFlag: UIImageView!
    //    @IBOutlet weak var phoneCode: UILabel!
    var didSelectCountry: ((_ item: String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countryPicker.countryPickerDelegate = self
        countryPicker.showPhoneNumbers = true
        //countryPicker.setCountry("IN")
        
        let user_defaults = UserDefaults.standard
        let tempPhoneCode = user_defaults.string(forKey: "temp_phonecode")
        
        if (tempPhoneCode ?? "").isEmpty {
            countryPicker.setCountry("IN")
        }else{
            countryPicker.setCountryByPhoneCode(tempPhoneCode!)
        }
    }

    func countryPhoneCodePicker(_ picker: MRCountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        //        self.countryName.text = name
        //        self.countryCode.text = countryCode
        //        self.phoneCode.text = phoneCode
        //        self.countryFlag.image = flag
        
        didSelectCountry?(phoneCode)
        let user_defaults = UserDefaults.standard
        user_defaults.set(phoneCode, forKey: "temp_phonecode")
        
    }

    @IBAction func cancelBtn(_ sender: Any) {        
        self.view.removeFromSuperview()
    }
    @IBAction func confirmBtn(_ sender: Any) {
        self.view.removeFromSuperview()
    }
}

