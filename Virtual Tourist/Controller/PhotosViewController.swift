//
//  PhotosViewController.swift
//  Virtual Tourist
//
//  Created by Sebastian Prokesch on 04.02.18.
//  Copyright © 2018 Sebastian Prokesch. All rights reserved.
//

import UIKit
import MapKit

class PhotosViewController: UIViewController {
    
    var mapPin: MapPin!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.addAnnotation(mapPin)
        mapView.setCenter(mapPin.coordinate, animated: true)
        mapView.setRegion(MKCoordinateRegionMakeWithDistance(mapPin.coordinate, 500,500), animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
