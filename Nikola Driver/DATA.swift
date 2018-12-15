//
//  DATA.swift
//  Nikola
//
//  Created by Sutharshan on 5/31/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation

class DATA {
    
    let USER_ID: String = "id";
    let CLIENT_ID: String = "client_id";
    let EMAIL: String = "email";
    let PASSWORD: String = "password";
    let PICTURE: String = "picture";
    let DEVICE_TOKEN: String = "device_token";
    let SESSION_TOKEN: String = "token";
    let LOGIN_BY: String = "login_by";
    let SOCIAL_ID: String = "social_id";
    public static let PROPERTY_REG_ID: String = "registration_id";
    public static let PROPERTY_APP_VERSION: String = "appVersion";
    private static let PRE_LOAD: String = "preLoad";
    
    let REQ_TIME: String = "req_time";
    let REQUEST_ID: String = "request_id";
    let NAME: String = "name";
    let ACCEPT_TIME: String = "accept_time";
    let CURRENT_TIME: String = "current_time";
    let CURRENCY: String = "currency";
    let LANGUAGE: String = "language";
    let REQUEST_TYPE: String = "type";
    let PAYMENT_MODE: String = "payment_mode";
    
    let INCOMING_REQUEST: String = "incoming_request";
    let INCOMING_REQUEST_ID: String = "incoming_request_id";
    let RIDE_HISTORY_DATA: String = "ride_history_data";
    let RIDE_HISTORY_SELECTED_DATA: String = "ride_history_selected_data";
    
    
    func clearRequestData(){
        putRequestId(reqId: Const.NO_REQUEST)
        putRequestData(request: "")
        putIncomingRequestId(reqId: Const.NO_REQUEST)
        putClientId(customerId: "")
        putRequestTime(reqTime: 0)
        putAcceptTime(acceptTime: 0)
        putCurrentTime(currentTime: 0)
        
    }
    
    func logOut(){
        putUserId(userId: "")
        putSessionToken(token: "")        
    }
    
    func putRequestTime(reqTime: Int64){
        let defaults = UserDefaults.standard
        defaults.set(reqTime, forKey: REQ_TIME)
    }
    
    func putAcceptTime(acceptTime: Int64){
        let defaults = UserDefaults.standard
        defaults.set(acceptTime, forKey: ACCEPT_TIME)
    }
    
    func putCurrentTime(currentTime: Int64){
        let defaults = UserDefaults.standard
        defaults.set(currentTime, forKey: CURRENT_TIME)
    }
    
    func putClientId(customerId: String){
        let defaults = UserDefaults.standard
        defaults.set(customerId, forKey: CLIENT_ID)
    }
    
    func getClientId()->Int{
        let defaults = UserDefaults.standard
        return defaults.integer(forKey: CLIENT_ID)
    }
    
    func putUserId(userId: String){
        let defaults = UserDefaults.standard
        defaults.set(userId, forKey: USER_ID)
    }
    func getUserId()->Int{
        let defaults = UserDefaults.standard
        return defaults.integer(forKey: USER_ID)
    }

    func putSessionToken(token: String){
        let defaults = UserDefaults.standard
        defaults.set(token, forKey: SESSION_TOKEN)
    }
    
    func putRequestId(reqId: Int){
        let defaults = UserDefaults.standard
        defaults.set(reqId, forKey: Const.Params.REQUEST_ID)
    }
    
    
    func getRequestId()->Int{
        let defaults = UserDefaults.standard
        return defaults.integer(forKey: REQUEST_ID)
    }
    
    func putIncomingRequestData(tempRequest: String){
        let defaults = UserDefaults.standard
        defaults.set(tempRequest, forKey: INCOMING_REQUEST)
    }
    
    func getIncomingRequestData()->String{
        let defaults = UserDefaults.standard
        return defaults.string(forKey: INCOMING_REQUEST)!
    }
    
    func putIncomingRequestId(reqId: Int){
        let defaults = UserDefaults.standard
        defaults.set(reqId, forKey: INCOMING_REQUEST_ID)
    }

    func getIncomingRequestId()->Int{
        let defaults = UserDefaults.standard
        return defaults.integer(forKey: INCOMING_REQUEST_ID)
    }
    
    func putRequestData(request: String){
        let defaults = UserDefaults.standard
        defaults.set(request, forKey: Const.CURRENT_REQUEST_DATA)
    }
    
    func getRequestData()->String{
        let defaults = UserDefaults.standard
        return defaults.string(forKey: Const.CURRENT_REQUEST_DATA)!
    }
    
    
    func putDeviceToken(data: String){
        let defaults = UserDefaults.standard
        defaults.set(data, forKey: DEVICE_TOKEN)
    }
    
    func getDeviceToken()->String{
        let defaults = UserDefaults.standard
        if defaults.object(forKey: DEVICE_TOKEN) != nil {
            return defaults.string(forKey: DEVICE_TOKEN)!
        }else {
            return "ssd"
        }
    }
    
    func putRideHistoryData(request: String){
        let defaults = UserDefaults.standard
        defaults.set(request, forKey: RIDE_HISTORY_DATA)
    }
    
    func getRideHistoryData()->String{
        let defaults = UserDefaults.standard
        if defaults.object(forKey: RIDE_HISTORY_DATA) != nil {
            return defaults.string(forKey: RIDE_HISTORY_DATA)!
        }else {
            return ""
        }
    }
    
    func putRideHistorySelectedData(request: String){
        let defaults = UserDefaults.standard
        defaults.set(request, forKey: RIDE_HISTORY_SELECTED_DATA)
    }
    
    func getRideHistorySelectedData()->String{
        let defaults = UserDefaults.standard
        if defaults.object(forKey: RIDE_HISTORY_DATA) != nil {
            return defaults.string(forKey: RIDE_HISTORY_SELECTED_DATA)!
        }else {
            return ""
        }
    }

    
}
