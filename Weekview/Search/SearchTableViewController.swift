//
//  SearchTableViewController.swift
//  Weekview
//
//  Created by Kay Boschmann on 16.11.18.
//  Copyright © 2018 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController, RViewControllerProtocol {
    @IBOutlet weak var searchBar: UISearchBar!
    
    private let reminderManager = ReminderManager.shared
    private let searchManager = SearchManager.shared
    private let settings = Settings.shared
    
    private var isSearching = false
    private var filteredData = [Reminder]()
    private var filteredDataDays = [[Reminder]]()
    private var dataDays: [[Reminder]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        setUpBarStyles()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        dataDays = searchManager.present(reminderManager.getAllReminders())
        tableView.reloadData()
    }

    func setUpBarStyles() {
        searchBar.barStyle = settings.barStyle
        navigationController?.navigationBar.barStyle = settings.barStyle
        navigationController?.navigationBar.tintColor = settings.barTintColor
    }
    
    
    private func getReminder(index: IndexPath) -> Reminder {
        if isSearching {
            return filteredDataDays[index.section][index.row]
        }
        return dataDays[index.section][index.row]
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isSearching {
            let abc = searchManager.present(filteredData)
            return abc[0].count
        }
        return dataDays.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isSearching {
            return DateHelper.write(date: filteredDataDays[section].first!.date)
        }
        return DateHelper.write(date: dataDays[section].first!.date)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredDataDays[section].count
        }
        return dataDays[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderTableViewCell", for: indexPath) as? ReminderTableViewCell
            else { fatalError() }

        let reminder: Reminder
        
        if isSearching {
            reminder = filteredDataDays[indexPath.section][indexPath.row]
        }
        else {
            print(indexPath.section)
            print(indexPath.row)
            reminder = dataDays[indexPath.section][indexPath.row]
        }

        cell.priorityLabel.backgroundColor = PriorityHelper.getColorOf(priority: reminder.priority, colorMode: settings.colorMode)
        cell.titleLabel.text = reminder.title
        cell.dateLabel.text = DateHelper.write(time: reminder.date)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? "" {
            
        case "ShowDetails":
            guard let reminderDetailViewController = segue.destination as? DetailTableViewController else {fatalError()}
            guard let selectedRemindCell = sender as? ReminderTableViewCell else {fatalError()}
            guard let indexPath = tableView.indexPath(for: selectedRemindCell) else {fatalError()}
            
            let selectedReminder = getReminder(index: indexPath)
            reminderDetailViewController.remind = selectedReminder
            
        default:
            fatalError("Unexpected Identifier")
        }
    }
}

extension SearchTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
        }
        else {
            isSearching = true
            filteredData = reminderManager.search(for: searchBar.text!)
            filteredDataDays = searchManager.present(filteredData)
        }
        tableView.reloadData()
    }
}
