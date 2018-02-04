//
//  FlickrPhoto+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Sebastian Prokesch on 03.02.18.
//  Copyright © 2018 Sebastian Prokesch. All rights reserved.
//
//

import Foundation
import CoreData


extension FlickrPhoto {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FlickrPhoto> {
        return NSFetchRequest<FlickrPhoto>(entityName: "FlickrPhoto")
    }

    @NSManaged public var imagePath: String?
    @NSManaged public var flickrURL: String?
    @NSManaged public var pin: MapPin?

}
