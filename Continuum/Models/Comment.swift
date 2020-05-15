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
    let timestamp: Date
    
    // CloudKit Properties
    var postReference: CKRecord.Reference?
    let recordID: CKRecord.ID
    
    // Initializer
    init(text: String,timestamp: Date = Date(), recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), postReference: CKRecord.Reference?) {
        self.text = text
        self.timestamp = timestamp
        self.recordID = recordID
        self.postReference = postReference
    }
}

// MARK: - Convert from CKRecord

extension Comment {
    
    convenience init?(ckRecord: CKRecord, post: Post) {
        guard let text = ckRecord[CommentStrings.textKey] as? String,
            let timestamp = ckRecord[CommentStrings.timestampKey] as? Date
            else { return nil }
        let postReference = ckRecord[CommentStrings.postReferenceKey] as? CKRecord.Reference
        
        self.init(text: text, timestamp: timestamp, recordID: ckRecord.recordID, postReference: postReference)
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
