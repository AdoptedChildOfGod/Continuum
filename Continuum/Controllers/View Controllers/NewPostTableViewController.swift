//
//  NewPostTableViewController.swift
//  Continuum
//
//  Created by Shannon Draeker on 5/12/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import UIKit

class NewPostTableViewController: UITableViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var postCaptionTextField: UITextField!
    @IBOutlet weak var choosePhotoButton: UIButton!
    
    // MARK: - Properties
    
    var photo: UIImage?
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        // Reset the caption and the photo
        postCaptionTextField.text = nil
        photo = nil
    }
    
    // MARK: - Actions
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        // Return to the main tab with all the posts
        tabBarController?.selectedIndex = 0
    }
    
    @IBAction func addPostButtonTapped(_ sender: UIButton) {
        // Make sure there's a caption and an image
        guard let caption = postCaptionTextField.text, !caption.isEmpty else {
            presentErrorAlert(for: "Caption is Blank", message: "Caption cannot be left blank - please enter a caption")
            return
        }
        guard let photo = photo else {
            presentErrorAlert(for: "No Photo Selected", message: "Photo cannot be left blank - please select a photo")
            return
        }
        
        // Create a new post
        PostController.shared.createPost(with: photo, caption: caption) { (result) in
            switch result {
            case .success(_):
                print("Successfully created new post")
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
        
        // Return to the main tab with all the posts
        tabBarController?.selectedIndex = 0
    }
    
    // MARK: - Embedded Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embeddedPhotoChooser" {
            guard let embeddedVC = segue.destination as? PhotoChooserViewController else { return }
            
            // Claim the role of delegate for the embedded view
            embeddedVC.delegate = self
        }
    }
}

// MARK: - Alert Controllers

extension NewPostTableViewController {
    
    func presentErrorAlert(for error: String, message: String) {
        // Create the alert
        let alert = UIAlertController(title: "\(error)", message: "\(message)", preferredStyle: .alert)
        
        // Add the dismiss button
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
        
        // Present the alert
        present(alert, animated: true)
    }
}

// MARK: - Adopt Photo Chooser Protocol

extension NewPostTableViewController: PhotoChooserViewControllerDelegate {
    
    func photoChooserViewControllerSelected(photo: UIImage) {
        self.photo = photo
    }
}
