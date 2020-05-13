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
        postCaptionTextField.text = nil
        postPhotoImageView.image = nil
        resetButton()
    }
    
    // MARK: - UI Helper Method
    
    func resetButton() {
        if postPhotoImageView.image == nil {
            choosePhotoButton.setTitle("Choose Photo", for: .normal)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        // Return to the main tab with all the posts
        tabBarController?.selectedIndex = 0
    }
    
    @IBAction func choosePhotoButtonTapped(_ sender: UIButton) {
        
        // Hide the text of the button
        choosePhotoButton.setTitle(nil, for: .normal)
        
        // Present an alert to allow the user to select an image from the photo library or the camera
        presentImagePickerAlert()
        
        //        // TODO: - Dummy data for now
        //        postPhotoImageView.image = #imageLiteral(resourceName: "spaceEmptyState")
    }
    
    @IBAction func addPostButtonTapped(_ sender: UIButton) {
        // Make sure there's a caption and an image
        guard let caption = postCaptionTextField.text, !caption.isEmpty else {
            presentErrorAlert(for: "Caption is Blank", message: "Caption cannot be left blank - please enter a caption")
            return
        }
        guard let photo = postPhotoImageView.image else {
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
    
    func presentImagePickerAlert() {
        // Create the alert
        let alert = UIAlertController(title: "Choose a photo", message: nil, preferredStyle: .actionSheet)
        
        // Create the button for the photo library if that functionality is enabled
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary)) {
            let libraryAction = UIAlertAction(title: "Select from photo library", style: .default) { [weak self] (_) in
                // Create the image picker, assign its delegate, and present it
                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                self?.present(imagePickerController, animated: true)
            }
            
            alert.addAction(libraryAction)
        }
        
        // Create the button for the camera if that functionality is enabled
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            let cameraAction = UIAlertAction(title: "Take photo with camera", style: .default) { [weak self] (_) in
                // Create the image picker, assign its delegate, and present it
                let imagePickerController = UIImagePickerController()
                imagePickerController.sourceType = UIImagePickerController.SourceType.camera
                imagePickerController.delegate = self
                self?.present(imagePickerController, animated: true)
            }
            
            alert.addAction(cameraAction)
        }
        
        // Create the dismiss button
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) {
            [weak self] (_) in
            // Reset the button's UI
            self?.resetButton()
        }
        alert.addAction(dismissAction)
        
        // Present the alert
        present(alert, animated: true)
    }
}

// MARK: - Image Picker Delegate

extension NewPostTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Get the photo
        guard let photo = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        // Place the photo in the image view
        postPhotoImageView.image = photo
        
        // Dismiss the image picker view
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Reset the button's UI
        resetButton()
    }
}
