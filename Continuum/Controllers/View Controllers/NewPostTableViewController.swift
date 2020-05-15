//
//  NewPostTableViewController.swift
//  Continuum
//
//  Created by Shannon Draeker on 5/12/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import UIKit
import Photos

class NewPostTableViewController: UITableViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var postCaptionTextField: UITextField!
    @IBOutlet weak var choosePhotoButton: UIButton!
    @IBOutlet weak var photoContainerView: UIView!
    
    // MARK: - Properties
    
    var photo: UIImage?
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoContainerView.layer.cornerRadius = 30
        photoContainerView.clipsToBounds = true
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
        PostController.shared.createPost(with: photo, caption: caption) { [weak self] (result) in
            switch result {
            case .success(_):
                // Save the photo to a custom album in the user's photo library
                self?.addPhotoToContiuumAlbum()
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

// MARK: - Adopt Photo Chooser Protocol

extension NewPostTableViewController: PhotoChooserViewControllerDelegate {
    
    func photoChooserViewControllerSelected(photo: UIImage) {
        self.photo = photo
    }
}

// MARK: - Custom Photo Album

extension NewPostTableViewController: PHPhotoLibraryChangeObserver {
    
  func photoLibraryDidChange(_ changeInstance: PHChange) {
    print("Photo Library did Change")
  }
  
  func createContinuumAlbum(completion: @escaping (Bool) -> Void) {
    PHPhotoLibrary.shared().register(self)
    PHPhotoLibrary.shared().performChanges({
      PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: "Continuum")
    }, completionHandler: { success, error in
      completion(success)
      if !success { print("Error creating album: \(String(describing: error)).") }
    })
  }
  
  func insert(photo: UIImage, in collection: PHAssetCollection) {
    PHPhotoLibrary.shared().performChanges({
      let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: photo)
      let addAssetRequest = PHAssetCollectionChangeRequest(for: collection)
      addAssetRequest?.addAssets([creationRequest.placeholderForCreatedAsset!] as NSArray)
    }, completionHandler: nil)
  }
  
  func fetchContinuumAlbum() ->  PHAssetCollection? {
    let fetchOptions = PHFetchOptions()
    fetchOptions.predicate = NSPredicate(format: "title = %@", "Continuum")
    let assetfetchResults = PHAssetCollection.fetchAssetCollections(with: .album, subtype: PHAssetCollectionSubtype.any, options: fetchOptions)
    return assetfetchResults.firstObject
  }
  
  func addPhotoToContiuumAlbum() {
    guard let photo = photo else { return }
    if let contiuumCollection = self.fetchContinuumAlbum() {
      self.insert(photo: photo, in: contiuumCollection)
    } else {
      self.createContinuumAlbum(completion: { (success) in
        guard success, let album = self.fetchContinuumAlbum() else { return }
        self.insert(photo: photo, in: album)
      })
    }
  }
}
