//
//  PhotosViewController.swift
//  Virtual Tourist
//
//  Created by Sebastian Prokesch on 04.02.18.
//  Copyright © 2018 Sebastian Prokesch. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotosViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    
    // MARK: Properties
    
    var mapPin: MapPin!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.addAnnotation(mapPin)
        mapView.setCenter(mapPin.coordinate, animated: true)
        mapView.setRegion(MKCoordinateRegionMakeWithDistance(mapPin.coordinate, 500,500), animated: true)
        
        do {
            try fetchResultsController.performFetch()
        } catch let error as NSError {
            print(error)
        }
        
        if fetchResultsController.fetchedObjects?.count == 0 {
            print("load from flickr")
            var flick = FlickrClient()
            flick.getPhotosList(pin: self.mapPin) { (success, error, result) in
                if success {
                    
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Core Data
    
    lazy var fetchResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "FlickrPhoto")
        fr.predicate = NSPredicate(format: "pin == %@", self.mapPin)
        fr.sortDescriptors = []
        
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: CoreDataStack.sharedInstance().managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultsController.delegate = self
        return fetchResultsController
    }()

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
