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
    private let dateController = DateSingleton.shared
    private let settings = Settings.shared
    
    private var selectedDate: Date?
    private var navigationBar: UINavigationBar?
    private var tabBar: UITabBar?
    private var dateReminders: [Reminder]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar = navigationController?.navigationBar
        tabBar = self.tabBarController?.tabBar
        setUpColors()
        setupCalendarView()
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
}
