//
//  NotificationController.swift
//  Weekview
//
//  Created by Kay Boschmann on 27.11.17.
//  Copyright © 2017 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation

class NotificationController: NSObject{
    private override init(){}
    class var shared : NotificationController {
        struct Static {
            static let instance : NotificationController = NotificationController()
        }
        return Static.instance
    }
    
    private var reminder: Reminder!
    private let repeating = false
    
    public func create(from reminder: Reminder, triggeredByLocation locationTrigger: Bool) {
        self.reminder = reminder
        let content: UNNotificationContent = setupContent()
        let trigger = setupTrigger(locationTrigger)
        let request = UNNotificationRequest(identifier: reminder.id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    private func setupContent() -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        if reminder.isNoticeSet() {
            content.body = reminder.notice
        }
        else {
            content.body = reminder.getDateAsString()
        }
        
        return content
    }
    
    private func setupTrigger(_ type: Bool) -> UNNotificationTrigger {
        if type {
            //Implement Region Notification
            return UNLocationNotificationTrigger(region: CLRegion(), repeats: repeating)
        }
        return UNCalendarNotificationTrigger(dateMatching: reminder!.date.components, repeats: repeating)
    }
}
