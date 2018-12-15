//
//  JsonParser.swift
//  Nikola
//
//  Created by Shantha Kumar on 9/4/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation

import SwiftyJSON

class JsonParser: NSObject {
    
    
    func jsonParser(dicData :[String : AnyObject]?) -> JSON {
        
        let json = JSON(dicData!)
        return json
        
    }
    
    
    
}
