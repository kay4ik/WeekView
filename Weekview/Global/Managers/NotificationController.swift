//
//  NotificationController.swift
//  Weekview
//
//  Created by Kay Boschmann on 27.11.17.
//  Copyright © 2017 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationController: NSObject, UNUserNotificationCenterDelegate{
    private override init(){}
    class var shared : NotificationController {
        struct Static {
            static let instance : NotificationController = NotificationController()
        }
        return Static.instance
    }
    
    
    //Handle Opening Notification!
    
    //OVERWORK!
    public func newNotify(with reminder: Reminder){
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = "Erinnerung ist abgelaufen!"
        if reminder.location != nil {
            let location = reminder.location
            content.body += "Ort: " + location!.route + ", " + location!.city
        }
        
        let calendar = Calendar.current
        let component = Calendar.Component.self
        let date = reminder.date
        
        var dateInfo = DateComponents()
        dateInfo.year = calendar.component(component.year, from: date)
        dateInfo.month = calendar.component(component.month, from: date)
        dateInfo.day = calendar.component(component.day, from: date)
        dateInfo.hour = calendar.component(component.hour, from: date)
        dateInfo.minute = calendar.component(component.minute, from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
        //identifierer has get changed to Reminder ID
        let request = UNNotificationRequest(identifier: reminder.title, content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
    }
}
