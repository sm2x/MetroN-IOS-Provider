//
//  RatingViewController.swift
//  Nikola
//
//  Created by Sutharshan on 5/29/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import Cosmos
import SwiftyJSON
import AlamofireImage
import NVActivityIndicatorView
import Toucan
import Localize_Swift

class RatingViewController : UIViewController{
    
    @IBOutlet weak var totalfare: UILabel!
    
    
    @IBOutlet weak var tripsummary: UILabel!
    
    @IBOutlet weak var lblratecustomer: UILabel!
    
    @IBOutlet weak var fareAmount: UILabel!
    
    
    @IBOutlet weak var carImageView: UIImageView!
    
    @IBOutlet weak var driverImageView: UIImageView!
    
    @IBOutlet weak var locationImageView: UIImageView!
    
    @IBOutlet weak var durationLabel: UIButton!
    
    @IBOutlet weak var distanceLabel: UIButton!
    
    @IBOutlet weak var ratingBar: CosmosView!
    
    
    var currencyStr : String = ""
    
    var status = ""
    var paymentMode = ""
    
    var requestDetail: RequestDetail = RequestDetail()
    var isPayShowing: Bool = false
    
    var isUserPaidShown: Bool = false
    
    var activityIndicatorView: NVActivityIndicatorView? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        totalfare.text = "Total Fare".localized()
        tripsummary.text = "Trip Summary".localized()
        lblratecustomer.text = "Rate the Customer".localized()
        
        
        self.navigationItem.setHidesBackButton(true, animated:true)
        let imageView: UIImageView = UIImageView(image: UIImage(named: ""))
        imageView.frame.size.width = 150;
        imageView.frame.size.height = 30;
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.title = "Ridey"
        let defaults = UserDefaults.standard
        
        requestDetail.initRequest(rqObj: JSON.init(parseJSON: DATA().getRequestData()))
        
        
        if let currn = defaults.string(forKey: "currency") {
            currencyStr = currn
        }
        
        if defaults.object(forKey: Const.CURRENT_INVOICE_DATA) != nil {
            let invoiceData = defaults.object(forKey: Const.CURRENT_INVOICE_DATA)! as? String ?? String()
            //let invoiceData: String = defaults.string(forKey: Const.CURRENT_INVOICE_DATA)!
            if !(invoiceData ?? "").isEmpty{
                let invoiceJson: JSON = JSON.init(parseJSON: invoiceData)
                requestDetail.initInvoice(rqObj: invoiceJson)
            }
        }
        
        paymentMode = requestDetail.payment_mode
        status = requestDetail.status
        
        durationLabel.setTitle("\(requestDetail.trip_time) mins", for: UIControlState.normal)
        distanceLabel.setTitle("\(requestDetail.trip_distance) \(requestDetail.trip_distance_unit)", for: UIControlState.normal)
        fareAmount.text = "\(requestDetail.trip_total_price) \(currencyStr)"
        
        
        let size = CGSize(width: 100.0, height: 100.0)
        let filter = AspectScaledToFillSizeCircleFilter(size: size)
        
        var pic: String = requestDetail.vehical_img
        if pic.isEmpty {
            pic = requestDetail.typePicture
        }
        
        if !pic.isEmpty{
            pic = pic.decodeUrl()
            
            let url = URL(string: pic)!
            let placeholderImage = UIImage(named: "ellipse_contacting")!
            
            carImageView?.af_setImage(
                withURL: url,
                placeholderImage: placeholderImage,
                filter: nil
            )
        }else{
            carImageView.image = UIImage(named: "ellipse_contacting")!
        }
        
        var pic2: String = requestDetail.user_picture
        if pic.isEmpty {
            pic = requestDetail.typePicture
        }
        if !pic2.isEmpty{
            pic2 = pic2.decodeUrl()
            
            let url2 = URL(string: pic2)!
            let placeholderImage2 = UIImage(named: "ellipse_contacting")!
            
            driverImageView?.af_setImage(
                withURL: url2,
                placeholderImage: placeholderImage2,
                filter: filter
            )
        }else{
            //self.driverImageView.image = UIImage(named: "passenger")
            self.driverImageView.image = Toucan(image: UIImage(named: "passenger")!).maskWithEllipse().image
        }
        
        let url3 = URL(string: getGoogleMapThumbnail(lati: Double(requestDetail.d_lat)!, longi: Double(requestDetail.d_lon)!))!
        let placeholderImage3 = UIImage(named: "ellipse_contacting")!
        
        locationImageView?.af_setImage(
            withURL: url3,
            placeholderImage: placeholderImage3,
            filter: filter
        )
        
        
        //        if requestDetail.driverStatus == 3 && !isPayShowing {
        //            showPayDialog()
        //        }
        
        self.startTimer()
        
