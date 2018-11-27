//
//  Reminder.swift
//  Weekview
//
//  Created by Kay Boschmann on 12.09.17.
//  Copyright © 2017 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import UIKit
import MapKit

class Reminder: NSObject, NSCoding {
    private let formatter = DateFormatter()
    
//     MARK: Properties
    
    //STANDARDS
    var id: String
    var title: String = ""
    var priority: Int = 0
    var location: Location?
    var notice: String = "Keine Notiz"
    var date: Date = Date()
    var done = false
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("weekview.reminders")
    
    
//    MARK: Inizialation
    override init() {
        self.id = UUID().uuidString
    }
    private init(id: String, title: String, date: Date, notice: String, priority: Int, done: Bool?, location: Location?) {
        self.id = id
        self.title = title
        self.date = date
        self.notice = notice
        self.priority = priority
        self.done = done ?? false
        self.location = location ?? nil
    }
    
    init(title: String, date: Date, notice: String, priority: Int, done: Bool?, location: Location?) {
        self.title = title
        self.date = date
        self.notice = notice
        self.priority = priority
        self.done = done ?? false
        self.location = location ?? nil
        
        self.id = UUID().uuidString
    }
    
    //MARK: Public Methods
    public func setDate(from: String){
        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        self.date = dFormatter.date(from: from)!
    }
    
    public func getDateAsString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: self.date)
    }
    
    private func setDate() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.date(from: "01.01.2000")!
    }
    
    public func getOneRowLocation() -> String {
        
        let a = (location?.route)! + " " + (location?.street_number)!
        let b = ", " + (location?.postalCode)! + " " + (location?.city)!
        return a + b
    }
    
    func isNoticeSet() -> Bool {
        if notice == "Keine Notiz" {
            return false
        }
        return true
    }
    
    //Encoding Methods
    required convenience init?(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeObject(forKey: "ID") as? String
        let title = aDecoder.decodeObject(forKey: "title") as? String
        let date = aDecoder.decodeObject(forKey: "date") as? Date
        let notice = aDecoder.decodeObject(forKey: "notice") as? String
        let priority = aDecoder.decodeInteger(forKey: "priority")
        let done = aDecoder.decodeBool(forKey: "done")
        let location = aDecoder.decodeObject(forKey: "location") as? Location
        self.init(id: id!, title: title!, date: date!, notice: notice!, priority: priority, done: done, location: location)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "ID")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(notice, forKey: "notice")
        aCoder.encode(priority, forKey: "priority")
        aCoder.encode(done, forKey: "doneDate")
        aCoder.encode(location, forKey: "location")
    }

}
