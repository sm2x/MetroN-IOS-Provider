//
//  RequestDetail.swift
//  Nikola
//
//  Created by Sutharshan on 5/27/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import SwiftyJSON

class RequestDetail {
    var requestId: Int = 0;
    var tripStatus: Int = 0;
    var driverStatus: Int = 0;
    var driver_name : String = "", driver_picture : String = "", user_picture : String = "", user_name : String = "", requst_id : String = "",driver_mobile : String = "", driver_rating : String = "",driver_id : String = "",vehical_img : String = "";
    var s_lat: String = "", s_lon: String = "", d_lat: String = "", d_lon: String = "", s_address: String = "", d_address: String = "";
    var driver_latitude: Double = 0.0,driver_longitude: Double = 0.0;
    var request_type: String = "",no_tolls: String = "";
    var trip_time: String = "",trip_distance: String = "",trip_total_price: String = "",trip_base_price: String = "",payment_mode: String = "";
    
    var serviceType : String = ""
    var timeLeft: Int = 0, jobStatus: Int = 0, onlinejobStatus: Int = 0
    
    var trip_distance_unit : String = ""
    
    
    var startTime : Int64 = 0
    
    var time : String = "",distance : String = "",unit : String = "",treatmentfee : String = "",medicinefee : String = "",date : String = "",total : String = "",bookingPrice : String = "",distanceCost : String = "",timecost : String = "",payment_type : String = "",referralBonus : String = "",promoBonus : String = "",user_id : String = ""
    
    var clientName : String = "",clientProfile : String = "",clientLatitude: String = "", clientLongitude: String = "",clientPhoneNumber: String = "",pricePerDistance: String = "", pricePerTime: String = "",userRating: String = ""
    
    var client_rating : Int64 = 0
    var status : String = ""
    var providerStatus : Int = 0
    var typePicture : String = ""
    var clientId : String = ""
    var hourly_package_details : String = ""
    var number_hours : String = ""
    var request_status_type : String = ""
    var time_left_to_respond : Int = 0
    
    
    init() {
    
    }
    
    
    func initRequest(rqObj: JSON) {
        
        if rqObj["provider_status"].exists() {
        providerStatus = rqObj["provider_status"].intValue
        }
        
        if rqObj["status"].exists() {
            status = rqObj["status"].stringValue
        }
        
        if rqObj["user_picture"].exists() && rqObj["user_picture"].stringValue != "null"{
            user_picture = rqObj["user_picture"].stringValue
        }
        if rqObj["user_name"].exists() && rqObj["user_name"].stringValue != "null"{
            user_name = rqObj["user_name"].stringValue
        }
        
        
        if rqObj["request_status_type"].exists() {
            request_status_type = rqObj["request_status_type"].stringValue
            
            if(request_status_type == "2"){
                number_hours = rqObj["hourly_package_details"]["number_hours"].stringValue
            }
        }
        
        if rqObj["time_left_to_respond"].exists() {
            time_left_to_respond = rqObj["time_left_to_respond"].intValue
        }
        

        user_id = rqObj["user_id"].stringValue
        clientPhoneNumber = rqObj["user_mobile"].stringValue
        no_tolls = rqObj["number_tolls"].stringValue
        requestId = rqObj["request_id"].intValue
        driver_rating = rqObj["rating"].stringValue
        
        s_address = rqObj["s_address"].stringValue
        d_address = rqObj["d_address"].stringValue
        
        s_lat = rqObj["s_latitude"].stringValue
        s_lon = rqObj["s_longitude"].stringValue
        d_lat = rqObj["d_latitude"].stringValue
        d_lon = rqObj["d_longitude"].stringValue
        
        serviceType = rqObj["service_type_name"].stringValue
        userRating = rqObj["user_rating"].stringValue
        
        if rqObj["driver_latitude"].exists() && rqObj["driver_latitude"].stringValue != "null" {
            driver_latitude = rqObj["driver_latitude"].doubleValue
        }
        
        if rqObj["driver_longitude"].exists() && rqObj["driver_longitude"].stringValue != "null" {
            driver_longitude = rqObj["driver_longitude"].doubleValue
        }
        
        vehical_img = rqObj["type_picture"].stringValue
    }
    
    func initInvoice(rqObj: JSON) {
        if valueOk(key: "total_time", rqObj: rqObj){
            if let tripDistance = Double(rqObj["total_time"].stringValue) {
                
                trip_time = String(format: "%.2f",tripDistance)
            } else {
               trip_time = rqObj["total_time"].stringValue
            }
            
        }
        if valueOk(key: "base_price", rqObj: rqObj){
            if let tripDistance = Double(rqObj["base_price"].stringValue) {
                
                trip_base_price = String(format: "%.2f",tripDistance)
            } else {
                trip_base_price = rqObj["base_price"].stringValue
            }
            
        }
   
        
        if valueOk(key: "payment_mode", rqObj: rqObj){
            payment_mode = rqObj["payment_mode"].stringValue
        }
        //trip_base_price = rqObj["base_price"].stringValue
        if valueOk(key: "total", rqObj: rqObj){
            
            if let tripDistance = Double(rqObj["total"].stringValue) {
                
                trip_total_price = String(format: "%.2f",tripDistance)
            } else {
                trip_total_price = rqObj["total"].stringValue
            }
        }
        if valueOk(key: "distance_travel", rqObj: rqObj){
            
            if let tripDistance = Double(rqObj["distance_travel"].stringValue) {
                
                trip_distance = String(format: "%.2f",tripDistance)
            } else {
               trip_distance = rqObj["distance_travel"].stringValue
            }
           
        }
        if valueOk(key: "number_tolls", rqObj: rqObj){
            no_tolls = rqObj["number_tolls"].stringValue
        }
        
        if valueOk(key: "request_status_type", rqObj: rqObj){
            request_status_type = rqObj["request_status_type"].stringValue
        }
        if valueOk(key: "user_id", rqObj: rqObj){
            user_id = rqObj["user_id"].stringValue
        }
        if valueOk(key: "user_name", rqObj: rqObj){
            user_name = rqObj["user_name"].stringValue
        }
        if valueOk(key: "picture", rqObj: rqObj){
            clientProfile = rqObj["picture"].stringValue
        }
        if valueOk(key: "user_mobile", rqObj: rqObj){
            clientPhoneNumber = rqObj["user_mobile"].stringValue
        }
        
        if valueOk(key: "d_latitude", rqObj: rqObj){
            d_lat = rqObj["d_latitude"].stringValue
        }
        if valueOk(key: "d_longitude", rqObj: rqObj){
            d_lon = rqObj["d_longitude"].stringValue
        }
        if valueOk(key: "type_picture", rqObj: rqObj){
            typePicture = rqObj["type_picture"].stringValue
        }
        
        if valueOk(key: "distance_unit", rqObj: rqObj){
            trip_distance_unit = rqObj["distance_unit"].stringValue
        }

        
        
        
        
//        requestId = rqObj["request_id"].intValue
//        providerStatus = rqObj["provider_status"].intValue
        
    }
    
    func valueOk(key: String, rqObj: JSON) -> Bool {
        if rqObj[key].exists() && rqObj[key].stringValue != "null" {
            return true
        }else{
            return false
        }
    }
    
    func getStaticMapUrl()-> String {
        let staticMapUrl: String = "http://maps.google.com/maps/api/staticmap?center=" + s_lat + "," + s_lon + "&markers=" + s_lat + "," + s_lon + "&zoom=14&size=270x270&sensor=false";
        
        return staticMapUrl
    }
    
}
