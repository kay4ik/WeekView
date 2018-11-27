//
//  EditTableViewController.swift
//  Weekview
//
//  Created by Kay Boschmann on 23.10.18.
//  Copyright © 2018 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import UIKit
import MapKit

class EditTableViewController: UITableViewController, RViewControllerProtocol {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var noticeTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var priorityPicker: UISegmentedControl!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    var navigationBar: UINavigationBar?
    
    var remind: Reminder?
    let remindController = ReminderManager.shared
    let setting = Settings.shared
    let notifyController = NotificationController.shared
    var alreadyExist = false
    var selectedDate: Date?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar = self.navigationController?.navigationBar
        titleTextField.delegate = self
        noticeTextView.delegate = self
        datePicker.locale = NSLocale(localeIdentifier: "de_DE") as Locale
        setUpBarStyles()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !alreadyExist {
            datePicker.minimumDate = Date()
            datePicker.date = self.selectedDate ?? Date()
            navigationItem.title = "Neue Erinnerung"
            remind = Reminder()
        }
        else {
            setReminderData()
            navigationItem.title = "Bearbeiten"
        }
        setNoticeText()
    }
    
    private func setReminderData(){
        titleTextField.text = remind!.title
        datePicker.date = remind!.date
        noticeTextView.text = remind!.notice
        priorityPicker.selectedSegmentIndex = (remind!.priority)
        priorityLabel.backgroundColor = PriorityHelper.getColorOf(priority: (remind!.priority), colorMode: setting.colorMode)
    }
    
    private func showLocation() {
        if remind!.location == nil {
            locationLabel.text = "Kein Standort festgelegt."
        } else {
            locationLabel.text = remind!.location?.getAddress()
        }
    }
    
    private func setNoticeText(){
        if noticeTextView.text == "Keine Notiz" || noticeTextView.text.isEmpty {
            noticeTextView.text = "Keine Notiz"
            noticeTextView.textColor = UIColor.lightGray
        } else {
            noticeTextView.textColor = UIColor.black
        }
    }
    
    func setUpBarStyles() {
        let barStyle = setting.barStyle
        let barTint = setting.barTintColor
        navigationBar?.barStyle = barStyle
        navigationBar?.tintColor = barTint
    }

    func checkEmptyTitle() {
        if titleTextField.text == "" {
            let alert = UIAlertController(title: "Geben Sie einen Titel ein:", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            alert.addTextField(configurationHandler: { textField in
                textField.placeholder = "Titel der Erinnerung"
            })
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                if let input = alert.textFields?.first?.text {
                    self.titleTextField.text = input
                }
            }))
            self.present(alert, animated: true)
        }
    }
    
    private func clear() {
        remind = nil
        alreadyExist = false
        titleTextField.text = ""
        noticeTextView.text = ""
        datePicker.date = Date()
        priorityPicker.selectedSegmentIndex = 0
        navigationItem.title = "Neue Erinnerung"
    }
    
    // MARK: - Actions
    
    @IBAction func save(_ sender: Any) {
        checkEmptyTitle()
        
        remind!.title = titleTextField.text ?? "No Title"
        remind!.date = datePicker.date
        remind!.notice = noticeTextView.text
        
        if alreadyExist {
            remindController.update(remind!)
        }
        else {
            remindController.insert(remind!)
            if remind!.priority >= 1 {
                notifyController.newNotify(with: remind!)
            }
        }
        clear()
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true);
    }
    
    @IBAction func prioPickerChanged(_ sender: Any) {
        let selected = priorityPicker.selectedSegmentIndex
        remind!.priority = selected
        priorityLabel.backgroundColor = PriorityHelper.getColorOf(priority: selected, colorMode: setting.colorMode)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let viewController = segue.destination as? LocationViewController else {
            fatalError("Unknown destination in EditLocation")
        }
        viewController.local = self.remind!.location
        viewController.remTitel = self.remind!.title
        viewController.delegate = self
    }

}
extension EditTableViewController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if noticeTextView.textColor == UIColor.lightGray {
            noticeTextView.text = nil
            noticeTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        remind!.notice = noticeTextView.text
        if noticeTextView.text.isEmpty {
            noticeTextView.text = "Keine Notiz"
            noticeTextView.textColor = UIColor.lightGray
        }
    }
}

extension EditTableViewController: LocationViewControllerDelegate {
    func locationViewController(sender: LocationViewController, didSave location: Location) {
        remind!.location = location
        locationLabel.text = remind!.getOneRowLocation()
    }
}
