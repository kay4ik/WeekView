//
//  DoneTableViewController.swift
//  Weekview
//
//  Created by Kay Boschmann on 15.11.17.
//  Copyright © 2017 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import UIKit

class DoneTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let dateController = DateSingleton.getInstance()
    let remindController = ReminderSingleton.getInstance()
    let settingController = SettingController.getInstance()
    var isIt: Bool?
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        remindController.loadDoneReminder()
        tableView.rowHeight = 72
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if remindController.doneReminders.count < 1 {
            thereIsNoDoneReminder()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "ShowDetails":
            guard let reminderDetailViewController = segue.destination as? DetailViewController
                else {
                    fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedRemindCell = sender as? DoneTableViewCell
                else {
                    fatalError("Unexpected sender: \(String(describing: sender))")
            }
            guard let indexPath = tableView.indexPath(for: selectedRemindCell)
                else {
                    fatalError("The selected cell dont exist")
            }
            let selectedReminder = remindController.getDoneReminder(at: indexPath)
            reminderDetailViewController.remind = selectedReminder
            reminderDetailViewController.archived = true
            reminderDetailViewController.index = indexPath.row
        default:
            fatalError()
        }
    }

    private func thereIsNoDoneReminder() {
        let uiAlert = UIAlertController(title: "Nichts Erledigt!",
                                        message: "Sie haben noch keine Erinnerungen als erledigt markiert.", preferredStyle: UIAlertController.Style.alert)
        self.present(uiAlert, animated: true, completion: nil)
        
        uiAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }))
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return remindController.doneReminders.count
    }
    
    public  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "DoneTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DoneTableViewCell
            else {
                fatalError("Fehler beim Konfigurieren der Zelle (Done)")
        }
        let doneReminder = remindController.getDoneReminder(at: indexPath)
        cell.titleLabel.text = doneReminder.title
        cell.dateLabel.text = dateController.writeComplete(date: doneReminder.date)
        cell.doneDateLabel.text = dateController.writeFormattedDate(from: doneReminder.doneDate!)
        return cell
    }
}
