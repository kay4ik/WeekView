//
//  PrioritySingleton.swift
//  Weekview
//
//  Created by Kay Boschmann on 06.11.17.
//  Copyright © 2017 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import Foundation
import UIKit

class PriorityHelper {
    
    private static let colors: [[UIColor]] = [
        [.lightGray, .orange, .red],
        [.green, .yellow, .red],
        [.purple, Colors.pink, .magenta],
        [.gray, Colors.defBlue, .cyan],
        [Colors.oliveGreen, Colors.limeGreen, .green]
    ]
    
    public static func getColorOf(priority: Int, colorMode: Int) -> UIColor {
        return colors[colorMode][priority]
    }
    
    public static func getTextOf(priority: Int) -> String {
        var text: String
        switch priority {
        case 0:
            text = "Normal"
        case 1:
            text = "Mittel"
        case 2:
            text = "Hoch"
        default:
            text = "Fehler"
            print("Fehler beim feststellen der Priorität")
        }
        return text
    }
}

