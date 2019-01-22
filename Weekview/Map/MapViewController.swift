//
//  MapViewController.swift
//  Weekview
//
//  Created by Kay Boschmann on 26.10.18.
//  Copyright © 2018 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import UIKit
import MapKit
import GooglePlaces

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    let settings = Settings.shared
    var places: GMSPlacesClient? = nil
    let core = CLLocationManager()
    let reminderManager = ReminderManager.shared
    var selected: Reminder?
    var location: Location?
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var detailTitleLabel: UILabel!
    @IBOutlet weak var detailSubtitleLabel: UILabel!
    @IBOutlet weak var detailAdressLabel: UILabel!
    @IBOutlet weak var showReminderButton: UIButton!
    @IBOutlet weak var showRouteButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        core.delegate = self
        places = GMSPlacesClient.shared()
        checkGPSAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        useSettings()
        setupDesign()
    }

    
    private func setupDesign() {
        toolbar.barStyle = settings.barStyle
        toolbar.tintColor = settings.barTintColor
        detailView.backgroundColor = settings.backgroundColor
        detailView.alpha = 0.9
        toolbar.roundCorners(corners: [.topLeft, .bottomLeft], radius: 22.5)
    
        for subview in detailView.subviews {
            if let label = subview as? UILabel {
                label.textColor = settings.mainTextColor
            }
            else if let button = subview as? UIButton {
                button.tintColor = settings.barTintColor
            }
        }
        
    }
    
    private func useSettings() {
        mapView.showsTraffic = settings.mapShowTraffic
        mapView.showsCompass = true
        mapView.mapType = getMapType(settings.mapType)
    }
    
    private func getMapType(_ of: Int) -> MKMapType{
        switch of {
        case 0:
            return MKMapType.standard
        case 1:
            return MKMapType.satellite
        case 2:
            return MKMapType.hybrid
        default:
            fatalError("Invalid Number for MapType")
        }
    }
    
    private func checkGPSAuthorization() {
        let authorizationCode = CLLocationManager.authorizationStatus()
        if authorizationCode != .authorizedWhenInUse {
            if Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") != nil {
                core.requestWhenInUseAuthorization()
            } else {
                print("No Description provided")
            }
        }
    }
    
    @IBAction func search(_ sender: Any) {
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        acController.navigationController?.navigationBar.tintColor = settings.barTintColor
        present(acController, animated: true, completion: nil)
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
extension MapViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        dismiss(animated: true, completion: nil)
        handleAddressing(place)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: \(error)")
        dismiss(animated: true, completion: nil)
    }
    
    // User cancelled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        print("Autocomplete was cancelled.")
        dismiss(animated: true, completion: nil)
    }
    
    func handleAddressing(_ place: GMSPlace){
        let count = place.addressComponents?.count
        var number: String?
        var street: String?
        var city: String?
        var postalCode: String?
        
        var i = 0
        while i < count! {
            let type = place.addressComponents?[i]
            
            switch type!.type {
            case "street_number":
                number = type!.name
                print("streetnumber set to: \(String(describing: number))")
            case "route":
                street = type!.name
                print("street set to: \(String(describing: street))")
            case "locality":
                city = type!.name
                print("city set to: \(String(describing: city))")
            case "postal_code":
                postalCode = type!.name
                print("ZIP set to: \(String(describing: postalCode))")
            default:
                print("NOTHING: \(type!.type)")
            }
            i += 1
        }
        if street == nil || city == nil{
            let uiAlert = UIAlertController(title: "Üngültiger Ort",
                                            message: "Der ausgewählte Ort muss über folgende attribute verfügen: \nOrt und Straße \nBitte suchen Sie präziser.", preferredStyle: UIAlertController.Style.alert)
            self.present(uiAlert, animated: true, completion: nil)
            
            uiAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
            }))
        } else {
            let coordinates = place.coordinate
            location = Location(route: street!, street_number: number,
                             postal_code: postalCode, city: city!,
                             latitude: coordinates.latitude , longitude: coordinates.longitude)
        }
    
    
}
}
