//  ScrollingVC.swift
//  WeekView
//
//  Created by Kay Boschmann on 12.12.17.
//  Copyright © 2017 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import UIKit
import JTAppleCalendar

class ScrollingPopUp: UIViewController {
    let setting = Settings.shared
    let remindControll = ReminderManager.shared
    public var delegate: ScrollingDelegate?
    var selectedDate = Date()
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var toolBar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendarView()
        setUpBackground()
        layoutViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupViewsOfCalendar(from: calendarView.visibleDates())
    }
    
    private func layoutViews() {
        toolBar.roundCorners(corners: [.topLeft, .topRight], radius: 15)
        //mainView.roundCorners(corners: [.topLeft, .topRight], radius: 15)
    }
    
    private func setUpBackground() {
        let color = setting.backgroundColor
        mainView.backgroundColor = color
        calendarView.backgroundColor = color
        titleLabel.textColor = setting.mainTextColor
        toolBar.barStyle = setting.barStyle
    }
    
    func setupCalendarView(){
        //Setup Spacings
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        //Setup Year and Date in Navigation Bar
        calendarView.visibleDates { (visibleDates) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
        calendarView.scrollToDate(Date(), animateScroll: false)
        calendarView.selectDates(from: Date(), to: Date())
        selectedDate = Date()
    }
    
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo){
        let dateFormatter = DateFormatter()
        let date = visibleDates.monthDates.first!.date
        dateFormatter.dateFormat = "yy"
        let year = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "MMMM"
        let month = dateFormatter.string(from: date)
        titleLabel.text = month + " '"+year
    }
    
    private func handleCellSelected(validCell: ScrollingCell, cellState: CellState){
        validCell.selectedView.backgroundColor = setting.backgroundColor
        validCell.selectedView.layer.borderWidth = 2
        validCell.selectedView.layer.borderColor = setting.mainTextColor.cgColor
        
        if cellState.isSelected {
            validCell.selectedView.isHidden = false
        } else {
            validCell.selectedView.isHidden = true
        }
    }
    
    private func handleTextColors(validCell: ScrollingCell, cellState: CellState){
        if cellState.dateBelongsTo == .thisMonth {
            validCell.dateLabel.textColor = setting.mainTextColor
        } else {
            validCell.dateLabel.textColor = setting.subTextColor
        }
    }
    
    func configureCell(cell: JTAppleCell?, cellState: CellState){
        guard let scrollingCell = cell as? ScrollingCell else {return}
        handleCellSelected(validCell: scrollingCell, cellState: cellState)
        handleTextColors(validCell: scrollingCell, cellState: cellState)
    }
    
    @IBAction func nextMonth(_ sender: Any) {
        var dateComponents = DateComponents()
        dateComponents.month = 1
        let visibleDates = calendarView.visibleDates().monthDates.first
        let firstDate = visibleDates.map{ $0.date }
        let nextMonth = Calendar.current.date(byAdding: dateComponents, to: firstDate!)
        calendarView.scrollToDate(nextMonth!)
    }
    
    @IBAction func previousMonth(_ sender: Any) {
        var dateComponents = DateComponents()
        dateComponents.month = -1
        let visibleDates = calendarView.visibleDates().monthDates.first
        let firstDate = visibleDates.map{ $0.date }
        let previousMonth = Calendar.current.date(byAdding: dateComponents, to: firstDate!)
        calendarView.scrollToDate(previousMonth!)
    }
    
    @IBAction func goToDate(_ sender: Any) {
        delegate?.scrollingPopUp(sender: self, wantScrollTo: selectedDate)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
extension ScrollingPopUp: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.timeZone = Calendar.current.timeZone
        dateFormatter.locale = Calendar.current.locale
        
        let startDate = dateFormatter.date(from: "01.11.2017")!
        let endDate = dateFormatter.date(from: "31.12.2022")!
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate, firstDayOfWeek: .monday)
        return parameters
    }
    
}
extension ScrollingPopUp: JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {}
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "ScrollingCell", for: indexPath) as! ScrollingCell
        cell.dateLabel.text = cellState.text
        configureCell(cell: cell, cellState: cellState)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(cell: cell, cellState: cellState)
        selectedDate = date
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }
}
