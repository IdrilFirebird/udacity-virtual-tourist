//
//  FlickrPhoto+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Sebastian Prokesch on 03.02.18.
//  Copyright © 2018 Sebastian Prokesch. All rights reserved.
//
//

import Foundation
import CoreData

@objc(FlickrPhoto)
public class FlickrPhoto: NSManagedObject {
    
    convenience init(flickrPhotoUrl: String, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "FlickrPhoto", in: context) {
            self.init(entity: ent, insertInto: context)
            self.flickrURL = flickrPhotoUrl
        } else {
            fatalError("Unable to find Entity" )
        }
    }
    
}
