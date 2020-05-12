//
//  PostTableViewCell.swift
//  Continuum
//
//  Created by Shannon Draeker on 5/12/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var postCaptionLabel: UILabel!
    @IBOutlet weak var postCommentsLabel: UILabel!
    @IBOutlet weak var postPhotoImageView: UIImageView!
    
    // MARK: - Properties
    
    var post: Post? { didSet { updateViews() } }
    
    // MARK: - Update Views
    
    func updateViews() {
        guard let post = post else { return }
        
        postCaptionLabel.text = post.caption
        postCommentsLabel.text = "Comments: \(post.comments.count)"
        if let photo = post.photo { postPhotoImageView.image = photo }
    }
}
