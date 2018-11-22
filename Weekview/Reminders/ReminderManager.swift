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
            value = reminders.filter({DateManager.isSame(date: date, like: $0.date) && $0.done == done})
        } else {
            value = reminders.filter({DateManager.isSame(date: date, like: $0.date)})
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
        let date = DateManager.write(date: at)
        let dateCheck = reminders.filter({DateManager.write(date: $0.date) == date && !$0.done})
        
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
        insert(ReminderManager.sampleOne)
        insert(ReminderManager.sampleTwo)
        insert(ReminderManager.sampleThree)
    }
    
    // MARK: - Data of SearchFeature
    public func search(for Title: String) -> [Reminder] {
        let result = reminders.filter({(item: Reminder) -> Bool in
            let stringMatch = item.title.lowercased().range(of: Title.lowercased())
            return stringMatch != nil ? true : false
        })
        if !settings.showDoneReminders {
            return Array(filterDonesOut(of: Array(result)))
        }
        return Array(result)
    }
    
    private func filterDonesOut(of: [Reminder]) -> [Reminder] {
        return of.filter({$0.done == false})
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

extension ReminderManager {
    static let sampleOne = Reminder(
        title: "Beispiel 1",
        date: Calendar.current.date(byAdding: Calendar.Component.hour, value: 2, to: Date())!,
        notice: "Wie gefällt ihnen WeekView?",
        priority: 0,
        done: false,
        location: nil)
    
    static let sampleTwo = Reminder(
        title: "Erledigter Beispiel 2",
        date: Calendar.current.date(byAdding: Calendar.Component.hour, value: 5, to: Date())!,
        notice: "Das ist eine Notiz.",
        priority: 1,
        done: true,
        location: nil)
    
    static let sampleThree = Reminder(
        title: "Ein anderes Beispiel",
        date: Calendar.current.date(byAdding: Calendar.Component.day, value: 1, to: Date())!,
        notice: "Keine Notiz",
        priority: 2,
        done: false,
        location: nil)
}
