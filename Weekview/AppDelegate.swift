//
//  AppDelegate.swift
//  Weekview
//
//  Created by Kay Boschmann on 05.09.17.
//  Copyright © 2017 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    let notificationController = NotificationController.shared
    let rManager = ReminderManager.shared
    let settingController = Settings.shared
    
    var window: UIWindow?

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        GMSPlacesClient.provideAPIKey("AIzaSyBf8eIYZKlOfgE8av5Hn9gDwOGPvdg7NSM")
        GMSServices.provideAPIKey("AIzaSyAsP7z89MTifodIcLB73D2ZdWumWvgol40")
        
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        rManager.load()
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge,.alert,.sound,.carPlay]) { (didAllowed, error) in
        }
        let center = UNUserNotificationCenter.current()
        center.delegate = notificationController
        settingController.setupRuntime()
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        rManager.save()
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}
