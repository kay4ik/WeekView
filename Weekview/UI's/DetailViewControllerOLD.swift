//
//  DetailViewController.swift
//  Weekview
//
//  Created by Kay Boschmann on 14.09.17.
//  Copyright © 2017 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
//    MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var noticeLabel: UITextView!
    @IBOutlet weak var priorityColor: UILabel!
    @IBOutlet weak var priorityText: UILabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var achriveTitleLabel: UILabel!
    @IBOutlet weak var archiveDateLabel: UILabel!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var isDoneLabel: UILabel!
    @IBOutlet weak var showLocationView: UIView!
    @IBOutlet weak var showLocationButton: UIButton!
    
    var remind: Reminder?
    let remindController = ReminderSingleton.getInstance()
    let dateController = DateSingleton.getInstance()
    let prioControll = PrioritySingleton.getInstance()
    let settingControll = SettingController.getInstance()
    var archived: Bool?
    var index: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        editButton.image = UIImage(named: "pencil")
        editButton.title = ""
        noticeLabel.layer.borderWidth = 1
        noticeLabel.layer.borderColor = settingControll.grey.cgColor
        noticeLabel.layer.cornerRadius = 5
        let color = settingControll.getBackgroundColor()
        buttonView.backgroundColor = color
    }
    
    override func viewWillAppear(_ animated: Bool) {
        titleLabel.text = remind!.title
        dateLabel.text = dateController.writeFormattedDate(from: remind!.date)
        
        //LocationButton Enabeling
        if remind?.location == nil {
            showLocationButton.isEnabled = false
            showLocationView.backgroundColor = settingControll.lightGrey
        } else {
            showLocationButton.isEnabled = true
            showLocationView.backgroundColor = settingControll.getBackgroundColor()
        }
        
        //Placeholder für TextView
        if remind!.notice == "Keine Notiz" {
            noticeLabel.text = nil
        } else {
            noticeLabel.text = remind!.notice
        }
        oldAlert(now: Date())
        
        //Priority:
        priorityColor.backgroundColor = prioControll.getColorOf(priority: (remind?.priority)!)
        let prioText = prioControll.getTextOf(priority: (remind?.priority)!)
        if prioText == "Hoch" {
            priorityText.font = UIFont.systemFont(ofSize: 19, weight: UIFont.Weight.bold)
        } else {
            priorityText.font = UIFont.systemFont(ofSize: 19, weight: UIFont.Weight.regular)
        }
        priorityText.text = prioText
        
        //Location
        if remind?.location != nil {
            locationLabelFirst.text = remind?.getOneRowLocation()
        } else {
            locationLabelFirst.text = "Kein Standort festgelegt"
        }
        
        //Done or not
        if archived! {
            doneButton.setTitle("Erneuern", for: .normal)
            archiveDateLabel.isHidden = false
            archiveDateLabel.text = dateController.writeFormattedDate(from: (remind?.doneDate)!)
            achriveTitleLabel.isHidden = false
            editButton.isEnabled = false
        } else {
            doneButton.setTitle("Erledigt", for: .normal)
            achriveTitleLabel.isHidden = true
            archiveDateLabel.isHidden = true
            editButton.isEnabled = true
        }
    }

    // MARK: Actions
    @IBAction func deleteActualReminder(_ sender: Any) {
        if archived! {
            deleteArchivedReminder()
        } else {
            deleteNotArchivedReminder()
        }
    }
    
    func deleteArchivedReminder() {
        let uiAlert = UIAlertController(title: " '\(remind?.title ?? "Erinnerung")'" + " wiklich löschen?",
                                        message: "Sind Sie sicher, dass Sie diese Erinnerung löschen möchten? \n \nDieser Vorgang kann nicht Rückgängig gemacht werden!", preferredStyle: UIAlertController.Style.alert)
        self.present(uiAlert, animated: true, completion: nil)
        
        uiAlert.addAction(UIAlertAction(title: "Löschen", style: .destructive, handler: { action in
            self.remindController.deleteDoneReminder(at: self.index!)
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }))
        
        uiAlert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: { action in
            print("Canceled 'delete Remind'")
        }))
    }
    
    func deleteNotArchivedReminder(){
        let uiAlert = UIAlertController(title: " '\(remind?.title ?? "Erinnerung")'" + " wiklich löschen?",
                                        message: "Sind Sie sicher, dass Sie diese Erinnerung löschen möchten? \n \n Dieser Vorgang kann nicht Rückgängig gemacht werden!", preferredStyle: UIAlertController.Style.alert)
        self.present(uiAlert, animated: true, completion: nil)
        
        uiAlert.addAction(UIAlertAction(title: "Löschen", style: .destructive, handler: { action in
            self.remindController.removeReminderBy(index: (self.remind?.myPosition)!)
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }))
        
        uiAlert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: { action in
            print("Canceled 'delete Remind'")
        }))
    }
    
    @IBAction func showLocation(_ sender: Any) {
        if remind?.location == nil {
            print("there is no location to display")
        } else {
            self.performSegue(withIdentifier: "showLocation", sender: nil)
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        if archived! {
            remindController.markAsOpen(reminder: remind!)
        } else {
            remindController.markAsDone(reminder: remind!)
        }
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        //Editing this reminder
        switch segue.identifier! {
        case "EditThis":
            guard let viewController = segue.destination as? EditViewController else {
                fatalError("Unknown destination in EditThis")
            }
            viewController.remind = self.remind!
            
        case "showLocation":
            guard let viewController = segue.destination as? ShowLocationPopUp else {
                fatalError("Unkown destination in showLocation")
            }
            viewController.location = remind?.location
            viewController.reminder = remind
            
        default:
            fatalError("Unknown segue Indentifier")
        }
        
    }
    
    private func oldAlert(now: Date){
        if (remind?.date)! <= now && archived == false {
            let uiAlert = UIAlertController(title: "Erinnerung ist abgelaufen!",
                                            message: "Möchten Sie die Erinnerung bearbeiten oder löschen?",
                                            preferredStyle: UIAlertController.Style.alert)
            self.present(uiAlert, animated: true, completion: nil)
            
            uiAlert.addAction(UIAlertAction(title: "Bearbeiten", style: .default, handler: { action in
                UIApplication.shared.sendAction(self.editButton.action!, to: self.editButton.target, from: nil, for: nil)
            }))
            
            uiAlert.addAction(UIAlertAction(title: "Erledigt", style: .default, handler: { action in
                self.doneButton.sendActions(for: .touchUpInside)
            }))
            
            uiAlert.addAction(UIAlertAction(title: "Löschen", style: .destructive, handler: { action in
                self.remindController.removeReminderBy(index: (self.remind?.myPosition)!)
                self.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }))
            
            uiAlert.addAction(UIAlertAction(title: "Nichts tun", style: .cancel, handler: { action in
            }))
        }
    }
}
