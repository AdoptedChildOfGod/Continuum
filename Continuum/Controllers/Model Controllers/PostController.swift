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
    
    // MARK: - Properties
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    // MARK: - Initializer
    
    init() {
        // Automatically subscribe users to receive notifications for new posts
        subscribeToNewPosts()
    }
    
    // MARK: - CRUD Methods
    
    // Create a new post
    func createPost(with photo: UIImage, caption: String, completion: @escaping (Result<Post, PostError>) -> Void) {
        // Create the post as a CKRecord
        let postRecord = CKRecord(post: Post(photo: photo, caption: caption))
        
        // Save the data to the cloud
        publicDB.save(postRecord) { [weak self] (record, error) in
            // Handle any errors
            if let error = error { return completion(.failure(.ckError(error))) }
            
            // Unwrap the data
            guard let record = record,
                let post = Post(ckRecord: record)
                else { return completion(.failure(.unableToUnwrap)) }
            
            // Save to the source of truth
            self?.posts.insert(post, at: 0)
            return completion(.success(post))
        }
    }
    
    // Read (fetch) all posts
    func fetchPosts(completion: @escaping (Result<[Post], PostError>) -> Void) {
        // Create the query to pull everything from the database
        let query = CKQuery(recordType: PostStrings.recordTypeKey, predicate: NSPredicate(value: true))
        
        // Fetch the data from the cloud
        publicDB.perform(query, inZoneWith: nil) { [weak self] (records, error) in
            // Handle any errors
            if let error = error { return completion(.failure(.ckError(error))) }
            
            // Unwrap the data
            guard let records = records else { return completion(.failure(.unableToUnwrap)) }
            var posts = records.compactMap { Post(ckRecord: $0) }
            posts = posts.sorted(by: { $0.timestamp > $1.timestamp })
            
            // Save to the source of truth
            self?.posts = posts
            return completion(.success(posts))
        }
    }
    
    // Read (fetch) all comments for a post
    func fetchComments(for post: Post, completion: @escaping (Result<[Comment], PostError>) -> Void) {
        // Create the predicate to pull the comments only for a specific post
        let predicateForPost = NSPredicate(format: "%K == %@", argumentArray: [CommentStrings.postReferenceKey, post.recordID])
        // Only fetch the comments that are not already loaded
        let predicateForNew = NSPredicate(format: "NOT(recordID IN %@)", post.comments.compactMap({$0.recordID}))
        // Combine the predicates
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateForPost, predicateForNew])
        
        // Create the query
        let query = CKQuery(recordType: CommentStrings.recordTypeKey, predicate: compoundPredicate)
        
        // Fetch the comments from the cloud
        publicDB.perform(query, inZoneWith: nil) { [weak self] (records, error) in
            // Handle any errors
            if let error = error { return completion(.failure(.ckError(error))) }
            
            // Unwrap the data
            guard let records = records else { return completion(.failure(.unableToUnwrap)) }
            let comments = records.compactMap { Comment(ckRecord: $0, post: post) }
            
            // Add the comments to the post
            post.comments.append(contentsOf: comments)
            post.comments = post.comments.sorted(by: { $0.timestamp > $1.timestamp })
            
            // Save the change to the post's comment count
            self?.update(post, withCommentCount: post.comments.count, completion: { (_) in })
            
            return completion(.success(comments))
        }
    }
    
    // Update a post with a new comment
    func add(comment text: String, to post: Post, completion: @escaping (Result<Comment, PostError>) -> Void) {
        // Create the comment as a CKRecord
        let commentRecord = CKRecord(comment: Comment(text: text, post: post))
        
        // Save the data to the cloud
        publicDB.save(commentRecord) { [weak self] (record, error) in
            // Handle any errors
            if let error = error { return completion(.failure(.ckError(error))) }
            
            // Unwrap the data
            guard let record = record,
                let comment = Comment(ckRecord: record, post: post)
                else { return completion(.failure(.unableToUnwrap)) }
            
            // Add the comment to the post's array of comments
            post.comments.insert(comment, at: 0)
            
            // Save the change to the post's comment count
            self?.update(post, withCommentCount: post.comments.count, completion: { (_) in })
            
            return completion(.success(comment))
        }
    }
    
    // Update a post
    func update(_ post: Post, withCommentCount commentCount: Int, completion: @escaping (Result<Post, PostError>) -> Void) {
        // Update the post
        post.commentCount = commentCount
        
        // Define the operation to save the update
        let operation = CKModifyRecordsOperation(recordsToSave: [CKRecord(post: post)])
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { (records, _, error) in
            // Handle any errors
            if let error = error { return completion(.failure(.ckError(error))) }
            
            // Unwrap the data
            guard let record = records?.first,
            let post = Post(ckRecord: record)
                else { return completion(.failure(.unableToUnwrap)) }
            
            return completion(.success(post))
        }
        
        // Save the update to the cloud
        publicDB.add(operation)
    }
    
    // Delete a post
    
    // MARK: - Notifications
    
    // Subscribe to notifications for all new posts
    func subscribeToNewPosts(completion: ((Bool, Error?) -> Void)? = nil) {
        // Set up the subscription to be alerted of all new posts
        let subscription = CKQuerySubscription(recordType: PostStrings.recordTypeKey, predicate: NSPredicate(value: true), options: [.firesOnRecordCreation])
        
        // Configure the display of the notifications
        let notificationInfo = CKQuerySubscription.NotificationInfo()
        notificationInfo.title = "New Continuum Post"
        notificationInfo.alertBody = "Check out the new post!"
        notificationInfo.shouldBadge = true
        subscription.notificationInfo = notificationInfo
        
        // Save the subscription if it hasn't already been saved
        publicDB.save(subscription) { (_, error) in
            guard let completion = completion else { return }
            if let error = error { return completion(false, error) }
            return completion(true, nil)
        }
    }
    
    // Subscribe to notifications for comments on a post
    func addSubscriptionToComments(for post: Post, completion: ((Bool, Error?) -> Void)? = nil) {
        // Set up the subscription to be alerted to comments for the particular post
        let predicateForPost = NSPredicate(format: "%K == %@", argumentArray: [CommentStrings.postReferenceKey, post.recordID])
        let subscription = CKQuerySubscription(recordType: CommentStrings.recordTypeKey, predicate: predicateForPost, subscriptionID: post.recordID.recordName, options: CKQuerySubscription.Options.firesOnRecordCreation)
        
        // Configure the display of the notifications
        let notificationInfo = CKQuerySubscription.NotificationInfo()
        notificationInfo.title = "New Comment"
        notificationInfo.alertBody = "A comment was added to the post \"\(post.caption)\""
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.desiredKeys = [CommentStrings.textKey, CommentStrings.timestampKey]
        notificationInfo.shouldBadge = true
        subscription.notificationInfo = notificationInfo
        
        // Save the subscription if it hasn't already been saved
        publicDB.save(subscription) { (_, error) in
            if let error = error { completion?(false, error) }
            else { completion?(true, nil) }
        }
    }
    
    // Remove a subscription to notifications for comments on a post
    func removeSubscriptionToComments(for post: Post, completion: ((Bool, Error?) -> Void)? = nil) {
        // Remove the subscription from the cloud
        publicDB.delete(withSubscriptionID: post.recordID.recordName) { (_, error) in
            if let error = error { completion?(false, error) }
            else { completion?(true, nil) }
        }
    }
    
    // Check to see if there's a subscription to notifications for comments on a post
    func checkSubscriptionToComments(for post: Post, completion: ((Bool, Error?) -> Void)? = nil) {
        publicDB.fetch(withSubscriptionID: post.recordID.recordName) { (subscription, error) in
            if let error = error { completion?(false, error) }
            else if subscription != nil { completion?(true, nil) }
            else { completion?(false, nil) }
        }
    }
    
    // Toggle a subscription to notifications for comments on a post
    func toggleSubscriptionToComments(for post: Post, completion: ((Bool, Error?) -> Void)? = nil) {
        // Check to see if a subscription already exists
        checkSubscriptionToComments(for: post) { [weak self] (subscriptionExists, error) in
            // If the subscription already exists, remove it
            if subscriptionExists {
                self?.removeSubscriptionToComments(for: post, completion: { (success, error) in
                    if success { completion?(false, nil) }
                    else { completion?(true, nil) }
                })
            }
                // Otherwise, add the new subscription
            else {
                self?.addSubscriptionToComments(for: post, completion: { (success, error) in
                    if success { completion?(true, nil) }
                    else { completion?(false, nil) }
                })
            }
        }
    }
}
