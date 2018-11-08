//
//  ReminderSingleton.swift
//  Weekview
//
//  Created by Kay Boschmann on 06.10.17.
//  Copyright © 2017 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import Foundation
class ReminderSingleton {
    var reminders = [Reminder]()
    var todaysReminders = [Reminder]()
    var doneReminders = [Reminder]()
    var todaysDoneReminders = [Reminder]()
    let dateController = DateSingleton.shared
    
    private init(){}
    private class var shared : ReminderSingleton {
        struct Static {
            static let instance : ReminderSingleton = ReminderSingleton()
        }
        return Static.instance
    }
    
    //MARK: Basic Controlling Methods
    //Every Method is printing the action and its values
    
    public func save(reminder: Reminder) {
        reminders += [reminder]
        //print("Saved new Reminder at: \(count()-1)")
        generatePositions()
        saveData()
    }
    
    public func removeReminderBy(index: Int){
        reminders.remove(at: index)
        //print("Removed Reminder at Index: \(index)")
        generatePositions()
    }
    
    public func update(reminder: Reminder, at: Int){
        reminders [at] = reminder
        //print("Updated Reminder at Index: \(at)")
    }
    
    public func getReminder(at: IndexPath) -> Reminder{
        return reminders[at.row]
    }
    
    //TODAYS REMINDERS
    public func setTodaysReminders(from date: String){
        todaysReminders = reminders.filter({$0.getDateAsString() == date})
        todaysReminders.sort() {$0.date < $1.date}
    }
    
    public func getTodaysReminder(at: IndexPath) -> Reminder{
        return todaysReminders[at.row]
    }
    
    //Done Reminder
    public func markAsDone(reminder: Reminder) {
        let movingReminder = reminder
        movingReminder.doneDate = Date()
        
        let movingIndex = movingReminder.myPosition
        removeReminderBy(index: movingIndex!)
        
        doneReminders.append(movingReminder)
        generateDonePositions()
        saveData()
        saveDoneReminder()
        print("This Reminder is done (count: \(doneReminders.count))")
    }
    
    public func markAsOpen(reminder: Reminder){
        reminder.doneDate = nil
        doneReminders.remove(at: reminder.myPosition)
        save(reminder: reminder)
        generateDonePositions()
        saveData()
        saveDoneReminder()
        print("This Reminder is Open again!")
    }
    
    public func getDoneReminder(at: IndexPath) -> Reminder{
        return doneReminders[at.row]
    }
    
    public func deleteAllDoneReminder(){
        doneReminders.removeAll()
        print("All deleted. Count: \(doneReminders.count)")
    }
    
    public func deleteDoneReminder(at: Int){
        doneReminders.remove(at: at)
    }
    
    public func updateDone(reminder: Reminder, at: Int){
        doneReminders[at] = reminder
    }
    
    //TODAYS DONE REMINDERS
    public func setTodaysDoneReminders(from date: String) {
        todaysDoneReminders = doneReminders.filter({$0.getDateAsString() == date})
        todaysDoneReminders = todaysDoneReminders.sorted(by: {$0.date < $1.date})
    }
    
    public func getTodaysDoneReminder(at: IndexPath) -> Reminder{
        return todaysDoneReminders[at.row]
    }
    
    
    //Reminding DOTS
    
    public func isThereAReminder(at: Date) -> Int {
        var checked: Int
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd.MM.yyyy"
        let date = dateFormat.string(from: at)
        let toCheck = reminders.filter({$0.getDateAsString() == date})
        
        if toCheck.count <= 0 {
            checked = 0
        } else {
            let prioCheck = toCheck.filter({$0.priority == 2})
            if prioCheck.count <= 0 {
                checked = 1
            } else {
                checked = 2
            }
        }
        // 0 = Kein Reminder, 1 = irgendwelche Reminder, 2 = wichtige Reminder
        return checked
    }
    
    public func setToday(from: String) {
        setTodaysReminders(from: from)
        setTodaysDoneReminders(from: from)
    }
    
