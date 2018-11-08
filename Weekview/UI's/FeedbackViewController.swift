//
//  FeedbackViewController.swift
//  Weekview
//
//  Created by Kay Boschmann on 24.10.18.
//  Copyright © 2018 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import UIKit
import MessageUI

class FeedbackViewController: UIViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var descField: UITextView!
    @IBOutlet weak var kindField: UISegmentedControl!
    @IBOutlet weak var sendLabel: UILabel!
    @IBOutlet weak var sendCircle: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }
    }
    
    @IBAction func sendMail(_ sender: Any) {
        if descField.text == "" {
            let msg = "Bitte fülle zuerst die Beschreibung aus!"
            provideMsg(msg: msg)
        }
        else if MFMailComposeViewController.canSendMail() {
            sendFeedback()
        }
        else {
            let msg = "Ein Fehler ist aufgetreten."
            provideMsg(msg: msg)
        }
    }
    
    
    @IBAction func emailHelp(_ sender: Any) {
        let msg = "Wenn du uns deine E-Mail adresse übermittelst, können wir dir Bescheid geben falls wir eine Antwort zu deinem anliegen haben."
        provideMsg(msg: msg)
    }
    @IBAction func descHelp(_ sender: Any) {
        let msg = "Bitte Beschreibe uns dein Anliegen. Wenn du dieses Feld nicht ausfüllst kannst du kein Feedback senden."
        provideMsg(msg: msg)
    }
    @IBAction func kindHelp(_ sender: Any) {
        let msg = "Feedback: Ein Hinweis, Lob oder Kritik von dir. \nProblem: Wenn dir ein Fehler in der App aufgefallen ist. \n\nWir bearbeiten Probleme mit höherer Priorität."
        provideMsg(msg: msg)
    }
    
    private func getMailBody() -> String {
        let br = "\n"
        let mail = emailField.text
        let desc = descField.text
        
        return mail ?? "no mail given" + br + desc! + br + "OS version: \(UIDevice.current.systemVersion)"
    }
    
    private func getProbKind() -> String{
        if kindField.selectedSegmentIndex == 0 {
            return "Feedback"
        }
        else {
            return "Problem"
        }
    }
    
    private func sendFeedback() {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        // Configure the fields of the interface.
        composeVC.setToRecipients(["boschmannkay@gmail.com"])
        composeVC.setSubject(getProbKind())
        composeVC.setMessageBody(getMailBody(), isHTML: false)
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    private func provideMsg(msg: String) {
        let uiAlert = UIAlertController(title: "Hilfe:",
                                        message: msg,
                                        preferredStyle: .actionSheet)
        self.present(uiAlert, animated: true, completion: nil)
        
        uiAlert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
    }
}
