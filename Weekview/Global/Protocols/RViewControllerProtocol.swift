//
//  RViewControllerProtocol.swift
//  Weekview
//
//  Created by Kay Boschmann on 23.11.18.
//  Copyright © 2018 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import Foundation
import UIKit

@objc protocol RViewControllerProtocol {
    func setUpBarStyles()
    @objc optional func setUpBackgroundColors()
}
