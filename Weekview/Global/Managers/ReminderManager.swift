//
//  ReminderManager.swift
//  Weekview
//
//  Created by Kay Boschmann on 31.10.18.
//  Copyright © 2018 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import Foundation

class ReminderManager {
    
    private var reminders = Set<Reminder>()
    private let settings = Settings.shared
    
    private init(){}
    class var shared : ReminderManager {
        struct Static {
            static let instance : ReminderManager = ReminderManager()
        }
        return Static.instance
    }
    
    //Manage List
    public func insert(_ reminder: Reminder) {
        reminders.insert(reminder)
    }
    
    public func remove(_ reminder: Reminder) {
        reminders.remove(reminder)
    }
    
    public func update(_ reminder: Reminder) {
        let id = reminder.id
        let old = reminders.filter({$0.id == id}).first! as Reminder
        remove(old)
        insert(reminder)
    }
    
    //(Un)Finish Reminders
    public func finish(_ reminder: Reminder) {
        let id = reminder.id
        reminders.filter({$0.id == id}).first!.done = true
    }
    
    public func unfinish(_ reminder: Reminder) {
        let id = reminder.id
        reminders.filter({$0.id == id}).first!.done = false
    }
    
    
    // MARK: - Data of CalendarView
    public func getAll(of date: Date, wichAreDone done: Bool?) -> [Reminder]{
        var value: [Reminder]
        if done != nil {
            value = reminders.filter({DateHelper.isSame(date: date, like: $0.date) && $0.done == done})
        } else {
            value = reminders.filter({DateHelper.isSame(date: date, like: $0.date)})
        }
        value = sort(value)
        return value
    }
    
    public func getSeperatedLists(of: Date) -> [[Reminder]] {
        return [getAll(of: of, wichAreDone: false), getAll(of: of, wichAreDone: true)]
    }
    
    public func getAllReminders() -> [Reminder] {
        return sort(Array(reminders))
    }
    
    private func sort(_ list: [Reminder]) -> [Reminder]{
        var value = list
        if settings.sortOnTime{
            value.sort(by: {$0.date < $1.date})
        } else {
            value.sort(by: {$0.priority > $1.priority})
        }
        return value
    }
    
    public func getReminder(with id: String) -> Reminder {
        return reminders.filter({$0.id == id}).first!
    }
    
    public func isThereA(reminder at: Date) -> Int {
        let date = DateHelper.write(date: at)
        let dateCheck = reminders.filter({DateHelper.write(date: $0.date) == date && !$0.done})
        
        if dateCheck.count <= 0 {
            return 0 //No Reminder
        } else {
            let prioCheck = dateCheck.filter({$0.priority == 2 })
            if prioCheck.count <= 0 {
                return 1 //Reminder without high Prio
            } else {
                return 2 // There is a high priorized Reminder
            }
        }
    }
    
    public func deleteAllDoneReminder() {
        for remind in reminders {
            if remind.done {
                self.remove(remind)
            }
        }
    }
    
    public func deleteAll() {
        reminders.removeAll()
    }
    
    public func loadSamples() {
        insert(Samples.one)
        insert(Samples.two)
        insert(Samples.three)
    }
    
    // MARK: - Data of SearchFeature
    public func search(for Title: String) -> [Reminder] {
        var returning: [Reminder]
        let result = reminders.filter({(item: Reminder) -> Bool in
            let stringMatch = item.title.lowercased().range(of: Title.lowercased())
            return stringMatch != nil ? true : false
        })
        returning = Array(result)
        returning.sort(by: { $0.date < $1.date})
        return returning
    }
    
    
    //MARK: - Encodings
    public func save() {
        let isSuccesfulSave = NSKeyedArchiver.archiveRootObject(reminders, toFile: Reminder.ArchiveURL.path)
        if isSuccesfulSave {
            print("ReminderManager: Reminders saved")
        }
        else {
            print("! ERROR ! : ReminderManager: Failed to save data")
        }
    }
    
    public func load(){
        let maybeReminders = NSKeyedUnarchiver.unarchiveObject(withFile: Reminder.ArchiveURL.path) as? Set<Reminder>
        if maybeReminders == nil {
            loadSamples()
            print("ReminderManager: Sample Reminders loaded")
        } else {
            reminders = maybeReminders!
            print("ReminderManager: Reminders loaded")
        }
    }
}
