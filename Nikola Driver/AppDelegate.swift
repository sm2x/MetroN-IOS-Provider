//
//  AppDelegate.swift
//  Nikola Driver
//
//  Created by Sutharshan on 6/14/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Firebase
import NotificationCenter
import UserNotifications
import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var finished : Bool = false
    override init() {
        super.init()
        UIFont.overrideInitialize()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])

        // Override point for customization after application launch.
        UIApplication.shared.isStatusBarHidden = false
        
        FirebaseApp.configure()
//        GMSServices.provideAPIKey("AIzaSyCVmS_V5hGTX2Yj0T0aFcdElDyEliaT6ys")
//        GMSPlacesClient.provideAPIKey("AIzaSyCVmS_V5hGTX2Yj0T0aFcdElDyEliaT6ys")
        GMSServices.provideAPIKey("AIzaSyDoujGbr86VY2F6vhh-bzZjsebCFoRn0ik")
        GMSPlacesClient.provideAPIKey("AIzaSyDoujGbr86VY2F6vhh-bzZjsebCFoRn0ik")
        
        UIApplication.shared.registerForRemoteNotifications()
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self //DID NOT WORK WHEN self WAS MyOtherDelegateClass()
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            // Enable or disable features based on authorization.
            if granted {
                // update application settings
            }
        }
        
//        let storyboard = UIStoryboard(name: "Splash", bundle: nil)
//        
//        let initialViewController = storyboard.instantiateViewController(withIdentifier: "SplashVC") as! SplashVC
//        
//        self.window?.rootViewController = initialViewController
//        self.window?.makeKeyAndVisible()

        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
        
        let signInViewController = storyboard.instantiateViewController(withIdentifier: "GetStartedNavigationController")
        
        
        let user_defaults = UserDefaults.standard
        let token = user_defaults.string(forKey: Const.Params.TOKEN)
        
        if (token ?? "").isEmpty  {
            self.window?.rootViewController = signInViewController
        }else{
            self.window?.rootViewController = mainViewController
        }
        self.window?.makeKeyAndVisible()
        registerForPushNotifications()
        
        application.applicationIconBadgeNumber = 0

        return true
    }
    
    func checkAppVersion() {
        API.getServerVersionNumber(){ json, error in
            
            if let error = error {
                
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    
                    let status = json[Const.STATUS_CODE].boolValue
                    
                    if(status){
                        
                        let forceUpdateStatus = json["success"].boolValue
                        
                        if(forceUpdateStatus)
                        {
                            let info = Bundle.main.infoDictionary
                            let currentVersion = info!["CFBundleShortVersionString"] as? String
                            let serverVersion = json["ios_driver_version"].stringValue
                            if(serverVersion.doubleValue > (currentVersion?.doubleValue)!)
                            {
                                self.popupUpdateDialogue(serverVersion)
                                
                            }
                        }
                        
                    }
                    
                    
                }else {
                    
                    
                    debugPrint("Invalid Json")
                }
                
            }
            
            
        }
        
        
        
    }
    func popupUpdateDialogue(_ serverVersion : String){
        
        
        var alertMessage = ""
        let lang = UserDefaults.standard.string(forKey: "currentLocalization")
        if (lang == "nb")
        {
            alertMessage = String(format: "Oppdatering %@ er tilgjengelig i app store.", serverVersion);
        }
        else{
            alertMessage = String(format: "Version %@ is available on App store.", serverVersion);
        }
        
        
        let alert = UIAlertController(title: "New version".localized(), message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okBtn = UIAlertAction(title: "Update".localized(), style: .default, handler: {(_ action: UIAlertAction) -> Void in
            if let url = URL(string: "https://itunes.apple.com/us/app/prai-partner/id1355386101?ls=1&mt=8"),
                UIApplication.shared.canOpenURL(url){
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        })
        let noBtn = UIAlertAction(title:"Skip this Version" , style: .destructive, handler: {(_ action: UIAlertAction) -> Void in
        })
        alert.addAction(okBtn)
        // alert.addAction(noBtn)
        
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        // Print notification payload data
        print("Push notification received: \(data)")
        
        let aps = data[AnyHashable("aps")]!
        
        print(aps)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent: UNNotification,
                                withCompletionHandler: @escaping (UNNotificationPresentationOptions)->()) {
        withCompletionHandler([.alert, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive: UNNotificationResponse,
                                withCompletionHandler: @escaping ()->()) {
        withCompletionHandler()
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        SocketIOManager.sharedInstance.closeConnection()
        

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        SocketIOManager.sharedInstance.establishConnection()
        checkAppVersion()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        finished = false
        updateAvailability(status: "0")
        while !finished {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode,
                                before: NSDate.distantFuture)
        }
        
        

    }
    func updateAvailability(status: String){
        
        
        API.updateAvailabilityStatus(status : status,forceClose: "1",  completionHandler: { json, error in
            
            
            if let error = error {
                //self.hideLoader()
                self.finished = true
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    self.finished = true
                    var active : Int = 0
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status){
                        print(json ?? "error in checkAvailability json")
                        
                        if json["active"].exists() && json["active"].stringValue != "" {
                            let activeString: String = json["active"].stringValue
                            active = Int(activeString)!
                        }
                        
                    }else{
                        print(json ?? "error in providerStarted json")
                        print(statusMessage)
                        print(json ?? "json empty")
                    }
                    
                }else{
                    self.finished = true
                    //self.hideLoader()
                    debugPrint("Invalid JSON :(")
                }
                
                
            }
            
            
        })
        
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("didRecieve->\(dump(userInfo))")
    }
    
//    func userNotificationCenter(center: UNUserNotificationCenter, willPresentNotification notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void)
//    {
//        completionHandler([UNNotificationPresentationOptions.alert,UNNotificationPresentationOptions.sound,UNNotificationPresentationOptions.badge])
//    }
    
    
    /** Register for remote notifications to get an APNs token to use for registration to GCM */
    func registerForRemoteNotifications(_ application: UIApplication) {
        if #available(iOS 8.0, *) {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            // Fallback
            let types: UIRemoteNotificationType = [.alert, .badge, .sound]
            application.registerForRemoteNotifications(matching: types)
        }
        
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
    }
    
    //    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    //
    //        return SDKApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    //
    //    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        DATA().putDeviceToken(data: token)
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    

}

extension String {
    var doubleValue: Double {
        return (self as NSString).doubleValue
    }
}
extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    } }
