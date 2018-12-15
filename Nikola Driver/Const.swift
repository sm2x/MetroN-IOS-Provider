//
//  Const.swift
//  Alicia
//
//  Created by Sutharshan on 5/3/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation

class Const {
    
    
    public class Url {
     //static let HOST_URL = "http://nikola.world/"
     static let HOST_URL = "http://46.101.106.16/"
     static let FORCE_UPDATE_URL = "http://nikola.world/get_version"
//    static let HOST_URL = "http://13.228.212.101/"// staging server
//    static let HOST_URL = "http://13.59.95.239/"// local nikola server
    static let SOCKET_URL = "http://46.101.106.16:3000"
    //static let HOST_URL = "http://139.59.46.81/"// PLdeveloping server
    static let BASE_URL = HOST_URL + "providerApi/"
    static let  LOGIN = BASE_URL + "login";
    static let  REGISTER = BASE_URL + "register";
    static let  UPDATE_PROFILE = BASE_URL + "updateProfile";
    static let  FORGOT_PASSWORD = BASE_URL + "forgotpassword";
    static let  TAXI_TYPE = HOST_URL + "serviceList";
    static let  UPDATE_LOCATION_URL = BASE_URL + "locationUpdate";
    static let  INCOMING_REQUEST_IN_PROGRESS_URL = BASE_URL + "incomingRequest";
    static let  CHECK_REQUEST_STATUS_URL = BASE_URL + "requestStatusCheck";
    static let  PROVIDER_ACCEPTED_URL = BASE_URL + "serviceAccept";
    static let  PROVIDER_REJECTED_URL = BASE_URL + "serviceReject";
    static let  PROVIDER_STARTED_URL = BASE_URL + "providerStarted";
    static let  PROVIDER_ARRIVED_URL = BASE_URL + "arrived";
    static let  PROVIDER_SERVICE_STARTED_URL = BASE_URL + "serviceStarted";
    static let  PROVIDER_SERVICE_COMPLETED_URL = BASE_URL + "serviceCompleted";
    static let  RATE_USER_URL = BASE_URL + "rateUser";
    static let  COD_CONFIRM_URL = BASE_URL + "codPaidConfirmation";
    static let  GET_CHECK_AVAILABLE_STATUS_URL = BASE_URL + "checkAvailableStatus?";
    static let  POST_AVAILABILITY_STATUS_URL = BASE_URL + "availableUpdate";
    static let  POST_CANCEL_TRIP_URL = BASE_URL + "cancelrequest";
    static let  POST_HISTORY_URL = BASE_URL + "history";
    static let  GET_DOC = BASE_URL + "documents?";
    static let  UPLOAD_DOC = BASE_URL + "upload_documents";
    static let  USER_MESSAGE_NOTIFY = BASE_URL + "message_notification?";
    static let  UPDATE_TIMEZONE = BASE_URL + "updatetimezone";
     static let LOG_OUT: String = BASE_URL + "logout"
     static let DELETE_PROVIDER: String = BASE_URL + "delete_account"
     
     static let GET_MESSAGE_API = BASE_URL + "message/get";
     
    }
    
           static let googlePlaceAPIkey = "AIzaSyDoujGbr86VY2F6vhh-bzZjsebCFoRn0ik"
    // Placesurls
    static let PLACES_API_BASE = "https://maps.googleapis.com/maps/api/place";
    static let TYPE_AUTOCOMPLETE = "/autocomplete";
    static let TYPE_NEAR_BY = "/nearbysearch";
    static let OUT_JSON = "/json";
    
    // direction API
    static let DIRECTION_API_BASE = "https://maps.googleapis.com/maps/api/directions/json?";
    static let ORIGIN = "origin";
    static let DESTINATION = "destination";
    static let EXTANCTION = "sensor=false&mode=driving&alternatives=true&key=AIzaSyDoujGbr86VY2F6vhh-bzZjsebCFoRn0ik";
    
    
    static let REQUEST_ACCEPT = "REQUEST_ACCEPT";
    static let REQUEST_CANCEL = "REQUEST_CANCEL";
    static let NO_REQUEST = -1;
    static let DRIVER_STATUS = "driverstatus";
        static let DELAY = 0;
    static let TIME_SCHEDULE = 5 * 1000;
    static let DELAY_OFFLINE = 15 * 60 * 1000;
    static let TIME_SCHEDULE_OFFLINE = 15 * 60 * 1000;
    
    static let PLACES_AUTOCOMPLETE_API_KEY = "AIzaSyC5fNTsNIv5Ji8AuOx-rJwouEAreUVC3s0";
    
    // AIzaSyCSYiLzX_yhDwBznjxO2b5tvnKqOIFOkMk // ios api key
    
    
    static let PREF_NAME = "SMARCAR_PRERENCE";
    static let GET: Int = 0;
    static let POST: Int = 1;
    static let TIMEOUT: Int = 20000;
    static let MAX_RETRY: Int = 3;
    static let DEFAULT_BACKOFF_MULT: Float = 1.0;
    
