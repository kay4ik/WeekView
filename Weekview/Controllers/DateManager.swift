//
//  DateManager.swift
//  Weekview
//
//  Created by Kay Boschmann on 05.11.18.
//  Copyright © 2018 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import Foundation
class DateManager {
    private init(){}
    class var shared : DateManager {
        struct Static {
            static let instance : DateManager = DateManager()
        }
        return Static.instance
    }
    
    public let formatter = DateFormatter()
    
    public func write(date: Date) -> String {
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
    
    public func write(time: Date) -> String {
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: time)
    }
    
    public func getDate(from: String) -> Date{
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.date(from: from)!
    }
    
    public func isSame(date: Date, like: Date) -> Bool {
        formatter.dateFormat = "dd.MM.yyyy"
        let checkDate = formatter.string(from: date)
        let likeDate = formatter.string(from: like)
        return checkDate == likeDate
    }
}
