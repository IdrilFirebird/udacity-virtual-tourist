//
//  PhotoCell.swift
//  Virtual Tourist
//
//  Created by Sebastian Prokesch on 04.02.18.
//  Copyright © 2018 Sebastian Prokesch. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if imageView.image == nil {
            activityView.isHidden = false
            activityView.startAnimating()
        }
    }
}
