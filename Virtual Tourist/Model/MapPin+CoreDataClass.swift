//
//  MapPin+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Sebastian Prokesch on 03.02.18.
//  Copyright © 2018 Sebastian Prokesch. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

@objc(MapPin)
public class MapPin: NSManagedObject, MKAnnotation {
    
    convenience init(coordinate: CLLocationCoordinate2D, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "MapPin", in: context) {
            self.init(entity: ent, insertInto: context)
            self.lat = coordinate.latitude
            self.lon = coordinate.longitude
        } else {
            fatalError("Unable to find Entity" )
        }
    }
    
    public var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        set(newCoordinate) {
            self.lat = newCoordinate.latitude
            self.lon = newCoordinate.longitude
        }
    }
}
