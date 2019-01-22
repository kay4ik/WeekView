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

class HomeViewController: UIViewController, RViewControllerProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var daysStack: UIStackView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    private let dateFormatter = DateFormatter()
    private let remindController = ReminderManager.shared
    private let settings = Settings.shared
    
    private var selectedDate: Date?
    private var navigationBar: UINavigationBar?
    private var tabBar: UITabBar?
    private var dateReminders: [[Reminder]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar = navigationController?.navigationBar
        tabBar = self.tabBarController?.tabBar
        tabBar?.barStyle = settings.barStyle
        initializeDesign()
        initializeCalendar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if calendarView.selectedDates.count > 0 {
            list(date: calendarView.selectedDates.first!)
        }
        reload()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if WVNotification.tapped {
            self.performSegue(withIdentifier: "showNotification", sender: nil)
        }
    }
    
    private func initializeDesign() {
        setUpBarStyles()
        setUpBackgroundColors()
    }
    
    private func initializeCalendar() {
        calendarView.selectDates([Date()])
        setupCalendarView()
        scrollToToday()
        list(date: Date())
    }
    
    private func reload() {
        calendarView.reloadData()
        tableView.reloadData()
    }
    
    func setUpBarStyles() {
        let style = settings.barStyle
        let tint = settings.barTintColor
        navigationBar?.barStyle = style
        navigationBar?.tintColor = tint
        tabBar?.barStyle = style
        tabBar?.tintColor = tint
        for label in daysStack.subviews as! [UILabel] {
            label.textColor = settings.subTextColor
        }
    }
    
    func setUpBackgroundColors() {
        let color = settings.backgroundColor
        backgroundView.backgroundColor = color
        calendarView.backgroundColor = color
        if settings.runtimeDarkMode == false {
            backgroundView.layer.borderWidth = 1
            backgroundView.layer.borderColor = Colors.lightBorder.cgColor
        }
    }
    
    func scrollToToday(){
        calendarView.scrollToDate(Date(), animateScroll: false)
        calendarView.selectDates(from: Date(), to: Date())
    }
    
    @IBAction func scrollToday(_ sender: Any) {
        scrollToToday()
    }
}


//MARK: - Calendar Stuff
extension HomeViewController: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
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
    
    private func handleCellSelected(validCell: RemindCollectionCell, cellState: CellState){
        validCell.selectedView.backgroundColor = settings.backgroundColor
        validCell.selectedView.layer.borderWidth = 2
        validCell.selectedView.layer.borderColor = settings.mainTextColor.cgColor
        
        if cellState.isSelected {
            validCell.selectedView.isHidden = false
        } else {
            validCell.selectedView.isHidden = true
        }
    }
    
    private func handleTextColors(validCell: RemindCollectionCell, cellState: CellState){
        if cellState.isSelected {
            validCell.dateLabel.textColor = settings.mainTextColor
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                validCell.dateLabel.textColor = settings.mainTextColor
            } else {
                validCell.dateLabel.textColor = UIColor.lightGray
            }
        }
    }
    
    private func handleEventDots(cell: RemindCollectionCell, cellState: CellState){
        let eventCode = remindController.isThereA(reminder: cellState.date)
        switch eventCode {
        case 0:
            cell.eventView.isHidden = true
        case 1:
            cell.eventView.isHidden = false
            cell.eventView.backgroundColor = PriorityHelper.getColorOf(priority: 0, colorMode: settings.colorMode)
        case 2:
            cell.eventView.isHidden = false
            cell.eventView.backgroundColor = PriorityHelper.getColorOf(priority: 2, colorMode: settings.colorMode)
        default:
            fatalError()
        }
    }
    
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
        reload()
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
    
    private func list(date: Date?) {
        dateReminders = remindController.getSeperatedLists(of: date ?? Date())
    }
    
    private func getReminder(index: IndexPath) -> Reminder {
        return dateReminders![index.section][index.row]
    }
}


