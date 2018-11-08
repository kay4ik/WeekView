//
//  CalendarViewController.swift
//  Weekview
//
//  Created by Kay Boschmann on 19.10.17.
//  Copyright © 2017 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import UIKit
import JTAppleCalendar
import UserNotifications

class CalendarViewController: UIViewController{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var daysStack: UIStackView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    var navigationBar: UINavigationBar?
    var tabBar: UITabBar?
    
    
    let dateFormatter = DateFormatter()
    let remindController = ReminderSingleton.shared
    let dateController = DateSingleton.shared
    let setting = Settings.shared
    var selectedDate: Date?
    
    var textColor: UIColor?
    
    
    //FIRST STEPS
    override func viewDidLoad() {
        super.viewDidLoad()
        textColor = setting.mainText
        navigationBar = navigationController?.navigationBar
        tabBar = self.tabBarController?.tabBar
        tabBar?.barStyle = setting.style
        tabBar?.tintColor = setting.tint
        navigationItem.title = "Monat"
        setupCalendarView()
        scrollToToday()
        createSwipes()
        tableView.reloadData()
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound,.badge,.alert]) { (didAllow, error) in
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpBackground()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.dateFormatter.dateFormat = "dd.MM.yyyy"
        let selectedDate = calendarView.selectedDates[0]
        
        let date = self.dateFormatter.string(from: selectedDate)
        remindController.setTodaysReminders(from: date)
        remindController.setTodaysDoneReminders(from: date)
        tableView.reloadData()
        calendarView.reloadData()
    }
    
    //SETUP METHODS
    func setupCalendarView(){
        //Setup Spacings
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        //Setup Year and Date in Navigation Bar
        calendarView.visibleDates { (visibleDates) in
        self.setupViewsOfCalendar(from: visibleDates)
        }
    }
    func setUpBackground(){
        let barStyle = setting.style
        let barTint = setting.tint
        let color = setting.background
        backgroundView.backgroundColor = color
        calendarView.backgroundColor = color
        
        if setting.runtimeDarkMode == false {
            backgroundView.layer.borderWidth = 1
            backgroundView.layer.borderColor = Colors.lightBorder.cgColor
        }
        
        navigationBar?.barStyle = barStyle
        navigationBar?.tintColor = barTint
        
        let daysColor = setting.subText
        
        var labels = daysStack.subviews as? [UILabel]
        var i = 0
        let count = labels?.count
        while i < count! {
            let actualLabel = labels![i]
            actualLabel.textColor = daysColor
            i += 1
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
    
    //SWIPING GESTURE METHODS
    func createSwipes() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            scrollInPast(value: -1)
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            scrollInFuture(value: 1)
        }
    }
    
    //NAVIGATION METHODS
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? "" {
            
        case "ShowDetails":
            guard let reminderDetailViewController = segue.destination as? DetailTableViewController
                else {
                    fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedRemindCell = sender as? ReminderTableViewCell
                else {
                    fatalError("Unexpected sender: \(String(describing: sender))")
            }
            guard let indexPath = tableView.indexPath(for: selectedRemindCell)
                else {
                    fatalError("The selected cell dont exist")
            }
            
            
            let selectedReminder: Reminder
            if indexPath.section == 0 {
                selectedReminder = remindController.todaysReminders[indexPath.row]
            } else {
                selectedReminder = remindController.getDoneReminder(at: indexPath)
                reminderDetailViewController.index = indexPath.row
            }
            reminderDetailViewController.remind = selectedReminder
            if selectedReminder.doneDate == nil {
                reminderDetailViewController.archived = false
            }else{
                reminderDetailViewController.archived = true
            }
            
            
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
    
    //CALENDAR SCROLLING
    func scrollToToday(){
        calendarView.scrollToDate(Date(), animateScroll: false)
        calendarView.selectDates(from: Date(), to: Date())
    }
    
    @IBAction func scrollToday(_ sender: Any) {
        scrollToToday()
        
    }
    func scrollInFuture(value: Int){
        let actual = calendarView.selectedDates[0]
        let calendar = Calendar.current
        let future = calendar.date(byAdding: Calendar.Component.day, value: value, to: actual)!
        
        calendarView.scrollToDate(future)
        calendarView.selectDates(from: future, to: future)
    }
    func scrollInPast(value: Int){
        let actual = calendarView.selectedDates[0]
        let calendar = Calendar.current
        let future = calendar.date(byAdding: Calendar.Component.day, value: value, to: actual)!
        
        calendarView.scrollToDate(future)
        calendarView.selectDates(from: future, to: future)
    }
    
    //HANDLING CALENDAR LOOKS
    private func handleTextColors(validCell: RemindCollectionCell, cellState: CellState){
        if cellState.isSelected {
            validCell.dateLabel.textColor = textColor!
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                validCell.dateLabel.textColor = textColor!
            } else {
                validCell.dateLabel.textColor = UIColor.lightGray
            }
        }
    }
    
    private func handleCellSelected(validCell: RemindCollectionCell, cellState: CellState){
        validCell.selectedView.backgroundColor = setting.background
        validCell.selectedView.layer.borderWidth = 2
        validCell.selectedView.layer.borderColor = textColor!.cgColor
        
        if cellState.isSelected {
            validCell.selectedView.isHidden = false
        } else {
                validCell.selectedView.isHidden = true
        }
    }
    
    private func handleEventDots(cell: RemindCollectionCell, cellState: CellState){
        let cellDate = cellState.date
        let eventCode = remindController.isThereAReminder(at: cellDate)
        switch eventCode {
        case 0:
            cell.eventView.isHidden = true
        case 1:
            cell.eventView.isHidden = false
            cell.eventView.backgroundColor = PriorityMngr.getColorOf(priority: 0, colorMode: setting.colorMode)
        case 2:
            cell.eventView.isHidden = false
            cell.eventView.backgroundColor = PriorityMngr.getColorOf(priority: 2, colorMode: setting.colorMode)
        default:
            cell.eventView.isHidden = true
            print("Fail to set EventDot")
        }
    }
    
    // CONFIGURATION CELL
    func configure(cell: JTAppleCell?, cellState: CellState){
        guard let reminderCell = cell as? RemindCollectionCell else { return }
        handleTextColors(validCell: reminderCell, cellState: cellState)
        handleCellSelected(validCell: reminderCell, cellState: cellState)
        handleEventDots(cell: reminderCell, cellState: cellState)
    }
}

