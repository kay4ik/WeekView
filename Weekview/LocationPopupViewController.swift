//
//  LocationPopupViewController.swift
//  Weekview
//
//  Created by Kay Boschmann on 16.11.17.
//  Copyright © 2017 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import UIKit
import MapKit

class LocationPopupViewController: UIViewController, UITextFieldDelegate {

    let locationManager = LocationManager.sharedInstance
    var locationView: LocationViewController!
    @IBOutlet weak var searchField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closePopUp(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func searchButton(_ sender: Any) {
        let text = searchField.text
        searchLocation(from: text!)
        dismiss(animated: true, completion: nil)
    }
    
    func searchLocation(from: String){
        let address = from
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {
                    // handle no location found
                    self.nothingFound()
                    return
            }
        }
    }
    
    func nothingFound() {
        let uiAlert = UIAlertController(title: "Kein Ergebnis",
                                        message: "Auf ihr Suchergebnis wurde nichts gefunden.", preferredStyle: UIAlertControllerStyle.alert)
        self.present(uiAlert, animated: true, completion: nil)
        
        uiAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
            self.searchField.text = ""
        }))
    }
    
    //override func prepare(for segue: UIStoryboardSegue, sender: Any?) {}
}
