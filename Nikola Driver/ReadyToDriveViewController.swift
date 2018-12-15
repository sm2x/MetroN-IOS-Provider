//
//  ReadyToDriveViewController.swift
//  Nikola Driver
//
//  Created by Sutharshan Ram on 07/07/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import Localize_Swift

class ReadyToDriveViewController : ViewController {
    
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var whatisthislbl: UILabel!
    @IBOutlet weak var lblavailable: UILabel!
    @IBOutlet weak var burgerMenu: UIBarButtonItem!
    @IBOutlet weak var availabilityToggle: UISwitch!
    var switchStatus: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Change Status"
        if revealViewController() != nil {
            
            burgerMenu.target = revealViewController()
            burgerMenu.action = "revealToggle:"
            
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
        txtView.text = "Use the button present above to toggle between Available & Not available ie. If you wish to take a break, you can trun-off your availability".localized()
        whatisthislbl.text = "What is this?".localized()
        lblavailable.text = "Am available ow/Not driving now".localized()
        
        
        self.checkAvailability()
        
    }
    
    
    @IBAction func availabilityToggleAction(_ sender: UISwitch) {
        
        
        if sender.isOn {
            updateAvailability(status: "1")
        }else{
            updateAvailability(status: "0")
        }
    }
    
    
    
    func updateAvailability(status: String){
        
        API.updateAvailabilityStatus(status : status,forceClose: "0",  completionHandler: { json, error in
            
            
            
            if let error = error {
                //self.hideLoader()
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    var active : Int = 0
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status){
                        print(json ?? "error in checkAvailability json")
                        
                        if json["active"].exists() && json["active"].stringValue != "" {
                            let activeString: String = json["active"].stringValue
                            active = Int(activeString)!
                        }
                        
                        if active == 0 {
                            self.availabilityToggle.setOn(false, animated: true)
                        }else{
                            self.availabilityToggle.setOn(true, animated: true)
                        }
                        
                    }else{
                        print(json ?? "error in providerStarted json")
                        print(statusMessage)
                        print(json ?? "json empty")
                        //var msg = json![Const.DATA].rawString()!
                        //msg = msg.replacingOccurrences( of:"[{}\",]", with: "", options: .regularExpression)
                        
                        //self.view.makeToast(message: msg)
                    }
                    
                }else{
                    //self.hideLoader()
                    debugPrint("Invalid JSON :(")
                }
                
                
            }
            
            
        })
        
    }
    
    
    
    func checkAvailability() {
        
        var active = 0
        API.checkAvailabilityStatus{ json, error in
            
            
            if let error = error {
                //self.hideLoader()
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    
                    let status =  json[Const.STATUS_CODE].boolValue
                    let statusMessage =  json[Const.STATUS_MESSAGE].stringValue
                    if(status){
                        print(json ?? "error in checkAvailability json")
                        
                        if json["active"].exists() && json["active"].stringValue != "" {
                            let activeString: String = json["active"].stringValue
                            active = Int(activeString)!
                        }
                        
                        if active == 0 {
                            self.availabilityToggle.setOn(false, animated: true)
                        }else{
                            self.availabilityToggle.setOn(true, animated: true)
                        }
                        
                    }else{
                        print(json ?? "error in providerStarted json")
                        print(statusMessage)
                        print(json ?? "json empty")
                        //var msg = json![Const.DATA].rawString()!
                        //msg = msg.replacingOccurrences( of:"[{}\",]", with: "", options: .regularExpression)
                        
                        //self.view.makeToast(message: msg)
                    }
                    
                    
                    
                }else{
                    //self.hideLoader()
                    debugPrint("Invalid JSON :(")
                }
                
            }
            
            
            
        }
    }
    
    
    
}
