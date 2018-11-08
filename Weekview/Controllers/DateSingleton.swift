//  DateSingleton.swift
//  Weekview
//
//  Created by Kay Boschmann on 11.10.17.
//  Copyright © 2017 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import Foundation
class DateSingleton {
    var date: Date?
    
    //Create Instance
    private init(){}
    class var shared : DateSingleton {
        struct Static {
            static let instance : DateSingleton = DateSingleton()
        }
        return Static.instance
    }
    
    // Date Controlling Methods
    public func isTodaySameDate(like: Date, past: Bool) -> Bool{
        // Today Components
        let now = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)
        
        // Given Date Componenets
        let givenYear = calendar.component(.year, from: like)
        let givenMonth = calendar.component(.month, from: like)
        let givenDay = calendar.component(.day, from: like)
        
        //Check if givenDate is Today
        if givenYear == year && givenMonth == month && givenDay == day{
            //print("date is today")
            return true
        } else if like <= now && past == true{
            //print("date is in past")
            return true
        } else {
            //print("date is in future")
            return false
        }
    }
    
    public func writeDate(from: Date) -> String{
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd.MM.yyyy"
        return dateFormat.string(from: from)
    }
    
    public func writeComplete(date: Date) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd.MM.yyyy HH:mm"
        
        return dateFormat.string(from: date)
    }
    
    public func writeFormattedDate(from: Date) -> String {
        let dateFormat = DateFormatter()
        let timeFormat = DateFormatter()
        var s: String
        dateFormat.dateFormat = "dd.MM.yyyy"
        timeFormat.dateFormat = "HH:mm"
        s = dateFormat.string(from: from) + ", um: " + timeFormat.string(from: from) + " Uhr"
        return s
    }
    
    public func getDate(from: String) -> Date{
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd.MM.yyyy"
        return dateFormat.date(from: from)!
    }
    
    public func writeTime(from: Date) -> String {
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "HH:mm"
        return timeFormat.string(from: from)
    }
}
