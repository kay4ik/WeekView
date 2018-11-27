//
//  ShowLocationVC.swift
//  Weekview
//
//  Created by Kay Boschmann on 08.12.17.
//  Copyright © 2017 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import UIKit
import MapKit

class ShowLocationPopUp: UIViewController {
    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    let setting = Settings.shared
    
    var traffic = false
    var location: Location?
    var reminder: Reminder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.backgroundColor = setting.backgroundColor
        mapView.showsScale = true
        mapView.showsUserLocation = true
        mapView.showsTraffic = traffic
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.navigationBar.frame
        rectShape.position = self.navigationBar.center
        rectShape.path = UIBezierPath(roundedRect: self.navigationBar.bounds, byRoundingCorners: [.topRight , .topLeft], cornerRadii: CGSize(width: 15, height: 15)).cgPath
        self.navigationBar.layer.mask = rectShape
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if location == nil {
            dismiss(animated: true, completion: nil)
            navigationController?.popViewController(animated: true)
        }
        else {
            display(location: location!.coordinates, reminder: self.reminder!)
        }
    }
    
    func display(location: CLLocation, reminder: Reminder){
        if mapView.annotations.count > 0 {
            mapView.removeAnnotations(mapView.annotations)
        }
        let coordinate = location.coordinate
        mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude , longitude: coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: true)
        
        let locationPinCoord = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationPinCoord
        annotation.title = reminder.title
        annotation.subtitle = reminder.getDateAsString()
        mapView.addAnnotation(annotation)
        mapView.showAnnotations([annotation], animated: true)
    }
    
    @IBAction func navigate(_ sender: Any) {
            let coordinates = reminder?.location?.coordinates.coordinate
            
            let placemark = MKPlacemark(coordinate: coordinates!)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = reminder?.title
            mapItem.openInMaps(launchOptions: nil)
    }
    
    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }
}
