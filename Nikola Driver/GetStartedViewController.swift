//
//  GetStartedViewController
//  Nikola
//
//  Created by Sutharshan on 5/22/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import UIKit

class GetStartedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func getStartedBtn(_ sender: UIButton) {
        let user_defaults = UserDefaults.standard
        let userId = user_defaults.string(forKey: Const.Params.ID)
        self.performSegue(withIdentifier: "loginScreen", sender: nil)
        
        //let mobileVerified = user_defaults.string(forKey: Const.MOBILE_VERIFIED)
        
//        if (userId ?? "").isEmpty  {
//            goToSignIn()
//        }else{
//            goToDashboard()
//        }        
    }
    func goToSignIn(){        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewContro‌​ller = storyBoard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        self.navigationController?.pushViewController(nextViewContro‌​ller, animated: true)
        
    }

    func goToDashboard(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
        self.present(secondViewController, animated: true, completion: nil)
    }
}

