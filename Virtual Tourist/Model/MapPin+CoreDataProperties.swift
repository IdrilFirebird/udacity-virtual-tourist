//
//  MapPin+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Sebastian Prokesch on 03.02.18.
//  Copyright © 2018 Sebastian Prokesch. All rights reserved.
//
//

import Foundation
import CoreData


extension MapPin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MapPin> {
        return NSFetchRequest<MapPin>(entityName: "MapPin")
    }

    @NSManaged public var lat: Double
    @NSManaged public var lon: Double
    @NSManaged public var photos: NSSet?

}

// MARK: Generated accessors for photos
extension MapPin {

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: FlickrPhoto)

    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: FlickrPhoto)

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)

}
