
import Foundation
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import CoreLocation


class API{
    
    static let url = "http://104.236.68.155/api/"
    
    static var current_user: User!
    
    
    class func getURL(url: String, query: [String:String] = [:]) -> String{
        
        let query_json = JSON(query)
        let query_string = API.prepareQueryString(json: query_json)
        
        return API.url+url+query_string
    }
    
    
    class func prepareQueryString(json: JSON) -> String{
        
        var query_string: String = "?"
        
        for (key,value):(String, JSON) in json {
            
            query_string = query_string + "&\(key)=\(value)"
        }
        
        return query_string
        
    }
    class func getAppVersion() -> String {
        if let info = Bundle.main.infoDictionary {
            
            let appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown"
            let appBuild = info[kCFBundleVersionKey as String] as? String ?? "Unknown"
            return "\(appVersion).\(appBuild)"
        }
        return "\(Bundle.main.infoDictionary!["CFBundleShortVersionString"] ?? "")"
    }
    
    
    class func getMessageChatApi(request_id: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        let parameters:[String:String] = [ Const.Params.REQUEST_ID: request_id,
                                           Const.Params.DEVICE_TYPE: "ios",
                                           Const.Params.ID : id!,
                                           Const.Params.TOKEN:sessionToken!
            
        ]
        
        //confirm this
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"        ]
        
        Alamofire.request( Const.Url.GET_MESSAGE_API, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completionHandler(json, nil)
            case .failure(let error):
                completionHandler(nil, error)
                
            }
        }
    }
    class func register(frist_name: String,timezone: String,service_type: String,color: String,brand: String,plate_no: String,gender: String, last_name: String,email: String,phonenumber: String, password: String,image: UIImage?=nil,car_image: UIImage?=nil,imagestatus: Bool, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let deviceToken = DATA().getDeviceToken()
        
        
        let parameters:[String:String] = [Const.Params.FIRSTNAME: frist_name,Const.Params.LAST_NAME: last_name, Const.Params.EMAIL: email, Const.Params.PASSWORD: password, Const.Params.DEVICE_TOKEN:deviceToken,Const.Params.GENDER: gender,Const.Params.PLATE_NO:plate_no,Const.Params.BRAND:brand,Const.Params.COLOR:color,Const.Params.SERVICE_TYPE:service_type,Const.Params.TIMEZONE:timezone,Const.Params.PHONE:phonenumber,Const.Params.DEVICE_TYPE:"ios",Const.Params.LOGIN_BY:"manual" ]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        
        
        if imagestatus {
            
            
            let imgData = UIImageJPEGRepresentation(image!, 0.2)!
             let car_imgData = UIImageJPEGRepresentation(car_image!, 0.2)!
            
            Alamofire.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(imgData, withName: Const.Params.PICTURE,fileName: "file.jpg", mimeType: "image/jpg")
                multipartFormData.append(car_imgData, withName: Const.Params.CAR_IMG,fileName: "car.jpg", mimeType: "image/jpg")
                for (key, value) in parameters {
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }
            },
                             to:Const.Url.REGISTER)
            { (result) in
                switch result {
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (progress) in
                        print("Upload Progress: \(progress.fractionCompleted)")
                    })
                    
                    upload.responseJSON { response in
                        print(response.result.value)
                        let json = JSON(response.result.value)
                        completionHandler(json, nil)
                    }
                    
                case .failure(let encodingError):
                    print(encodingError)
                    completionHandler(nil, encodingError)
                    
                }
            }
            
            
            print("image nil")
            
        }else {
            Alamofire.request( Const.Url.REGISTER, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    
                    let json = JSON(value)
                    
                    completionHandler(json, nil)
                    
                    
                case .failure(let error):
                    completionHandler(nil, error)
                    
                }
            }
            
        }
        
        
        
    }
    
    
    
    
    class func googlePlaceAPICall(with apiPath: String, completionHandler: @escaping ([String : AnyObject]?, NSError?) -> ()) {
        
        
        Alamofire.request(apiPath, method: .get, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            //            debugPrint(response)
            
            
            
            switch (response.result) {
            case .success:
                //do json stuff
                
                if let json = response.result.value {
                    //                                            print("JSON: \(json)")
                    
                    completionHandler(json as? [String : AnyObject],nil)
                    
                    
                }
                
                break
            case .failure(let error):
                
                
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                    
                }
                completionHandler(nil,error as NSError)
                
                print("\n\nAuth request failed with error:\n \(error)")
                break
            }
            
            
        }
        
        
        
        
    }
    
    
    
    
    class func signIn(email: String, password: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let deviceToken = DATA().getDeviceToken()
        let parameters:[String:String] = [ Const.Params.EMAIL: email, Const.Params.PASSWORD: password, Const.Params.DEVICE_TOKEN:deviceToken, Const.Params.DEVICE_TYPE: "ios", Const.Params.LOGIN_BY: Const.MANUAL ]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        //API.getURL(url: "user/login")
        print(Const.Url.LOGIN)
        Alamofire.request( Const.Url.LOGIN, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                completionHandler(json, nil)
                
                
            case .failure(let error):
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func getuserDetails(user_Id: String, token: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        print(Const.Url.BASE_URL)
        
        let urlString: String = Const.Url.BASE_URL + "userdetails?" + "id=\(user_Id)" + "&token=\(token)"
        debugPrint(urlString)
        
        Alamofire.request( urlString, method: .get, parameters: nil, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                completionHandler(json, nil)
                
                
            case .failure(let error):
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func getTaxiTypes(completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        print(Const.Url.TAXI_TYPE)
        Alamofire.request( Const.Url.TAXI_TYPE, method: .get, parameters: nil, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                completionHandler(json, nil)
                
                
            case .failure(let error):
                completionHandler(nil, error)
                
            }
        }
    }
    
    
    
    class func getIncomingRequestsInProgress(completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        if id == nil || sessionToken == nil
        {
            return
        }
        
        let parameters:[String:String] = [ Const.Params.ID: id!, Const.Params.TOKEN: sessionToken!, Const.Params.DEVICE_TYPE: "ios"]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        
        
        Alamofire.request( Const.Url.INCOMING_REQUEST_IN_PROGRESS_URL, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                completionHandler(json, nil)
                
                
            case .failure(let error):
                completionHandler(nil, error)
                
            }
        }
    }
    
    
    class func cancelRide(completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        var requestId = "\(DATA().getRequestId())"
        
        let parameters:[String:String] = [ Const.Params.ID: id!, Const.Params.TOKEN: sessionToken!, Const.Params.REQUEST_ID: requestId, Const.Params.DEVICE_TYPE: "ios"]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        Alamofire.request( Const.Url.POST_CANCEL_TRIP_URL, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                completionHandler(json, nil)
                
                
            case .failure(let error):
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func rejectRequest(completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        var requestId = "\(DATA().getIncomingRequestId())"
        //requestId = (requestId ?? "1")
        
        
        let parameters:[String:String] = [ Const.Params.ID: id!, Const.Params.TOKEN: sessionToken!, Const.Params.REQUEST_ID: requestId, Const.Params.DEVICE_TYPE: "ios"]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        Alamofire.request( Const.Url.PROVIDER_REJECTED_URL, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                completionHandler(json, nil)
                
                
            case .failure(let error):
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func acceptRequest(completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        var requestId = "\(DATA().getIncomingRequestId())"
        
        let parameters:[String:String] = [ Const.Params.ID: id!, Const.Params.TOKEN: sessionToken!, Const.Params.REQUEST_ID: requestId, Const.Params.DEVICE_TYPE: "ios"]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        Alamofire.request( Const.Url.PROVIDER_ACCEPTED_URL, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                completionHandler(json, nil)
                
                
            case .failure(let error):
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func checkRequestStatus(completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        var requestId = "\(DATA().getRequestId())"
        
        let parameters:[String:String] = [ Const.Params.ID: id!,
                                           Const.Params.TOKEN: sessionToken!,
                                           Const.Params.REQUEST_ID: requestId,
                                           Const.Params.DEVICE_TYPE: "ios"]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        Alamofire.request( Const.Url.CHECK_REQUEST_STATUS_URL, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completionHandler(json, nil)
            case .failure(let error):
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func updateLocation(lat: String, lon: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        var requestId = "\(DATA().getIncomingRequestId())"
        //requestId = (requestId ?? "1")
        
        
        if let token = sessionToken {
            
            let parameters:[String:String] = [ Const.Params.ID: id!, Const.Params.TOKEN: token,
                                               Const.Params.LATTITUDE: lat,Const.Params.LONGITUDE: lon, Const.Params.DEVICE_TYPE: "ios"]
            
            let headers = [
                "Content-Type": "application/x-www-form-urlencoded"
            ]
            
            Alamofire.request( Const.Url.UPDATE_LOCATION_URL, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    completionHandler(json, nil)
                case .failure(let error):
                    completionHandler(nil, error)
                    
                }
            }
            
            
        }
        
    }
    
    class func providerStarted(completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        var requestId = "\(DATA().getRequestId())"
        
        let parameters:[String:String] = [ Const.Params.ID: id!, Const.Params.TOKEN: sessionToken!, Const.Params.REQUEST_ID: requestId, Const.Params.DEVICE_TYPE: "ios"]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        Alamofire.request( Const.Url.PROVIDER_STARTED_URL, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                completionHandler(json, nil)
                
                
            case .failure(let error):
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func providerArrived(completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        var requestId = "\(DATA().getRequestId())"
        
        let parameters:[String:String] = [ Const.Params.ID: id!, Const.Params.TOKEN: sessionToken!, Const.Params.REQUEST_ID: requestId, Const.Params.DEVICE_TYPE: "ios"]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        Alamofire.request( Const.Url.PROVIDER_ARRIVED_URL, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completionHandler(json, nil)
            case .failure(let error):
                completionHandler(nil, error)
                
            }
        }
    }
    
    
    class func providerServiceStarted(completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        var requestId = "\(DATA().getRequestId())"
        
        let parameters:[String:String] = [ Const.Params.ID: id!, Const.Params.TOKEN: sessionToken!, Const.Params.REQUEST_ID: requestId, Const.Params.DEVICE_TYPE: "ios"]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        Alamofire.request( Const.Url.PROVIDER_SERVICE_STARTED_URL, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completionHandler(json, nil)
            case .failure(let error):
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func providerServiceCompleted(distance: String, duration: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        var requestId = "\(DATA().getRequestId())"
        
        let parameters:[String:String] = [ Const.Params.ID: id!,
                                           Const.Params.TOKEN: sessionToken!,
                                           Const.Params.REQUEST_ID: requestId,
                                           Const.Params.DISTANCE: distance,
                                           Const.Params.TIME: duration,
                                           Const.Params.DEVICE_TYPE: "ios"]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        Alamofire.request( Const.Url.PROVIDER_SERVICE_COMPLETED_URL, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completionHandler(json, nil)
            case .failure(let error):
                completionHandler(nil, error)
                
            }
        }
    }
    
    
    class func checkAvailabilityStatus(completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        let parameters:[String:String] = [ Const.Params.ID: id!,
                                           Const.Params.TOKEN: sessionToken!,
                                           Const.Params.DEVICE_TYPE: "ios"]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"        ]
        
        Alamofire.request( Const.Url.GET_CHECK_AVAILABLE_STATUS_URL, method: .get, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completionHandler(json, nil)
            case .failure(let error):
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func updateAvailabilityStatus(status: String,forceClose : String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        let parameters:[String:String] = [ Const.Params.ID: id!,
                                           Const.Params.TOKEN: sessionToken!,
                                           Const.Params.STATUS: status,
                                           Const.Params.DEVICE_TYPE: "ios",
                                           Const.Params.FORCE_CLOSE:forceClose]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"        ]
        
        
        print(Const.Url.POST_AVAILABILITY_STATUS_URL)
        Alamofire.request( Const.Url.POST_AVAILABILITY_STATUS_URL, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completionHandler(json, nil)
            case .failure(let error):
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func getServerVersionNumber(completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        manager.request( Const.Url.FORCE_UPDATE_URL, method: .get, headers: headers).validate().responseJSON { response in
            switch response.result {
                
            case .success(let value):
                let json = JSON(value)
                completionHandler(json, nil)
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }

    class func deleteProvider(completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        let parameters:[String:String] = [ Const.Params.ID: id!, Const.Params.TOKEN: sessionToken!]
        
        print(parameters)
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        Alamofire.request(Const.Url.DELETE_PROVIDER, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                completionHandler(json, nil)
                
            case .failure(let error):
                print(error.localizedDescription)
                completionHandler(nil, error)
                
            }
        }
    }
    class func providerLogout(completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        let parameters:[String:String] = [ Const.Params.ID: id!, Const.Params.TOKEN: sessionToken!]
        
        print(parameters)
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        manager.request(Const.Url.LOG_OUT, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                completionHandler(json, nil)
                
            case .failure(let error):
                print(error.localizedDescription)
                completionHandler(nil, error)
                
            }
        }
    }
    
    
    class func giveRating(rating:String, comment: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        let requestId = "\(DATA().getRequestId())"
        
        var parameters:[String:String] = [:]
        
        parameters = [ Const.Params.ID: id!,
                       Const.Params.TOKEN: sessionToken!,
                       Const.Params.REQUEST_ID : requestId,
                       Const.Params.COMMENT : comment,
                       Const.Params.RATING : rating,
                       Const.Params.DEVICE_TYPE: "ios" ]
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        Alamofire.request( Const.Url.RATE_USER_URL, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
                
            case .success(let value):
                let json = JSON(value)
                completionHandler(json, nil)
                
            case .failure(let error):
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func postCodConfirmation(completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        var requestId = "\(DATA().getRequestId())"
        
        let parameters:[String:String] = [ Const.Params.ID: id!, Const.Params.TOKEN: sessionToken!, Const.Params.REQUEST_ID: requestId, Const.Params.DEVICE_TYPE: "ios"]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        Alamofire.request( Const.Url.COD_CONFIRM_URL, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completionHandler(json, nil)
            case .failure(let error):
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func getDocs(completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        let parameters:[String:String] = [ Const.Params.ID: id!,
                                           Const.Params.TOKEN: sessionToken!,
                                           Const.Params.DEVICE_TYPE: "ios"]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"        ]
        
        Alamofire.request( Const.Url.GET_DOC, method: .get, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completionHandler(json, nil)
            case .failure(let error):
                completionHandler(nil, error)
            }
        }
    }
    
    class func fetchRideHistory(completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        let parameters:[String:String] = [ Const.Params.ID: id!, Const.Params.TOKEN: sessionToken!, Const.Params.DEVICE_TYPE: "ios"]
        
        print(parameters)
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        Alamofire.request(Const.Url.POST_HISTORY_URL, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                completionHandler(json, nil)
                
            case .failure(let error):
                print(error.localizedDescription)
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func uploadDocument(docId: String, image: UIImage, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        let parameters:[String:String] = [ Const.Params.ID: id!,
                                           Const.Params.TOKEN: sessionToken!,
                                           "document_id": docId,
                                           Const.Params.DEVICE_TYPE: "ios"]
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        let imgData = UIImageJPEGRepresentation(image, 0.2)!
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData, withName: Const.Params.DOC_URL,fileName: "file.jpg", mimeType: "image/jpg")
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        },
                         to:Const.Url.UPLOAD_DOC)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    print(response.result.value)
                    let json = JSON(response.result.value)
                    completionHandler(json, nil)
                }
                
            case .failure(let encodingError):
                print(encodingError)
                completionHandler(nil, encodingError)
                
            }
        }
    }
    
    
    class func updateProfile(firstName: String, lastName: String, gender: String, phone: String, email: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        let parameters:[String:String] = [ Const.Params.ID: id!,
                                           Const.Params.TOKEN: sessionToken!,
                                           Const.Params.FIRSTNAME: firstName,
                                           Const.Params.LAST_NAME: lastName,
                                           Const.Params.GENDER: gender,
                                           Const.Params.EMAIL: email,
                                           Const.Params.PHONE: phone,
                                           Const.Params.DEVICE_TYPE: "ios"]
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        Alamofire.request( Const.Url.UPDATE_PROFILE, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                completionHandler(json, nil)
                
                
            case .failure(let error):
                completionHandler(nil, error)
                
            }
        }
        
    }
    
    class func updateProfileWithImage(firstName: String, lastName: String, gender: String, phone: String, email: String, image: UIImage, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        let parameters:[String:String] = [ Const.Params.ID: id!,
                                           Const.Params.TOKEN: sessionToken!,
                                           Const.Params.FIRSTNAME: firstName,
                                           Const.Params.LAST_NAME: lastName,
                                           Const.Params.GENDER: gender,
                                           Const.Params.EMAIL: email,
                                           Const.Params.PHONE: phone,
                                           Const.Params.DEVICE_TYPE: "ios"]
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        let imgData = UIImageJPEGRepresentation(image, 0.2)!
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData, withName: Const.Params.PICTURE,fileName: "file.jpg", mimeType: "image/jpg")
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        },
                         to:Const.Url.UPDATE_PROFILE)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    print(response.result.value)
                    let json = JSON(response.result.value)
                    completionHandler(json, nil)
                }
                
            case .failure(let encodingError):
                print(encodingError)
                completionHandler(nil, encodingError)
                
            }
        }
    }
    
    class func updateTimeZone(completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let timeZone: String = TimeZone.current.identifier
        print(timeZone)
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        let parameters:[String:String] = [ Const.Params.ID: id!,
                                           Const.Params.TOKEN: sessionToken!,
                                           Const.Params.TIMEZONE: timeZone,
                                           Const.Params.DEVICE_TYPE: "ios"]
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        Alamofire.request( Const.Url.UPDATE_TIMEZONE, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completionHandler(json, nil)
            case .failure(let error):
                completionHandler(nil, error)
                
            }
        }
        
    }
    
    
    class func forgotPassword(email: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        let parameters:[String:String] = [ Const.Params.EMAIL: email,
                                           Const.Params.DEVICE_TYPE: "ios"]
        
        //confirm this
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"        ]
        
        Alamofire.request( Const.Url.FORGOT_PASSWORD, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completionHandler(json, nil)
            case .failure(let error):
                completionHandler(nil, error)
                
            }
        }
    }
    
    
    class func authenticate(authenticate_user: User){
        
        let user_defaults = UserDefaults.standard
        
        
        user_defaults.set(true, forKey: "isloggedin")
        user_defaults.set(authenticate_user.name, forKey: "user_name")
        user_defaults.set(authenticate_user.email, forKey: "user_email")
        user_defaults.set(authenticate_user.id, forKey: "user_id")
        user_defaults.set(authenticate_user.token, forKey: "user_token")
        user_defaults.set(authenticate_user.img_url, forKey: "user_image")
        user_defaults.set(authenticate_user.is_user, forKey: "is_user")
        user_defaults.set(authenticate_user.is_seller, forKey: "is_seller")
        user_defaults.set(authenticate_user.phone, forKey: "phone")
        user_defaults.synchronize()
        
        
        
        
        
        API.loadUser()
        
        
    }
    
    
    class func  isLoggedIn() -> Bool{
        
        let user_defaults = UserDefaults.standard
        let isloggedin: Bool = user_defaults.bool(forKey: "isloggedin")
        
        if(isloggedin){
            return true
        }
        else{
            return false
        }
        
        print("No one logged")
        return false
    }
    
    
    class func loadUser(){
        
        if(API.isLoggedIn()){
            
            let user_defaults = UserDefaults.standard
            
            let name = user_defaults.string(forKey: "user_name")
            let email = user_defaults.string(forKey: "user_email")
            let id = user_defaults.string(forKey: "user_id")
            let token = user_defaults.string(forKey: "user_token")
            let img_url = user_defaults.string(forKey: "user_image")
            
            let is_seller = user_defaults.bool(forKey: "is_seller")
            let is_user = user_defaults.bool(forKey: "is_user")
            let phone = user_defaults.string(forKey: "phone")
            
            let current_user = User(id: id!, name: name!, email: email!, token: token!, phone: phone!)
            
            current_user.is_seller = is_seller
            current_user.is_user = is_user
            
            current_user.img_url = img_url
            
            
            API.current_user = current_user
            
            let nc = NotificationCenter.default // Note that default is now a property, not a method call
            nc.post(name:Notification.Name(rawValue:"MyNotification"),
                    object: nil,
                    userInfo: [:])
            
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            //     appDelegate.setup_pubnub()
            
        }
        
    }
    
    
    class func logout(){
        
        let user_defaults = UserDefaults.standard
        user_defaults.set(false, forKey: "isloggedin")
        user_defaults.set("", forKey: "user_name")
        user_defaults.set("", forKey: "user_email")
        user_defaults.set("", forKey: "user_id")
        user_defaults.set("", forKey: "user_token")
        user_defaults.set("", forKey: "user_image")
        user_defaults.set(false, forKey: "is_user")
        user_defaults.set(false, forKey: "is_seller")
        user_defaults.set("", forKey: "phone")
        user_defaults.synchronize()
        API.current_user = nil
    }
    
    
    
    class func getHeaders(headers: [String:String] = [:]) -> [String:String]{
        
        var new_headers: [String:String] = headers
        let defaults = UserDefaults.standard
        
        if(API.isLoggedIn()){
            
            if let token = defaults.string(forKey: Const.Params.TOKEN) {
                print(token) // Some String Value
                new_headers["Authorization"] = token //API.current_user.token!
            }
        }
        return new_headers
    }
    
    
    
    class func loadActivityIndicator() -> NVActivityIndicatorView{
        
        let activity = NVActivityIndicatorView(frame: CGRect(x:0,y:0,width:0,height:0), type: NVActivityIndicatorType.ballClipRotate, color: UIColor.clear)
        return activity
    }
    
    class func isSuccess(response : JSON) -> Bool {
        do{
            let status: Bool = response[Const.STATUS_CODE].boolValue
            return status
        }catch{
            return false
        }
    }
    
    class func getErrorCode(response : JSON)-> Int {
        do{
            let errorCode: Int = response["error_code"].intValue
            return errorCode
        }catch{
            return 0
        }
        
        return 0
    }
    
    
    class func getRequestId(response : JSON)-> Int {
        do{
            
            let status: Bool = response[Const.STATUS_CODE].boolValue
            if status {
                let jsonAry:[JSON]  = response[Const.DATA].arrayValue
                if jsonAry != nil && jsonAry.count > 0 {
                    let requestData: JSON = jsonAry[0]
                    if requestData.exists() && requestData[Const.Params.REQUEST_ID].exists() {
                        let requestId : Int = requestData[Const.Params.REQUEST_ID].intValue
                        return requestId
                    }
                }
            }
        }catch{
            return Const.NO_REQUEST
        }
        
        return Const.NO_REQUEST
    }
    
    
    
}
