//
//  HomeViewController.swift
//  Weekview
//
//  Created by Kay Boschmann on 07.11.18.
//  Copyright © 2018 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import UIKit
import JTAppleCalendar
import UserNotifications

class HomeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var daysStack: UIStackView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    private let dateFormatter = DateFormatter()
    private let remindController = ReminderManager.shared
    private let dateController = DateManager.shared
    private let settings = Settings.shared
    
    private var selectedDate: Date?
    private var navigationBar: UINavigationBar?
    private var tabBar: UITabBar?
    private var dateReminders: [[Reminder]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarView.selectDates([Date()])
        navigationBar = navigationController?.navigationBar
        tabBar = self.tabBarController?.tabBar
        setUpColors()
        setupCalendarView()
        reload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        scrollToToday()
    }
    
    private func reload() {
        //list(date: calendarView.selectedDates[0])
        calendarView.reloadData()
        tableView.reloadData()
    }
    
    func setupCalendarView(){
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        calendarView.visibleDates { (visibleDates) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
    }
    
    private func setupViewsOfCalendar(from visibleDates: DateSegmentInfo){
        let date = visibleDates.monthDates.first!.date
        self.dateFormatter.dateFormat = "yy"
        let year = self.dateFormatter.string(from: date)
        self.dateFormatter.dateFormat = "MMMM"
        let month = self.dateFormatter.string(from: date)
        navigationItem.title = month + " '"+year
    }
    
    private func setUpColors() {
        setUpBackgroundView()
        navigationBar?.barStyle = settings.style
        navigationBar?.tintColor = settings.tint
        
        for label in daysStack.subviews as! [UILabel] {
            label.textColor = settings.subText
        }
    }
    
    private func setUpBackgroundView() {
        let color = settings.background
        backgroundView.backgroundColor = color
        calendarView.backgroundColor = color
        if settings.runtimeDarkMode == false {
            backgroundView.layer.borderWidth = 1
            backgroundView.layer.borderColor = Colors.lightBorder.cgColor
        }
    }
    
    @IBAction func scrollToday(_ sender: Any) {
        scrollToToday()
    }
    
    func scrollToToday(){
        calendarView.scrollToDate(Date(), animateScroll: false)
        calendarView.selectDates(from: Date(), to: Date())
    }
    
    private func handleTextColors(validCell: RemindCollectionCell, cellState: CellState){
        if cellState.isSelected {
            validCell.dateLabel.textColor = settings.mainText
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                validCell.dateLabel.textColor = settings.mainText
            } else {
                validCell.dateLabel.textColor = UIColor.lightGray
            }
        }
    }
    
    private func handleCellSelected(validCell: RemindCollectionCell, cellState: CellState){
        validCell.selectedView.backgroundColor = settings.background
        validCell.selectedView.layer.borderWidth = 2
        validCell.selectedView.layer.borderColor = settings.mainText.cgColor
        
        if cellState.isSelected {
            validCell.selectedView.isHidden = false
        } else {
            validCell.selectedView.isHidden = true
        }
    }
    
    private func handleEventDots(cell: RemindCollectionCell, cellState: CellState){
        let eventCode = remindController.isThereA(reminder: cellState.date)
        switch eventCode {
        case 0:
            cell.eventView.isHidden = true
        case 1:
            cell.eventView.isHidden = false
            cell.eventView.backgroundColor = PriorityMngr.getColorOf(priority: 0, colorMode: settings.colorMode)
        case 2:
            cell.eventView.isHidden = false
            cell.eventView.backgroundColor = PriorityMngr.getColorOf(priority: 2, colorMode: settings.colorMode)
        default:
            fatalError()
        }
    }
    
}