    //Encoding Methods
    public func saveData() {
        let isSuccesfulSave = NSKeyedArchiver.archiveRootObject(reminders, toFile: Reminder.ArchiveURL.path)
        if isSuccesfulSave {
            print("Reminders saved :D")
        }
        else {
            print("Failed to save data!!")
        }
    }
    
    public func saveDoneReminder() {
        generatePositions()
        let isSuccesfulSave = NSKeyedArchiver.archiveRootObject(doneReminders, toFile: Reminder.DoneArchiveURL.path)
        if isSuccesfulSave {
            print("Done Reminders saved")
        } else {
            print("Failed to save Done Reminder")
        }
    }
    
    public func loadData(){
        let maybeReminders = NSKeyedUnarchiver.unarchiveObject(withFile: Reminder.ArchiveURL.path) as? [Reminder]
        if maybeReminders == nil {
            loadSampleReminders()
            print("Sample Reminders loaded")
        } else {
            reminders = maybeReminders!
            print("Reminders loaded")
        }
        generatePositions()
    }
    
    public func loadDoneReminder(){
        let gottenReminders = NSKeyedUnarchiver.unarchiveObject(withFile: Reminder.DoneArchiveURL.path) as? [Reminder]
        if gottenReminders == nil {
            print("No Done Reminders to load")
        } else {
            doneReminders = gottenReminders!
            print("Done Reminders loaded")
        }
        generateDonePositions()
    }
    
    public func generatePositions() {
        var i = 0
        let number = reminders.count
        while i < number {
            let remind = reminders[i]
            remind.myPosition = i
            update(reminder: remind, at: i)
            //print("Reminder at Position \(i) has value in myPos: \(remind.myPosition)")
            i = i + 1
        }
        print("generated Open Posintions")
    }
    
    public func generateDonePositions() {
        var i = 0
        let number = doneReminders.count
        while i < number {
            let remind = doneReminders[i]
            remind.myPosition = i
            updateDone(reminder: remind, at: i)
            i = i + 1
        }
        print("generated Done Posintions")
    }
    
    //MARK: Sample Reminders:
    public func loadSampleReminders(){
        let calendar = Calendar.current
        let today = Date()
        let tomorrow = calendar.date(byAdding: Calendar.Component.day, value: 1, to: today)!
        
        let remind0 = Reminder()
        remind0.title = "Kalendererklärung"
        remind0.date = calendar.date(byAdding: Calendar.Component.hour, value: 2, to: today)!
        remind0.notice = "Sie haben eine Ansicht der aktuellen Woche. In dieser Ansicht können Sie in die vergangenen (nach links) oder in die zukünftigen (nach rechts) Wochen scrollen. Oben sehen Sie den aktuellen Monat und das Jahr (2017 = '17) und können über den 'heute'-Button sofort auf den heutigen Tag zurück springen."
        remind0.priority = 2
        
        
        let remindA = Reminder()
        remindA.title = "Erläuterungsbeispiel"
        remindA.date = calendar.date(byAdding: Calendar.Component.hour, value: 5, to: today)!
        remindA.notice = "Oben rechts können Sie bereits erstelle Erinnerungen bearbeiten. \n Unten links können Sie die ausgewählte Erinnerung löschen."
        remindA.priority = 0
        
        let remindB = Reminder()
        remindB.title = "Notizbeispiel"
        remindB.date = tomorrow
        remindB.notice = "In diesem Feld können Sie ihre Notizen sehen oder im Bearbeitungsmodus bearbeiten."
        remindB.priority = 1
        
        let remindC = Reminder()
        remindC.title = "Beispiel Erinnerung"
        remindC.date = tomorrow
        remindC.notice = "Jede Erinnerung lässt sich Priorisieren. Unten können Sie diese Priorisierung einstellen. \n Diese lassen sich leicht durch die Unterschiedlichen Farben unterscheiden."
        remindC.priority = 2
        
        reminders += [remind0, remindA, remindB, remindC]
        generatePositions()
    }
}
