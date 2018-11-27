//
//  DateHelper.swift
//  Weekview
//
//  Created by Kay Boschmann on 05.11.18.
//  Copyright © 2018 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import Foundation
class DateHelper {
    
    public static let formatter = DateFormatter()
    
    public static func write(date: Date) -> String {
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
    
    public static func write(time: Date) -> String {
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: time)
    }
    
    public static func getDate(from: String) -> Date{
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.date(from: from)!
    }
    
    public static func isSame(date: Date, like: Date) -> Bool {
        formatter.dateFormat = "dd.MM.yyyy"
        let checkDate = formatter.string(from: date)
        let likeDate = formatter.string(from: like)
        return checkDate == likeDate
    }
}
