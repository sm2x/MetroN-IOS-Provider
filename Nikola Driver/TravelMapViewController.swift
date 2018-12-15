//
//  TravelMapViewController.swift
//  Nikola
//
//  Created by Sutharshan on 5/29/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import UIKit
import Floaty
import SwiftyJSON
import AlamofireImage
import GoogleMaps
import NVActivityIndicatorView
import Toucan
import PubNub
import Localize_Swift

class TravelMapViewController: BaseViewController , FloatyDelegate,PNObjectEventListener {
    
    var hud : MBProgressHUD = MBProgressHUD()
    @IBOutlet weak var burgerMenu: UIButton!
    @IBOutlet weak var requestStatusLabel: UILabel!
    
    @IBOutlet weak var pickupAddressLabel: UILabel!
    @IBOutlet weak var addressTitle: UILabel!
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var userMobileLabel: UILabel!
    @IBOutlet weak var floatingButton: Floaty!
    
    @IBOutlet weak var changeTripStatusBtn: UIButton!
    
    @IBOutlet weak var gmsMapView: GMSMapView!
    var piPoint : CLLocationCoordinate2D? = nil
    var drPoint : CLLocationCoordinate2D? = nil
    
    var driverPoint : CLLocationCoordinate2D? = nil
    var pick_marker : GMSMarker? = nil
    var drop_marker : GMSMarker? = nil
    var driver_marker : GMSMarker? = nil
    
    var requestDetail: RequestDetail = RequestDetail()
    var floaty: Floaty? = nil
    
    var jobStatus: Int = 0
    let locationManager = CLLocationManager()
    var heading : Double? = 0.0
    var activityIndicatorView: NVActivityIndicatorView? = nil
    
    var client: PubNub!
    var nickname: String! = ""
    
    var timer1 = Timer()
    var totaltime : Int = 0
    
    var distance : Double!
    
    var polyline : GMSPolyline!
    
    var tripStarted : Bool = false
    
    var slat : String = ""
    var slog : String = ""
    
    var dlat : String = ""
    var dlog : String = ""
    
     var tripStartTime: Date?
    
    var curPoint : CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SocketIOManager.sharedInstance.establishConnection()
        
        self.navigationItem.setHidesBackButton(true, animated:true);
        if revealViewController() != nil {
            
            burgerMenu .addTarget(revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: UIControlEvents.touchUpInside)
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
             revealViewController().frontViewController.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        
        addressTitle.text = "PICKUP ADDRESS".localized()
        
        changeTripStatusBtn.setTitle("Tap when Departed".localized(), for: .normal)
        
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        gmsMapView.delegate = self
        
        
        let requestData: String = DATA().getRequestData()
        let requestJson: JSON = JSON.init(parseJSON: requestData)
        requestDetail.initRequest(rqObj: requestJson)
        DATA().putRequestId(reqId: requestDetail.requestId)
        DATA().putClientId(customerId: requestDetail.user_id)
        
        self.jobStatus = requestDetail.providerStatus
        if self.jobStatus == 0 {
            self.jobStatus = Const.IS_PROVIDER_ACCEPTED
        }
        
        
        let defaults = UserDefaults.standard
        let pi_lat: String = requestDetail.s_lat
        let pi_lon: String = requestDetail.s_lon
        
        let dr_lat: String = requestDetail.d_lat
        let dr_lon: String = requestDetail.d_lon
        
        let pLati = Double(pi_lat ?? "") ?? 0.0
        let pLongi = Double(pi_lon ?? "") ?? 0.0
        
        let dLati = Double(dr_lat ?? "") ?? 0.0
        let dLongi = Double(dr_lon ?? "") ?? 0.0
        
        let piPointLat : CLLocationDegrees = pLati
        piPoint = CLLocationCoordinate2DMake(pLati, pLongi)
        drPoint = CLLocationCoordinate2DMake(dLati, dLongi)
        if drPoint != nil && (drPoint?.latitude != 0 && drPoint?.longitude != 0){
            drop_marker = GMSMarker(position: drPoint!)
            drop_marker?.title = "Drop location".localized()
            //drop_marker?.title = nearest_eta
            drop_marker?.icon = #imageLiteral(resourceName: "map_drop_marker")
            drop_marker?.map = gmsMapView
        }
        
        if defaults.object(forKey: Const.CURRENT_INVOICE_DATA) != nil {
            let invoiceData = defaults.object(forKey: Const.CURRENT_INVOICE_DATA)! as? String ?? String()
            //let invoiceData: String = defaults.string(forKey: Const.CURRENT_INVOICE_DATA)!
            if !(invoiceData ?? "").isEmpty{
                let invoiceJson: JSON = JSON.init(parseJSON: invoiceData)
                requestDetail.initInvoice(rqObj: invoiceJson)
            }
        }
        
        userMobileLabel.text = requestDetail.clientPhoneNumber
        userNameLabel.text = requestDetail.user_name
        pickupAddressLabel.text = requestDetail.s_address
        
        let size = CGSize(width: 100.0, height: 100.0)
        let filter = AspectScaledToFillSizeCircleFilter(size: size)
        
        if !(requestDetail.user_picture ?? "").isEmpty{
            let url = URL(string: requestDetail.user_picture)!
            let placeholderImage = UIImage(named: "ellipse_contacting")!
            
            userImage?.af_setImage(
                withURL: url,
                placeholderImage: placeholderImage,
                filter: filter
            )
        }else{
            
            //userImage.image = UIImage(named: "passenger")
            userImage.image = Toucan(image: UIImage(named: "passenger")!).maskWithEllipse().image
            
        }
        
        locationManager.startUpdatingHeading()
        layoutFAB()
        self.setJobStatus(jobStaus: self.jobStatus)
        
        self.startTimer()
        
        activityIndicatorView = API.loadActivityIndicator()
        
        let configuration = PNConfiguration(publishKey: Const.Publish_key, subscribeKey: Const.Subscribe_key)
        self.client = PubNub.clientWithConfiguration(configuration)
        self.client.addListener(self)
        
        let channel: String  =  "\(Const.CHANNEL_ID)\(DATA().getUserId())"
        self.client.subscribeToChannels([channel], withPresence: false)
        
        nickname = "\(DATA().getUserId())"
        SocketIOManager.sharedInstance.connectToServerWithNickname(self.nickname, completionHandler: { (userList) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                //                if userList != nil {
                //                    self.users = userList!
                //                    self.tblUserList.reloadData()
                //                    self.tblUserList.isHidden = false
                //                }
                print("connected to server")
            })
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopTimer()
        self.locationManager.stopUpdatingLocation()
    }
    
