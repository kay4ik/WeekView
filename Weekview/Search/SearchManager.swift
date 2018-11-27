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
    private let settings = Settings.shared
    
    private init(){}
    class var shared : SearchManager {
        struct Static {
            static let instance : SearchManager = SearchManager()
        }
        return Static.instance
    }
    
    public func present(_ searched: [Reminder]) -> [[Reminder]] {
        var search = searched
        if !settings.showDoneReminders {
            search = filterDonesOut(of: searched)
        }
        
        var present = [[Reminder]]()
        var dates = countDays(search)
        
        var index = 0
        while index < dates.count {
            let abc = search.filter({DateHelper.isSame(date: $0.date, like: dates[index])})
            present.append(abc)
            index += 1
        }
        
        return sort(present)
    }
    
    private func countDays(_ reminders: [Reminder]) -> [Date] {
        var dates = [Date]()
        
        for reminder in reminders {
            if dates.count != 0 {
                if !DateHelper.isSame(date: reminder.date, like: dates.last!) {
                    dates.append(reminder.date)
                }
            }
            else { dates.append(reminder.date) }
        }
        return dates
    }
    
    private func sort(_ search: [[Reminder]]) -> [[Reminder]] {
        return search.sorted(by: {$0.first!.date < $1.first!.date})
    }
    
    private func filterDonesOut(of: [Reminder]) -> [Reminder] {
        return of.filter({$0.done == false})
    }
}