        activityIndicatorView = API.loadActivityIndicator()
    }
    
    var timer: DispatchSourceTimer?
    
    func startTimer() {
        let queue = DispatchQueue(label: "com.prov.nikola.driver.timer")  // you can also use `DispatchQueue.main`, if you want
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer!.scheduleRepeating(deadline: .now(), interval: .seconds(2))
        timer!.setEventHandler { [weak self] in
            // do whatever you want here
            
            self?.checkRequestStatus()
        }
        timer!.resume()
        
    }
    
    func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
    deinit {
        self.stopTimer()
    }
    
    func checkRequestStatus(){
        API.checkRequestStatus{ json, error in
            
            if self.timer == nil {
                print("timer nil")
                return
            }
            
            if let error = error {
                //self.hideLoader()
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    
                    var requestDetail: RequestDetail = RequestDetail()
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(json[Const.STATUS_CODE].boolValue){
                        
                        if(json[Const.DATA].exists() && json[Const.DATA].arrayValue.count > 0) {
                            let jsonAry:[JSON]  = json[Const.DATA].arrayValue
                            let defaults = UserDefaults.standard
                            
                            requestDetail.initRequest(rqObj: jsonAry[0])
                            
                            let invoiceAry:[JSON]  = json[Const.INVOICE].arrayValue
                            if invoiceAry.count > 0 {
                                let invoiceData = invoiceAry[0]
                                //print("invoice json")
                                print(invoiceData.rawString() ?? "invoiceData null")
                                defaults.set(invoiceData.rawString(), forKey: Const.CURRENT_INVOICE_DATA)
                                requestDetail.initInvoice(rqObj: invoiceData)
                            }
                            
                            self.status = requestDetail.status
                            self.paymentMode = requestDetail.payment_mode
                            
                            if self.isUserPaidShown == false && self.status == "8" && self.paymentMode == Const.CASH {
                                self.isUserPaidShown = true
                                self.showCashPaymentDialog()
                            }
                        }
                        
                    }else{
                        print(statusMessage)
                        print(json ?? "json empty")
                        var msg = json[Const.DATA].rawString()!
                        msg = msg.replacingOccurrences( of:"[{}\",]", with: "", options: .regularExpression)
                        
                        self.view.makeToast(message: msg)
                    }
                    
                    
                    
                }else{
                    //self.hideLoader()
                    debugPrint("Invalid JSON :(")
                }
            }
            
            
        }
    }
    
    func showCashPaymentDialog(){
        
        isPayShowing = true
        let alert = UIAlertController(title: "", message: "Your Ride Total is: \(currencyStr) \(self.requestDetail.trip_total_price)", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(
        title: "Confirm", style: UIAlertActionStyle.default) { (action) in
            //self.sendPay()
            self.postCodConfirmation()
        }
        
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func postCodConfirmation() {
        API.postCodConfirmation{ json, error in
            self.hideLoading()
            
            if let error = error {
                //self.hideLoader()
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status){
                        self.view.makeToast(message: "Cash payment done successfully")
                        //                    self.jobStatus = Const.IS_PROVIDER_SERVICE_STARTED
                        //                    self.setJobStatus(jobStaus: self.jobStatus)
                        print(json ?? "error in providerStarted json")
                    }else{
                        
                        print(json ?? "error in providerStarted json")
                        print(statusMessage)
                        print(json ?? "json empty")
                        var msg = json[Const.DATA].rawString()!
                        msg = msg.replacingOccurrences( of:"[{}\",]", with: "", options: .regularExpression)
                        
                        self.view.makeToast(message: msg)
                    }
                    
                    
                    
                }else{
                    //self.hideLoader()
                    debugPrint("Invalid JSON :(")
                }
            }
            
            
        }
    }
    
    func showLoading(){
        self.view.addSubview(activityIndicatorView!)
        self.activityIndicatorView?.startAnimating()
    }
    
    func hideLoading(){
        self.activityIndicatorView?.removeFromSuperview()
        self.activityIndicatorView?.stopAnimating()
    }
    
    
    
    @IBAction func submitAction(_ sender: UIButton) {
        
        if self.status == "3" && paymentMode == Const.CASH{
            self.view.makeToast(message: "Please wait till User to Confirm Payment!")
            return
        }
        giveRating()
    }
    
    
    func sendPay(){
        
        let ispaid: String = "1"
        let paymentMode: String = requestDetail.payment_mode
        
    }
    
    func giveRating(){
        
        let comment:String = ""
        let ratingValue: Int = Int(exactly:ratingBar.rating)!
        let rating: String = "\(ratingValue)"
        
        API.giveRating(rating: rating, comment: comment){ json, error in
            
            if let error = error {
                //self.hideLoader()
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    let status =  json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status){
                        
                        print(json ?? "error in sendPay json")
                        
                        
                        
                        self.stopTimer()
                        DATA().clearRequestData()
                        self.goToDashboard()
                    }else{
                        print(statusMessage)
                        print(json ?? "sendPay json empty")
                        //var msg = json![Const.DATA].rawString()!
                        //                msg = msg.replacingOccurrences( of:"[{}\",]", with: "", options: .regularExpression)
                        
                        let errorCode: Int = json["error_code"].int!
                        
                        if errorCode == 150 {
                            self.view.makeToast(message: "Waiting for driver to confirm the payment")
                        }
                    }
                    
                    
                }else{
                    //self.hideLoader()
                    debugPrint("Invalid JSON :(")
                }
                
                
                
            }
            
            
            
        }
    }
    
    func showPayDialog(){
        
        isPayShowing = true
        let alert = UIAlertController(title: "", message: "Your Ride is complete!\n\nYou need to pay: \(currencyStr) \(self.requestDetail.trip_total_price)", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(
        title: "Yes", style: UIAlertActionStyle.default) { (action) in
            self.sendPay()
        }
        
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func getGoogleMapThumbnail(lati: Double, longi: Double) -> String {
        let staticMapUrl: String = "http://maps.google.com/maps/api/staticmap?center=\(lati),\(longi)&markers=\(lati),\(longi)&zoom=14&size=150x120&sensor=false";
        return staticMapUrl;
    }
    
    func goToDashboard(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "SWRevealViewController") as? UIViewController
        self.present(secondViewController!, animated: true, completion: nil)
    }
    
    
}
