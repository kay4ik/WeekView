//
//  ViewController.swift
//  Weekview
//
//  Created by Kay Boschmann on 05.09.17.
//  Copyright © 2017 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import UIKit
import os.log
import MapKit

class EditViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    //    MARK: Properties
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var noticeTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var priorityPicker: UISegmentedControl!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    var navigationBar: UINavigationBar?
    
    var remind = Reminder()
    let remindController = ReminderSingleton.getInstance()
    let prioControll = PrioritySingleton.getInstance()
    let settingControll = SettingController.getInstance()
    let notifyController = NotificationController.shared()
    var alreadyExist: Bool?
    var selectedDate: Date?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar = self.navigationController?.navigationBar
        titleTextField.delegate = self
        noticeTextView.delegate = self
        datePicker.locale = NSLocale(localeIdentifier: "de_DE") as Locale
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupBackground()
        if remind.myPosition == nil {
            alreadyExist = false
            datePicker.minimumDate = Date()
            datePicker.date = self.selectedDate ?? Date()
            navigationItem.title = "Neue Erinnerung"
        }
        else {
            setReminderData()
            navigationItem.title = "Bearbeiten"
            alreadyExist = true
        }
        setLocationLabel()
        setNoticeText()
        updateButton()
        print("Position in main Reminders array: \(String(describing: remind.myPosition))")
    }
    
    func setReminderData(){
        titleTextField.text = remind.title
        datePicker.date = remind.date
        noticeTextView.text = remind.notice
        priorityPicker.selectedSegmentIndex = (remind.priority)
        priorityLabel.backgroundColor = prioControll.getColorOf(priority: (remind.priority))
    }
    
    func setLocationLabel() {
        if remind.location == nil {
            locationLabel.text = "Kein Standort festgelegt."
        } else {
            locationLabel.text = remind.getOneRowLocation()
        }
    }
    
    func setNoticeText(){
        if noticeTextView.text == "Keine Notiz" || noticeTextView.text.isEmpty {
            noticeTextView.text = "Keine Notiz"
            noticeTextView.textColor = UIColor.lightGray
        } else {
            noticeTextView.textColor = UIColor.black
        }
    }
    
    func setupBackground(){
        let barStyle = settingControll.getBarStyle()
        let barTint = settingControll.getBarTint()
        navigationBar?.barStyle = barStyle
        navigationBar?.tintColor = barTint
    }
    
    @IBAction func datePickerChanged(_ sender: Any) {
        remind.date = datePicker.date
    }
    
//    MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let viewController = segue.destination as? LocationViewController else {
            fatalError("Unknown destination in EditLocation")
        }
        viewController.local = self.remind.location
        viewController.remTitel = self.remind.title
        viewController.delegate = self
    }
    
    @IBAction func save(_ sender: Any) {
        guard let button = sender as? UIBarButtonItem, button === saveButton
            else {
                os_log("save button was not pressed, cancelling", log: OSLog.default, type: .debug)
                return
        }
        remind.title = titleTextField.text ?? "No Title"
        remind.date = datePicker.date
        remind.notice = noticeTextView.text
        
        if remind.myPosition != nil {
            remindController.update(reminder: remind, at: (remind.myPosition)!)
        }
        else {
            remindController.save(reminder: remind)
            if remind.priority >= 1 {
                notifyController.newNotify(with: remind)
            }
        }
        
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true);
    }
    
//    MARK: Text Field Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateButton()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateButton()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.remind.title = textField.text ?? ""
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: Text View Delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if noticeTextView.textColor == UIColor.lightGray {
            noticeTextView.text = nil
            noticeTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        remind.notice = noticeTextView.text
        if noticeTextView.text.isEmpty {
            noticeTextView.text = "Keine Notiz"
            noticeTextView.textColor = UIColor.lightGray
        }
    }
    
//    MARK: Private Methods
    private func updateButton() {
        if titleTextField.text == "" {
            saveButton.isEnabled = false
        }
        else {
            saveButton.isEnabled = true
        }
    }
    @IBAction func PrioPickerDidChanged(_ sender: Any) {
        let selected = priorityPicker.selectedSegmentIndex
        remind.priority = selected
        priorityLabel.backgroundColor = prioControll.getColorOf(priority: selected)
    }
}

extension EditViewController: LocationViewControllerDelegate {
    func LocationViewControllerDidSave(sender: LocationViewController, location: Location) {
        remind.location = location
        locationLabel.text = remind.getOneRowLocation()
    }
}
