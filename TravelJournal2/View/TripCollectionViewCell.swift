//
//  TripCollectionViewCell.swift
//  TravelJournal2
//
//  Created by Samuel Lavasani on 2019-01-24.
//  Copyright © 2019 Niclas Nordling. All rights reserved.
//

import UIKit

class TripCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var tripImage: UIImageView!
    
    @IBOutlet weak var tripTitle: UILabel!
    @IBOutlet weak var tripDate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.tripImage.layer.cornerRadius = 20
    }

}
