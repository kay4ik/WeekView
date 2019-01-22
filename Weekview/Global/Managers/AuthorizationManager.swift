//
//  AuthorizationManager.swift
//  Weekview
//
//  Created by Kay Boschmann on 27.11.18.
//  Copyright © 2018 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import Foundation
import UserNotifications
import MapKit

class AuthorizationManager {
    
    public static func requestNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge,.alert,.sound,.carPlay], completionHandler: { (didAllowed, error) in })
    }
    
    public static func isLocationAllowed() -> Bool {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            return true
        }
        return false
    }
    
    public static func requestLocation() {
        let authorizationCode = CLLocationManager.authorizationStatus()
        if authorizationCode != .authorizedAlways {
            if Bundle.main.object(forInfoDictionaryKey: "NSLocationAlwaysUsageDescription") != nil {
                CLLocationManager().requestAlwaysAuthorization()
            } else {
                print("No Description provided")
            }
        }
    }
}
