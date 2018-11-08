//
//  ShowNoticeViewController.swift
//  Weekview
//
//  Created by Kay Boschmann on 23.10.18.
//  Copyright © 2018 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import UIKit

class ShowNoticeViewController: UIViewController {
    var notice = "Keine Notiz"
    @IBOutlet weak var textbox: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textbox.text = notice
    }
}
