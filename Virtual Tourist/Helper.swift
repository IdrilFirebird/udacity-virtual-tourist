//
//  Helper.swift
//  Virtual Tourist
//
//  Created by Sebastian Prokesch on 04.02.18.
//  Copyright © 2018 Sebastian Prokesch. All rights reserved.
//

import UIKit

func showErrorAlert(viewController: UIViewController, message: String, dismissButtonTitle: String = "OK") {
    let controller = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    
    controller.addAction(UIAlertAction(title: dismissButtonTitle, style: .default) { (action: UIAlertAction!) in
        controller.dismiss(animated: true, completion: nil)
    })
    
    viewController.present(controller, animated: true, completion: nil)
}
