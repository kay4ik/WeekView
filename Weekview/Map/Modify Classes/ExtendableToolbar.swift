//
//  ExtendableToolbar.swift
//  Weekview
//
//  Created by Kay Boschmann on 17.01.19.
//  Copyright © 2019 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import UIKit

class ExtendableToolbar: UIToolbar {

    public var state: WVToolbarState = .shortended
    
    public func extend() {
        
    }
    
    public func shorten() {
        
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

enum WVToolbarState {
    case extended
    case shortended
}
