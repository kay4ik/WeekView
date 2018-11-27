//
//  LocationViewController.swift
//  Weekview
//
//  Created by Kay Boschmann on 16.11.17.
//  Copyright © 2017 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import UIKit
import MapKit
import GooglePlaces

class LocationViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var locationView: UIView!
    
    public var delegate: LocationViewControllerDelegate?
    let placesClient = GMSPlacesClient.shared()
    let coreLocationManager = CLLocationManager()
    let setting = Settings.shared
    
    var local: Location?
    var remTitel: String?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coreLocationManager.delegate = self
        let authorizationCode = CLLocationManager.authorizationStatus()
        if authorizationCode != .authorizedWhenInUse {
            
            if Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") != nil {
                coreLocationManager.requestWhenInUseAuthorization()
            } else {
                print("No Description provided")
            }
        }
        
        mapView.showsCompass = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let color = setting.backgroundColor
        titleView.backgroundColor = color
        searchView.backgroundColor = color
        locationView.backgroundColor = color
        
        if local == nil {
            print("No location detected")
        } else {
            print("Location detected")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if local == nil {
            getCurrentLocation()
        } else {
            let nummi = local?.street_number ?? ""
            let titel = local!.route + " " + nummi
            var subtitel: String?
            if local?.postalCode == "" {
                subtitel = local!.postalCode! + " " + local!.city
            } else {
                subtitel = local!.city
            }
            display(location: local!.coordinates, titel: titel, subtitel: subtitel!)
            streetLabel.text = titel
            cityLabel.text = subtitel
        }
    }
    
    func getCurrentLocation() {
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            self.streetLabel.text = "Ortung nicht möglich"
            self.cityLabel.text = "Irgendwas läuft falsch."
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    self.streetLabel.text = place.name
                    self.cityLabel.text = place.formattedAddress?.components(separatedBy: ", ")
                        .joined(separator: "\n")
                    let locality = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
                    self.display(location: locality, titel: place.name, subtitel: nil )
                }
            }
        })
    }
    
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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .authorizedWhenInUse {
            coreLocationManager.requestWhenInUseAuthorization()
        }
    }
    @IBAction func tappedInAddressBar(_ sender: UITapGestureRecognizer) {
        searchButton.sendActions(for: .touchUpInside)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any){
        if local == nil {
            let uiAlert = UIAlertController(title: "Kein Ort gewählt!",
                                            message: "Es kann nicht gespeichert werden.", preferredStyle: UIAlertController.Style.alert)
            self.present(uiAlert, animated: true, completion: nil)
            
            uiAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
            }))
        } else {
            delegate?.locationViewController(sender: self, didSave: self.local!)
            navigationController?.popViewController(animated: true)
        }
    }
    
    
    @IBAction func searchLocation(_ sender: Any) {
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        present(acController, animated: true, completion: nil)
        
    }
    
    @IBAction func getCurrentPlace(_ sender: UIButton) {
        getCurrentLocation()
    }
}

extension LocationViewController: GMSAutocompleteViewControllerDelegate {
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
        local = Location(route: street!, street_number: number,
                               postal_code: postalCode, city: city!,
                               latitude: coordinates.latitude , longitude: coordinates.longitude)
        }
    }
}
