//
//  ShowNoticeViewController.swift
//  Weekview
//
//  Created by Kay Boschmann on 23.10.18.
//  Copyright © 2018 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import UIKit

class ShowNoticeViewController: UIViewController {
    private let settings = Settings.shared
    var notice = "Keine Notiz"
    @IBOutlet weak var textbox: UITextView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var mainView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textbox.text = notice
        toolbar.roundCorners(corners: [.topLeft, .topRight], radius: 15)
        toolbar.barStyle = settings.barStyle
        toolbar.barTintColor = settings.barTintColor
        mainView.backgroundColor = settings.backgroundColor
        textbox.tintColor = settings.mainTextColor
        textbox.backgroundColor = settings.backgroundColor
    }
    
    @IBAction func disappear(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
