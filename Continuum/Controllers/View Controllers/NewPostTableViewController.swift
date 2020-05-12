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
    @IBOutlet weak var postPhotoImageView: UIImageView!
    @IBOutlet weak var choosePhotoButton: UIButton!
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        // Reset the photo choosing button, the caption, and the photo
        choosePhotoButton.setTitle("Choose Photo", for: .normal)
        postCaptionTextField.text = nil
        postPhotoImageView.image = nil
    }
    
    // MARK: - Actions
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        // Return to the main tab with all the posts
        tabBarController?.selectedIndex = 0
    }
    
    @IBAction func choosePhotoButtonTapped(_ sender: UIButton) {
        
        // Hide the text of the button
        choosePhotoButton.setTitle(nil, for: .normal)
        
        // TODO: - Dummy data for now
        postPhotoImageView.image = #imageLiteral(resourceName: "spaceEmptyState")
    }
    
    @IBAction func addPostButtonTapped(_ sender: UIButton) {
        // Make sure there's a caption and an image
        guard let caption = postCaptionTextField.text, !caption.isEmpty else {
            presentErrorAlert(for: "Caption")
            return
        }
        guard let photo = postPhotoImageView.image else {
            presentErrorAlert(for: "Image")
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
}

// MARK: - Alert Controller

extension NewPostTableViewController {
    
    func presentErrorAlert(for error: String) {
        // Create the alert
        let alert = UIAlertController(title: "\(error) Blank", message: "Uh oh! \(error) cannot be left blank!", preferredStyle: .alert)
        
        // Add the dismiss button
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
        
        // Present the alert
        present(alert, animated: true)
    }
}
