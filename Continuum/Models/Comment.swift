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
    static let timestampKey = "timestamp"
    static let postReferenceKey = "post"
}

// MARK: - Comment

class Comment {
    // Comment Properties
    let text: String
    weak var post: Post?
    let timestamp: Date
    
    // CloudKit Properties
    var postReference: CKRecord.Reference? {
        guard let post = post else { return nil }
        return CKRecord.Reference(recordID: post.recordID, action: .none)
    }
    let recordID: CKRecord.ID
    
    // Initializer
    init(text: String, post: Post, timestamp: Date = Date(), recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.text = text
        self.post = post
        self.timestamp = timestamp
        self.recordID = recordID
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
    
    convenience init?(ckRecord: CKRecord, post: Post) {
        guard let text = ckRecord[CommentStrings.textKey] as? String,
//            let postReference = ckRecord[CommentStrings.postReferenceKey] as? CKRecord.Reference,
            let timestamp = ckRecord[CommentStrings.timestampKey] as? Date
            else { return nil }
        
        self.init(text: text, post: post, timestamp: timestamp, recordID: ckRecord.recordID)
    }
}

// MARK: - Convert to CKRecord

extension CKRecord {
    
    convenience init(comment: Comment) {
        self.init(recordType: CommentStrings.recordTypeKey, recordID: comment.recordID)
        
        setValuesForKeys([
            CommentStrings.textKey : comment.text,
            CommentStrings.postReferenceKey : comment.postReference,
            CommentStrings.timestampKey : comment.timestamp
        ])
    }
}
