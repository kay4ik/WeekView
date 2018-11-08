//
//  EditTableViewController.swift
//  Weekview
//
//  Created by Kay Boschmann on 23.10.18.
//  Copyright © 2018 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import UIKit
import MapKit

class EditTableViewController: UITableViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var noticeTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var priorityPicker: UISegmentedControl!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var navigationBar: UINavigationBar?
    
    var remind: Reminder?
    let remindController = ReminderManager.shared
    let setting = Settings.shared
    let notifyController = NotificationController.shared
    var alreadyExist = false
    var selectedDate: Date?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar = self.navigationController?.navigationBar
        titleTextField.delegate = self
        noticeTextView.delegate = self
        datePicker.locale = NSLocale(localeIdentifier: "de_DE") as Locale
        setupBackground()
        mapView.removeAnnotations(mapView.annotations)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !alreadyExist {
            datePicker.minimumDate = Date()
            datePicker.date = self.selectedDate ?? Date()
            navigationItem.title = "Neue Erinnerung"
            remind = Reminder()
        }
        else {
            setReminderData()
            navigationItem.title = "Bearbeiten"
        }
        setLocationLabel()
        setNoticeText()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        handleMapView()
    }
    
    func handleMapView() {
        let title: String
        if remind!.title == "" {
            title = "Neue Erinnerung"
        }
        else {
            title = remind!.title
        }
        
        if remind!.location != nil {
            let location = remind!.location!.coordinates
            display(location: location, titel: title, subtitel: "")
        }
        
    }
    
    func setReminderData(){
        titleTextField.text = remind!.title
        datePicker.date = remind!.date
        noticeTextView.text = remind!.notice
        priorityPicker.selectedSegmentIndex = (remind!.priority)
        priorityLabel.backgroundColor = PriorityMngr.getColorOf(priority: (remind!.priority), colorMode: setting.colorMode)
    }
    
    func setLocationLabel() {
        if remind!.location == nil {
            locationLabel.text = "Kein Standort festgelegt."
        } else {
            locationLabel.text = remind!.location?.getAddress()
        }
    }
    
    func setNoticeText(){
        if noticeTextView.text == "Keine Notiz" || noticeTextView.text.isEmpty {
            noticeTextView.text = "Keine Notiz"
            noticeTextView.textColor = UIColor.lightGray
        } else {
            noticeTextView.textColor = UIColor.black
        }
    }
    func setupBackground(){
        let barStyle = setting.style
        let barTint = setting.tint
        navigationBar?.barStyle = barStyle
        navigationBar?.tintColor = barTint
    }

    func checkEmptyTitle() {
        if titleTextField.text == "" {
            let alert = UIAlertController(title: "Geben Sie einen Titel ein:", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            alert.addTextField(configurationHandler: { textField in
                textField.placeholder = "Titel der Erinnerung"
            })
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                if let input = alert.textFields?.first?.text {
                    self.titleTextField.text = input
                }
            }))
            self.present(alert, animated: true)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func save(_ sender: Any) {
        checkEmptyTitle()
        
        remind!.title = titleTextField.text ?? "No Title"
        remind!.date = datePicker.date
        remind!.notice = noticeTextView.text
        
        if alreadyExist {
            remindController.update(remind!)
        }
        else {
            remindController.insert(remind!)
            if remind!.priority >= 1 {
                notifyController.newNotify(with: remind!)
            }
        }
        
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true);
    }
    
    @IBAction func prioPickerChanged(_ sender: Any) {
        let selected = priorityPicker.selectedSegmentIndex
        remind!.priority = selected
        priorityLabel.backgroundColor = PriorityMngr.getColorOf(priority: selected, colorMode: setting.colorMode)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let viewController = segue.destination as? LocationViewController else {
            fatalError("Unknown destination in EditLocation")
        }
        viewController.local = self.remind!.location
        viewController.remTitel = self.remind!.title
        viewController.delegate = self
    }

}
extension EditTableViewController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if noticeTextView.textColor == UIColor.lightGray {
            noticeTextView.text = nil
            noticeTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        remind!.notice = noticeTextView.text
        if noticeTextView.text.isEmpty {
            noticeTextView.text = "Keine Notiz"
            noticeTextView.textColor = UIColor.lightGray
        }
    }
}
extension EditTableViewController {
    func display(location: CLLocation, titel: String?, subtitel: String?){
        if mapView.annotations.count > 0 {
            mapView.removeAnnotations(mapView.annotations)
        }
        let coordinate = location.coordinate
        mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude , longitude: coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: true)
        
        let locationPinCoord = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationPinCoord
        annotation.title = titel ?? ""
        annotation.subtitle = subtitel ?? ""
        
        mapView.addAnnotation(annotation)
        mapView.showAnnotations([annotation], animated: true)
    }
}
extension EditTableViewController: LocationViewControllerDelegate {
    func LocationViewControllerDidSave(sender: LocationViewController, location: Location) {
        remind!.location = location
        locationLabel.text = remind!.getOneRowLocation()
    }
}