extension HomeViewController: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {}
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "RemindCollectionCell", for: indexPath) as! RemindCollectionCell
        cell.dateLabel.text = cellState.text
        configure(cell: cell, cellState: cellState)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configure(cell: cell, cellState: cellState)
        list(date: date)
        //tableView.reloadData()
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configure(cell: cell, cellState: cellState)
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        
        let startDate = formatter.date(from: "01.01.2018")
        let endDate = formatter.date(from: "31.12.2099")
        
        return ConfigurationParameters(
            startDate: startDate!, endDate: endDate!,
            numberOfRows: 1,
            generateInDates: .forFirstMonthOnly,
            generateOutDates: .off,
            firstDayOfWeek: .monday)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }
    
    
    private func configure(cell: JTAppleCell?, cellState: CellState) {
        guard let cell = cell as? RemindCollectionCell else { return }
        handleTextColors(validCell: cell, cellState: cellState)
        handleCellSelected(validCell: cell, cellState: cellState)
        handleEventDots(cell: cell, cellState: cellState)
    }
    
    private func list(date: Date) {
        dateReminders = remindController.getSeperatedLists(of: date)
        tableView.reloadData()
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dateReminders?.count == 0 {
            tableView.isHidden = true
            noDataLabel.isHidden = false
            return 0
        }
        else {
            tableView.isHidden = false
            noDataLabel.isHidden = true
            if section == 0 {
                return dateReminders?[0].count ?? 0
            }
            else {
                return dateReminders?[1].count ?? 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(indexPath: indexPath)
        let actualReminder = dateReminders![indexPath.section][indexPath.row]
        cell.reminderid = actualReminder.id
        
        cell.titleLabel.attributedText = strikeThrough(string: actualReminder.title, value: indexPath.section)
        cell.dateLabel.text = dateController.write(time: actualReminder.date)
        cell.priorityLabel.backgroundColor = PriorityMngr.getColorOf(priority: actualReminder.priority, colorMode: settings.colorMode)
        
        let font = getFont(style: actualReminder.priority)
        cell.titleLabel.font = font
        cell.dateLabel.font = font
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {return "Offene Erinnerungen"}
        return "Erledigte Erinnerungen"
    }
    
    private func getCell(indexPath: IndexPath) -> ReminderTableViewCell {
        let cellIdent = "ReminderTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdent, for: indexPath) as? ReminderTableViewCell else {
            fatalError()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let cell = getCell(indexPath: indexPath)
        let id = cell.reminderid
        if indexPath.section == 0 {
            let edit = UITableViewRowAction(style: .normal, title: "Bearbeiten", handler: { (action, index) in
                print("Ofenne Erinnerung bearbeiten")
                let selectedReminder = self.remindController.getReminder(with: id!)
                self.performSegue(withIdentifier: "editDirectly", sender: selectedReminder)
            })
            edit.backgroundColor = Colors.blue
            
            let done = UITableViewRowAction(style: .normal, title: "Erledigen", handler: { (action, index) in
                print("offene erinnerung erledigen")
                self.remindController.finish(self.remindController.getReminder(with: id!))
                self.reload()
            })
            done.backgroundColor = UIColor.red
            return [done, edit]
        } else {
            let del = UITableViewRowAction(style: .normal, title: "Löschen", handler: { (action, index) in
                print("erledigte löschen")
                let selectedReminder = self.remindController.getReminder(with: id!)
                self.remindController.remove(selectedReminder)
                self.reload()
            })
            del.backgroundColor = UIColor.red
            
            let redo = UITableViewRowAction(style: .normal, title: "Erneuern", handler: { (action, index) in
                print("erledigte erneuern")
                let selectedReminder = self.remindController.getReminder(with: id!)
                self.remindController.unfinish(selectedReminder)
                self.reload()
            })
            redo.backgroundColor = UIColor.gray
            return [del, redo]
        }
    }
    
    private func strikeThrough(string: String, value: Int) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: value, range: NSMakeRange(0, attributedString.length))
        return attributedString
    }
    
    private func getFont(style: Int) -> UIFont {
        var weight = UIFont.Weight.regular
        if style == 2 { weight = .bold }
        return UIFont.systemFont(ofSize: 19, weight: weight)
    }
}

extension HomeViewController: ScrollingDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? "" {
            
        case "ShowDetails":
            guard let reminderDetailViewController = segue.destination as? DetailTableViewController else {fatalError()}
            guard let selectedRemindCell = sender as? ReminderTableViewCell else {fatalError()}
            guard let indexPath = tableView.indexPath(for: selectedRemindCell) else {fatalError()}
            
            let selectedReminder = dateReminders![indexPath.section][indexPath.row]
            reminderDetailViewController.remind = selectedReminder
            
        case "editDirectly":
            guard let reminderEditViewController = segue.destination as? EditTableViewController
                else {
                    fatalError("Unexpected destination: \(segue.destination)")
            }
            reminderEditViewController.remind = (sender as? Reminder)!
            
        case "fastScroll":
            guard let viewController = segue.destination as? ScrollingPopUp
                else {
                    fatalError("Unexpected destination: \(segue.destination)")
            }
            viewController.delegate = self
            
        case "settings":
            print("")
            
        default:
            fatalError("Unexpected Identifier")
        }
    }
    
    func didSelectDate(sender: ScrollingPopUp, date: Date) {
        calendarView.scrollToDate(date)
        calendarView.selectDates([date])
    }
}
