//
//  PostCollectionViewCell.swift
//  TravelJournal2
//
//  Created by Samuel Lavasani on 2019-01-28.
//  Copyright © 2019 Niclas Nordling. All rights reserved.
//

import UIKit

class PostCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageCoverView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        // 1
        let standardHeight = UltravisualLayoutConstants.Cell.standardHeight
        let featuredHeight = UltravisualLayoutConstants.Cell.featuredHeight
        
        // 2
        let delta = 1 - (
            (featuredHeight - frame.height) / (featuredHeight - standardHeight)
        )
        
        // 3
        let minAlpha: CGFloat = 0.3
        let maxAlpha: CGFloat = 0.75
        imageCoverView.alpha = maxAlpha - (delta * (maxAlpha - minAlpha))
        
        let scale = max(delta, 0.5)
        titleLabel.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        dateLabel.alpha = delta
        imageView.contentMode = .scaleAspectFill
        
    }

}