    func showLoading(){
        self.view.addSubview(activityIndicatorView!)
        self.activityIndicatorView?.startAnimating()
    }
    
    func hideLoading(){
        self.activityIndicatorView?.removeFromSuperview()
        self.activityIndicatorView?.stopAnimating()
    }
    
//    func timerRunning() {
//
//
//        totaltime =  totaltime + 1
//
//
//    }
    
    
    
    func setJobStatus(jobStaus : Int) {
        
        switch jobStatus {
        case Const.IS_PROVIDER_ACCEPTED:
            changeTripStatusBtn.setTitle("Tap when departed".localized(), for: .normal)
        case Const.IS_PROVIDER_STARTED:
            changeTripStatusBtn.setTitle("Arrived at customer's Place".localized(), for: .normal)
        case Const.IS_PROVIDER_ARRIVED:
            if (floaty?.items.count)! > 2 {
                self.floaty?.removeItem(index: 2)
            }
            addressTitle.text = "DROP ADDRESS".localized()
            addressTitle.textColor = UIColor(red:0.09, green:0.85, blue:0.24, alpha:1.0)
            if requestDetail.d_address != nil && requestDetail.d_address != "" {
                pickupAddressLabel.text = requestDetail.d_address
            }else {
                pickupAddressLabel.text = "--Not Available--".localized()
            }
            changeTripStatusBtn.setTitle("Tap to Start Trip".localized(), for: .normal)
        case Const.IS_PROVIDER_SERVICE_STARTED:
            if (floaty?.items.count)! > 2 {
                self.floaty?.removeItem(index: 2)
            }
            addressTitle.text = "DROP ADDRESS".localized()
            addressTitle.textColor = UIColor(red:1.00, green:0.00, blue:0.00, alpha:1.0)
            if requestDetail.d_address != nil && requestDetail.d_address != "" {
                pickupAddressLabel.text = requestDetail.d_address
            }else {
                pickupAddressLabel.text = "--Not Available--".localized()
            }
            changeTripStatusBtn.setTitle("Tap to End Trip".localized(), for: .normal)
        default:
            break
        }
        
    }
    
    
    func cancelRide(){
        self.showLoading()
        API.cancelRide{ json, error in
            self.hideLoading()
            do{
                
                if json == nil {
                    print("json nil")
                    return
                }
                
                
                let status = json![Const.STATUS_CODE].boolValue
                let statusMessage = json![Const.STATUS_MESSAGE].stringValue
                if(status){
                    self.stopTimer()
                    DATA().clearRequestData()
                    self.goToDashboard()
                    print(json ?? "error in cancelRide json")
                }else{
                    
                    print(json ?? "error in cancelRide json")
                    print(statusMessage)
                    print(json ?? "json empty")
                    var msg = json![Const.DATA].rawString()!
                    msg = msg.replacingOccurrences( of:"[{}\",]", with: "", options: .regularExpression)
                    
                    self.view.makeToast(message: msg)
                }
            }catch{
                print(json ?? "error in cancelRide json")
            }
        }
    }
    
