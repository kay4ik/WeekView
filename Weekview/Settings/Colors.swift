//
//  Color.swift
//  Weekview
//
//  Created by Kay Boschmann on 30.10.18.
//  Copyright © 2018 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import UIKit
struct Colors{ //Collection of Colors
    // COLORS:
    //Primärfarben
    static let lightBorder = UIColor(rgb: 0xE6E6E6)
    static let darkBackground = UIColor(rgb: 0x595959)
    static let lightBack = UIColor(rgb: 0xf9f9f9)
    
    //Weitere Farben
    static let ultraLightGrey = UIColor(rgb: 0xEFEFEF)
    static let blue = UIColor(rgb: 0x2196F3)
    static let defBlue = UIColor(rgb: 0x007AFF)
    
    //Hinweisfarben
    static let pink = UIColor(rgb: 0xCD1076)
    static let grayBlue = UIColor(rgb: 0x5f768d)
    
    static let oliveGreen = UIColor(rgb: 0x6B8E23)
    static let limeGreen = UIColor(rgb: 0x32CD32)
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
