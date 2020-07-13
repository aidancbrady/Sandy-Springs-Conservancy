//
//  Constants.swift
//  Sandy Springs
//
//  Created by aidancbrady on 10/22/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    
    var setLocationNotifications = false
    var window: UIWindow?
    var locationManager: CLLocationManager!
    
    class func getInstance() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func onLaunch() {
        //register for notifications
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .badge, .sound, .carPlay]) {
            (granted, error) in
        }
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        locationManager.pausesLocationUpdatesAutomatically = false
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if !setLocationNotifications {
            let accepted = (status == CLAuthorizationStatus.authorizedWhenInUse || status == CLAuthorizationStatus.authorizedAlways)
            if accepted {
                ParkController.Parks.initLocationUpdates()
                print("Set up location notifications")
            } else {
                print("Failed to set up location notifications")
            }
            
            setLocationNotifications = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Constants.LAST_LOCATION = locations[0]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void) {
        if let parkName = response.notification.request.content.userInfo["PARK"] as? String {
            if self.window!.rootViewController!.presentedViewController != nil {
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let destController = mainStoryboard.instantiateViewController(withIdentifier: "ParkController") as! ParkController
                let menuNavigation = self.window!.rootViewController!.presentedViewController as! MenuNavigation
                
                destController.parkName = parkName
                menuNavigation.setViewControllers([destController], animated: true)
                Utilities.loadPark(menuNavigation)
            } else {
                (self.window!.rootViewController! as! InitController).notificationOpen = parkName
            }
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}

