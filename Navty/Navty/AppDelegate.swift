//
//  AppDelegate.swift
//  Navty
//
//  Created by Edward Anchundia on 2/28/17.
//  Copyright © 2017 Edward Anchundia. All rights reserved.
//

import CoreLocation
import UIKit
import GoogleMaps
import Firebase
import GooglePlaces
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()
    let messageComposer = MessageComposer()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FIRApp.configure()
        registerForRemoteNotification()
        GMSServices.provideAPIKey("AIzaSyCbkeAtt4S2Cfkji1Z4SBY-TliAQ6QinDc")
        //GMSPlacesClient.provideAPIKey("AIzaSyCbkeAtt4S2Cfkji1Z4SBY-TliAQ6QinDc")
        GMSPlacesClient.provideAPIKey("AIzaSyBqaampQDtShdJer3y91Slz5uiYJhtHsIQ")
//        let navigationMapView = NavigationMapViewController()
//        let navController = UINavigationController(rootViewController: navigationMapView)
        
//        let userdefaults = UserDefaults.standard
//        UNUserNotificationCenter.current().delegate = self
       
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        

        let navController = UINavigationController(rootViewController: SplashScreenViewController())
        self.window?.rootViewController = navController
  
        
        self.window?.makeKeyAndVisible()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        
        
        let actionOne = UNNotificationAction(identifier: "agree", title: "Ok", options: [.foreground])
        let actionTwo = UNNotificationAction(identifier: "disagree", title: "No", options: [.foreground])
        let category = UNNotificationCategory(identifier: "myCategory", actions: [actionOne, actionTwo], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
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
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
    func registerForRemoteNotification() {
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                if error == nil{
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func handleEvent(forRegion region: CLRegion!) {
        
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//        let newTrigger = UNLocationNotificationTrigger(region: region, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = "Text Message"
        content.body = "Do you want to notice your arrival to your friends?"
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "myCategory"
        
        
        if let path = Bundle.main.path(forResource: "Navty_Plain_logo", ofType: "png") {
            let url = URL(fileURLWithPath: path)
            
            do {
                let attachment = try UNNotificationAttachment(identifier: "logo", url: url, options: nil)
                content.attachments = [attachment]
            } catch {
                print("The attachment was not loaded.")
            }
        }
        
        let request = UNNotificationRequest(identifier: "Destination", content: content, trigger: trigger)
//        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request) {(error) in
           
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }
        
        
//        
//        let alert = UIAlertController(title: "In the Geo", message: "It worked?", preferredStyle: UIAlertControllerStyle.alert)
//        let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (action) -> Void in
//            
//            if (self.messageComposer.canSendText()) {
//                
//                let messageComposeVC = self.messageComposer.configuredMessageComposeViewController()
//                alert.dismiss(animated: true, completion: {
//                    
//                    self.window?.rootViewController?.present(messageComposeVC, animated: true, completion: nil)
//                })
//            }
//        }
//        alert.addAction(ok)
//        self.window?.rootViewController?.present(alert, animated: true, completion: nil) 
//
        
       
    }
    
   

}

extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region)
        }
    }
    
}


extension AppDelegate: UNUserNotificationCenterDelegate {
    
    
    
    func userNotificationCenter(_: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // some other way of handling notification
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        
        switch response.actionIdentifier {
        case "agree":
            
            //
            if (self.messageComposer.canSendText()) {
                
                let messageComposeVC = self.messageComposer.configuredMessageComposeViewController()
                
                self.window?.rootViewController?.present(messageComposeVC, animated: true, completion: nil)
                
                
            }else{
                print("Can not present the View Controller")
            }
            
            //present(DetailViewController(), animated: true, completion: nil)
        //imageView.image = UIImage(named: "firstGuy")
        case "disagree":
            print("I disagree")
        default:
            break
        }
        
        completionHandler()
        
    }
}
