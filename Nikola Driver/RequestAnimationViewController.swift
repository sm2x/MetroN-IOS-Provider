//
//  RequestAnimationViewController.swift
//  Nikola
//
//  Created by Sutharshan on 5/31/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import NVActivityIndicatorView
import Toucan
import UICircularProgressRing
import SwiftyJSON
import AlamofireImage
import AVFoundation


class RequestAnimationViewController: UIViewController, AVAudioPlayerDelegate  {
    
    
    
    var player: AVAudioPlayer!
    
    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var timerCountBtn: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UITextView!
    @IBOutlet weak var circularProgressBar: UICircularProgressRingView!
    
    var timeLeft = 9000
    var timeLeftStamp: Int64 = 0
    let requestDetail: RequestDetail = RequestDetail()
    var hourlyDetailsDic = [String: AnyObject]()
    var hoursStr : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        carImage.image = Toucan(image: carImage.image!).maskWithEllipse().image
        //self.view.backgroundColor = UIColor(red: CGFloat(237 / 255.0), green: CGFloat(85 / 255.0), blue: CGFloat(101 / 255.0), alpha: 1)
        
        let cellWidth = Int(self.view.frame.width)
        let cellHeight = Int(self.view.frame.height)
        
        
        
        if (hourlyDetailsDic.isEmpty) {
            
        }
        else {
          
        let hour  = (hourlyDetailsDic["number_hours"])!
            
            print(hour)
            
            
        }
        
        
        let x = 0//Int(self.view.frame.size.width/2)
        let y = 0//Int(self.view.frame.size.height/2)
        
        //self.view.addSubview(animationTypeLabel)
        self.view.bringSubview(toFront: carImage)
        self.view.bringSubview(toFront: cancelBtn)
        
        
        //        timerCountBtn.frame.height = timerCountBtn.frame.width
        timerCountBtn.layer.masksToBounds = true
        timerCountBtn.layer.cornerRadius = timerCountBtn.frame.width/2
        timerCountBtn.backgroundColor = UIColor.red
        timerCountBtn.setTitleColor(UIColor.black, for: UIControlState.normal)
        
        let incomingRequestString : String = DATA().getIncomingRequestData()
        
        let jsonObj : JSON = JSON.init(parseJSON: incomingRequestString)
        
        print(jsonObj)
        
        
        
        requestDetail.initRequest(rqObj: jsonObj)
        
        
        print(requestDetail.number_hours)
        
        let staticMapUrl: String = requestDetail.getStaticMapUrl()
        
        print(staticMapUrl)
        
        let url = URL(string: requestDetail.getStaticMapUrl().decodeUrl())!
        let placeholderImage = UIImage(named: "ellipse_contacting")!
        
        let size = CGSize(width: 100.0, height: 100.0)
        let filter = AspectScaledToFillSizeCircleFilter(size: size)
        
        carImage?.af_setImage(
            withURL: url,
            placeholderImage: placeholderImage,
            filter: filter,
            completion: { response in
                print(response.result.value)
                print(response.result.error)
        }
        )
        
        nameLabel.text = "Name: "+requestDetail.user_name
        addressLabel.text = "Pickup Address".localized() + " " + requestDetail.s_address
        
        if requestDetail.request_status_type == "2" {
            hoursLabel.text = "No. Hours: " + "\((hourlyDetailsDic["number_hours"])!)"
        }else{
            
            hoursLabel.text = ""
        }
        
        timeLeft = requestDetail.time_left_to_respond
        
        timeLeftStamp = timeLeft * 1000 + getCurrentMillis()
        self.circularProgressBar.maxValue = 100
        
        
        //self.circularProgressBar.progres
        self.startAnimationTimer()
        print("View has loaded")
        
        
        // audio while request coming
        print(Bundle.main.path(
            forResource: "Alert",
            ofType: "m4a"))
        //        let soundUrl = URL.init(fileURLWithPath: Bundle.main.path(
        //            forResource: "Alert",
        //            ofType: "m4a")!)
        let soundUrl = Bundle.main.url(forResource: "Alert", withExtension: "m4a")!
        
