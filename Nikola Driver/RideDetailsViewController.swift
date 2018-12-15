//
//  RideDetailsViewController.swift
//  Nikola
//
//  Created by Sutharshan Ram on 31/07/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import SwiftyJSON
import AlamofireImage
import Toucan
import Localize_Swift


class RideDetailsViewController: UIViewController {
    
    @IBOutlet weak var receipt: UILabel!
    
    
    @IBOutlet weak var basefare: UILabel!
    
    
    @IBOutlet weak var minimum: UILabel!
    
    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var distance: UILabel!
    
    @IBOutlet weak var bookingfee: UILabel!
    
    @IBOutlet weak var servicetax: UILabel!
    
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var mapImageView: UIImageView!
    
    @IBOutlet weak var dateTime: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var carTypeLabel: UILabel!
    
    @IBOutlet weak var fromLabel: UILabel!
    
    @IBOutlet weak var toLabel: UILabel!
    
    @IBOutlet weak var driverImage: UIImageView!
    
    @IBOutlet weak var tripWithLabel: UILabel!
    
    @IBOutlet weak var baseFareLabel: UILabel!
    
    @IBOutlet weak var minFareLabel: UILabel!
    
    @IBOutlet weak var timeFareLabel: UILabel!
    
    @IBOutlet weak var distanceFareLabel: UILabel!
    
    @IBOutlet weak var bookingFeeLabel: UILabel!
    
    @IBOutlet weak var serviceTaxLabel: UILabel!
    
    @IBOutlet weak var totalFareLabel: UILabel!
    
    @IBOutlet weak var carReceiptLabel: UILabel!
    
    //var ride : RideHistoryItem? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        basefare.text = "Base Fare".localized()
        minimum.text = "Minimim Fare".localized()
        time.text = "Time".localized()
        distance.text = "Distance".localized()
        bookingfee.text = "Booking Fee".localized()
        servicetax.text = "Service Tax".localized()
        total.text = "TOTAL".localized()
        
        
        let jsnRaw: String = DATA().getRideHistorySelectedData()
        let jsnObj: JSON = JSON.init(parseJSON: jsnRaw)
        
        var ride : RideHistoryItem = RideHistoryItem.init(jsonObj: jsnObj)
        
        print(ride.map_image)
        print(ride.picture)
        
        let size = CGSize(width: 100.0, height: 100.0)
        let filter = AspectScaledToFillSizeCircleFilter(size: size)
        
        
        if !((ride.map_image ).isEmpty)
        {
            let mapString: String = (ride.map_image)
            
            //mapString.stringb
            
            let encodedHost = mapString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            
            let words:[String] = mapString.components(separatedBy: "staticmap?")
            print(words)
            
            let url2 = URL(string: mapString)
            
            
            if let correctedAddress = words[1].addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                let properUrl = URL(string: "http://maps.googleapis.com/maps/api/staticmap?\(correctedAddress)"){
                print(properUrl)
                
                
                
                
                //let url = URL(string: mapString)!
                _ = UIImage(named: "ellipse_contacting")!
                
                mapImageView?.af_setImage(withURL: properUrl)
                //placeholderImage: placeholderImage,
            }
        }else{
            mapImageView.image = Toucan(image: UIImage(named: "taxi")!).maskWithEllipse().image
        }
        
        
        
        if !((ride.picture ).isEmpty)
        {
            
            let url = URL(string: (ride.picture))!
            let placeholderImage = UIImage(named: "ellipse_contacting")!
            
            driverImage?.af_setImage(
                withURL: url,
                placeholderImage: placeholderImage,
                filter: filter)
        }else{
            driverImage.image = Toucan(image: UIImage(named: "taxi")!).maskWithEllipse().image
        }
        
        dateTime.text = ride.date
        amountLabel.text = "$ \(ride.total)"
        carTypeLabel.text = "Car type \(ride.taxi_name)"
        fromLabel.text = "\(ride.s_address)"
        toLabel.text = "\(ride.d_address)"
        
        tripWithLabel.text = "Your trip with \(ride.user_name)"
        
        
        carReceiptLabel.text = "\(ride.taxi_name) Receipt"
        
        baseFareLabel.text = "$\(ride.base_price as String)"
        minFareLabel.text = "$\(ride.min_price)"
        timeFareLabel.text = "$\(ride.time_price) / \(ride.total_time) mins"
        distanceFareLabel.text = "$\(ride.distance_price) / \(ride.distance_travel) miles"
        bookingFeeLabel.text = "$\(ride.booking_fee)"
        serviceTaxLabel.text = "$\(ride.tax_price)"
        
        totalFareLabel.text = "$\(ride.total)"
        
        
    }
    
    
    func UTCToLocal(date:String) -> String {
        let dateFormator = DateFormatter()
        dateFormator.dateFormat = "H:mm:ss"
        dateFormator.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormator.date(from: date)
        dateFormator.timeZone = TimeZone.current
        dateFormator.dateFormat = "h:mm a"
        
        return dateFormator.string(from: dt!)
    }
    
}
