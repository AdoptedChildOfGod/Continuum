//
//  Comment.swift
//  Continuum
//
//  Created by Shannon Draeker on 5/12/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import Foundation
import CloudKit

// MARK: - Comment Strings Struct

struct CommentStrings {
    static let recordTypeKey = "Comment"
    static let textKey = "text"
    static let postKey = "post"
    static let timestampKey = "timestamp"
}

// MARK: - Comment

class Comment {
    
    // Properties
    
    let text: String
    weak var post: Post?
    let timestamp: Date
    
    // Initializer
    
    init(text: String, post: Post, timestamp: Date = Date()) {
        self.text = text
        self.post = post
        self.timestamp = timestamp
    }
}

// MARK: - Equatable

//extension Comment: Equatable {
//
//    static func == (lhs: Comment, rhs: Comment) -> Bool {
//        return
//    }
//
//}

// MARK: - Convert from CKRecord

extension Comment {
    
    convenience init?(ckRecord: CKRecord) {
        guard let text = ckRecord[CommentStrings.textKey] as? String,
            let post = ckRecord[CommentStrings.postKey] as? Post,
            let timestamp = ckRecord[CommentStrings.timestampKey] as? Date
            else { return nil }
        
        self.init(text: text, post: post, timestamp: timestamp)
    }
}

// MARK: - Convert to CKRecord

extension CKRecord {
    
    convenience init(comment: Comment) {
        self.init(recordType: CommentStrings.recordTypeKey)
        
        setValuesForKeys([
            CommentStrings.textKey : comment.text,
            CommentStrings.postKey : comment.post,
            CommentStrings.timestampKey : comment.timestamp
        ])
    }
}
