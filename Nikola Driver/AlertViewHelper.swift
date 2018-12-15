//
//  AlertViewHelper.swift
//  Enjoy Apps
//
//  Created by Shantha Kumar on 7/27/17.
//  Copyright © 2017 Shantha Kumar. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showAlert(with messgage:String,leftButtonTitle:String?=nil,rightButtonTitle:String?=nil) {
        let alert = UIAlertController(title: "Message", message: messgage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    
    
    
    
}

