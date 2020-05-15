//
//  UIViewControllerExtension.swift
//  Continuum
//
//  Created by Shannon Draeker on 5/14/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func presentErrorAlert(for error: String, message: String) {
        // Create the alert
        let alert = UIAlertController(title: "\(error)", message: "\(message)", preferredStyle: .alert)
        
        // Add the dismiss button
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
        
        // Present the alert
        present(alert, animated: true)
    }
}
