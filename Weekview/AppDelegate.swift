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
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import AppCenterDistribute

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
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
        center.delegate = self
        settingController.setupRuntime()
        
        #if DEBUG
        MSAppCenter.start("951828f7-de3b-4fa0-b337-89681af90d70", withServices: [MSAnalytics.self, MSCrashes.self])
        #else
        MSAppCenter.start("951828f7-de3b-4fa0-b337-89681af90d70", withServices: [MSAnalytics.self, MSCrashes.self, MSDistribute.self])
        #endif
        
        MSDistribute.setDelegate(self)
        MSDistribute.setEnabled(true)
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        rManager.save()
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let homeNav = storyBoard.instantiateViewController(withIdentifier: "homeNav") as! UINavigationController
        
        WVNotification.tapped = true
        WVNotification.id = response.notification.request.identifier
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = homeNav
        self.window?.makeKeyAndVisible()
    }
}
extension AppDelegate: MSDistributeDelegate{
    func distribute(_ distribute: MSDistribute!, releaseAvailableWith details: MSReleaseDetails!) -> Bool {
        // Your code to present your UI to the user, e.g. an UIAlertController.
        let alertController = UIAlertController(title: "Update available.",
                                                message: "Do you want to update?",
                                                preferredStyle:.alert)
        
        alertController.addAction(UIAlertAction(title: "Update", style: .cancel) {_ in
            MSDistribute.notify(.update)
        })
        
        alertController.addAction(UIAlertAction(title: "Postpone", style: .default) {_ in
            MSDistribute.notify(.postpone)
        })
        
        // Show the alert controller.
        self.window?.rootViewController?.present(alertController, animated: true)
        return true;
    }
}
