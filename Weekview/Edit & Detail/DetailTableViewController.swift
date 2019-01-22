//
//  DetailTableViewController.swift
//  Weekview
//
//  Created by Kay Boschmann on 23.10.18.
//  Copyright © 2018 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import UIKit

class DetailTableViewController: UITableViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priorityColor: UIView!
    @IBOutlet weak var priorityText: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var noticeLabel: UILabel!
    @IBOutlet weak var noticeCell: UITableViewCell!
    @IBOutlet weak var locationCell: UITableViewCell!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var remind: Reminder!
    let remindController = ReminderManager.shared
    let settingControll = Settings.shared
    var index: Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        titleLabel.text = remind.title
        dateLabel.text = DateHelper.write(date: remind.date)
        handleLocationCell()
        handleNoticeCell()
        handlePriority()
        handleStatus()
        noticeCell.isSelected = false
        locationCell.isSelected = false
    }

    func handleLocationCell() {
        if remind.location == nil {
            locationLabel.text = "Kein Standort"
            locationCell.selectionStyle = .none
        }
        else {
            locationLabel.text = remind.location?.getAddress()
            locationCell.selectionStyle = .default
        }
    }
    
    func handleNoticeCell() {
        let notice = remind.notice
        noticeLabel.text = notice.truncate()
        if notice == "Keine Notiz" {
            noticeCell.selectionStyle = .none
        }
        else {
            noticeCell.selectionStyle = .default
        }
    }
    
    func handlePriority() {
        priorityColor.backgroundColor = PriorityHelper.getColorOf(priority: remind.priority, colorMode: settingControll.colorMode)
        priorityText.text = PriorityHelper.getTextOf(priority: (remind.priority))
    }
    
    func handleStatus() {
        if remind.done {
            statusLabel.text = "Erledigt"
            doneButton.image = UIImage(named: "cancel")
            editButton.isEnabled = false
        }
        else {
            statusLabel.text = "Offen"
            doneButton.image = UIImage(named: "checked")
            editButton.isEnabled = true
        }
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier! {
        case "editThis":
            guard let viewController = segue.destination as? EditTableViewController else {
                fatalError("Unknown destination in EditThis")
            }
            viewController.remind = self.remind!
            viewController.alreadyExist = true
            
        case "showLocation":
            guard let viewController = segue.destination as? ShowLocationPopUp else {
                fatalError("Unkown destination in showLocation")
            }
            viewController.location = remind?.location
            viewController.reminder = remind
            
        case "showNotice":
            guard let viewController = segue.destination as? ShowNoticePopUp else {
                fatalError("Unkown destination in showNotice")
            }
            viewController.notice = remind.notice
        
        default:
            fatalError("Unknown segue Indentifier")
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case "showNotice":
            if !remind.isNoticeSet() {
                print("BLOCKED")
                return false
            }
        
        case "showLocation":
            if remind.location == nil {
                print("BLOCKED")
                return false
            }
            
        default:
            return true
            
        }
        return true
    }

    // MARK: - Actions
    // MARK: - Delete Button Pressed
    
    @IBAction func deleteReminder(_ sender: Any) {
        deleteReminder()
    }
    
    func deleteReminder() {
        let uiAlert = UIAlertController(title: "Sicher?",
                                        message: "Durch das löschen wird die Erinnerung gelöscht. Dies kann nicht Rückgängig gemacht werden.",
                                        preferredStyle: .actionSheet)
        self.present(uiAlert, animated: true, completion: nil)
        
        uiAlert.addAction(UIAlertAction(title: "Löschen", style: .destructive, handler: { action in
            self.remindController.remove(self.remind)
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }))
        
        uiAlert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil))
    }
    
    // MARK: - Done Button Pressed
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        if remind.done {
            remindController.unfinish(self.remind)
        } else {
            remindController.finish(self.remind)
        }
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension String {
    func truncate() -> String {
        let length = 25
        let trailing = "..."
        
        if self.count > length {
            return String(self.prefix(length)) + trailing
        } else {
            return self
        }
    }
}
