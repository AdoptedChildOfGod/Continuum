//
//  PhotoChooserViewController.swift
//  Continuum
//
//  Created by Shannon Draeker on 5/13/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import UIKit

// MARK: - Photo Chosen Protocol

protocol PhotoChooserViewControllerDelegate: class {
    func photoChooserViewControllerSelected(photo: UIImage)
}

class PhotoChooserViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var postPhotoImageView: UIImageView!
    @IBOutlet weak var choosePhotoButton: UIButton!
    
    // MARK: - Properties
    
    weak var delegate: PhotoChooserViewControllerDelegate?
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        // Reset the UI by removing the image and showing the text of the button
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
    
    @IBAction func choosePhotoButtonTapped(_ sender: UIButton) {
        // Hide the text of the button
        choosePhotoButton.setTitle(nil, for: .normal)
        
        // Present an alert to allow the user to select an image from the photo library or the camera
        presentImagePickerAlert()
    }
}

// MARK: - Alert Controllers

extension PhotoChooserViewController {
    
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
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) { [weak self] (_) in self?.resetButton() }
        alert.addAction(dismissAction)
        
        // Present the alert
        present(alert, animated: true)
    }
}


// MARK: - Image Picker Delegate

extension PhotoChooserViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Get the photo
        guard let photo = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        // Place the photo in the image view
        postPhotoImageView.image = photo
        
        // Pass the image to the delegate so it can be saved
        delegate?.photoChooserViewControllerSelected(photo: photo)
        
        // Dismiss the image picker view
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the image picker view
        picker.dismiss(animated: true)
        
        // Reset the button's UI
        resetButton()
    }
}
