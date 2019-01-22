//
//  DateExtension.swift
//  Weekview
//
//  Created by Kay Boschmann on 06.12.18.
//  Copyright © 2018 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import Foundation

extension Date {
    public var components: DateComponents {
        get {
            return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        }
    }
}
