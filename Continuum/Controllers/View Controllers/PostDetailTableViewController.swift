//
//  PostDetailTableViewController.swift
//  Continuum
//
//  Created by Shannon Draeker on 5/12/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import UIKit

class PostDetailTableViewController: UITableViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var postPhotoImageView: UIImageView!
    @IBOutlet weak var followPostButton: UIButton!
    
    // MARK: - Properties
    
    var post: Post?
    
    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        updateViews()
    }
    
    // MARK: - Update Views
    
    func updateViews() {
        guard let post = post, let photo = post.photo else { return }
        
        postPhotoImageView.image = photo
        postPhotoImageView.layer.cornerRadius = 30
        
        // Fetch the comments for that post
        PostController.shared.fetchComments(for: post) { [weak self] (result) in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
        
        // Check to see if the post is being followed or not
        PostController.shared.checkSubscriptionToComments(for: post) { [weak self] (isFollowed, _) in
            // Set the button's title based on whether or not the post is being followed
            DispatchQueue.main.async {
                self?.followPostButton.setTitle(isFollowed ? "Unfollow Post" : "Follow Post", for: .normal)
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func commentButtonTapped(_ sender: UIButton) {
        presentAddCommentAlert()
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        // Make sure the post exists
        guard let caption = post?.caption, let photo = post?.photo else { return }
        
        // Create the activity controller
        let activityController = UIActivityViewController(activityItems: [photo, caption], applicationActivities: nil)
        
        present(activityController, animated: true)
    }
    
    @IBAction func followPostButtonTapped(_ sender: UIButton) {
        guard let post = post else { return }
        
        PostController.shared.toggleSubscriptionToComments(for: post) { [weak self] (subscribed, error) in
            // Handle any errors
            if let error = error { print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)") }
                
                // Set the button's title based on whether or not the post is being followed
            else {
                DispatchQueue.main.async {
                    self?.followPostButton.setTitle(subscribed ? "Unfollow Post" : "Follow Post", for: .normal)
                    
                }
            }
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post?.comments.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)

        guard let comment = post?.comments[indexPath.row] else { return cell }
        
        cell.textLabel?.text = comment.text
        cell.detailTextLabel?.text = comment.timestamp.formatDate()

        return cell
    }

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */
}

// MARK: - Comment Alert Controller

extension PostDetailTableViewController {
    
    func presentAddCommentAlert() {
        // Create the alert controller
        let alert = UIAlertController(title: "Comment", message: "Comment on this post", preferredStyle: .alert)
        
        // Add the text field for the comment
        alert.addTextField { (textField) in
            // Format the textField with a placeholder and autocorrect options
            textField.placeholder = "Type comment here"
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .sentences
        }
        
        // Create the save and cancel buttons
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] (_) in
            // Get the text from the text string
            guard let text = alert.textFields?.first?.text, !text.isEmpty, let post = self?.post else { return }
            
            // Add the comment to the post
            PostController.shared.add(comment: text, to: post) { (result) in
                switch result {
                case .success(_):
                    DispatchQueue.main.async { self?.tableView.reloadData() }
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
        
        // Attach the buttons and display the alert
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}
