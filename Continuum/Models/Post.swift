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
    fileprivate static let commentCountKey = "commentCount"
    fileprivate static let timestampKey = "timestamp"
    fileprivate static let photoAssetKey = "photoAsset"
}

// MARK: - Searchable Protocol

protocol SearchableRecord {
    func search(for searchterm: String) -> Bool
}

// MARK: - Post Object

class Post {
    
    // MARK: - Properties
    
    // Post Properties
    let caption: String
    var comments: [Comment]
    var commentCount: Int
    let timestamp: Date
    var photoData: Data?
    var photo: UIImage? {
        get {
            guard let photoData = photoData else { return nil }
            return UIImage(data: photoData)
        }
        set {
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    
    // CloudKit Properties
    var photoAsset: CKAsset? {
        let tempDirectory = NSTemporaryDirectory()
        let tempURL = URL(fileURLWithPath: tempDirectory)
        let fileURL = tempURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
        do {
            try photoData?.write(to: fileURL)
        } catch let error {
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
        }
        return CKAsset(fileURL: fileURL)
    }
    let recordID: CKRecord.ID
    
    // MARK: - Initializer
    
    init(photo: UIImage?, caption: String, timestamp: Date = Date(), comments: [Comment] = [], commentCount: Int = 0, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.caption = caption
        self.timestamp = timestamp
        self.comments = comments
        self.commentCount = commentCount
        self.recordID = recordID
        self.photo = photo
    }
}

// MARK: - Searchable Extension

extension Post: SearchableRecord {
    
    func search(for searchterm: String) -> Bool {
        // Search in the caption
        if caption.lowercased().contains(searchterm.lowercased()) { return true }
        
        // Search in the comments
        if comments.filter({ $0.text.lowercased().contains(searchterm.lowercased()) }).count > 0 { return true}
        
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
            let commentCount = ckRecord[PostStrings.commentCountKey] as? Int,
            let timestamp = ckRecord[PostStrings.timestampKey] as? Date
            else { return nil }
        
        var photo: UIImage? = nil
        if let photoAsset = ckRecord[PostStrings.photoAssetKey] as? CKAsset {
            do {
                let data = try Data(contentsOf: photoAsset.fileURL)
                photo = UIImage(data: data)
            } catch {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
        
        self.init(photo: photo, caption: caption, timestamp: timestamp, comments: [], commentCount: commentCount, recordID: ckRecord.recordID)
    }
}

// MARK: - Convert to CKRecord

extension CKRecord {
    
    convenience init(post: Post) {
        self.init(recordType: PostStrings.recordTypeKey, recordID: post.recordID)
        
        setValuesForKeys([
            PostStrings.captionKey : post.caption,
            PostStrings.commentCountKey : post.commentCount,
            PostStrings.timestampKey : post.timestamp,
            PostStrings.photoAssetKey : post.photoAsset
        ])
    }
}
