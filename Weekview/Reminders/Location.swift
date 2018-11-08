//
//  Location.swift
//  Weekview
//
//  Created by Kay Boschmann on 21.11.17.
//  Copyright © 2017 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import MapKit
import GooglePlaces

class Location: NSObject, NSCoding {
    var route: String
    var street_number: String?
    var city: String
    var postalCode: String?
    var coordinates: CLLocation
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("reminders.location")
    
    public init(route: String, street_number: String?, postal_code: String?, city: String, latitude: Double, longitude: Double){
        self.route = route
        self.street_number = street_number ?? ""
        self.city = city
        self.postalCode = postal_code ?? ""
        
        self.coordinates = CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private init(route: String, streetNumber: String?, postalCode: String?, city: String, coords: CLLocation) {
        self.route = route
        self.street_number = streetNumber ?? ""
        self.postalCode = postalCode ?? ""
        self.city = city
        self.coordinates = coords
    }
    
    public func getAddress() -> String{
        var address: String
        
        let street = self.route
        let stadt = self.city
        let number = self.street_number
        if number != "0" {
            address = street + " " + number! + ", " + stadt
        } else {
            address = street + ", " + stadt
        }
        
        return address
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(route, forKey: "route")
        aCoder.encode(street_number, forKey: "number")
        aCoder.encode(city, forKey: "city")
        aCoder.encode(postalCode, forKey: "zip")
        aCoder.encode(coordinates, forKey: "coordinates")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let route = aDecoder.decodeObject(forKey: "route") as! String
        let streetNumber = aDecoder.decodeObject(forKey:"number") as? String
        let city = aDecoder.decodeObject(forKey:"city") as! String
        let postalCode = aDecoder.decodeObject(forKey: "zip") as? String
        let coordinates = aDecoder.decodeObject(forKey: "coordinates") as! CLLocation
        
        self.init(route: route, streetNumber: streetNumber, postalCode: postalCode, city: city, coords: coordinates)
    }
}