        do {
            
            try player = AVAudioPlayer(contentsOf: soundUrl)
            player?.delegate = self
            player?.prepareToPlay()
            if player.isPlaying {
                print("already playing")
               // player = nil
            }else {
                player?.play()
                
            }
            
        } catch let error as NSError {
            print("audioPlayer error \(error.localizedDescription)")
        }
        
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.circularProgressBar.setProgress(value: 100, animationDuration: Double(timeLeft)){
            print("Done animating!")
            // Do anything your heart desires...
        }
        print("View has appeared")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
         player?.stop()
        player = nil
    }
    
   

    
    func buttonTapped(_ sender: UIButton) {
        let size = CGSize(width: 30, height: 30)
        
        //startAnimating(size, message: "Loading...", type: NVActivityIndicatorType(rawValue: sender.tag)!)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            //  NVActivityIndicatorPresenter.sharedInstance.setMessage("Authenticating...")
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            //  self.stopAnimating()
        }
    }
    
    @IBAction func acceptAction(_ sender: UIButton) {
        acceptRequest()
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        
        self.rejectRequest()
        /*
         let alertController = UIAlertController(title: "Title", message: "This is my text", preferredStyle: UIAlertControllerStyle.alert)
         
         let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
         {
         (result : UIAlertAction) -> Void in
         print("You pressed OK")
         self.rejectRequest()
         }
         let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
         {
         (result : UIAlertAction) -> Void in
         print("You pressed OK")
         self.rejectRequest()
         }
         alertController.addAction(okAction)
         self.present(alertController, animated: true, completion: nil)
         
         */
    }
    
    func acceptRequest(){
        player?.stop()
        player = nil
        //statusLabel.text = "Cancelling..."
        self.view.makeToast(message: "Accepting...")
        API.acceptRequest{ json, error in
            
            if let error = error {
                //self.hideLoader()
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status){
                        
                        //DATA().clearRequestData()
                        print(json ?? "error in  accept request json")
                        
                        let reqObj : JSON = json[Const.DATA]
                        
                        DATA().putRequestData(request: reqObj.rawString()!)
                        DATA().putRequestId(reqId: Int(json[Const.DATA]["request_id"].stringValue)!)
                        DATA().putClientId(customerId: json[Const.DATA]["user_id"].stringValue)
                        self.view.makeToast(message: "Accepted")
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "requestAccepted"), object: nil)
                        self.view.removeFromSuperview()
                        self.navigationController?.setNavigationBarHidden(true, animated: false)
                        //self.statusLabel.text = "Cancelled"
                    }else{
                        print(statusMessage)
                        print(json ?? "json empty")
                        var msg = json[Const.DATA].rawString()!
                        msg = msg.replacingOccurrences( of:"[{}\",]", with: "", options: .regularExpression)
                        //self.statusLabel.text = "Cancel Failed. Continuing "
                        self.view.makeToast(message: "Accept request failed")
                        self.navigationController?.setNavigationBarHidden(true, animated: false)
                        //self.view.makeToast(message: msg)
                    }
                    
                    
                } else{
                    //self.hideLoader()
                    debugPrint("Invalid JSON :(")
                }
                
                
                
            }
            
            
            
            
        }
        
    }
    
    func rejectRequest(){
        player?.stop()
        player = nil
        //statusLabel.text = "Cancelling..."
        self.view.makeToast(message: "Cancelling...")
        API.rejectRequest{ json, error in
            
            if let error = error {
                //self.hideLoader()
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status){
                        
                        DATA().clearRequestData()
                        self.view.makeToast(message: "Cancelled")
                        self.view.removeFromSuperview()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "requestRejected"), object: nil)
                        self.navigationController?.setNavigationBarHidden(true, animated: false)
                        //self.statusLabel.text = "Cancelled"
                    }else{
                        print(statusMessage)
                        print(json ?? "json empty")
                        var msg = json[Const.DATA].rawString()!
                        msg = msg.replacingOccurrences( of:"[{}\",]", with: "", options: .regularExpression)
                        self.view.makeToast(message: "Cancel Failed")
                        //self.view.makeToast(message: msg)
                        
                        if json["error_code"].exists(){
                            var msg = json["error_code"].intValue
                            self.view.removeFromSuperview()
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "requestRejectedError"), object: nil)
                            self.navigationController?.setNavigationBarHidden(true, animated: false)
                        }
                    }
                    
                    
                }else{
                    //self.hideLoader()
                    debugPrint("Invalid JSON :(")
                }
                
                
            }
            
            
            
        }
        
    }
    
    
    func getBgCircle(){
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "bg")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        self.view.backgroundColor = UIColor(patternImage: image)
    }
    
    
    deinit {
        //self.stopTimer()
        self.stopAnimationTimer()
    }
    
    var animationTimer: DispatchSourceTimer?
    
    var queue : DispatchQueue? = nil
    var currentTime: Int64 = 0
    func startAnimationTimer() {
        queue = DispatchQueue(label: "com.prov.nikola.driver.animationtimer")  // you can also use `DispatchQueue.main`, if you want
        animationTimer = DispatchSource.makeTimerSource(queue: queue)
        animationTimer!.scheduleRepeating(deadline: .now(), interval: .milliseconds(100))
        currentTime = Int64(timeLeft * 1000)
        animationTimer!.setEventHandler { [weak self] in
            // do whatever you want here
            do{
                //self?.getIncomingRequestsInProgress()
                
                //print("\((self?.timeLeftStamp)! - (self?.getCurrentMillis())!)")
                let progress : Double = Double((((self?.timeLeftStamp)! - (self?.getCurrentMillis())! ) / ((self?.timeLeft)! * 1000)) * 100)
                var secondsLeft = ((self?.timeLeftStamp)! - (self?.getCurrentMillis())! )  / 1000
                
                print("\(secondsLeft)")
                if secondsLeft >= 0 {
                    
                    //self?.timerCountBtn.titleLabel?.text = "\(secondsLeft)"
                    DispatchQueue.main.async {
                        self?.timerCountBtn.setTitle("\(secondsLeft)", for: UIControlState.normal)
                    }
                }else{
                    DispatchQueue.main.async {
                        self?.view.removeFromSuperview()
                    }
                    self?.stopAnimationTimer()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "requestExpired"), object: nil)
                    
                }
            }catch{
                self?.stopAnimationTimer()
            }
        }
        animationTimer!.resume()
    }
    
    func getCurrentMillis()->Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopAnimationTimer()
    }
    
    func stopAnimationTimer() {
        animationTimer?.cancel()
        animationTimer = nil
    }
    
    
    
}
