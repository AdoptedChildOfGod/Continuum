//
//  Post.swift
//  Continuum
//
//  Created by Shannon Draeker on 5/12/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import Foundation
import CloudKit
import UIKit.UIImage

// MARK: - Post Strings Struct

struct PostStrings {
    static let recordTypeKey = "Post"
    fileprivate static let captionKey = "caption"
    fileprivate static let commentsKey = "comments"
    fileprivate static let timestampKey = "timestamp"
    fileprivate static let photoDataKey = "photoData"
}

// MARK: - Searchable Protocol

protocol SearchableRecord {
    func search(for searchterm: String) -> Bool
}

// MARK: - Post Object

class Post {
    
    // Properties
    
    let caption: String
    var comments: [Comment]
    let timestamp: Date
    var photoData: Data?
    var photo: UIImage? {
        get {
            guard let photoData = photoData else { return nil }
            return UIImage(data: photoData)
        }
        set {
            photoData = newValue?.jpegData(compressionQuality: 1.0)
        }
    }
    
    // Initializer
    
    init(photo: UIImage?, caption: String, timestamp: Date = Date(), comments: [Comment] = []) {
        self.caption = caption
        self.timestamp = timestamp
        self.comments = comments
        self.photo = photo
    }
}

// MARK: - Searchable Extension

extension Post: SearchableRecord {
    
    func search(for searchterm: String) -> Bool {
        // Search in the caption
        if caption.contains(searchterm) { return true }
        
        // Search in the comments
        if comments.filter({ $0.text.contains(searchterm) }).count > 0 { return true}
        
        return false
    }
}

// MARK: - Equatable

//extension Post: Equatable {
//
//    static func == (lhs: Post, rhs: Post) -> Bool {
//        return
//    }
//
//}

// MARK: - Convert from CKRecord

extension Post {
    
    convenience init?(ckRecord: CKRecord) {
        guard let caption = ckRecord[PostStrings.captionKey] as? String,
            let timestamp = ckRecord[PostStrings.timestampKey] as? Date,
            let comments = ckRecord[PostStrings.commentsKey] as? [Comment],
            let photoData = ckRecord[PostStrings.photoDataKey] as? Data
            else { return nil }
        
        self.init(photo: UIImage(data: photoData), caption: caption, timestamp: timestamp, comments: comments)
    }
}

// MARK: - Convert to CKRecord

extension CKRecord {
    
    convenience init(post: Post) {
        self.init(recordType: PostStrings.recordTypeKey)
        
        setValuesForKeys([
            PostStrings.captionKey : post.caption,
            PostStrings.timestampKey : post.timestamp,
            PostStrings.commentsKey : post.comments,
            PostStrings.photoDataKey : post.photoData
        ])
    }
}