    func goToDashboard(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "SWRevealViewController") as? UIViewController
        self.present(secondViewController!, animated: true, completion: nil)
    }
    
    func goToRating(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewContro‌​ller = storyBoard.instantiateViewController(withIdentifier: "RatingViewController") as! RatingViewController
        self.navigationController?.pushViewController(nextViewContro‌​ller, animated: true)
    }
    
    func layoutFAB() {
        
        let screenSize: CGRect = UIScreen.main.bounds
        floaty = Floaty(frame: CGRect(x: screenSize.width - 6 - 64, y: screenSize.height - 30 - 84, width: 64 - 10, height: 64))
        floaty?.buttonColor = UIColor(red:1.00, green:0.59, blue:0.00, alpha:1.0)
        floaty?.buttonImage = UIImage(named: "dots_vertical")
        
        var item = FloatyItem()
        item.title = "Message".localized()
        item.iconImageView.image = UIImage(named: "message_outline")
        item.buttonColor = UIColor(red:1.00, green:0.25, blue:0.51, alpha:1.0)
        item.handler =  { item in
            self.goToChat()
        }
        
        floaty?.addItem(item: item)
        
        item = FloatyItem()
        item.title = "Call".localized()
        item.iconImageView.image = UIImage(named: "phone_classic")
        item.buttonColor = UIColor(red:0.22, green:0.61, blue:0.68, alpha:1.0)
        item.handler =  { item in
            self.callNumber()
        }
        floaty?.addItem(item: item)
        
        item = FloatyItem()
        //item.titleLabel.text = "Cancel Trip"
        item.title = "Cancel Trip".localized()
        item.iconImageView.image = UIImage(named: "alert")
        item.buttonColor = UIColor(red:0.98, green:0.08, blue:0.04, alpha:1.0)
        item.handler =  { item in
            
            let alert = UIAlertController(title: "", message: "Are you sure? You want to Cancel this Ride?", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(
                title: "No".localized(),
                style: UIAlertActionStyle.cancel) { (action) in
                    // ...
            }
            
            let confirmAction = UIAlertAction(
            title: "Yes".localized(), style: UIAlertActionStyle.default) { (action) in
                // ...
                self.stopTimer()
                self.cancelRide()
            }
            
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
            
            //alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        
        floaty?.addItem(item: item)
        
        //self.placeFloaty()
        self.view.addSubview(floaty!)
        
        //        let screenSize: CGRect = UIScreen.main.bounds
        //        let myView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width - 10, height: 10))
        //        self.view.addSubview(myView)
        //
        floaty?.fabDelegate = self
        
        
        //changeTripStatusBtn.frame.size.height
        
    }
    
    func goToChat(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewContro‌​ller = storyBoard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        self.navigationController?.pushViewController(nextViewContro‌​ller, animated: true)
    }
    
    func callNumber(){
        if !self.requestDetail.driver_mobile.isEmpty {
            guard let number = URL(string: "tel://" + self.requestDetail.clientPhoneNumber) else { return }
            UIApplication.shared.open(number)
        }else{
            self.view.makeToast(message: "User number not available".localized())
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //        self.placeFloaty()
        //        self.view.layoutIfNeeded()
        //        self.floaty?.layoutIfNeeded()
        //
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        //placeFloaty()
        let screenSize: CGRect = UIScreen.main.bounds
        floaty?.frame = CGRect(x: screenSize.width - 6 - 64, y: screenSize.height - 26 - 84, width: 64 - 10, height: 64)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //placeFloaty()
    }
    
    var currentY: Double = 0
    
    func placeFloaty()
    {
        
        floaty?.translatesAutoresizingMaskIntoConstraints = false
        let X = floatingButton.frame.origin.x + (floatingButton.superview?.frame.origin.x)! + (floatingButton.superview?.superview?.frame.origin.x)! + (floatingButton.superview?.superview?.superview?.frame.origin.x)! + (floatingButton.superview?.superview?.superview?.superview?.frame.origin.x)!
        let Y = floatingButton.frame.origin.y + (floatingButton.superview?.frame.origin.y)! + (floatingButton.superview?.superview?.frame.origin.y)! + (floatingButton.superview?.superview?.superview?.frame.origin.y)! + (floatingButton.superview?.superview?.superview?.superview?.frame.origin.y)!
        
        floaty?.frame = CGRect(x: X, y: Y, width: floatingButton.frame.size.width, height: floatingButton.frame.size.height)
        
        //        if currentY != 0 {
        //        floaty?.frame = CGRect(x: X, y: Y, width: floatingButton.frame.size.width, height: floatingButton.frame.size.height)
        //        } else {
        //            currentY = Double(Y)
        //        }
        
        
        //        floaty?.frame = self.view.convert(floatingButton.frame, to: self.view)
        
    }
    
    func floatyOpened(_ floaty: Floaty) {
        print("Floaty Opened")
    }
    
    func floatyClosed(_ floaty: Floaty) {
        print("Floaty Closed")
    }
    
    
    // Pass your source and destination coordinates in this method.
    func getPolylineRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){
        
        
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&\(Const.EXTANCTION)")!
        //sensor=false&mode=driving")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print("path get error")
                print(error!.localizedDescription)
            }else{
                print("path got")
                do {
                    print(data ?? "")
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{
                        
                        let routes = json["routes"] as? [Any]
                        if routes?.count == 0 {
                            print("error routes count zero")
                            return
                        }
                        let route = routes?[0] as?[String:Any]
                        let overview_polyline = route?["overview_polyline"] as?[String:Any]
                        let polyString : String = (overview_polyline?["points"] as?String)!
                        print(polyString)
                        //Call this method to draw path on map
                        DispatchQueue.main.async
                            {
                                //                                // 2. Perform UI Operations.
                                //                                var position = CLLocationCoordinate2DMake(17.411647,78.435637)
                                //                                var marker = GMSMarker(position: position)
                                //                                marker.title = "Hello World"
                                //                                marker.map = vwGoogleMap
                                self.showPath(polyStr: polyString)
                        }
                        
                    }
                    
                }catch{
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
    }
    
    func showPath(polyStr :String){
        
        //        polyline.map = nil
        
        let path:GMSPath = GMSPath(fromEncodedPath: polyStr)!
        polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 3.0
        polyline.strokeColor = UIColor.black
        polyline.map = gmsMapView // Your map view
        //gmsMapView.bounds
        
        //        var bounds = GMSCoordinateBounds()
        
        //        for index:UInt in 1...path.count() {
        //            bounds = bounds.includingCoordinate(path.coordinate(at: index))
        //        }
        //
        //        gmsMapView.animate(with: GMSCameraUpdate.fit(bounds))
    }
    
    
    var timer: DispatchSourceTimer?
    
    func startTimer() {
        let queue = DispatchQueue(label: "com.prov.nikola.driver.timer")  // you can also use `DispatchQueue.main`, if you want
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer!.scheduleRepeating(deadline: .now(), interval: .seconds(4))
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
        locationManager.stopUpdatingLocation()
    }
    
    func checkRequestStatus(){
        API.checkRequestStatus{ json, error in
            
            
            if self.timer == nil {
                print("timer nil")
                return
            }
            
            if let error = error {
                self.hideLoader()
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            } else {
                
                if let json = json {
                    
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                      let isRideCancelled = json[Const.IS_RIDE_CANCELLED].boolValue
                    if(status){
                        
                        let requestDetail: RequestDetail = RequestDetail()
                        let jsonAry:[JSON]  = json[Const.DATA].arrayValue
                        let defaults = UserDefaults.standard
                        
                        
                        print("json currency \(json["currency"])")
                        
                        
                        UserDefaults.standard.set(json["currency"].string, forKey: "currency")
                        
                        if(isRideCancelled){
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.window?.makeToastMiddle(message: "Unfortunately the passenger had to cancel, you will soon receive a new request".localized())
                            requestDetail.tripStatus = Const.NO_REQUEST
                            let defaults = UserDefaults.standard
                            DATA().putRequestId(reqId: Const.NO_REQUEST)
                            self.stopTimer()
                            let delay = 4 * Double(NSEC_PER_SEC)
                            print("#####################Came Out @@@@@@@@@@@@@@@@@@@@")
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)) { () -> Void in
                                print("#####################Came In @@@@@@@@@@@@@@@@@@@@")
                                self.goToDashboard()
                                
                            }
                            
                            
                        }
//                        if json[Const.DATA].exists() && json[Const.DATA].arrayValue.count == 0 {
//                            let alert = UIAlertController(title: "", message: "Trip Cancelled by User!", preferredStyle: .alert)
//
//                            let confirmAction = UIAlertAction(
//                            title: "Ok", style: UIAlertActionStyle.default) { (action) in
//                                // ...
//                                requestDetail.tripStatus = Const.NO_REQUEST
//                                let defaults = UserDefaults.standard
//                                DATA().putRequestId(reqId: Const.NO_REQUEST)
//                                self.goToDashboard()
//                                self.stopTimer()
//                            }
//
//                            alert.addAction(confirmAction)
//
//                            //alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
//                            self.present(alert, animated: true, completion: nil)
//
//                        }
                        //self.goToDashboard()
                        //self.view.makeToast(message: "Logged In")
                    }else{
                        print(statusMessage)
                        print(json ?? "json empty")
                        var msg = json[Const.DATA].rawString()!
                        msg = msg.replacingOccurrences( of:"[{}\",]", with: "", options: .regularExpression)
                        
                        self.view.makeToast(message: msg)
                    }
                    
                    
                }else {
                    self.hideLoader()
                    debugPrint("Invalid JSON :(")
                }
                
                
            }
            
        }
    }
    
    func processStatus(json: JSON, tripStatus: Int){
        /*
         let defaults = UserDefaults.standard
         var requestDetail: RequestDetail = RequestDetail()
         let jsonAry:[JSON]  = json[Const.DATA].arrayValue
         if jsonAry.count > 0 {
         let driverData = jsonAry[0]
         if driverData.exists() {
         //saving driver data
         defaults.set(driverData.rawString(), forKey: Const.CURRENT_DRIVER_DATA)
         defaults.set(driverData["request_id"].stringValue, forKey: Const.Params.REQUEST_ID)
         requestDetail.initDriver(rqObj: driverData)
         }
         }
         
         // saving invoice data
         let invoiceAry:[JSON]  = json[Const.INVOICE].arrayValue
         if invoiceAry.count > 0 {
         let invoiceData = invoiceAry[0]
         defaults.set(invoiceData.rawString(), forKey: Const.CURRENT_INVOICE_DATA)
         requestDetail.initInvoice(rqObj: invoiceData)
         }
         switch(tripStatus){
         
         case Const.NO_REQUEST:
         PreferenceHelper.clearRequestData()
         self.view.makeToast(message: "No Providers found please try after some time!")
         self.stopTimer()
         print("No Providers found please try after some time!")
         case Const.IS_ACCEPTED:
         
         defaults.set(Const.IS_ACCEPTED, forKey: Const.DRIVER_STATUS)
         print("Driver accepted")
         let jsonAry:[JSON]  = json[Const.DATA].arrayValue
         if jsonAry.count > 0 {
         let driverData = jsonAry[0]
         if driverData.exists() {
         
         self.jobStatus = Const.IS_ACCEPTED;
         addressTitle.text = "Pickup Address"
         addressTitle.textColor = UIColor(red:0.09, green:0.85, blue:0.24, alpha:1.0)
         
         pickupAddressLabel.text = requestDetail.s_address
         requestStatusLabel.text = "DRIVER ACCEPTED THE REQUEST"
         }
         
         // saving invoice data
         let invoiceAry:[JSON]  = json[Const.INVOICE].arrayValue
         if invoiceAry.count > 0 {
         let invoiceData = invoiceAry[0]
         defaults.set(invoiceData.rawString(), forKey: Const.CURRENT_INVOICE_DATA)
         requestDetail.initInvoice(rqObj: invoiceData)
         }
         }
         case Const.IS_DRIVER_DEPARTED:
         self.jobStatus = Const.IS_DRIVER_DEPARTED;
         addressTitle.text = "Pickup Address"
         addressTitle.textColor = UIColor(red:0.09, green:0.85, blue:0.24, alpha:1.0)
         
         pickupAddressLabel.text = requestDetail.s_address
         requestStatusLabel.text = "DRIVER IS ON THE WAY"
         case Const.IS_DRIVER_ARRIVED:
         self.jobStatus = Const.IS_DRIVER_ARRIVED;
         addressTitle.text = "Drop Address"
         addressTitle.textColor = UIColor(red:0.98, green:0.08, blue:0.04, alpha:1.0)
         
         if (requestDetail.d_address ?? "").isEmpty{
         pickupAddressLabel.text = "--Not Available--"
         }else{
         pickupAddressLabel.text = requestDetail.d_address
         }
         requestStatusLabel.text = "DRIVER HAS ARRIVED AT YOUR PLACE"
         if (floaty?.items.count)! > 2 {
         self.floaty?.removeItem(index: 2)
         }
         case Const.IS_DRIVER_TRIP_STARTED:
         self.jobStatus = Const.IS_DRIVER_TRIP_STARTED;
         addressTitle.text = "Drop Address"
         addressTitle.textColor = UIColor(red:0.98, green:0.08, blue:0.04, alpha:1.0)
         
         if (requestDetail.d_address ?? "").isEmpty{
         pickupAddressLabel.text = "--Not Available--"
         }else{
         pickupAddressLabel.text = requestDetail.d_address
         }
         requestStatusLabel.text = "YOUR TRIP HAS BEEN STARTED"
         if (floaty?.items.count)! > 2 {
         self.floaty?.removeItem(index: 2)
         }
         case Const.IS_DRIVER_TRIP_ENDED:
         self.jobStatus = Const.IS_DRIVER_TRIP_ENDED;
         addressTitle.text = "Drop Address"
         addressTitle.textColor = UIColor(red:0.98, green:0.08, blue:0.04, alpha:1.0)
         
         if (requestDetail.d_address ?? "").isEmpty{
         pickupAddressLabel.text = "--Not Available--"
         }else{
         pickupAddressLabel.text = requestDetail.d_address
         }
         requestStatusLabel.text = "YOUR TRIP IS COMPLETED"
         if (floaty?.items.count)! > 2 {
         self.floaty?.removeItem(index: 2)
         }
         stopTimer()
         goToRating()
         
         case Const.IS_DRIVER_RATED:
         self.jobStatus = Const.IS_DRIVER_RATED;
         addressTitle.text = "Drop Address"
         addressTitle.textColor = UIColor(red:0.98, green:0.08, blue:0.04, alpha:1.0)
         
         if (requestDetail.d_address ?? "").isEmpty{
         pickupAddressLabel.text = "--Not Available--"
         }else{
         pickupAddressLabel.text = requestDetail.d_address
         }
         requestStatusLabel.text = "YOUR TRIP IS COMPLETED"
         if (floaty?.items.count)! > 2 {
         self.floaty?.removeItem(index: 2)
         }
         stopTimer()
         goToRating()
         
         default:
         print("something else happened")
         }
         
         */
    }
    
    func setDriverMarker( latlong: CLLocationCoordinate2D){
        if latlong == nil {
            return
        }
        
        if driver_marker == nil {
            driver_marker = GMSMarker(position: latlong)
            driver_marker?.icon = #imageLiteral(resourceName: "car")
            driver_marker?.title = "Driver".localized()
            driver_marker?.map = gmsMapView
        }else{
            driver_marker?.position = latlong
        }
        
    }
    
    @IBAction func changeTripStatusAction(_ sender: UIButton) {
        
        switch self.jobStatus {
        case Const.IS_PROVIDER_ACCEPTED:
            showLoading()
            self.providerStarted()
        case Const.IS_PROVIDER_STARTED:
            showLoading()
            self.providerArrived()
        case Const.IS_PROVIDER_ARRIVED:
            showLoading()
            if let polyline = polyline {
                polyline.map = nil
            }
            gmsMapView.clear()
            if drPoint != nil && (drPoint?.latitude != 0 && drPoint?.longitude != 0){
                drop_marker = GMSMarker(position: drPoint!)
                drop_marker?.title = "Drop location".localized()
                //drop_marker?.title = nearest_eta
                drop_marker?.icon = #imageLiteral(resourceName: "map_drop_marker")
                drop_marker?.map = gmsMapView
            }
            
            tripStarted = true
//            self.tripStartTime = Date()
            self.getPolylineRoute(from: self.curPoint!, to: drPoint!)
            self.tripStartTime = Date()
            UserDefaults.standard.set(self.tripStartTime, forKey: "TripStartTime")
            UserDefaults.standard.synchronize()
            self.providerServiceStarted()
        case Const.IS_PROVIDER_SERVICE_STARTED:
            showLoading()
          
            if let mTripStartDate = self.tripStartTime {
                print("Trip start time is \(mTripStartDate)")
            }
            else
            {
                let tripststartime = UserDefaults.standard.object(forKey: "TripStartTime") as? Date
                
                if(tripststartime == nil)
                {
                    self.tripStartTime = Date()
                }
                else{
                    
                    self.tripStartTime = tripststartime
                }
                
            }
            let components = Calendar.current.dateComponents([.month, .day,.minute, .second, .hour], from: self.tripStartTime!, to: Date())
            let secondsDifference: Int = components.second!
            let minutesDifference: Int = (components.minute! * 60)
            let hoursDifference: Int = (components.hour! * 3600)
            
            print("\(secondsDifference) \(minutesDifference) \(hoursDifference)")
            
            totaltime = secondsDifference + minutesDifference + hoursDifference
            
            print(totaltime)
            timer1.invalidate()
            
            let lat : String = String(format:"%f", (curPoint?.latitude)!)
            let log : String = String(format:"%f", (curPoint?.longitude)!)
            
            
            
            print("\(lat) \(log)")
            
            let dlat: Double = Double(requestDetail.s_lat)!
            let dlog: Double = Double(requestDetail.s_lon)!
            
            print("\(dlat) \(dlog)")
            
            let slat: String = String(format:"%f", (dlat))
            let slog: String = String(format:"%f", (dlog))
            
            print("\(slat) \(slog)")
            
            
            findDistanceTime(pi_lat: requestDetail.s_lat, pi_lon: requestDetail.s_lon, dr_lat: "\(lat)", dr_lon: "\(log)")

            
            
            
        default:
            print("change trip default")
        }
    }
 
    func providerStarted() {
        self.showLoader(str: "Loading".localized())
        API.providerStarted{ json, error in
            // self.hideLoading()
            
            if let error = error {
                self.hideLoader()
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status){
                        self.hideLoader()
                        self.jobStatus = Const.IS_PROVIDER_STARTED
                        self.setJobStatus(jobStaus: self.jobStatus)
                        print(json ?? "error in providerStarted json")
                    }else{
                        self.hideLoader()
                        print(json ?? "error in providerStarted json")
                        print(statusMessage)
                        print(json ?? "json empty")
                        var msg = json[Const.DATA].rawString()!
                        msg = msg.replacingOccurrences( of:"[{}\",]", with: "", options: .regularExpression)
                        
                        self.view.makeToast(message: msg)
                    }
                    
                    
                }else {
                    self.hideLoader()
                    debugPrint("Invalid JSON :(")
                }
                
                
                
            }
            
            
        }
    }
    
    func providerArrived() {
        self.showLoader(str: "Loading".localized())
        API.providerArrived{ json, error in
            self.hideLoading()
            
            if let error = error {
                self.hideLoader()
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status){
                        self.hideLoader()
                        self.jobStatus = Const.IS_PROVIDER_ARRIVED
                        self.setJobStatus(jobStaus: self.jobStatus)
                        print(json ?? "error in providerStarted json")
                    }else{
                        self.hideLoader()
                        print(json ?? "error in providerStarted json")
                        print(statusMessage)
                        print(json ?? "json empty")
                        var msg = json[Const.DATA].rawString()!
                        msg = msg.replacingOccurrences( of:"[{}\",]", with: "", options: .regularExpression)
                        
                        self.view.makeToast(message: msg)
                    }
                    
                    
                }else {
                    self.hideLoader()
                    debugPrint("Invalid JSON :(")
                }
                
            }
            
            
            
        }
    }
    
    func providerServiceStarted() {
        self.showLoader(str: "Loading".localized())
        API.providerServiceStarted{ json, error in
            
            if let error = error {
                self.hideLoader()
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status){
                        self.hideLoader()
                        self.jobStatus = Const.IS_PROVIDER_SERVICE_STARTED
                        self.setJobStatus(jobStaus: self.jobStatus)
//                        self.timer1 = Timer.scheduledTimer(timeInterval: 1.0, target: self,  selector: #selector(self.timerRunning), userInfo: nil, repeats: true)
                        print(json ?? "error in providerStarted json")
                    }else{
                        //                            self.hideLoader()
                        //                            print(json ?? "error in providerStarted json")
                        //                            print(statusMessage)
                        //                                        print(json ?? "json empty")
                        //                                        var msg = json[Const.DATA].rawString()!
                        //                                        msg = msg.replacingOccurrences( of:"[{}\",]", with: "", options: .regularExpression)
                        //
                        //                                        self.view.makeToast(message: msg)
                        
                        self.hideLoader()
                        debugPrint("Failed on:\(statusMessage)")
                    }
                    
                    
                    
                }else {
                    self.hideLoader()
                    debugPrint("Invalid JSON :(")
                }
                
                
            }
            
            
        }
        
        
    }
    
    func providerServiceCompleted(distance: String, duration: String) {
        self.showLoader(str: "Loading".localized())
        API.providerServiceCompleted(distance:  distance, duration: duration, completionHandler: { json, error in
            
            if let error = error {
                self.hideLoader()
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status == true){
                        self.hideLoader()
                        self.jobStatus = Const.IS_USER_RATED
                        self.setJobStatus(jobStaus: self.jobStatus)
                        self.stopTimer()
                        
                        let defaults = UserDefaults.standard
                        
                        let invoiceAry:[JSON]  = json[Const.INVOICE].arrayValue
                        if invoiceAry.count > 0 {
                            let invoiceData = invoiceAry[0]
                            debugPrint("invoice json")
                            debugPrint(invoiceData.rawString() ?? "invoiceData null")
                            defaults.set(invoiceData.rawString(), forKey: Const.CURRENT_INVOICE_DATA)
                            //requestDetail.initInvoice(rqObj: invoiceData)
                        }
                        
                        self.goToRating()
                    }else {
                        self.hideLoader()
                        debugPrint("Failed on:\(statusMessage)")
                    }
                }else {
                    self.hideLoader()
                    debugPrint("Invalid JSON :(")
                }
            }
            
        })
    }
    
    
    func findDistanceTime(pi_lat: String,pi_lon: String,dr_lat: String,dr_lon: String){
        
        let defaults = UserDefaults.standard
        
        
        
        let url = URL(string: Const.GOOGLE_MATRIX_URL + Const.Params.ORIGINS + "="
            + pi_lat + "," + pi_lon + "&" + Const.Params.DESTINATION + "="
            + dr_lat + "," + dr_lon + "&" + Const.Params.MODE + "="
            + "driving" + "&" + Const.Params.LANGUAGE + "="
            + "en-EN" + Const.Params.KEY + "=" + Const.googlePlaceAPIkey + "&" + Const.Params.SENSOR + "="
            + "false")
        print(url)
        
        
        
        var path : String = "\(Const.GOOGLE_MATRIX_URL)\(Const.Params.ORIGINS)=\(pi_lat),\(pi_lon)&\(Const.Params.DESTINATION)=\(dr_lat),\(dr_lon)&\(Const.Params.MODE)=driving&\(Const.Params.KEY)=\(Const.googlePlaceAPIkey)&\(Const.Params.LANGUAGE)=en-EN&\(Const.Params.SENSOR)=false"
        
        path = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        print(path)
        
        
        API.googlePlaceAPICall(with: path){ responseObject, error in
            
            
            if let error = error {
                self.hideLoader()
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                
                print(error ?? "Any")
                
                if responseObject == nil {
                    print("json nil")
                    return
                }
                
                
                
                if let resData = responseObject {
                    //
                    //
                    let json = self.jsonParser.jsonParser(dicData: resData)
                    
                    print(json)
                    //
                    //
                    if let dic = json["rows"].array, dic.count > 0 {
                        //
                        
                        if let value = dic[0]["elements"].array {
                            
                            print(value[0]["duration"])
                            
                            let durationeDic = value[0]["distance"].dictionary
                            
                            
                            if let dist : Int = durationeDic?["value"]?.int {
                                
                                self.distance = Double(dist) * 0.001
                                
                                print(self.distance)
                                
                                
                            }
                            else
                            {
                                
                                self.distance = 0.0
                            }
                            
                            
                            if let duration = durationeDic?["text"]?.string {
                                
                                print(duration)
                                
                            }
                            
                            self.providerServiceCompleted(distance:  String(format:"%f", self.distance), duration:  String(self.totaltime));
                            
                        }
                    }
                    
                }
                
                
                
            }
            
            
            
            
        }
        
        
    }
    
    
    
    // Handle new message from one of channels on which client has been subscribed.
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        
        // Handle new message stored in message.data.message
        if message.data.channel != message.data.subscription {
            
            // Message has been received on channel group stored in message.data.subscription.
        }
        else {
            
            do{
                let dict = message.data.message as! Dictionary<String, Any>
                //let msg  = message.data.message as! [String:Any]?
                let lat: Double  = try (dict["lat"] as! Double?)!
                let lon: Double  = try (dict["lan"] as! Double?)!
                
                //moveToNextPosition(newCoordinate: CLLocationCoordinate2DMake(lat, lon))
                // Message has been received on channel stored in message.data.channel.
            }catch{
                print(error.localizedDescription)
            }
        }
        
        print("Received message: \(message.data.message) on channel \(message.data.channel) at \(message.data.timetoken)")
    }
    
    
    @IBAction func navigationActionMethod(_ sender: Any) {
        
        
        if tripStarted {
            
            slat = String(format:"%f", (piPoint?.latitude)!)
            slog = String(format:"%f", (piPoint?.longitude)!)
            
            dlat = String(format:"%f", (drPoint?.latitude)!)
            dlog = String(format:"%f", (drPoint?.longitude)!)
            
            print("started")
            
        }else {
            
            slat = String(format:"%f", (curPoint?.latitude)!)
            slog = String(format:"%f", (curPoint?.longitude)!)
            
            dlat = String(format:"%f", (piPoint?.latitude)!)
            dlog = String(format:"%f", (piPoint?.longitude)!)
            
            print("not started")
        }
        
        
        if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
            
            
            print("google map")
            
            UIApplication.shared.open(NSURL(string:
                "comgooglemaps://?saddr=\(slat),\(slog)&daddr=\(dlat),\(dlog)")! as URL, options: [:], completionHandler: nil)
            
            
            
        } else {
            
            print("no google map")
            
            UIApplication.shared.open(NSURL(string:
                "https://www.google.co.in/maps/dir/?saddr=\(slat),\(slog)&daddr=\(dlat),\(dlog)")! as URL, options: [:], completionHandler: nil)
            
            
        }
        
        
    }
    
    
    
    
    func publishPubNub(){
        self.client.publish("Hello from the PubNub Swift SDK", toChannel: "my_channel",
                            compressed: false, withCompletion: { (status) in
                                
                                if !status.isError {
                                    
                                    // Message successfully published to specified channel.
                                }
                                else{
                                    
                                    /**
                                     Handle message publish error. Check 'category' property to find
                                     out possible reason because of which request did fail.
                                     Review 'errorData' property (which has PNErrorData data type) of status
                                     object to get additional information about issue.
                                     
                                     Request can be resent using: status.retry()
                                     */
                                }
        })
    }
    
    func publishLocationPubNub(lat: Double, lon: Double){
        
        var jsonObj = JSON(["lat": lat, "lan": lon])
        
        
        let channel: String  =  "\(Const.CHANNEL_ID)\(DATA().getUserId())"
        
        let parameters:[String:Double] = [ "lat": lat, "lan": lon, "heading":heading! ]
        
        let locString = "{\"lat\":\(lat),\"lan\":\(lon)"
        self.client.publish(parameters, toChannel: channel,
                            compressed: false, withCompletion: { (status) in
                                
                                if !status.isError {
                                    print("published successfully")
                                    // Message successfully published to specified channel.
                                }
                                else{
                                    print("publish error")
                                    print(status.category)
                                    print(status.category.rawValue)
                                    if status.category == .PNMalformedFilterExpressionCategory {
                                        print(status.debugDescription)
                                    }
                                    print(status.debugDescription)
                                    print(status.errorData.information)
                                    print("Error End")
                                    //print(status.category)
                                    /**
                                     Handle message publish error. Check 'category' property to find
                                     out possible reason because of which request did fail.
                                     Review 'errorData' property (which has PNErrorData data type) of status
                                     object to get additional information about issue.
                                     
                                     Request can be resent using: status.retry()
                                     */
                                }
        })
    }
    
    
}

