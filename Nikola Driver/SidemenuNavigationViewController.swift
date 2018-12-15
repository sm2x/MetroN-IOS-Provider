//
//  SidemenuNavigationViewController.swift
//  Alicia
//
//  Created by Sutharshan on 5/12/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation

class SidemenuNavigationViewController: UITableViewController {
    var hud : MBProgressHUD = MBProgressHUD()
    var menu = ["SideMenuTopCell","Home","Ready to drive?","Upload your documents", "Ride History", "Help","Logout"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == 0 {
            return 200.0;//Choose your custom row height
        }else {
            return tableView.rowHeight
        }
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let cellIdentifier = menu[indexPath.row]
        
        if indexPath.row == 0 {
            let cell: SideMenuTopCell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTopCell", for: indexPath) as! SideMenuTopCell
            //cell.imgView.setRandomDownloadImage(128, height: 128)
            //cell.lblName.text = "Sutharshan"
            return cell
        }else
        {
            let cellIdentifier = menu[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        return cell
        }
        
    }
    

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
        switch indexPath.row
        {
//        case 0:
//            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "DummyDashViewController") as? DummyDashViewController
//            let navController = UINavigationController(rootViewController: secondViewController!)
//            navController.setViewControllers([secondViewController!], animated:true)
//            self.revealViewController().pushFrontViewController(navController, animated: false)
//            ////self.revealViewController.pushFrontViewController:navController animated:YES];
//            break;
//            
//        case 1:
//            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "DummyDashViewController") as? DummyDashViewController
//            let navController = UINavigationController(rootViewController: secondViewController!)
//            navController.setViewControllers([secondViewController!], animated:true)
//            self.revealViewController().pushFrontViewController(navController, animated: false)
//            
//            break;
        case 1:
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let secondViewController = storyBoard.instantiateViewController(withIdentifier: "SWRevealViewController") as? UIViewController
            self.present(secondViewController!, animated: true, completion: nil)
            
        case 6:
            
            self.revealViewController().revealToggle(animated: true)
            
            
            let refreshAlert = UIAlertController(title: "Message".localized(), message: "Are sure you want to logout.", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {  (action: UIAlertAction!) in
                
                
                self.logoutProvider()
                
//                         self.updateAvailability(status: "0")
//                            let defaults = UserDefaults.standard
//                            let appDomain = Bundle.main.bundleIdentifier!
//                            defaults.set("", forKey: Const.Params.TOKEN)
//                            defaults.set(false, forKey: "isloggedin")
//                            defaults.removePersistentDomain(forName: appDomain)
//
//                            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//
//
//                            let queue = DispatchQueue(label: "com.prov.nikola.timer2")  // you can also use
//                //            queue.suspend()
//
//                            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "GetStartedViewController") as! GetStartedViewController
//                            self.present(nextViewController, animated: true, completion: nil)
                print("Handle Ok logic here")
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { (action: UIAlertAction!) in
                print("Handle Cancel Logic here")
            }))
            
            present(refreshAlert, animated: true, completion: nil)
            
            break
        default:
            break;
            
        }
    }
    
    
    //MARK:- UpdateAvailability Method
    func updateAvailability(status: String) {
        
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

    func logoutProvider(){
        
        self.showLoader(str: "Logout...".localized())
        
        API.providerLogout{ json, error in
            
            if json == nil {
                print("json nil")
                self.hideLoader()
                print(error?.localizedDescription)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // change 2 to desired number of seconds
                    self.hideLoader()
                    let defaults = UserDefaults.standard
                    let appDomain = Bundle.main.bundleIdentifier!
                    defaults.set("", forKey: Const.Params.TOKEN)
                    defaults.set(false, forKey: "isloggedin")
                    defaults.removePersistentDomain(forName: appDomain)
                    
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "GetStartedViewController") as! GetStartedViewController
                    self.present(nextViewController, animated: true, completion: nil)
                }
                return
            }
            
            let status = json![Const.STATUS_CODE].boolValue
            let statusMessage = json![Const.STATUS_MESSAGE].stringValue
            if(status){
                print(json ?? nil)
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // change 2 to desired number of seconds
                    self.hideLoader()
                    let defaults = UserDefaults.standard
                    let appDomain = Bundle.main.bundleIdentifier!
                    defaults.set("", forKey: Const.Params.TOKEN)
                    defaults.set(false, forKey: "isloggedin")
                    defaults.removePersistentDomain(forName: appDomain)
                    
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "GetStartedViewController") as! GetStartedViewController
                    self.present(nextViewController, animated: true, completion: nil)
                }
                
                
            }else{
                print(statusMessage)
                self.hideLoader()
                print(json ?? "json empty")
                var msg = json![Const.ERROR].rawString()!
                self.view.makeToast(message: msg)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // change 2 to desired number of seconds
                    self.hideLoader()
                    let defaults = UserDefaults.standard
                    let appDomain = Bundle.main.bundleIdentifier!
                    defaults.set("", forKey: Const.Params.TOKEN)
                    defaults.set(false, forKey: "isloggedin")
                    defaults.removePersistentDomain(forName: appDomain)
                    
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "GetStartedViewController") as! GetStartedViewController
                    self.present(nextViewController, animated: true, completion: nil)
                }
            }
        }
        
    }
    
}
extension SidemenuNavigationViewController : MBProgressHUDDelegate {
    
    func showLoader(str: String) {
        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
            hud = MBProgressHUD.showAdded(to:window, animated: true)
            hud.mode = MBProgressHUDModeIndeterminate
            hud.labelText = str
        }
        //        let window = overKeyboard ? UIApplication.sharedApplication().windows.last!
        //            : UIApplication.sharedApplication().delegate!.window!
        
    }
    
    func hideLoader() {
        hud.hide(true)
    }
}

