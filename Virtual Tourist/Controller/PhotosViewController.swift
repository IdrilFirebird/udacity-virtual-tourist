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

class PhotosViewController: UIViewController, NSFetchedResultsControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    // MARK: Properties
    
    var mapPin: MapPin!
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newImagesButton: UIButton!
    
//    var selectedIndexes   = [IndexPath]()
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths : [IndexPath]!
    var updatedIndexPaths : [IndexPath]!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.addAnnotation(mapPin)
        mapView.setCenter(mapPin.coordinate, animated: true)
        mapView.setRegion(MKCoordinateRegionMakeWithDistance(mapPin.coordinate, 2500,2500), animated: true)
        
        
        do {
            try fetchResultsController.performFetch()
        } catch let error as NSError {
            print(error)
        }
        
        if fetchResultsController.fetchedObjects?.count == 0 {
            print("load from flickr")
            newImagesButton.isEnabled = false
            loadImages()
        }
    }

    func loadImages() {
        for photo in fetchResultsController.fetchedObjects as! [FlickrPhoto] {
            CoreDataStack.sharedInstance().managedObjectContext.delete(photo)
        }
        
        CoreDataStack.sharedInstance().saveContext()
        
        FlickrClient().getPhotosList(pin: mapPin) { (success, error, result) in
            if !success {
                showErrorAlert(viewController: self, message: "Photo download went wrong")
                return
            }
        }
    }
    
    @IBAction func refreshImagesSet(_ sender: Any) {
        loadImages()
    }
    // Mark: Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = fetchResultsController.sections {
            let current = sections[section]
            return current.numberOfObjects
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell
        let photo = fetchResultsController.object(at: indexPath) as! FlickrPhoto
        
        if photo.image != nil {
            cell.imageView.image = UIImage(data: photo.image! as Data)
            cell.activityView.stopAnimating()
            cell.activityView.isHidden = true
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = fetchResultsController.object(at: indexPath) as! FlickrPhoto
        let alert = UIAlertController(title: "Remove Photo!", message: "Do you realy wan't to delete this photo", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {(action: UIAlertAction) in
            collectionView.deselectItem(at: indexPath, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {(action: UIAlertAction) in
            collectionView.deselectItem(at: indexPath, animated: true)
            CoreDataStack.sharedInstance().managedObjectContext.delete(photo)
            CoreDataStack.sharedInstance().saveContext()
        }))
        
        present(alert, animated: true, completion: nil)
        
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

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths  = [IndexPath]()
        updatedIndexPaths  = [IndexPath]()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
        case .update:
            updatedIndexPaths.append(indexPath!)
        case .delete:
            deletedIndexPaths.append(indexPath!)
        default:
            break
        }
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItems(at: [indexPath])
            }
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItems(at: [indexPath])
            }
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItems(at: [indexPath])
            }
        }, completion:  { (success) in
            self.newImagesButton.isEnabled = true
        })
    }
    
}
