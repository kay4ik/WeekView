//
//  SettingTableViewController.swift
//  Weekview
//
//  Created by Kay Boschmann on 22.10.18.
//  Copyright © 2018 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {
    private let setting = Settings.shared
    private let remindController = ReminderManager.shared
    
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var sortModeSwitch: UISwitch!
    @IBOutlet weak var trafficSwitch: UISwitch!
    @IBOutlet weak var mapTypeLabel: UILabel!
    @IBOutlet weak var colorModeLabel: UILabel!
    @IBOutlet weak var showDoneReminderSwitch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSwitches()
        let navigation = navigationController?.navigationBar
        navigation?.barStyle = setting.style
        navigation?.tintColor = setting.tint
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setMapTypeLabel(setting.mapType)
        setColorModeLabel(setting.colorMode)
    }

    // MARK: - Actions
    @IBAction func changeTrafficMode(_ sender: Any) {
        setting.showTraffic = trafficSwitch.isOn
    }
    
    @IBAction func changeDarkMode(_ sender: Any) {
        setting.set(darkMode: darkModeSwitch.isOn)
        restartRequest()
    }
    
    @IBAction func changeSortMode(_ sender: Any) {
        setting.sortOnTime = sortModeSwitch.isOn
    }
    
    @IBAction func changeShowDoneReminder(_ sender: Any) {
        setting.showDoneReminders = showDoneReminderSwitch.isOn
    }
    
    @IBAction func loadSampleReminders(_ sender: Any) {
        self.remindController.loadSamples()
        self.remindController.save()
        let uiAlert = UIAlertController(title: "Erledigt",
                                        message: "Die Beispiel Erinnerungen wurden geladen.", preferredStyle: .actionSheet)
        self.present(uiAlert, animated: true, completion: nil)
        
        // change to desired number of seconds (in this case 5 seconds)
        let when = DispatchTime.now() + 1.5
        DispatchQueue.main.asyncAfter(deadline: when){
            // your code with delay
            uiAlert.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func loadStandardSettings(_ sender: Any) {
        setting.loadStandardSettings()
        restartRequest()
    }
    
    @IBAction func deleteDoneReminder(_ sender: Any) {
        let uiAlert = UIAlertController(title: "Sind Sie sich sicher?",
                                        message: "Alle erledigten Erinnerungen werden unwiederruflich gelöscht! \nDas kann nicht Rückgängig gemacht werden!", preferredStyle: .actionSheet)
        self.present(uiAlert, animated: true, completion: nil)
        
        uiAlert.addAction(UIAlertAction(title: "Löschen", style: .destructive, handler: { action in
            self.remindController.deleteAllDoneReminder()
            self.remindController.save()
        }))
        
        uiAlert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: { action in        }))
    }
    
    @IBAction func deleteAllData(_ sender: Any) {
        let uiAlert = UIAlertController(title: "Sind Sie sich sicher?",
                                        message: "Alle Erinnerungen werden unwiederruflich gelöscht! \nDas kann nicht Rückgängig gemacht werden!", preferredStyle: .actionSheet)
        self.present(uiAlert, animated: true, completion: nil)
        
        uiAlert.addAction(UIAlertAction(title: "Löschen", style: .destructive, handler: { action in
            self.remindController.deleteAll()
            self.remindController.deleteAllDoneReminder()
            self.remindController.save()
        }))
        
        uiAlert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: { action in        }))
    }
    // MARK: - Functions
    
    private func setMapTypeLabel(_ mode: Int) {
        let s: String
        switch mode {
        case 0:
            s = "Standard"
        case 1:
            s = "Satelit"
        case 2:
            s = "Hybrid"
        default:
            fatalError()
        }
        mapTypeLabel.text = s
    }
    
    private func setColorModeLabel(_ mode: Int) {
        let s: String
        switch mode {
        case 0:
            s = "Standard"
        case 1:
            s = "Ampel"
        case 2:
            s = "Pink"
        case 3:
            s = "Blau"
        case 4:
            s = "Grün"
        default:
            fatalError()
        }
        colorModeLabel.text = s
    }
    
    private func setSwitches() {
        darkModeSwitch.setOn(setting.runtimeDarkMode, animated: false)
        trafficSwitch.setOn(setting.showTraffic, animated: false)
        sortModeSwitch.setOn(setting.sortOnTime, animated: false)
        showDoneReminderSwitch.setOn(setting.showDoneReminders, animated: false)
    }
    
    private func restartRequest(){
        let title = "Neustart Notwendig"
        let msg = "Um die Einstellungen zu übernehmen muss die App geschlossen werden. Beim nächsten Start der App sind die Einstellungen übernommen. \nKlicken Sie Schließen um die App jetzt zu beenden."
        
        let exitAppAlert = UIAlertController(title: title, message: msg, preferredStyle: .actionSheet)
        
        let resetApp = UIAlertAction(title: "Schließen", style: .destructive) {
            (alert) -> Void in self.exitApp()
        }
        
        let laterAction = UIAlertAction(title: "Später", style: .cancel) {
            (alert) -> Void in self.dismiss(animated: true, completion: nil)
        }
        
        exitAppAlert.addAction(resetApp)
        exitAppAlert.addAction(laterAction)
        present(exitAppAlert, animated: true, completion: nil)
    }
    
    private func exitApp(){
        // home button pressed programmatically - to thorw app to background
        UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        // terminaing app in background
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            exit(EXIT_SUCCESS)
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
