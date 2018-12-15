//
//  MainDriverViewController.swift
//  Nikola Driver
//
//  Created by Sutharshan on 6/16/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import UIKit
import Floaty
import SwiftyJSON
import AlamofireImage
import GoogleMaps




class MainDriverViewController: UIViewController {// , FloatyDelegate {
    
    /*
    @IBOutlet weak var gmsMapView: GMSMapView!
    var requestDetail: RequestDetail
    var floaty: Floaty? = nil
    
    var jobStatus: Int = 0
    let locationManager = CLLocationManager()
    @IBOutlet weak var burgerMenu: UIBarButtonItem!
    var piPoint : CLLocationCoordinate2D? = nil
    var drPoint : CLLocationCoordinate2D? = nil
    var driverPoint : CLLocationCoordinate2D? = nil
    
    var pick_marker : GMSMarker? = nil
    var drop_marker : GMSMarker? = nil
    var driver_marker : GMSMarker? = nil
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView: UIImageView = UIImageView(image: UIImage(named: "logo_header.png"))
        imageView.frame.size.width = 150;
        imageView.frame.size.height = 30;
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
   
        /*
        checkRequestStatus()
        //startProviderTimer()
    
        if revealViewController() != nil {
            
            burgerMenu.target = revealViewController()
            burgerMenu.action = "revealToggle:"
            
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        gmsMapView.delegate = self
        
        self.startTimer()
        
    }
    
    
    
    var timer: DispatchSourceTimer?
    
    func startTimer() {
        let queue = DispatchQueue(label: "com.prov.nikola.timer")  // you can also use `DispatchQueue.main`, if you want
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
    }
    
    func checkRequestStatus(){
        API.checkRequestStatus{ json, error in
            
            do {
                print("Full checkrequeststatus JSON")
                print(json ?? "json null")
                
                let status = json![Const.STATUS_CODE].boolValue
                let statusMessage = json![Const.STATUS_MESSAGE].stringValue
                if(status){
                    
                    var requestDetail: RequestDetail = RequestDetail()
                    let jsonAry:[JSON]  = json![Const.DATA].arrayValue
                    let defaults = UserDefaults.standard
                    
                    if jsonAry.count > 0 {
                        let driverData = jsonAry[0]
                        if driverData.exists() {
                            
                            defaults.set(driverData["request_id"].stringValue, forKey: Const.Params.REQUEST_ID)
                            defaults.set(driverData["provider_id"].stringValue, forKey: Const.Params.DRIVER_ID)
                            requestDetail.initDriver(rqObj: driverData)
                            
                            
                            let driver_lat: String = requestDetail.s_lat
                            let driver_lon: String = requestDetail.s_lon
                            
                            let driverLati = Double(driver_lat ?? "") ?? 0.0
                            let driverLongi = Double(driver_lon ?? "") ?? 0.0
                            
                            self.driverPoint = CLLocationCoordinate2DMake(driverLati, driverLongi)
                            self.setDriverMarker(latlong: self.driverPoint!)
                            
                        }
                        let invoiceAry:[JSON]  = json![Const.INVOICE].arrayValue
                        if invoiceAry.count > 0 {
                            let invoiceData = invoiceAry[0]
                            print("invoice json")
                            print(invoiceData.rawString() ?? "invoiceData null")
                            defaults.set(invoiceData.rawString(), forKey: Const.CURRENT_INVOICE_DATA)
                            requestDetail.initInvoice(rqObj: invoiceData)
                        }
                    //    self.processStatus(json: json!, tripStatus:requestDetail.tripStatus)
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
                    var msg = json![Const.DATA].rawString()!
                    msg = msg.replacingOccurrences( of:"[{}\",]", with: "", options: .regularExpression)
                    
                    self.view.makeToast(message: msg)
                }
                
            }catch{
                
                print("error in JSONSerialization")
            }
        }
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
        let path:GMSPath = GMSPath(fromEncodedPath: polyStr)!
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 1.0
        polyline.strokeColor = UIColor.black
        polyline.map = gmsMapView // Your map view
        //gmsMapView.bounds
        
        var bounds = GMSCoordinateBounds()
        
        for index:UInt in 1...path.count() {
            bounds = bounds.includingCoordinate(path.coordinate(at: index))
        }
        
        gmsMapView.animate(with: GMSCameraUpdate.fit(bounds))
    }


    func setDriverMarker( latlong: CLLocationCoordinate2D){
        if latlong == nil {
            return
        }
        
        if driver_marker == nil {
            
            driver_marker = GMSMarker(position: latlong)
            driver_marker?.icon = #imageLiteral(resourceName: "car")
            driver_marker?.title = "Driver"
            driver_marker?.map = gmsMapView
        }else{
            driver_marker?.position = latlong
        }
        
    }

    
    func floatyOpened(_ floaty: Floaty) {
        print("Floaty Opened")
    }
    
    func floatyClosed(_ floaty: Floaty) {
        print("Floaty Closed")
    }
    
}

// MARK: - GMSMapViewDelegate
extension MainDriverViewController: GMSMapViewDelegate {
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

// MARK: - CLLocationManagerDelegate
extension MainDriverViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            gmsMapView.isMyLocationEnabled = true
            gmsMapView.settings.myLocationButton = true
            
            //        let position = CLLocationCoordinate2D(latitude: 40.717041, longitude: -73.988007)
            //        let hello = GMSMarker(position: position)
            //        hello.title = "Hello world!"
            //        hello.snippet = "Welcome to my marker"
            //
            //        hello.map = mapView
            
            let pi_lat: String = requestDetail.s_lat
            let pi_lon: String = requestDetail.s_lon
            
            let dr_lat: String = requestDetail.d_lat
            let dr_lon: String = requestDetail.d_lon
            
            let pLati = Double(pi_lat ?? "") ?? 0.0
            let pLongi = Double(pi_lon ?? "") ?? 0.0
            
            let dLati = Double(dr_lat ?? "") ?? 0.0
            let dLongi = Double(dr_lon ?? "") ?? 0.0
            
            piPoint = CLLocationCoordinate2DMake(pLati, pLongi)
            drPoint = CLLocationCoordinate2DMake(dLati, dLongi)
            
            if piPoint != nil && (piPoint?.latitude != 0 && piPoint?.longitude != 0){
                pick_marker = GMSMarker(position: piPoint!)
                pick_marker?.title = "Pickup location"
                //pick_marker?.snippet = self.nearest_eta
                pick_marker?.icon = #imageLiteral(resourceName: "map_pick_marker")
                pick_marker?.map = gmsMapView
            }
            
            
            if drPoint != nil && (drPoint?.latitude != 0 && drPoint?.longitude != 0){
                drop_marker = GMSMarker(position: drPoint!)
                drop_marker?.title = "Drop location"
                //drop_marker?.title = nearest_eta
                drop_marker?.icon = #imageLiteral(resourceName: "map_drop_marker")
                drop_marker?.map = gmsMapView
            }
            
            if piPoint != nil && drPoint != nil{
                self.getPolylineRoute(from: piPoint!, to: drPoint!)
            }
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            gmsMapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
        }
    }
}
*/
    }
}
