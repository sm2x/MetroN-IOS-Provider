//
//  SplashVC.swift
//  Nikola
//
//  Created by Shantha Kumar on 10/6/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import UIKit
import AVFoundation

class SplashVC: UIViewController {

    
    @IBOutlet weak var view1: UIView!
    
    @IBOutlet weak var view2: UIView!
    
     var timer : Timer! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
//        let width:CGFloat = self.view.frame.size.width
//        let height:CGFloat = self.view.frame.size.height/2
//
//        let topView = CarAnimView(frame: CGRect(x: self.view.frame.size.width/2 - width/2, y: self.view.frame.size.height/4 - height/2, width: width, height:height))
//        let bottomView = CarAnimView(frame: CGRect(x: self.view.frame.size.width/2 - width/2, y: self.view.frame.size.height/2, width: width, height:height))
//
//
//        self.view1.addSubview(topView)
//        self.view1.addSubview(bottomView)
////
//        self.view.addSubview(topView)
//        self.view.addSubview(bottomView)

        let videoURL = Bundle.main.path(forResource: "splash_video", ofType:"mp4")
        let player = AVPlayer(url: URL(fileURLWithPath: videoURL!))
        player.isMuted = true
        let playerLayer = AVPlayerLayer(player: player)
       
        playerLayer.frame = self.view.frame
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    
//        playerLayer.videoRect = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.view.layer.addSublayer(playerLayer)
        player.play()
        
        
        // Do any additional setup after loading the view.
    }

    
    override func viewWillAppear(_ animated: Bool) {
        
         self.timer = Timer.scheduledTimer(timeInterval:  7.0, target: self,  selector: #selector(navigationMethod), userInfo: nil, repeats: false)
        
    }
    
    
    func navigationMethod() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
        
         var signInViewController: UIViewController
        
         signInViewController = storyboard.instantiateViewController(withIdentifier: "GetStartedNavigationController")
        
                let user_defaults = UserDefaults.standard
                let token = user_defaults.string(forKey: Const.Params.TOKEN)
        
                if (token ?? "").isEmpty  {
                   self.present(signInViewController, animated: true, completion: nil)
                }else{
                     self.present(mainViewController, animated: true, completion: nil)
                }

        
//        
//        if UserDefaults.standard.bool(forKey: "loggedIn") {
//            
//            self.present(mainViewController, animated: true, completion: nil)
//     
//        }
//        else {
//            
//
//            self.present(signInViewController, animated: true, completion: nil)
//        
//        }
    }
    
    
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
