//
//  RideHistoryItem.swift
//  Nikola
//
//  Created by Sutharshan Ram on 15/07/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import SwiftyJSON

class RideHistoryItem {
    
    var request_id: String = ""
    var date: String = "", user_name: String = "", picture: String = "", total: String = "", taxi_name: String = "", s_address: String = "", d_address: String = "", map_image: String = "", base_price: String = "", distance_travel: String = "", total_time: String = "", time_price: String = "", distance_price: String = "", tax_price: String = "", min_price: String = "", booking_fee: String = ""
    
    var jsnObj: JSON!
    
    init(jsonObj: JSON) {
        request_id = jsonObj["request_id"].stringValue
        date = jsonObj["date"].stringValue
        user_name = jsonObj["user_name"].stringValue
        picture = jsonObj["picture"].stringValue
       
        if let totalFare = Double(jsonObj["total"].stringValue) {
            total = String(format: "%.1f",totalFare)
        } else {
           total = jsonObj["total"].stringValue
        }
        taxi_name = jsonObj["taxi_name"].stringValue
        s_address = jsonObj["s_address"].stringValue
        d_address = jsonObj["d_address"].stringValue
        
        map_image = jsonObj["map_image"].stringValue
        if let basepriceItem = Double(jsonObj["base_price"].stringValue) {
            
            base_price = String(format: "%.1f",basepriceItem)
        } else {
            base_price = jsonObj["base_price"].stringValue
        }
        
        if let distanceTravel = Double(jsonObj["distance_travel"].stringValue) {
            
            distance_travel = String(format: "%.1f",distanceTravel)
        } else {
            distance_travel = jsonObj["distance_travel"].stringValue
        }
        if let totalTime = Double(jsonObj["total_time"].stringValue) {
            
            total_time = String(format: "%.2f",totalTime)
        } else {
            total_time = jsonObj["total_time"].stringValue
        }
        if let timePrice = Double(jsonObj["time_price"].stringValue) {
            
            time_price = String(format: "%.2f",timePrice)
        } else {
            time_price = jsonObj["time_price"].stringValue
        }
        
        if let timePrice = Double(jsonObj["distance_price"].stringValue) {
            distance_price = String(format: "%.2f",timePrice)
        } else {
           distance_price = jsonObj["distance_price"].stringValue
        }
        
        if let timePrice = Double(jsonObj["tax_price"].stringValue) {
            tax_price = String(format: "%.2f",timePrice)
        } else {
            tax_price = jsonObj["tax_price"].stringValue
        }
        
        if let timePrice = Double(jsonObj["min_price"].stringValue) {
            min_price = String(format: "%.2f",timePrice)
        } else {
            min_price = jsonObj["min_price"].stringValue
        }
       
        if let timePrice = Double(jsonObj["booking_fee"].stringValue) {
            booking_fee = String(format: "%.2f",timePrice)
        } else {
            booking_fee = jsonObj["booking_fee"].stringValue
        }
        
        jsnObj = jsonObj
    }

}
