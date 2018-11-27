//
//  MoveDatePopUp.swift
//  Weekview
//
//  Created by Kay Boschmann on 22.11.18.
//  Copyright © 2018 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import UIKit

class MoveDatePopUp: UIViewController {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var goButton: UIBarButtonItem!
    
    public var reminder: Reminder?
    public var delegate: MoveDateDelegate?
    
    private let settings = Settings.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyle()
    }
    
    private func setupStyle() {
        toolbar.barStyle = settings.barStyle
        goButton.tintColor = settings.barTintColor
        mainView.backgroundColor = settings.backgroundColor
        datePicker.setValue(settings.mainTextColor, forKeyPath: "textColor")
        toolbar.roundCorners(corners: [.topLeft, .topRight], radius: 15)
    }

    @IBAction func cancel(_ sender: Any) {
        disappear()
    }
    
    @IBAction func move(_ sender: Any) {
        delegate?.moveDatePopUp(selectedNew: datePicker.date, for: self.reminder!)
        disappear()
    }
    
    private func disappear() {
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
