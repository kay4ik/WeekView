//
//  StringExtension.swift
//  Weekview
//
//  Created by Kay Boschmann on 23.11.18.
//  Copyright © 2018 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import Foundation
extension String {
    func strikeThrough(value: Int) -> NSMutableAttributedString {
        let striked = NSMutableAttributedString(string: self)
        striked.addAttribute(NSAttributedString.Key.strikethroughStyle, value: value, range: NSMakeRange(0, striked.length))
        return striked
    }
}
