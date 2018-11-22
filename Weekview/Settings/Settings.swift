//
//  SettingController.swift
//  Weekview
//
//  Created by Kay Boschmann on 14.11.17.
//  Copyright © 2017 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//
import MapKit
import UIKit
class Settings {
//    var options = Options()
//    var bar = Bar()
    public var runtimeDarkMode: Bool!
    
    public func loadStandardSettings() {
        darkMode = false
        colorMode = 0
        sortOnTime = true
        showTraffic = false
        mapType = 0
    }
    
    public func setupRuntime() {
        runtimeDarkMode = darkMode
    }
    
    public func set(darkMode: Bool) {
        self.darkMode = darkMode
    }
    
    private init() {}
    class var shared : Settings {
        struct Static {
            static let sharedInstance : Settings = Settings()
        }
        return Static.sharedInstance
    }
    
    
    //MARK: - OPTIONS
    // MARK: - Design Settings
    private var darkMode: Bool{ //RUNTIME VAR IN CONTROLLER
        get {
            if isNotSet(key: "darkMode") {
                return false
            }
            return UserDefaults.standard.bool(forKey: "darkMode")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "darkMode")
        }
    }
    
    var colorMode: Int{
        get{
            if isNotSet(key: "prioColorMode") {
                return 0
            }
            return UserDefaults.standard.integer(forKey: "prioColorMode")
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "prioColorMode")
        }
    }
    
    // MARK: - Calendar Settings
    var sortOnTime: Bool{
        get {
            if isNotSet(key: "sortMode") {
                return true
            }
            return UserDefaults.standard.bool(forKey: "sortMode")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "sortMode")
        }
    }
    
    // MARK: - Search Settings
    var showDoneReminders: Bool {
        get {
            if isNotSet(key: "showDoneReminders") {
                return true
            }
            return UserDefaults.standard.bool(forKey: "showDoneReminders")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "showDoneReminders")
        }
    }
    
    // MARK: - Map Settings
    var showTraffic: Bool{
        get {
            if isNotSet(key: "showTraffic") {
                return false
            }
            return UserDefaults.standard.bool(forKey: "showTraffic")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "showTraffic")
        }
    }
    
    var mapType: Int{
        get {
            if isNotSet(key: "mapType") {
                return 0
            }
            return UserDefaults.standard.integer(forKey: "mapType")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "mapType")
        }
    }
    
    
    //MARK: - Bar Options
    var style: UIBarStyle {
        get {
            if runtimeDarkMode { return UIBarStyle.black }
            else { return UIBarStyle.default }
        }
    }
    
    var tint: UIColor {
        get {
            if runtimeDarkMode { return UIColor.white }
            else { return Colors.defBlue }
        }
    }
    
    //MARK: - Color Otions
    var background: UIColor{
        get {
            if runtimeDarkMode { return Colors.darkBackground }
            else { return Colors.lightBack }
        }
    }
    
    var mainText: UIColor {
        get {
            if runtimeDarkMode { return UIColor.white }
            else { return UIColor.black }
        }
    }
    
    var subText: UIColor{
        get{
            if runtimeDarkMode { return UIColor.lightGray }
            else { return UIColor.gray}
        }
    }
}

// MARK: - Functions
private func isNotSet(key: String) -> Bool{
    let check = UserDefaults.standard.object(forKey: key)
    if check == nil {
        return true
    }
    return false
}

