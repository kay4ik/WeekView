//
//  RemindCollectionCell.swift
//  Weekview
//
//  Created by Kay Boschmann on 19.10.17.
//  Copyright © 2017 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import UIKit
import JTAppleCalendar

class RemindCollectionCell: JTAppleCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var eventView: UIView!
}
