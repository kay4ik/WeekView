//
//  WeekviewTests.swift
//  WeekviewTests
//
//  Created by Kay Boschmann on 05.09.17.
//  Copyright © 2017 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import XCTest
@testable import Weekview

class WeekviewTests: XCTestCase {
    let remindController = ReminderSingleton.getInstance()
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testHello() {
        let reminder = Reminder(title: "XCTests",
                                date: Date(),
                                notice: "Provisorische Notiz",
                                priority: 0,
                                done: nil,
                                location: nil)
        remindController.save(reminder: reminder!)
        _ = remindController.reminders[remindController.reminders.count - 1]
        
    }
    
}
