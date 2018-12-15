//
//  DriverStatus.swift
//  Nikola Driver
//
//  Created by Shantha Kumar on 21/12/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import UIKit

class DriverStatus: NSObject {

    
}

struct DriverUpdateStatus {
    
    //MARK:- UpdateAvailability Method
    func updateAvailability(status: String) {
        
        API.updateAvailabilityStatus(status : status,forceClose: "0",completionHandler: { json, error in
            
            
            if let error = error {
                //self.hideLoader()
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    var active : Int = 0
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status){
                        print(json)
                        
                        if json["active"].exists() && json["active"].stringValue != "" {
                            let activeString: String = json["active"].stringValue
                            active = Int(activeString)!
                        }
                        
                        print(active)
                        //  return active
                        
                    }else{
                        print(json )
                        print(statusMessage)
                        print(json )
                        
                    }
                    
                }else{
                    //self.hideLoader()
                    debugPrint("Invalid JSON :(")
                }
                
                
            }
            
            
        })
        
    }
    
}
