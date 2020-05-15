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
    @IBOutlet weak var cellBorderView: UIView!
    
    // MARK: - Properties
    
    var post: Post? { didSet { updateViews() } }
    
    // MARK: - Update Views
    
    func updateViews() {
        guard let post = post else { return }
        
        postCaptionLabel.text = post.caption
        postCommentsLabel.text = "Comments: \(post.commentCount)"
        if let photo = post.photo { postPhotoImageView.image = photo }
        
        cellBorderView.layer.cornerRadius = 20
        cellBorderView.clipsToBounds = true
        postPhotoImageView.layer.cornerRadius = 30
        postCaptionLabel.layer.cornerRadius = 10
        postCaptionLabel.clipsToBounds = true
        postCommentsLabel.layer.cornerRadius = 10
        postCommentsLabel.clipsToBounds = true
    }
}
