//
//  MainMapsViewController.swift
//  Nikola
//
//  Created by Sutharshan on 5/25/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import GoogleMaps
import SwiftyJSON
import Localize_Swift
import UserNotifications

class MainMapsViewController: UIViewController {
    
    @IBOutlet weak var lblOff: UILabel!
    @IBOutlet weak var mapCenterPinImage: UIImageView!
    @IBOutlet weak var burgerMenu: UIButton!
    // You don't need to modify the default init(nibName:bundle:) method.
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var addressLabel: UILabel!
    let locationManager = CLLocationManager()
    
    //let dataProvider = GoogleDataProvider()
    
    @IBOutlet weak var availabilityToggle: UISwitch!
    
    var latlon : CLLocationCoordinate2D? = nil
    
    var markers: [GMSMarker] = []
    
    var hourlyDetailsDic = [String: AnyObject]()
    override func viewDidLoad() {
        super.viewDidLoad()
    

        lblOff.text = "Go Online/Go Offline".localized()
        startProviderTimer()
        
        if revealViewController() != nil {
            
            
            burgerMenu .addTarget(revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: UIControlEvents.touchUpInside)
            
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            revealViewController().frontViewController.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
         locationManager.desiredAccuracy = kCLLocationAccuracyBest
        mapView.delegate = self
        
        //self.showRequestAnimation()
        
        NotificationCenter.default.addObserver(self, selector: #selector(startProviderTimer), name: NSNotification.Name(rawValue: "requestRejected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startProviderTimer), name: NSNotification.Name(rawValue: "requestRejectedError"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(requestAccepted), name: NSNotification.Name(rawValue: "requestAccepted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startProviderTimer), name: NSNotification.Name(rawValue: "requestExpired"), object: nil)
         setLoggedInTag()
        self.checkAvailability()
        self.checkRequestStatus()
        
        
    }
    private func setLoggedInTag() {
        
        UserDefaults.standard.set(true, forKey: "loggedIn")
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver("callForAlert")
    }
    
    
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
            //self.addressLabel.unlock()
            if let address = response?.firstResult() {
                let lines = address.lines as! [String]
                self.addressLabel.text = lines.joined(separator: "\n")
                
                let defaults = UserDefaults.standard
                defaults.set(lines.joined(separator: "\n"), forKey: Const.CURRENT_ADDRESS)
                defaults.set(coordinate.latitude, forKey: Const.CURRENT_LATITUDE)
                defaults.set(coordinate.longitude, forKey: Const.CURRENT_LONGITUDE)
                
                let labelHeight = self.addressLabel.intrinsicContentSize.height
                self.mapView.padding = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0, bottom: labelHeight, right: 0)
                
                UIView.animate(withDuration: 0.25) {
                    //   self.pinImageVerticalConstraint.constant = ((labelHeight - self.topLayoutGuide.length) * 0.5)
                    self.view.layoutIfNeeded()
                }
                print(" current address is -- ")
                print(lines.joined(separator: "\n"))
                
                
            }
        }
    }
    
    
    @IBAction func menuBtnAction(_ sender: Any) {
        
        
        //        revealViewController().revealToggle(sender)
        
    }
    
    func pickBtnAction(_ sender: UIButton) {
    }
    
    //MARK:- CheckReqeustStatus
    
    func checkRequestStatus(){
        API.checkRequestStatus{ json, error in
            
            print("Full checkrequeststatus JSON")
            
            if let error = error {
                //self.hideLoader()
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    
                    if (!API.isSuccess(response: json)){
                        
                        if (API.getErrorCode(response: json) == Const.REQUEST_ID_NOT_FOUND){
                            DATA().clearRequestData()
                        }else if (API.getErrorCode(response: json) == Const.INVALID_TOKEN){
                            DATA().clearRequestData()
                            self.stopProviderTimer()
                            DATA().logOut()
                            self.goToSignIn()
                            self.view.makeToast(message: "You have logged in from another device. Please login again.")
                        }else if(API.getErrorCode(response: json) == Const.INVALID_REQUEST_ID){
                            DATA().clearRequestData()
                            self.startProviderTimer()
                        }
                    }else if(status){
                        
                        var requestDetail: RequestDetail = RequestDetail()
                        
                        let jsonAry:[JSON]  = json[Const.DATA].arrayValue
                        let defaults = UserDefaults.standard
                        
                        if jsonAry.count > 0 {
                            let requestData = jsonAry[0]
                            if requestData.exists() {
                                
            
                                requestDetail.initRequest(rqObj: requestData)
                                
                                switch(requestDetail.providerStatus){
                                    
                                case Const.NO_REQUEST:
                                    DATA().clearRequestData()
                                    
                                case Const.IS_PROVIDER_ACCEPTED,Const.IS_PROVIDER_STARTED,Const.IS_PROVIDER_ARRIVED,Const.IS_PROVIDER_SERVICE_STARTED:
                                    
                                    DATA().putRequestId(reqId: Int(requestData["request_id"].stringValue)!)
                                    DATA().putClientId(customerId: requestData["user_id"].stringValue)
                                    DATA().putRequestData(request: requestData.rawString()!)
                                    self.goToTravelMap()
                                    
                                case Const.IS_PROVIDER_SERVICE_COMPLETED:
                                    
                                    DATA().putRequestId(reqId: Int(requestData["request_id"].stringValue)!)
                                    DATA().putClientId(customerId: requestData["user_id"].stringValue)
                                    DATA().putRequestData(request: requestData.rawString()!)
                                    if json[Const.INVOICE].exists(){
                                        let invoiceAry:[JSON]  = json[Const.INVOICE].arrayValue
                                        if invoiceAry.count > 0 {
                                            let invoiceData = invoiceAry[0]
                                            print("invoice json")
                                            print(invoiceData.rawString() ?? "invoiceData null")
                                            defaults.set(invoiceData.rawString(), forKey: Const.CURRENT_INVOICE_DATA)
                                            //requestDetail.initInvoice(rqObj: invoiceData)
                                        }
                                    }
                                    self.goToRating()
                                default :
                                    print("extra case")
                                }
                            }
                            
                            self.processStatus(json: json, tripStatus:requestDetail.tripStatus)
                        } else {
                            requestDetail.tripStatus = Const.NO_REQUEST
                            let defaults = UserDefaults.standard
                            defaults.set(Const.NO_REQUEST, forKey: Const.Params.REQUEST_ID)
                        }
                        
                        //self.goToDashboard()
                        //self.view.makeToast(message: "Logged In")
                    }else{
                        print(statusMessage)
                        print(json ?? "json empty")
                        var msg = json[Const.DATA].rawString()!
                        msg = msg.replacingOccurrences( of:"[{}\",]", with: "", options: .regularExpression)
                        
                        self.view.makeToast(message: msg)
                    }
                    
                    
                }
                
            }
            
        }
    }
    
    //MARK:- ProcessStatus
    func processStatus(json: JSON, tripStatus: Int){
        
        //var requestDetail: RequestDetail = RequestDetail()
        switch(tripStatus){
            
        case Const.NO_REQUEST:
            DATA().clearRequestData()
            self.view.makeToast(message: "No Providers found please try after some time!")
            print("No Providers found please try after some time!")
            //case Const.IS_CREATED:
            
        default:
            print("something else happened")
        }
        
    }
    
    //MARK:- SignIn Navigation Method
    func goToSignIn(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewContro‌​ller = storyBoard.instantiateViewController(withIdentifier: "SignInNavigationController")
        self.present(nextViewContro‌​ller, animated: true)
    }
    
        func requestAccepted(){
        goToTravelMap()
    }
    
    //MARK:- TravelMap Navigation Method
    func goToTravelMap(){
        
        SocketIOManager.sharedInstance.establishConnection()
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewContro‌​ller = storyBoard.instantiateViewController(withIdentifier: "TravelMapViewController") as! TravelMapViewController
        self.navigationController?.pushViewController(nextViewContro‌​ller, animated: true)
    }
    //MARK:- Rating Navigation Method
    func goToRating(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        //        let nextViewContro‌​ller = storyBoard.instantiateViewController(withIdentifier: "TravelMapViewController") as! TravelMapViewController
        let nextViewContro‌​ller = storyBoard.instantiateViewController(withIdentifier: "RatingViewController") as! RatingViewController
        self.navigationController?.pushViewController(nextViewContro‌​ller, animated: true)
    }
    
    deinit {
        //self.stopTimer()
        self.stopProviderTimer()
    }
    
    var timerProviders: DispatchSourceTimer? = nil
    
    var queue : DispatchQueue? = nil
    func startProviderTimer() {
        if timerProviders == nil {
            queue = DispatchQueue(label: "com.prov.nikola.driver.timer")  // you can also use `DispatchQueue.main`, if you want
            timerProviders = DispatchSource.makeTimerSource(queue: queue)
            timerProviders!.scheduleRepeating(deadline: .now(), interval: .seconds(4))
            timerProviders!.setEventHandler { [weak self] in
                // do whatever you want here
                do{
                    self?.getIncomingRequestsInProgress()
                }catch{
                    self?.stopProviderTimer()
                }
            }
            timerProviders!.resume()
        }
    }
    
    //MARK:- Override Method
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopProviderTimer()
    }
    
    func stopProviderTimer() {
        timerProviders?.cancel()
        timerProviders = nil
    }
    
    //MARK:- AvailabilityToggleAction
    @IBAction func availabilityToggleAction(_ sender: UISwitch) {
        
        if sender.isOn {
            updateAvailability(status: "1")
        }else{
            updateAvailability(status: "0")
        }
        
    }
    //MARK:- CheckAvailability Method
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
                        print(json)
                        
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
                        print(json )
                        print(statusMessage)
                        print(json )
                       
                    }
                    
                    
                    
                }else{
                    //self.hideLoader()
                    debugPrint("Invalid JSON :(")
                }
                
            }
            
            
            
        }
    }
    
    
    
    //MARK:- UpdateAvailability Method
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
                        print(json)
                        
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
                        print(json )
                        print(statusMessage)
                        print(json )
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
    
    
    
    //MARK:- GetIncomingRequests Method
    
    func getIncomingRequestsInProgress(){
        
        if self.timerProviders == nil{
            return
        }
        API.getIncomingRequestsInProgress{ json, error in
            
            print("Full getIncomingRequestsInProgress JSON")
            
            if let error = error {
                //self.hideLoader()
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    print(json)
                    
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    
                    if (!API.isSuccess(response: json)){
                        
                        if (API.getErrorCode(response: json) == Const.REQUEST_ID_NOT_FOUND){
                            DATA().clearRequestData()
                        }else if (API.getErrorCode(response: json) == Const.INVALID_TOKEN){
                            DATA().clearRequestData()
                            self.stopProviderTimer()
                            DATA().logOut()
                            self.goToSignIn()
                            self.view.makeToast(message: "You have logged in from another device. Please login again.")
                        }
                    }else if(status){
                        
                        if( API.getRequestId(response: json) == Const.NO_REQUEST){
                            
                        }else {
                            
                            if self.timerProviders == nil{
                                
                                print("session out")
                                
                                return
                            }
                            
                            var requestDetail: RequestDetail = RequestDetail()
                            
                            print(json ?? "empty json in incoming request")
                            let jsonAry:[JSON]  = json[Const.DATA].arrayValue
                            
                            print(jsonAry)
                            
                           // let items = json
                            
                            //let items = jsonAry[Const]
                            
                            
                            if  json["hourly_package_details"].dictionary != nil
                            {
                                let jsonHourly = json["hourly_package_details"].dictionary
                                
                                if (jsonHourly?.isEmpty)! {
                                    
                                    
                                    
                                }
                                else {
                                    
                                    self.hourlyDetailsDic = jsonHourly as! [String : AnyObject]
                                    
                                    //                        print(jsonHourly)
                                }
                                
                                //write your code
                            }
                                
                            else {
                                
                            }
                            
                            
                            let defaults = UserDefaults.standard
                            
                            if jsonAry.count > 0 {
                                let requstData = jsonAry[0]
                                if requstData.exists() {
                                    DATA().putIncomingRequestData(tempRequest: requstData.rawString()!)
                                    //defaults.set(requstData.rawString(), forKey: Const.CURRENT_REQUEST_DATA)
                                    //requestDetail.initDriver(rqObj: requstData)
                                    
                                    DATA().putIncomingRequestId(reqId: API.getRequestId(response: json))
                                    self.stopProviderTimer()
                                    self.showRequestAnimation()
                                    let content = UNMutableNotificationContent()
                                    content.title = NSString.localizedUserNotificationString(forKey: "New ride request:".localized(), arguments: nil)
                                    content.body = NSString.localizedUserNotificationString(forKey: "Hello！You have got a new ride request.Tap to accept/reject the request".localized(), arguments: nil)
                                    
                                    
                                    content.sound = UNNotificationSound(named:"Alert.m4a")
                                    //  content.sound = UNNotificationSound(named:String(contentsOf: soun))
                                    
                                    content.categoryIdentifier = "com.Prai.localNotification"
                                    // Deliver the notification in five seconds.
                                    let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1.0, repeats: false)
                                    let request = UNNotificationRequest.init(identifier: "PraiDriverNewrequest", content: content, trigger: trigger)
                                    
                                    // Schedule the notification.
                                    let center = UNUserNotificationCenter.current()
                                    center.add(request)
                                }
                                
                                self.processStatus(json: json, tripStatus:requestDetail.tripStatus)
                            } else {
                                requestDetail.tripStatus = Const.NO_REQUEST
                                let defaults = UserDefaults.standard
                                defaults.set(Const.NO_REQUEST, forKey: Const.Params.REQUEST_ID)
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
    
    //MARK:- ReqeustAnimation Navigationmethod
    var popOverVC: RequestAnimationViewController? = nil
    
    func showRequestAnimation(){
        
        popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RequestAnimationViewController") as! RequestAnimationViewController
        
        popOverVC?.hourlyDetailsDic = self.hourlyDetailsDic
        self.addChildViewController(popOverVC!)
        popOverVC!.view.frame = self.view.frame
        self.view.addSubview(popOverVC!.view)
        popOverVC!.didMove(toParentViewController: self)
    }
    
    //MARK:- UpdateLocation API Method
    func updateLocation(lat: String, lon: String){
        
        print("\(lat) \(lon)")
        API.updateLocation(lat: lat, lon: lon, completionHandler:{ json, error in
            if json != nil{
                let status = json![Const.STATUS_CODE].boolValue
                let statusMessage = json![Const.STATUS_MESSAGE].stringValue
                if(status){
                    print(json ?? "error in  updateLocation json")
                    print("location updated")
                }else{
                    print(statusMessage)
                    print(json ?? "json empty")
                }
            }else{
                print(json ?? "json nil")
            }
        })
    }
}



// MARK: - CLLocationManagerDelegate
extension MainMapsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            if (self.latlon?.latitude != location.coordinate.latitude || self.latlon?.longitude != location.coordinate.longitude ) {
                updateLocation(lat: "\(location.coordinate.latitude)", lon: "\(location.coordinate.longitude)" )
                mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            }
            self.latlon = location.coordinate
            
            //locationManager.stopUpdatingLocation()
            //fetchNearbyPlaces(location.coordinate)
            
        }
        
    }
}

// MARK: - GMSMapViewDelegate
extension MainMapsViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView!, idleAt position: GMSCameraPosition!) {
        reverseGeocodeCoordinate(coordinate: position.target)
    }
    
    func mapView(_ mapView: GMSMapView!, willMove gesture: Bool) {
        //addressLabel.lock()
        
        if (gesture) {
            //mapCenterPinImage.fadeIn(0.25)
            mapView.selectedMarker = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView!, markerInfoContents marker: GMSMarker!) -> UIView! {
        let placeMarker = marker as! PlaceMarker
        
        if let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView {
            infoView.nameLabel.text = placeMarker.place.name
            
            if let photo = placeMarker.place.photo {
                infoView.placePhoto.image = photo
            } else {
                infoView.placePhoto.image = UIImage(named: "generic")
            }
            
            return infoView
        } else {
            return nil
        }
    }
    
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
