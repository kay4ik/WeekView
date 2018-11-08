//
//  MapsViewController.swift
//  Weekview
//
//  Created by Kay Boschmann on 20.11.17.
//  Copyright © 2017 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController, GMSMapViewDelegate{
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    var selectedPlace: GMSPlace?
    
    // An array to hold the list of likely places.
    var likelyPlaces: [GMSPlace] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GMSServices.provideAPIKey("AIzaSyDNwk2ozzd0Blnb-Uvf5X8IJkQgz2GhLLQ ")
        GMSPlacesClient.provideAPIKey("AIzaSyAcmsUJgH9P4my4-EaWgtSWMPxia8aYzO0")
        
        //INITIALIZE location manager
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        placesClient = GMSPlacesClient.shared()

        //Map initialation
        let camera = GMSCameraPosition.camera(withLatitude: 49.149915, longitude: 9.299294, zoom: 14)
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        self.view = mapView
        self.mapView = mapView
        
        mapView.isMyLocationEnabled = true
        mapView.settings.compassButton = true
        mapView.settings.setAllGesturesEnabled(true)
        
        
        
        //Location Manager code
        self.locationManager.delegate = self
        //self.locationManager.startUpdatingLocation()
        
    }
    
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        print("You tapped \(name): \(placeID), \(location.latitude)/\(location.longitude) ")
        
        let infoMarker = GMSMarker()
        infoMarker.snippet = placeID
        infoMarker.position = location
        infoMarker.title = name
        infoMarker.opacity = 0
        infoMarker.infoWindowAnchor.y = 1
        infoMarker.map = mapView
        mapView.selectedMarker = infoMarker
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Populate the array with the list of likely places.
    func listLikelyPlaces() {
        // Clean up from previous sessions.
        likelyPlaces.removeAll()
        
        placesClient.currentPlace(callback: { (placeLikelihoods, error) -> Void in
            if let error = error {
                // TODO: Handle the error.
                print("Current Place error: \(error.localizedDescription)")
                return
            }
            
            // Get likely places and add to the list.
            if let likelihoodList = placeLikelihoods {
                for likelihood in likelihoodList.likelihoods {
                    let place = likelihood.place
                    self.likelyPlaces.append(place)
                }
            }
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }

    @IBAction func gotoMyLocation(_ sender: Any){
        locationManager.startUpdatingLocation()
    }
    
    
}

extension MapViewController: CLLocationManagerDelegate {
    //Handle incoming location events
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        mapView.animate(to: camera)
        listLikelyPlaces()
    }
    
    //Handle authorization for location Manager
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}
