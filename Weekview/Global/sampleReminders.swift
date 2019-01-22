//
//  SampleReminders.swift
//  Weekview
//
//  Created by Kay Boschmann on 22.01.19.
//  Copyright © 2019 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import Foundation
struct Samples {
    static let one = Reminder(
        title: "Beispiel 1",
        date: Calendar.current.date(byAdding: Calendar.Component.hour, value: 2, to: Date())!,
        notice: "Wie gefällt ihnen WeekView?",
        priority: 0,
        done: false,
        location: nil)
    
    static let two = Reminder(
        title: "Erledigter Beispiel 2",
        date: Calendar.current.date(byAdding: Calendar.Component.hour, value: 5, to: Date())!,
        notice: "Das ist eine Notiz.",
        priority: 1,
        done: true,
        location: nil)
    
    static let three = Reminder(
        title: "Ein anderes Beispiel",
        date: Calendar.current.date(byAdding: Calendar.Component.day, value: 1, to: Date())!,
        notice: "Keine Notiz",
        priority: 2,
        done: false,
        location: nil)
}
