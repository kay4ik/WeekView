//
//  SearchManager.swift
//  Weekview
//
//  Created by Kay Boschmann on 16.11.18.
//  Copyright © 2018 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import Foundation

class SearchManager{
    private let reminderManager = ReminderManager.shared
    
    private init(){}
    class var shared : SearchManager {
        struct Static {
            static let instance : SearchManager = SearchManager()
        }
        return Static.instance
    }
    
    public func present(_ search: [Reminder]) -> [[Reminder]] {
        var present = [[Reminder]]()
        var dates = countDays(search)
        
        var index = 0
        while index < dates.count {
            let abc = search.filter({DateManager.isSame(date: $0.date, like: dates[index])})
            present.append(abc)
            index += 1
        }
        
        return present
    }
    
    public func countDays(_ reminders: [Reminder]) -> [Date] {
        var dates = [Date]()
        
        for reminder in reminders {
            if dates.count != 0 {
                if !DateManager.isSame(date: reminder.date, like: dates.last!) {
                    dates.append(reminder.date)
                }
            }
            else { dates.append(reminder.date) }
        }
        return dates
    }
}
