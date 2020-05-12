//
//  PostController.swift
//  Continuum
//
//  Created by Shannon Draeker on 5/12/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import Foundation
import CloudKit
import UIKit.UIImage

class PostController {
    
    // MARK: - Singleton
    
    static let shared = PostController()
    
    // MARK: - Source of Truth
    
    var posts: [Post] = []
    
    // MARK: - CRUD Methods
    
    // Create a new post
    func createPost(with photo: UIImage, caption: String, completion: @escaping (Result<Post, PostError>) -> Void) {
        // Create the post as a CKRecord
        let postRecord = CKRecord(post: Post(photo: photo, caption: caption))
        
        // TODO: - delete this later, handle in completion
        let post = Post(photo: photo, caption: caption)
        posts.append(post)
        return completion(.success(post))
        
        // Save the post to the cloud
    }
    
    // Read (fetch) all posts
    
    // Update a post with a new comment
    func add(comment text: String, to post: Post, completion: @escaping (Result<Post, PostError>) -> Void) {
        // Add the comment to the post
        post.comments.append(Comment(text: text, post: post))
        return completion(.success(post))
        
        // Prepare the operation to make the change in the cloud
        
        // Save the information to the cloud
        
    }
    
    // Update a post
    
    // Delete a post
    
}
