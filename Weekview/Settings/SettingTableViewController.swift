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
    @IBOutlet weak var sortSettingLabel: UILabel!
    @IBOutlet weak var trafficSwitch: UISwitch!
    @IBOutlet weak var mapTypeLabel: UILabel!
    @IBOutlet weak var colorModeLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSwitches()
        sortSettingLabel.text = "Zeit"
        let navigation = navigationController?.navigationBar
        navigation?.barStyle = setting.style
        navigation?.tintColor = setting.tint
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setMapTypeLabel(setting.mapType)
        setColorModeLabel(setting.colorMode)
        sortSettingLabel.text = "Zeit"
    }

    // MARK: - Actions
    @IBAction func changeTrafficMode(_ sender: Any) {
        setting.showTraffic = trafficSwitch.isOn
    }
    
    @IBAction func changeDarkMode(_ sender: Any) {
        setting.set(darkMode: darkModeSwitch.isOn)
        restartRequest()
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
    
    // MARK: - Table view data source

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension UIViewController {
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    } }