//MARK: - Much Table View Stuff
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    private func handleNoDataLabel() {
        var value = false
        if dateReminders?[0].count ?? 0 == 0 && dateReminders?[1].count ?? 0 == 0{
            value = true
        }
        noDataLabel.isHidden = !value
        tableView.isHidden = value
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        handleNoDataLabel()
        return dateReminders![section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(indexPath: indexPath)
        let actualReminder = getReminder(index: indexPath)
        cell.reminderid = actualReminder.id
        
        cell.titleLabel.attributedText =  actualReminder.title.strikeThrough(value: indexPath.section)
        cell.dateLabel.text = DateHelper.write(time: actualReminder.date)
        cell.priorityLabel.backgroundColor = PriorityHelper.getColorOf(priority: actualReminder.priority, colorMode: settings.colorMode)
        
        let font = getFont(style: actualReminder.priority)
        cell.titleLabel.font = font
        cell.dateLabel.font = font
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            if dateReminders![section].count > 0 {
                return "Offene Erinnerungen"
            }
        }
        else {
            if dateReminders![section].count > 0 {
                return "Erledigte Erinnerungen"
            }
        }
        return ""
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
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let selectedReminder = self.getReminder(index: indexPath)
        var action: [UIContextualAction]
        if indexPath.section == 0 {
            let edit = UIContextualAction(style: .normal, title: "Bearbeiten", handler: { (action, index, nil)  in
                print("Ofenne Erinnerung bearbeiten")
                self.performSegue(withIdentifier: "editDirectly", sender: selectedReminder)
            })
            edit.backgroundColor = Colors.blue
            
            let move = UIContextualAction(style: .normal, title: "Verschieben", handler: {(action, index, nil) in
                print("Offene Erinnerung verschieben")
                self.performSegue(withIdentifier: "moveDate", sender: selectedReminder)
            })
            move.backgroundColor = UIColor.gray
            action = [edit, move]
        } else {
            let del = UIContextualAction(style: .destructive, title: "Löschen", handler: { (action, index, nil) in
                print("erledigte löschen")
                self.remindController.remove(selectedReminder)
                self.list(date: self.calendarView.selectedDates[0])
                self.reload()
            })
            action = [del]
        }
        return UISwipeActionsConfiguration(actions: action)
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let selectedReminder = self.getReminder(index: indexPath)
        let action: UIContextualAction
        if indexPath.section == 0 {
            let done = UIContextualAction(style: .normal, title: "Erledigen", handler: { (action, index, nil) in
                print("offene erinnerung erledigen")
                self.remindController.finish(selectedReminder)
                self.list(date: self.calendarView.selectedDates[0])
                self.reload()
            })
            done.backgroundColor = Colors.oliveGreen
            action = done
        } else {
            let redo = UIContextualAction(style: .normal, title: "Erneuern", handler: { (action, index, nil) in
                print("erledigte erneuern")
                self.remindController.unfinish(selectedReminder)
                self.list(date: self.calendarView.selectedDates[0])
                self.reload()
            })
            redo.backgroundColor = UIColor.gray
            action = redo
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let selectedReminder = self.getReminder(index: indexPath)
        if indexPath.section == 0 {
            let edit = UITableViewRowAction(style: .normal, title: "Bearbeiten", handler: { (action, index) in
                print("Ofenne Erinnerung bearbeiten")
                self.performSegue(withIdentifier: "editDirectly", sender: selectedReminder)
            })
            edit.backgroundColor = Colors.blue
            
            let done = UITableViewRowAction(style: .normal, title: "Erledigen", handler: { (action, index) in
                print("offene erinnerung erledigen")
                self.remindController.finish(selectedReminder)
                self.list(date: self.calendarView.selectedDates[0])
                self.reload()
            })
            done.backgroundColor = UIColor.red
            return [done, edit]
        } else {
            let del = UITableViewRowAction(style: .destructive, title: "Löschen", handler: { (action, index) in
                print("erledigte löschen")
                self.remindController.remove(selectedReminder)
                self.list(date: self.calendarView.selectedDates[0])
                self.reload()
            })
            del.backgroundColor = UIColor.red
            
            let redo = UITableViewRowAction(style: .normal, title: "Erneuern", handler: { (action, index) in
                print("erledigte erneuern")
                self.remindController.unfinish(selectedReminder)
                self.list(date: self.calendarView.selectedDates[0])
                self.reload()
            })
            redo.backgroundColor = UIColor.gray
            return [del, redo]
        }
    }
    
    private func getFont(style: Int) -> UIFont {
        var weight = UIFont.Weight.regular
        if style == 2 { weight = .bold }
        return UIFont.systemFont(ofSize: 19, weight: weight)
    }
}

extension HomeViewController: ScrollingDelegate, MoveDateDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? "" {
        case "showNotification":
            guard let detailTableViewController = segue.destination as? DetailTableViewController else {fatalError()}
            detailTableViewController.remind = remindController.getReminder(with: WVNotification.id)
            WVNotification.id = ""
            WVNotification.tapped = false
            
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
            reminderEditViewController.alreadyExist = true
            
        case "fastScroll":
            guard let scrollingPopUp = segue.destination as? ScrollingPopUp
                else { fatalError("Unexpected destination: \(segue.destination)") }
            scrollingPopUp.delegate = self
            
        case "moveDate":
            guard let moveDatePopUp = segue.destination as? MoveDatePopUp
                else { fatalError("Unexpected destination: \(segue.destination)") }
            moveDatePopUp.delegate = self
            moveDatePopUp.reminder = (sender as? Reminder)!
            
        default:
            fatalError("Unexpected Identifier")
        }
    }
    
    func scrollingPopUp(sender: ScrollingPopUp, wantScrollTo date: Date) {
        calendarView.scrollToDate(date)
        calendarView.selectDates([date])
    }
    
    func moveDatePopUp(selectedNew date: Date, for reminder: Reminder) {
        reminder.date = date
        self.remindController.update(reminder)
        list(date: calendarView.selectedDates.first!)
        reload()
    }
}
