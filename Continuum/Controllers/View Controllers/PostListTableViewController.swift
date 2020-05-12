//
//  PostListTableViewController.swift
//  Continuum
//
//  Created by Shannon Draeker on 5/12/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var postSearchBar: UISearchBar!
    
    // MARK: - Properties
    
    var filteredPosts: [Post] = []
    var isSearching = false
    var dataSource: [Post] {
        return isSearching ? filteredPosts : PostController.shared.posts
    }
    
    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        postSearchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        filteredPosts = PostController.shared.posts
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostTableViewCell else { return UITableViewCell() }
        
        cell.post = dataSource[indexPath.row]

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

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC" {
            // Get the index of the selected row and the destination of the segue
            guard let indexPath = tableView.indexPathForSelectedRow,
                let destinationVC = segue.destination as? PostDetailTableViewController
                else { return }
            
            // Pass the post to the destination view
            destinationVC.post = PostController.shared.posts[indexPath.row]
        }

    }
}

// MARK: - Search Bar Delegate

extension PostListTableViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Search for the search term
        filteredPosts = PostController.shared.posts.filter { $0.search(for: searchText) }
        
        // Update the UI
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filteredPosts = PostController.shared.posts
        
        // Update the UI
        searchBar.text = nil
        tableView.reloadData()
    }
}