// MARK: - CLLocationManagerDelegate
extension TravelMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
            gmsMapView.isMyLocationEnabled = true
            gmsMapView.settings.myLocationButton = true
            locationManager.allowsBackgroundLocationUpdates = true
            
            //        let position = CLLocationCoordinate2D(latitude: 40.717041, longitude: -73.988007)
            //        let hello = GMSMarker(position: position)
            //        hello.title = "Hello world!"
            //        hello.snippet = "Welcome to my marker"
            //
            //        hello.map = mapView
            
            let pi_lat: String = requestDetail.s_lat
            let pi_lon: String = requestDetail.s_lon
            
            //            let dr_lat: String = requestDetail.d_lat
            //            let dr_lon: String = requestDetail.d_lon
            
            let pLati = Double(pi_lat ?? "") ?? 0.0
            let pLongi = Double(pi_lon ?? "") ?? 0.0
            
            //            let dLati = Double(dr_lat ?? "") ?? 0.0
            //            let dLongi = Double(dr_lon ?? "") ?? 0.0
            
            piPoint = CLLocationCoordinate2DMake(pLati, pLongi)
            //drPoint = CLLocationCoordinate2DMake(dLati, dLongi)
            
            if piPoint != nil && (piPoint?.latitude != 0 && piPoint?.longitude != 0){
                pick_marker = GMSMarker(position: piPoint!)
                pick_marker?.title = "Pickup location".localized()
                //pick_marker?.snippet = self.nearest_eta
                pick_marker?.icon = #imageLiteral(resourceName: "map_pick_marker")
                pick_marker?.map = gmsMapView
            }
            
            
            //            if drPoint != nil && (drPoint?.latitude != 0 && drPoint?.longitude != 0){
            //                drop_marker = GMSMarker(position: drPoint!)
            //                drop_marker?.title = "Drop location"
            //                //drop_marker?.title = nearest_eta
            //                drop_marker?.icon = #imageLiteral(resourceName: "map_drop_marker")
            //                drop_marker?.map = gmsMapView
            //            }
            
            if piPoint != nil && drPoint != nil{
                //                self.getPolylineRoute(from: piPoint!, to: drPoint!)
            }
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            if (self.curPoint?.latitude != location.coordinate.latitude || self.curPoint?.longitude != location.coordinate.longitude ) {
                self.setDriverMarker(latlong: location.coordinate)
                publishLocationPubNub(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
                updateLocation(lat: "\(location.coordinate.latitude)", lon: "\(location.coordinate.longitude)" )
                SocketIOManager.sharedInstance.sendCarIconHeading(String(format:"%f", heading!), lat: String(location.coordinate.latitude), long: String(location.coordinate.longitude))
                gmsMapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 18, bearing: 0, viewingAngle: 0)
                //
                
                // focusMapToShowAllMarkers(myLocation: location.coordinate)
                
            }
            self.curPoint = location.coordinate
            
            if tripStarted == false {
                self.getPolylineRoute(from: self.curPoint!, to: piPoint!)
            }
            
            
            
            
            //locationManager.stopUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading.trueHeading;
        driver_marker?.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        driver_marker?.rotation = heading!
        driver_marker?.map = gmsMapView;
        
        // print(driver_marker?.rotation)
    }
    //    func focusMapToShowAllMarkers(myLocation : CLLocationCoordinate2D) {
    //        var bounds: GMSCoordinateBounds = GMSCoordinateBounds(coordinate: myLocation, coordinate: myLocation)
    //
    //        bounds = bounds.includingCoordinate((pick_marker?.position)!)
    //        if drop_marker != nil && drop_marker?.position != nil {
    //            bounds = bounds.includingCoordinate((drop_marker?.position)!)
    //        }
    //        self.gmsMapView.animate(with: GMSCameraUpdate.fit(bounds,  with: UIEdgeInsets(top: 150, left: 10,bottom: 120, right: 10)))
    //    }
    //
    func updateLocation(lat: String, lon: String){
        
        API.updateLocation(lat: lat, lon: lon, completionHandler:{ json, error in
            
            if json != nil && self.timer != nil {
                let status = json![Const.STATUS_CODE].boolValue
                let statusMessage = json![Const.STATUS_MESSAGE].stringValue
                if(status){
                    print(json ?? "error in  updateLocation json")
                    print("location updated")
                }else{
                    print(statusMessage)
                    print(json ?? "json empty")
                }
                print(json ?? "json nil")
            }
        })
    }
}