extension CalendarViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.timeZone = Calendar.current.timeZone
        dateFormatter.locale = Calendar.current.locale
        
        let startDate = dateFormatter.date(from: "01.11.2017")!
        let endDate = dateFormatter.date(from: "31.12.2022")!
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 1, generateInDates: .forFirstMonthOnly, generateOutDates: .off, firstDayOfWeek: .monday)
        return parameters
    }
}

extension CalendarViewController: JTAppleCalendarViewDelegate{
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {}
    
    //Display Cell
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "RemindCollectionCell", for: indexPath) as! RemindCollectionCell
        cell.dateLabel.text = cellState.text
        configure(cell: cell, cellState: cellState)
        return cell
    }
    
    //SELECT
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configure(cell: cell, cellState: cellState)
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let actual = dateFormatter.string(from: date)
        remindController.setTodaysReminders(from: actual)
        remindController.setTodaysDoneReminders(from: actual)
        self.selectedDate = date
        tableView.reloadData()
    }
    
    //UNSELECT (select another date)
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configure(cell: cell, cellState: cellState)
    }
    
    //SCROLL to next Week
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows: Int
        if remindController.todaysReminders.count+remindController.todaysDoneReminders.count == 0 {
            numberOfRows = 0
            tableView.isHidden = true
            noDataLabel.isHidden = false
        } else {
            if section == 0 {
                numberOfRows = remindController.todaysReminders.count
            } else {
                numberOfRows = remindController.todaysDoneReminders.count
            }
            tableView.isHidden = false
            noDataLabel.isHidden = true
        }
        return numberOfRows
    }
    
    public  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let cellIdentifier = "ReminderTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ReminderTableViewCell
            else {
                fatalError("Fehler beim Konfigurieren der Zelle")
        }
        
        let remind: Reminder
        if indexPath.section == 0 {
            remind = remindController.getTodaysReminder(at: indexPath)
            let attributedString = NSMutableAttributedString(string: remind.title)
            attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 0, range: NSMakeRange(0, attributedString.length))
            cell.titleLabel.attributedText = attributedString
            cell.dateLabel.text = dateController.writeTime(from: remind.date)
            cell.priorityLabel.backgroundColor = PriorityMngr.getColorOf(priority: remind.priority, colorMode: setting.colorMode)
            
            if remind.priority > 1 {
                cell.titleLabel.font = UIFont.systemFont(ofSize: 19, weight: UIFont.Weight.bold)
                cell.dateLabel.font = UIFont.systemFont(ofSize: 19, weight: UIFont.Weight.bold)
            }else {
                cell.titleLabel.font = UIFont.systemFont(ofSize: 19, weight: UIFont.Weight.regular)
                cell.dateLabel.font = UIFont.systemFont(ofSize: 19, weight: UIFont.Weight.regular)
            }
        } else {
            remind = remindController.getTodaysDoneReminder(at: indexPath)
            
            let attributedString = NSMutableAttributedString(string: remind.title)
            attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, attributedString.length))
            cell.titleLabel.attributedText = attributedString
            cell.titleLabel.font = UIFont.systemFont(ofSize: 19, weight: UIFont.Weight.thin)
            cell.dateLabel.font = UIFont.systemFont(ofSize: 19, weight: UIFont.Weight.thin)
            
            cell.dateLabel.text = dateController.writeTime(from: remind.date)
            cell.priorityLabel.backgroundColor = PriorityMngr.getColorOf(priority: remind.priority, colorMode: setting.colorMode)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Offene Erinnerungen"
        } else {
            if self.remindController.todaysDoneReminders.count != 0 {
                return "Erledigte Erinnerungen"
            }else {
                return ""
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 0 {
            let edit = UITableViewRowAction(style: .normal, title: "Bearbeiten", handler: { (action, index) in
                print("Ofenne Erinnerung bearbeiten")
                let selectedReminder = self.remindController.getTodaysReminder(at: indexPath)
                self.performSegue(withIdentifier: "editDirectly", sender: selectedReminder)
                self.remindController.setToday(from: self.dateController.writeDate(from: self.calendarView.selectedDates[0]))
            })
            edit.backgroundColor = Colors.blue
            
            let done = UITableViewRowAction(style: .normal, title: "Erledigen", handler: { (action, index) in
                print("offene erinnerung erledigen")
                self.remindController.markAsDone(reminder: self.remindController.todaysReminders[indexPath.row])
                self.remindController.setToday(from: self.dateController.writeDate(from: self.calendarView.selectedDates[0]))
                self.reload()
            })
            done.backgroundColor = UIColor.red
            return [done, edit]
        } else {
            let del = UITableViewRowAction(style: .normal, title: "Löschen", handler: { (action, index) in
                print("erledigte löschen")
                let selectedReminder = self.remindController.getTodaysDoneReminder(at: indexPath)
                self.remindController.deleteDoneReminder(at: selectedReminder.myPosition)
                self.remindController.setToday(from: self.dateController.writeDate(from: self.calendarView.selectedDates[0]))
                self.reload()
            })
            del.backgroundColor = UIColor.red
            
            let redo = UITableViewRowAction(style: .normal, title: "Erneuern", handler: { (action, index) in
                print("erledigte erneuern")
                let selectedReminder = self.remindController.getTodaysDoneReminder(at: indexPath)
                self.remindController.markAsOpen(reminder: selectedReminder)
                self.remindController.setToday(from: self.dateController.writeDate(from: self.calendarView.selectedDates[0]))
                self.reload()
            })
            redo.backgroundColor = UIColor.gray
            return [del, redo]
        }
    }
    
    private func reload(){
        let date = dateController.writeDate(from: calendarView.selectedDates[0])
        remindController.setTodaysReminders(from: date)
        remindController.setTodaysDoneReminders(from: date)
        tableView.reloadData()
        calendarView.reloadData()
    }
}

extension CalendarViewController: ScrollingDelegate {
    func didSelectDate(sender: ScrollingPopUp, date: Date) {
        calendarView.scrollToDate(date)
        calendarView.selectDates([date])
    }
}
