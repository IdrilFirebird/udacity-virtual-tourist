//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Sebastian Prokesch on 14.01.18.
//  Copyright © 2018 Sebastian Prokesch. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let tapGestureRecognizer = UILongPressGestureRecognizer(target: self, action:#selector(addAnnotation))
        tapGestureRecognizer.minimumPressDuration = 1
        tapGestureRecognizer.allowableMovement = 1
        tapGestureRecognizer.delegate = self
        mapView.addGestureRecognizer(tapGestureRecognizer)
        mapView.delegate = self
        
        mapView.addAnnotations(getAllSavedPins())
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func addAnnotation(tapGestureRecognizer: UITapGestureRecognizer) {
        // only listen for began state of touch. When hold and move don't do anything (state changes to changed)
        if tapGestureRecognizer.state == .began {
            let point = tapGestureRecognizer.location(in: mapView)
//            annotation.coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            let pin = MapPin(coordinate: mapView.convert(point, toCoordinateFrom: mapView), context: CoreDataStack.sharedInstance().managedObjectContext)
//            let annotation = pin
            CoreDataStack.sharedInstance().saveContext()
            mapView.addAnnotation(pin)
            
        }
    }
    
    func getAllSavedPins() -> [MapPin] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MapPin")
        var pins:[MapPin] = []
        
        do {
            let resutls = try CoreDataStack.sharedInstance().managedObjectContext.fetch(fetchRequest)
            pins = resutls as! [MapPin]
        } catch let error as NSError {
            print("Allert \(error)")
        }
        return pins
    }
    
    //MARK: MapViewDelegate Methods
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        if let annotation = annotation as? MapPin {
        
            if let pin = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView {
                pin.annotation = annotation
                return pin
            } else {
                let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pin.canShowCallout = false
                pin.animatesDrop = true
                pin.isDraggable = false
                return pin
            }
            
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print(view)
        let selectedPin = view.annotation as! MapPin
        
        performSegue(withIdentifier: "photosView", sender: selectedPin)
    }
    
    //MARK: GestureDelegate Methods
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view is MKAnnotationView) {
            print("pin was taped \((touch.view as! MKAnnotationView)    )")
            // Here transistion to next View with pictures
            return false
        } else {
            return true
        }
    
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photosView" {
            mapView.deselectAnnotation(sender as? MapPin, animated: false)
            let destController = segue.destination as! PhotosViewController
            destController.mapPin = sender as? MapPin
            print("go to photo view")
        }
    }

}