// MARK: - GMSMapViewDelegate
extension TravelMapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView!, idleAt position: GMSCameraPosition!) {
        // reverseGeocodeCoordinate(coordinate: position.target)
    }
    
    func mapView(_ mapView: GMSMapView!, willMove gesture: Bool) {
        //addressLabel.lock()
        
        if (gesture) {
            //mapCenterPinImage.fadeIn(0.25)
            mapView.selectedMarker = nil
        }
    }
    
    //    func mapView(_ mapView: GMSMapView!, markerInfoContents marker: GMSMarker!) -> UIView! {
    //        let placeMarker = marker as! PlaceMarker
    //
    //        if let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView {
    //            infoView.nameLabel.text = placeMarker.place.name
    //
    //            if let photo = placeMarker.place.photo {
    //                infoView.placePhoto.image = photo
    //            } else {
    //                infoView.placePhoto.image = UIImage(named: "generic")
    //            }
    //
    //            return infoView
    //        } else {
    //            return nil
    //        }
    //    }
    
    func mapView(_ mapView: GMSMapView!, didTap marker: GMSMarker!) -> Bool {
        //mapCenterPinImage.fadeOut(0.25)
        return false
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView!) -> Bool {
        // mapCenterPinImage.fadeIn(0.25)
        mapView.selectedMarker = nil
        return false
    }
}
extension TravelMapViewController : MBProgressHUDDelegate {
    
    func showLoader(str: String) {
        hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = MBProgressHUDModeIndeterminate
        hud.labelText = str
    }
    
    func hideLoader() {
        hud.hide(true)
    }
    
    
}