    static let CHOOSE_PHOTO: Int = 100;
    static let TAKE_PHOTO: Int = 101;
    static let PROVIDER_REQUEST_STATUS: String = "provider_request_status";
    static let PROVIDER_INTENT_MESSAGE: String = "provider_intent_message";
    static let CARD: String = "card";
    static let CASH: String = "cod";
    //Provider status
    
    static let IS_PROVIDER_ACCEPTED: Int = 1;
    static let IS_PROVIDER_STARTED: Int = 2;
    static let IS_PROVIDER_ARRIVED: Int = 3;
    static let IS_PROVIDER_SERVICE_STARTED: Int = 4;
    static let IS_PROVIDER_SERVICE_COMPLETED: Int = 5;
    static let IS_USER_RATED: Int = 6;
    
    static let INVOICE = "invoice"
    
    
    static let PROVIDER_STATUS: String = "provider_status";
    static let STATUS: String = "status";
    
    
    static let DEVICE_TYPE_IOS: String = "ios";
    static let SOCIAL_FACEBOOK: String = "facebook";
    static let SOCIAL_GOOGLE: String = "google";
    static let MANUAL: String = "manual";
    static let SOCIAL: String = "social";
    static let REQUEST_DETAIL: String = "requestDetails";
    
    
    static let GOOGLE_MATRIX_URL: String = "https://maps.googleapis.com/maps/api/distancematrix/json?";
    
    // error code
    static let  INVALID_TOKEN: Int = 104
    static let  REQUEST_ID_NOT_FOUND: Int = 408
    static let  INVALID_REQUEST_ID: Int = 101

    
    public class Params {
        static let ID : String = "id";
        static let TOKEN: String = "token";
        static let STATUS: String = "status";
        static let SOCIAL_ID: String = "social_unique_id";
        static let URL: String = "url";
        static let PICTURE: String = "picture";
        static let EMAIL: String = "email";
        static let PASSWORD: String = "password";
        static let REPASSWORD: String = "confirm_password";
        static let FIRSTNAME: String = "first_name";
        static let LAST_NAME: String = "last_name";
        static let PHONE: String = "mobile";
        static let OTP: String = "otp";
        static let SSN: String = "ssn";
        static let DEVICE_TOKEN: String = "device_token";
        static let ICON: String = "icon";
        static let DEVICE_TYPE: String = "device_type";
        static let LOGIN_BY: String = "login_by";
        static let CURRENCY: String = "currency_code";
        static let LANGUAGE: String = "language";
        static let REQUEST_ID: String = "request_id";
        static let GENDER: String = "gender";
        static let COUNTRY: String = "country";
        static let TIMEZONE: String = "timezone";
        static let LATTITUDE: String = "latitude";
        static let LONGITUDE: String = "longitude";
        static let RATING: String = "rating";
        static let SENSOR: String = "sensor";
        static let ORIGINS: String = "origins";
        static let DESTINATION: String = "destinations";
        static let MODE: String = "mode";
        static let TIME: String = "time";
        static let DISTANCE: String = "distance";
        static let DOC_URL: String = "document_url";        
        static let COMMENT = "comment";
        static let ACTIVE = "active";
        static let SERVICE_TYPE = "service_type";
        static let PLATE_NO = "plate_no"
        static let BRAND = "model"
        static let  KEY = "key"
        static let COLOR = "color"
        static let CAR_IMG = "car_image"
        static let SERVICE_TYPE_NAME = "service_type_name";
        static let FORCE_CLOSE: String = "force_close";
        static let APP_VERSION: String = "app_version";
    }
    
    static let CURRENT_REQUEST_DATA = "current_request_data";
    
    static let PI_LATITUDE = "pic_latitude";
    static let PI_LONGITUDE = "pic_longitude";
    static let DR_LATITUDE = "drp_latitude";
    static let DR_LONGITUDE = "drp_longitude";
    
    static let PI_ADDRESS = "pi_address";
    static let DR_ADDRESS = "drp_address";
    
    static let CURRENT_DRIVER_DATA = "current_driver_data";
    static let CURRENT_INVOICE_DATA = "current_invoice_data";
    
    static let CURRENT_ADDRESS = "current_address";
    static let CURRENT_LATITUDE = "current_latitude";
    static let CURRENT_LONGITUDE = "current_longitude";
    
    static let TAXI_LONG_PRESS = "taxi_long_press";
    
    static let STATUS_CODE = "success"    
    static let STATUS_MESSAGE = "text"
    static let DATA = "data"    
    static let ERROR = "error"
    static let IS_RIDE_CANCELLED = "is_cancelled"
    
                                    
    static let Publish_key:String = "pub-c-e19fa9a9-2cc6-4cba-8a75-6b5c26208f5c";
    static let Subscribe_key:String = "sub-c-e268740e-4ec3-11e7-99ed-0619f8945a4f";
    static let CHANNEL_ID:String = "Location";
    
}
