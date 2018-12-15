//
//  UploadItem.swift
//  Nikola Driver
//
//  Created by Sutharshan Ram on 18/08/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import SwiftyJSON

class UploadItem {
    
    var name: String = ""
    var id: String = ""
    var image: String = ""
    
    init(rqObj: JSON) {
        
        if rqObj["id"].exists() {
            id = rqObj["id"].stringValue
        }
        if rqObj["name"].exists() {
            name = rqObj["name"].stringValue
        }
        if rqObj["document_url"].exists() {
            image = rqObj["document_url"].stringValue
        }
    }
}
