//
//  SettingView.swift
//  Weekview
//
//  Created by Kay Boschmann on 14.11.17.
//  Copyright © 2017 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//
import UIKit

class SettingView: UIViewController {
    let settingController = SettingController.getInstance()
    let prioController = PrioritySingleton.getInstance()
    let remindController = ReminderSingleton.getInstance()
    
    var navigationBar: UINavigationBar?
    
    @IBOutlet weak var darkNavToggler: UISwitch!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var colorShowView: UIView!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var extendButton: UIButton!
    @IBOutlet weak var normalPrioColorLabel: UILabel!
    @IBOutlet weak var middlePrioColorLabel: UILabel!
    @IBOutlet weak var highPrioColorLabel: UILabel!
    @IBOutlet weak var prioColorLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar = self.navigationController?.navigationBar
        navigationItem.title = "Einstellungen"
        //let saveButon = UIBarButtonItem(image: #imageLiteral(resourceName: "floppy"), style: .plain, target: self, action: #selector(saveButtonPressed(_:)))
        //self.navigationItem.rightBarButtonItem = saveButon
        self.viewHeight.constant = 25
        self.normalPrioColorLabel.alpha = 0
        self.middlePrioColorLabel.alpha = 0
        self.highPrioColorLabel.alpha = 0
        self.prioColorLabel.alpha = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupBackground()
        darkNavToggler.setOn(settingController.setting.darkMode, animated: false)
        buttonView.backgroundColor = settingController.getBackgroundColor()
    }
    
    func setupBackground() {
        navigationBar?.barStyle = settingController.getBarStyle()
        navigationBar?.tintColor = settingController.getBarTint()
        
        normalPrioColorLabel.backgroundColor = prioController.getColorOf(priority: 0)
        middlePrioColorLabel.backgroundColor = prioController.getColorOf(priority: 1)
        highPrioColorLabel.backgroundColor = prioController.getColorOf(priority: 2)
    }
    
    
    @IBAction func changedDarkmode(_ sender: Any) {
        settingController.setting.darkMode = darkNavToggler.isOn
        
        let exitAppAlert = UIAlertController(title: "Neustart Notwendig",
                                             message: "Um die Einstellungen zu übernehmen muss die App geschlossen werden. Beim nächsten Start der App sind die Einstellungen übernommen. \nKlicken Sie Schließen um die App jetzt zu beenden.",
                                             preferredStyle: .actionSheet)
        
        let resetApp = UIAlertAction(title: "Schließen", style: .destructive) {
            (alert) -> Void in
            // home button pressed programmatically - to thorw app to background
            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
            // terminaing app in background
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                exit(EXIT_SUCCESS)
            })
        }
        
        let laterAction = UIAlertAction(title: "Später", style: .cancel) {
            (alert) -> Void in
            self.dismiss(animated: true, completion: nil)
        }
        
        exitAppAlert.addAction(resetApp)
        exitAppAlert.addAction(laterAction)
        present(exitAppAlert, animated: true, completion: nil)
        
    }
    
    @IBAction func expandOrReduce(_ sender: Any) {
        if viewHeight.constant == 25 {
            UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.transitionCurlUp, animations: {
                self.viewHeight.constant = 90
                self.view.layoutIfNeeded()
                self.extendButton.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
                
            }, completion: nil)
            showObjects(false)
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.transitionCurlUp, animations: {
                self.viewHeight.constant = 25
                self.view.layoutIfNeeded()
                self.extendButton.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) * 180.0)
            }, completion: nil)
            showObjects(true)
        }
    }
    
    /*@IBAction func saveButtonPressed(_ sender: Any) {
        setupNavBar()
        settingController.setting.darkMode = darkNavToggler.isOn
        let barStyle = settingController.getBarStyle()
        let barTint = settingController.getBarTint()
        let tabBar = self.tabBarController?.tabBar
        tabBar?.barStyle = barStyle
        tabBar?.tintColor = barTint
        dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }*/
    
    @IBAction func loadSampleReminders(_ sender: Any) {
        self.remindController.loadSampleReminders()
        self.remindController.saveData()
        self.erfolgreich()
    }
    
    @IBAction func deleteAllMainReminder(_ sender: Any) {
        let uiAlert = UIAlertController(title: "Sind Sie sich sicher?",
                                        message: "Alle offenen Erinnerungen werden unwiederruflich gelöscht! \nDas kann nicht Rückgängig gemacht werden!", preferredStyle: UIAlertController.Style.alert)
        self.present(uiAlert, animated: true, completion: nil)
        
        uiAlert.addAction(UIAlertAction(title: "Löschen", style: .destructive, handler: { action in
            self.remindController.reminders.removeAll()
            self.remindController.saveData()
            self.erfolgreich()
        }))
        
        uiAlert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: { action in        }))
    }
    
    @IBAction func deleteAllDoneReminder(_ sender: Any) {
        let uiAlert = UIAlertController(title: "Sind Sie sich sicher?",
                                        message: "Alle archivierten Erinnerungen werden unwiederruflich gelöscht! \nDas kann nicht Rückgängig gemacht werden!", preferredStyle: UIAlertController.Style.alert)
        self.present(uiAlert, animated: true, completion: nil)
        
        uiAlert.addAction(UIAlertAction(title: "Löschen", style: .destructive, handler: { action in
            self.remindController.deleteAllDoneReminder()
            self.remindController.saveDoneReminder()
            self.erfolgreich()
        }))
        
        uiAlert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: { action in        }))
    }
    
    private func showObjects(_ show: Bool) {
        var alpha: CGFloat
        if !show {
            alpha = 1
        } else {
            alpha = 0
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.transitionCurlUp, animations: {
            self.normalPrioColorLabel.alpha = alpha
            self.middlePrioColorLabel.alpha = alpha
            self.highPrioColorLabel.alpha = alpha
            self.prioColorLabel.alpha = alpha
        } , completion: nil)
    }
    
    private func erfolgreich(){
        self.performSegue(withIdentifier: "seccess", sender: nil)
        
    }
}
