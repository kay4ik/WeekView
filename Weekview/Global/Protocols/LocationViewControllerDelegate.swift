//
//  LocationViewControllerDelegate.swift
//  Weekview
//
//  Created by Kay Boschmann on 23.11.18.
//  Copyright © 2018 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import Foundation

protocol LocationViewControllerDelegate {
    func locationViewController(sender : LocationViewController, didSave location: Location)
}
